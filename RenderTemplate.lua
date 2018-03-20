local widget = require "widget"
local composer = require "composer"
local sqlite3 = require "sqlite3"
local sharedMem = require( "sharedMem" )

local renderTemplate = composer.newScene()

-- Open the database to load fields
local fPath = system.pathForFile( "SoftPlan_001.db", system.DocumentsDirectory )
local db = sqlite3.open(fPath)

-- Create a table to store progress data
local ProgressTable = {}

--Create a table to store references to the category heading images
local headingImgTable = {}

--Create a flag to monitor when a heading value has been changed
local isHeadChange = false

--Create a view to contain item rows for the checklist
local tableView

--Forward declare the function for saving data to database
--local writeProgress

-- Function for setting status colour
local function setStatusColour( index, object )
  if (ProgressTable[index] == 0) then
    object:setFillColor(0.8)
  elseif (ProgressTable[index] == 1) then
    object:setFillColor(1,0,0)
  elseif (ProgressTable[index] == 2) then
    object:setFillColor(255/256,189/256,0/256)
  else
    object:setFillColor(0,1,0)
  end
end

-- Function for testing heading or subheading
local function isTopLevel( number )
  local result = false
  if (string.match(number, "^%d$") or string.match(number, "^%d%d$")) then
    result = true
  end
  return result
end

-- Function for updating heading status
local function updateHeading( currentItem )
  --Find top level number in currentItem
  local topLevel = string.match(currentItem, "^(%d*)%.")
  topLevel = tonumber( topLevel )
  --Look at the current value assigned to the heading with this number

  --If the current value is zero or greater than the value being inserted
  --at the time of this call, update the heading value to be the new value
  if ((ProgressTable[topLevel] == nil) or (ProgressTable[topLevel] == 0)) then
    ProgressTable[topLevel] = ProgressTable[currentItem]
  else
    --Scan entire ProgressTable and check the value of items belonging to the topLevel number
    --Assume currentItem is governing the floor value - set changeHead to false
    --if another item disproves this

    --print("Made it into the scanning section")
    print("The new status is", ProgressTable[currentItem])
    local changeHead = true
    for name, val in pairs(ProgressTable) do
      local parentNum = string.match(name, "^(%d*)%.")
      parentNum = tonumber( parentNum )
      --print("ParentNum is", parentNum, "and the topLevel is", topLevel)
      if (parentNum == topLevel) then
        --print("Found a matching item")
        --print("The name is", name, "and the value is", val)

        if (((val > 0) and (val < ProgressTable[currentItem])) or (ProgressTable[currentItem] == 0)) then
          --print("Turns out the current item isn't the floor")
          changeHead = false
        end
      end
    end
    print("Finished scanning")
    if (changeHead) then
      print("We're changing the head value")
      ProgressTable[topLevel] = ProgressTable[currentItem]
      isHeadChange = true
    end
  end
  print("The value of isHeadChange is now", isHeadChange)
  --Otherwise, leave the heading value as is
  --print("The img reference for the heading is", headingImgTable[topLevel], "and topLevel is", topLevel)
  --Finally, update the colour of the heading image
  setStatusColour(topLevel,headingImgTable[topLevel])
end


--This function is called every time a row is created or returns to the screen
local function onRowRender( event )

  local row = event.row

  local rowHeight = row.contentHeight
  local rowWidth = row.contentWidth

  --replace all rowTitle with rowNumber
  --create new rowDescription

  local rowNumber = display.newText(
    {
      parent = row,
      text = row.params.IteNum,
      x = display.contentWidth/24,
      y = rowHeight * 0.5,
      font = nil,
      fontSize = 20,
      width = display.contentWidth/22,
      anchorX = 0,
      align = "right"
    } )
  rowNumber:setFillColor( 0 )

  --rowNumber.anchorX = 0
  --rowNumber.x = 0
  --rowNumber.y = rowHeight * 0.5

  local rowDescription = display.newText(
    {
      parent = row,
      text = row.params.IteDesc,
      x = display.contentWidth*0.45,
      y = rowHeight * 0.5,
      font = nil,
      fontSize = 20,
      width = display.contentWidth*0.7,
      anchorX = 0,
    } )
  rowDescription:setFillColor( 0 )

  local statusLight = {
    x = display.contentWidth - display.contentWidth/8,
    y = rowHeight * 0.5
  }

  row.status = display.newCircle( statusLight.x, statusLight.y, 20 )
  setStatusColour(row.params.IteNum, row.status)

  row:insert( row.status )

  --Create a function to modify progress data
  function row:touch( event )
    if (event.phase == "ended") then
      print("They called me!")
      print(ProgressTable[row.params.IteNum])
      ProgressTable[row.params.IteNum] = ProgressTable[row.params.IteNum] + 1
      if (ProgressTable[row.params.IteNum] > 3) then
        ProgressTable[row.params.IteNum] = 0
      end
      setStatusColour(row.params.IteNum, row.status)
      updateHeading(row.params.IteNum)
    end
    tableView:reloadData()

  end

  --If a row is a heading, don't assign a button, but make sure a reference
  --is stored to provide access to the heading image when other rows are updated
  if not (isTopLevel(row.params.IteNum)) then
    row.status:addEventListener("touch",row)
  else
    --print("We're adding to the table")
    --print("The index is ", row.params.IteNum)
    --print("The object is ", row.status)
    headingImgTable[row.params.IteNum] = row.status
  end

  --tableView:insert(row)
end


local function theReloader( event )
  if (isHeadChange) then
    print("isHeadChange here is", isHeadChange)
    tableView:reloadData()
    isHeadChange = false
    print("----Data reload processed----")
  end
  --print("isHeadChange here is", isHeadChange)
end


--Create a view to contain item rows for the checklist
tableView = widget.newTableView( {
  onRowRender = onRowRender,
  listener = theReloader
} )


--Create a function to write the ProgressTable to the database
function writeProgress()
  print("writeProgress has been called")
  --Populate table with query values
  local args = {}
  args[0] = [["]] .. sharedMem.tempType .. [["]]
  args[1] = [["]] .. sharedMem.tempID .. [["]]

  if (sharedMem.loadProject) then
    args[3] = [["]] .. sharedMem.projID .. [["]]
  else
    args[3] = [["]] .. sharedMem.newName .. [["]]
  end

  for k, v in pairs(ProgressTable) do

    --Add key and value to the arguments table - the other args don't change
    args[4] = v
    args[2] = [["]] .. k .. [["]]

    --Record an individual progress value using args[] and RowID from TemplateEntries
    local err = db:exec(
      "INSERT OR REPLACE INTO ProjectValues (ProjectID, ItemID, Value)\
      SELECT " .. args[3] .. ", TemplateEntries.RowID, " .. args[4] .. " \
      FROM TemplateEntries \
      WHERE TemplateType=" .. args[0] .. " \
      AND TemplateID=" .. args[1] .. " \
      AND ItemNumber=" .. args[2] .. ";"
    )

    --print("The result of the write to database is", err)
  end
end


--Declare database queries for new and existing projects separately
local newProjQuery = "SELECT ItemNumber, ItemDescription\
                      FROM TemplateEntries\
                      WHERE TemplateID='" .. sharedMem.tempID .. "'\
                      AND TemplateType='" .. sharedMem.tempType .. "';"

local existProjQuery = "SELECT T1.ItemNumber, T1.ItemDescription, T2.Value\
                      FROM TemplateEntries AS T1, ProjectValues AS T2\
                      WHERE T1.RowID=T2.ItemID\
                      AND T2.ProjectID='" .. sharedMem.projID .. "'\
                      AND T1.TemplateType='" .. sharedMem.tempType .. "';"

--Set actionable query depending on create or retrieve request
local retrieveTemplate
if (sharedMem.loadProject) then
  retrieveTemplate = existProjQuery
else
  retrieveTemplate = newProjQuery
end

print("The loadProject flag is:", sharedMem.loadProject)
print("The selected query is:", retrieveTemplate)

--Iterate through database and generate rows for the table view
for row in db:nrows( retrieveTemplate ) do

  print("Iterating through database")

  if not (row.ItemNumber == '') then

    print("The item number for this row is", row.ItemNumber)

    --Create data entry in the progress table
    if (sharedMem.loadProject) then
      ProgressTable[row.ItemNumber] = row.Value
    else
      ProgressTable[row.ItemNumber] = 0
    end

    isCat = isTopLevel(row.ItemNumber)

    tableView:insertRow{
      isCategory = isCat,
      rowHeight = 70,
      params = {
        IteNum = row.ItemNumber,
        IteDesc = row.ItemDescription,
      },
    }
  end
end


--Create a save button to write data to the database
local buttonRect1 = display.newRoundedRect(display.actualContentWidth*0.875, display.contentHeight*0.95, 80, 60, 12)

local saveButton = widget.newButton( {
  label="Save",
  x = display.actualContentWidth*0.875,
  y = display.contentHeight*0.95,
} )

local function onSave( event )
  if (event.phase == "ended") then
    writeProgress()
  end
end

saveButton:addEventListener("touch", onSave)

--Create a save/exit button to write to database and return to start screen
local buttonRect2 = display.newRoundedRect(display.actualContentWidth*0.875, display.contentHeight*0.85, 80, 60, 12)

local saveExitButton = display.newText( {
  text="Save\n&\nExit",
  x = display.actualContentWidth*0.875,
  y = display.contentHeight*0.85,
  align = "center"
} )

saveExitButton:setFillColor(0)

local function onSaveExit( event )
  if (event.phase == "ended") then
    writeProgress()
    composer.gotoScene("StartScreen")
    print("Tried to change scene but you probably didn't see it")
  end
end

saveExitButton:addEventListener("touch", onSaveExit)


-- Function to handle button events
local function handleTabBarEvent( event )
    print( event.target.id )  -- Reference to button's 'id' parameter
    if (event.target.id == 'progTab') then
      print("Changing shared memory to Progress")
      sharedMem.tempType = 'Progress'
    elseif (event.target.id == 'docTab') then
      print("Changing shared memory to Document")
      sharedMem.tempType = 'Document'
    else
      print("Invalid tab and revision options")
    end

    print("The new value for tempType is", sharedMem.tempType)

    composer.removeScene("RenderTemplate")
    composer.gotoScene("RenderTemplate")
end

-- Configure the tab buttons to appear within the bar
local tabButtons = {
    {
        label = "Progress",
        id = "progTab",
        defaultFile = "clock.png",
        overFile = "clock.png",
        width = 60,
        height = 60,
        --labelYOffset = 8,
        selected = true,
        onPress = handleTabBarEvent
    },
    {
        label = "Documents",
        id = "docTab",
        defaultFile = "doc.png",
        overFile = "doc.png",
        width = 303/5,
        height = 228/5,
        onPress = handleTabBarEvent
    }
}


-- Create the widget
local tabHeight = (display.actualContentWidth - display.contentWidth)/2
local tabBar = widget.newTabBar(
    {
        top = display.contentHeight/2 - 52,
        --*Horizontal*--top = 0,--display.contentHeight-52,
        left = tabHeight/2-display.actualContentWidth/2+1,
        --*Horizontal*--left = -(display.actualContentWidth - display.contentWidth)/2 + 1,
        height = tabHeight,--display.contentHeight,
        --width = display.contentHeight,--(display.actualContentWidth - display.contentWidth)/2,
        buttons = tabButtons,
        rotation = 90,
    }
)

tabBar.rotation = 90
--tabBar:setFillColor(0.5)

-- Pass the scene content to an event listener
renderTemplate:addEventListener("create",renderTemplate)

return renderTemplate

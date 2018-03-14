local widget = require "widget"
local composer = require "composer"
local sqlite3 = require "sqlite3"
local sharedMem = require( "sharedMem" )

local sceneHospital = composer.newScene()

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

  local rowTitle = display.newText( row, "    " .. row.params.IteNum .. "   " .. row.params.IteDesc, 0, 0, nil, 20 )
  rowTitle:setFillColor( 0 )

  --if (isTopLevel(row.params.IteNum)) then
    --row:setRowColor( 0.2 )
  --else
    --row:setRowColor( 0 )
  --end

  rowTitle.anchorX = 0
  rowTitle.x = 0
  rowTitle.y = rowHeight * 0.5

  row.status = display.newCircle( 900, rowHeight * 0.5, 20 )
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
  print("isHeadChange here is", isHeadChange)
end

--Create a view to contain item rows for the checklist
tableView = widget.newTableView( {
  onRowRender = onRowRender,
  listener = theReloader
} )



--tableView:addEventListener("touch",tableView)

for row in db:nrows("SELECT ItemNumber, ItemDescription FROM TemplateEntries WHERE TemplateID='" .. sharedMem.tempType .. "';") do

  if not (row.ItemNumber == '') then

    --Create data entry in table
    ProgressTable[row.ItemNumber] = 0

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

-- Pass the scene content to an event listener
sceneHospital:addEventListener("create",sceneHospital)

return sceneHospital

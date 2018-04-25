local widget = require "widget"
local composer = require "composer"
local sqlite3 = require "sqlite3"
local sharedMem = require "sharedMem"
local utility = require "utility"

local renderTemplate = composer.newScene()

-- Helper function for debugging
----------------------------------------
----------------------------------------
function dump(o)
   if type(o) == 'table' then
      local s = '\n{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} \n\n'
   else
      return tostring(o)
   end
end
----------------------------------------
----------------------------------------


function renderTemplate:create( event )
  local sceneGroup = self.view

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

  display.setDefault( "background", 1)

  ----------------------General Use Functions-----------------------
  ------------------------------------------------------------------
  -- Function for setting status colour
  local function setStatusColour( index, object )
    if (ProgressTable[index][sharedMem.outputDate] == 0) then
      object:setFillColor(0.8)
    elseif (ProgressTable[index][sharedMem.outputDate] == 1) then
      object:setFillColor(1,0,0)
    elseif (ProgressTable[index][sharedMem.outputDate] == 2) then
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
    print("Top level:", topLevel)
    --If the current value is zero or greater than the value being inserted
    --at the time of this call, update the heading value to be the new value
    if ((ProgressTable[topLevel][sharedMem.outputDate] == nil) or (ProgressTable[topLevel][sharedMem.outputDate] == 0)) then
      ProgressTable[topLevel][sharedMem.outputDate] = ProgressTable[currentItem][sharedMem.outputDate]
    else
      --Scan entire ProgressTable and check the value of items belonging to the topLevel number
      --Assume currentItem is governing the floor value - set changeHead to false
      --if another item disproves this

      --print("Made it into the scanning section")
      print("The new status is", ProgressTable[currentItem][sharedMem.outputDate])
      local changeHead = true
      for name, val in pairs(ProgressTable) do
        local parentNum = string.match(name, "^(%d*)%.")
        parentNum = tonumber( parentNum )
        --print("ParentNum is", parentNum, "and the topLevel is", topLevel)
        if (parentNum == topLevel) then
          --print("Found a matching item")
          --print("The name is", name, "and the value is", val)
          print("Arg 1 is:", ProgressTable[currentItem][sharedMem.outputDate] )
          print("Arg 2 is:", ProgressTable[currentItem][sharedMem.outputDate] )
          if (((val[sharedMem.outputDate] > 0) and (val[sharedMem.outputDate] < ProgressTable[currentItem][sharedMem.outputDate])) or (ProgressTable[currentItem][sharedMem.outputDate] == 0)) then
            --print("Turns out the current item isn't the floor")
            changeHead = false
          end
        end
      end
      print("Finished scanning")
      if (changeHead) then
        print("We're changing the head value")
        ProgressTable[topLevel][sharedMem.outputDate] = ProgressTable[currentItem][sharedMem.outputDate]
        isHeadChange = true
      end
    end
    print("The value of isHeadChange is now", isHeadChange)
    --Otherwise, leave the heading value as is
    --print("The img reference for the heading is", headingImgTable[topLevel], "and topLevel is", topLevel)
    --Finally, update the colour of the heading image
    setStatusColour(topLevel,headingImgTable[topLevel])
    --GUI_Response.setStatusColour(ProgressTable,topLevel,sharedMem.outputDate,headingImgTable[topLevel])
  end
  -------------------------------------------------------------------------
  --------------------End of General Functions-----------------------------

  ----------------------Table View Functions--------------------
  --------------------------------------------------------------
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

    local statusRLight = {
      x = display.contentWidth - display.contentWidth/8,
      y = rowHeight * 0.5
    }

    --row.status = display.newCircle( statusLight.x, statusLight.y, 20 )
    --row.status
    row.status = display.newImage(row,'white_circle.png')
    row.status.x = display.contentWidth - display.contentWidth/8
    row.status.y = rowHeight * 0.5
    row.status.height = 40
    row.status.width = 40
    setStatusColour(row.params.IteNum, row.status)

    row:insert( row.status )

    --Create a function to modify progress data
    function row:touch( event )
      if (event.phase == "ended") then
        ProgressTable[row.params.IteNum][sharedMem.outputDate] = ProgressTable[row.params.IteNum][sharedMem.outputDate] + 1
        if (ProgressTable[row.params.IteNum][sharedMem.outputDate] > 3) then
          ProgressTable[row.params.IteNum][sharedMem.outputDate] = 0
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
    --tableView.height = display.contentHeight+50
  end


  local function theReloader( event )
    if (isHeadChange) then
      print("isHeadChange here is", isHeadChange)
      tableView:reloadData()
      isHeadChange = false
      print("----Data reload processed----")
    end
  end

  -- Create titlebar to go at the top of the screen
  local titleBar = display.newRect(display.contentCenterX, 0, display.contentWidth, 50)

  titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5

  local titleText = display.newText{
    text = sharedMem.projID,
    x = display.contentCenterX,
    y = titleBar.y + titleBar.y*0.2,
    height = titleBar.height,
    font = native.systemFontBold,
    fontSize = 25
  }
  titleText:setFillColor( 0 )

  sceneGroup:insert(titleBar)
  sceneGroup:insert(titleText)



  --Create a view to contain item rows for the checklist
  tableView = widget.newTableView( {
    onRowRender = onRowRender,
    listener = theReloader,
    height = display.contentHeight - titleBar.height,
    top = titleBar.height
  } )

  sceneGroup:insert(tableView)


  --Create a function to write the ProgressTable to the database
  function writeProgress()
    print("writeProgress has been called")
    print("The template type is:", sharedMem.tempType)
    --Populate table with query values
    local args = {}
    args[0] = [["]] .. sharedMem.tempType .. [["]]
    args[1] = [["]] .. sharedMem.tempID .. [["]]
    args[5] = [["]] .. sharedMem.outputDate .. [["]]
    args[3] = [["]] .. sharedMem.projID .. [["]]

    --print("The progress table is:\n", dump(ProgressTable))
    for k, v in pairs(ProgressTable) do

      --Add key and value to the arguments table - the other args don't change
      args[4] = v[sharedMem.outputDate]
      args[2] = [["]] .. k .. [["]]

      --print("The key value here is:", dump(args))

      --Record an individual progress value using args[] and RowID from TemplateEntries
      local err = db:exec(
        "INSERT OR REPLACE INTO ProjectValues (ProjectID, ItemID, Value, Date)\
        SELECT " .. args[3] .. ", TemplateEntries.RowID, " .. args[4] .. ", " .. args[5] .. "\
        FROM TemplateEntries \
        WHERE TemplateType=" .. args[0] .. " \
        AND TemplateID=" .. args[1] .. " \
        AND ItemNumber=" .. args[2] .. ";"
      )

      --print("the result of the save action is:", err)

    end
  end

  --Declare a lookup table to assist with date generation
  --[[local months = {
    "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  }]]

  --Function to generate array of months between project start and end dates
  --[[local function dateToDate( startDate, endDate )
    local dateArray = {}

    local sYear, sMonth, sDay = string.match(startDate, "(%d%d%d%d)%-(%d%d)%-(%d%d)")
    sYear = tonumber( sYear )
    sMonth = tonumber( sMonth )
    sDay = tonumber( sDay )

    local eYear, eMonth, eDay = string.match(endDate, "(%d%d%d%d)%-(%d%d)%-(%d%d)")
    eYear = tonumber( eYear )
    eMonth = tonumber( eMonth )
    eDay = tonumber( eDay )

    --This loop must still execute once when sYear and eYear are equal
    for i = sYear, eYear, 1 do
      if (i == sYear) then
        sM = sMonth
      else
        sM = 1
      end

      if (i == eYear) then
        eM = eMonth
      else
        eM = 12
      end

      print("The loop limits are:", sM, eM )
      for j = sM, eM, 1 do
        year = tostring(i)
        local monthName = months[j] .. "-" .. string.match(year,"^%d%d(%d%d)")
        dateArray[#dateArray+1] = monthName
      end
    end

    return dateArray
  end]]


  --Declare database queries for new and existing projects separately
  local newProjQuery = "SELECT ItemNumber, ItemDescription\
                        FROM TemplateEntries\
                        WHERE TemplateID='" .. sharedMem.tempID .. "'\
                        AND TemplateType='" .. sharedMem.tempType .. "';"

  local existProjQuery = "SELECT T1.ItemNumber,\
                        T1.ItemDescription, T2.Value, T2.Date\
                        FROM TemplateEntries AS T1, ProjectValues AS T2\
                        WHERE T1.RowID=T2.ItemID\
                        AND T2.ProjectID='" .. sharedMem.projID .. "'\
                        AND T1.TemplateType='" .. sharedMem.tempType .. "';"


  print("shared memory value for new project is:", sharedMem.newProject)
  if (sharedMem.loadProject or sharedMem.newProject) then
    sharedMem.dateArray = utility.dateToDate(sharedMem.newSDate, sharedMem.newEDate)
    sharedMem.outputDate = sharedMem.dateArray[1]
  end

  print("The loadProject flag is:", sharedMem.loadProject)

  --Iterate through database and generate rows for the table view
  for row in db:nrows( newProjQuery ) do

    if not (row.ItemNumber == '') then

      ProgressTable[row.ItemNumber] = {}
      for k, v in pairs(sharedMem.dateArray) do
        ProgressTable[row.ItemNumber][v] = 0
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


  print("The output date is set to", sharedMem.outputDate)
  for row in db:nrows( existProjQuery ) do

    ProgressTable[row.ItemNumber][row.Date] = row.Value

  end


  tableView:reloadData()

  --Create a save button to write data to the database
  local buttonRect1 = display.newRoundedRect(display.actualContentWidth*0.875, display.contentHeight*0.95, 80, 60, 12)

  local saveButton = widget.newButton( {
    label="Save",
    x = display.actualContentWidth*0.875,
    y = display.contentHeight*0.95,
  } )

  local function onSave( event )
    sharedMem.newProject = false
    if (event.phase == "ended") then
      print("---Saving the project data")
      writeProgress()
    end
  end

  saveButton:addEventListener("touch", onSave)

  sceneGroup:insert(buttonRect1)
  sceneGroup:insert(saveButton)

  --Create a save/exit button to write to database and return to start screen
  local buttonRect2 = display.newRoundedRect(display.actualContentWidth*0.875, display.contentHeight*0.85, 80, 60, 12)

  local saveExitButton = display.newText( {
    text="Save\n&\nExit",
    x = display.actualContentWidth*0.875,
    y = display.contentHeight*0.85,
    align = "center"
  } )

  saveExitButton:setFillColor( 0 )

  local function onSaveExit( event )
    if (event.phase == "ended") then
      composer.removeScene("RenderTemplate")
      composer.gotoScene("StartScreen")
      writeProgress()
      sharedMem.newProject = false
    end
  end

  saveExitButton:addEventListener("touch", onSaveExit)

  sceneGroup:insert(buttonRect2)
  sceneGroup:insert(saveExitButton)

  --Create navigation buttons to increment and decrement the output date
  local dateInc = display.newRoundedRect(display.contentWidth*0.95, titleBar.height/2, 30, 30, 4)
  dateInc.strokeWidth = 2
  dateInc:setStrokeColor( 0 )

  local dateDec = display.newRoundedRect(display.contentWidth*0.80, titleBar.height/2, 30, 30, 4)
  dateDec.strokeWidth = 2
  dateDec:setStrokeColor( 0 )

  local dateIncButton = widget.newButton( {
    label=">",
    x = display.contentWidth*0.95,
    y = titleBar.height/2,
  } )

  local dateDecButton = widget.newButton( {
    label="<",
    x = display.contentWidth*0.80,
    y = titleBar.height/2,
  } )

  local dateDisplay = display.newText {
    text = sharedMem.outputDate,
    x = display.contentWidth*0.875,
    y = titleBar.y+titleBar.y*0.4,
    height = titleBar.height,
    font = native.systemFontBold,
    fontSize = 15
  }
  dateDisplay:setFillColor( 0 )

  local function onInc( event )
    if (event.phase == "ended") then
      i = table.indexOf(sharedMem.dateArray, sharedMem.outputDate)
      if (i < #sharedMem.dateArray) then
        sharedMem.outputDate = sharedMem.dateArray[i+1]
        dateDisplay.text = sharedMem.outputDate
        tableView:reloadData()
      end
    end
  end

  local function onDec( event )
    if (event.phase == "ended") then
      i = table.indexOf(sharedMem.dateArray, sharedMem.outputDate)
      print("The value of the index is:", i)
      if (i > 1) then
        sharedMem.outputDate = sharedMem.dateArray[i-1]
        dateDisplay.text = sharedMem.outputDate
        tableView:reloadData()
      end
    end
  end

  dateIncButton:addEventListener("touch", onInc)
  dateDecButton:addEventListener("touch", onDec)

  sceneGroup:insert(dateDec)
  sceneGroup:insert(dateInc)
  sceneGroup:insert(dateDecButton)
  sceneGroup:insert(dateIncButton)
  sceneGroup:insert(dateDisplay)


  -- Function to handle button events
  local function handleTabBarEvent( event )
    if (event.phase == 'ended') then
      onSave(event)
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
  end

  -- Configure the tab buttons to appear within the bar
  local tabMargin = (display.actualContentWidth - display.contentWidth)/2
  local progPageBox = display.newRect(0,0,0,0)
  progPageBox.width = tabMargin
  progPageBox.height = display.actualContentHeight/2
  progPageBox.x = -tabMargin/2
  progPageBox.y = display.contentHeight/2 - progPageBox.height/2
  progPageBox:setFillColor(0.9)

  local progPageButton = display.newImage('clock.png')
  progPageButton.width = 60
  progPageButton.height = 60
  progPageButton.x = -display.actualContentWidth*0.04
  progPageButton.y = progPageBox.y
  progPageButton.rotation = 90

  local progPageText = display.newText{
    text = 'Progress\nReview',
    x = progPageBox.x,
    y = progPageBox.y + progPageButton.height*0.8,
    width = tabMargin,
    fontSize = 18,
    align = 'center'
  }
  progPageText:setFillColor(0)

  local docPageButton = display.newImage('doc.png')
  docPageButton.width = 303/5
  docPageButton.height = 228/5
  docPageButton.x = -display.actualContentWidth*0.04
  docPageButton.y = display.actualContentHeight*0.72
  docPageButton.rotation = 90

  local docPageBox = display.newRect(0,0,0,0)
  docPageBox.width = tabMargin
  docPageBox.height = display.actualContentHeight/2
  docPageBox.x = -tabMargin/2
  docPageBox.y = display.contentHeight/2 + docPageBox.height/2
  docPageBox:setFillColor(0.9)

  local docPageText = display.newText{
    text = 'Documents\nReview',
    x = docPageBox.x,
    y = docPageButton.y + docPageButton.height,
    width = tabMargin,
    fontSize = 16,
    align = 'center'
  }
  docPageText:setFillColor(0)

  local function onProgPage( event )
    if (event.phase == 'ended') then
      onSave(event)
      sharedMem.tempType = 'Progress'
      sharedMem.newProject = false
      sharedMem.loadProject = false
      composer.removeScene("RenderTemplate")
      composer.gotoScene("RenderTemplate")
      print(dump(sharedMem))
    end
  end

  local function onDocPage( event )
    if (event.phase == 'ended') then
      onSave(event)
      sharedMem.tempType = 'Document'
      sharedMem.newProject = false
      sharedMem.loadProject = false
      composer.removeScene("RenderTemplate")
      composer.gotoScene("RenderTemplate")
      print(dump(sharedMem))
    end
  end

  --Provide UI colour feedback for tab selection
  if (sharedMem.tempType == 'Document') then
    --Set the tab box colour
    progPageBox:setFillColor(0.98)
    docPageBox:setFillColor(0.9)
    --Set the tab text colour
    progPageText:setFillColor(0)
    docPageText:setFillColor(30/255,144/255,255/255)
  elseif (sharedMem.tempType == 'Progress') then
    --Set the tab box colour
    progPageBox:setFillColor(0.9)
    docPageBox:setFillColor(0.98)
    --Set the tab text colour
    progPageText:setFillColor(30/255,144/255,255/255)
    docPageText:setFillColor(0)
  end

  docPageButton:addEventListener('touch',onDocPage)
  progPageButton:addEventListener('touch',onProgPage)

  sceneGroup:insert(progPageBox)
  sceneGroup:insert(progPageButton)
  sceneGroup:insert(progPageText)
  sceneGroup:insert(docPageBox)
  sceneGroup:insert(docPageButton)
  sceneGroup:insert(docPageText)

----------------------------End of Create Scene------------------------
end



function renderTemplate:show( event )
  local sceneGroup = self.view

  params = event.params

  if event.phase == "did" then
  end

end


-- Pass the scene content to an event listener
renderTemplate:addEventListener("create",renderTemplate)
renderTemplate:addEventListener("show",renderTemplate)
renderTemplate:addEventListener("hide",renderTemplate)
renderTemplate:addEventListener("destroy",renderTemplate)

return renderTemplate

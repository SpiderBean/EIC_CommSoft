--This is an overlay scene providing a list of projects to be added to the multiview
local widget = require "widget"
local sqlite3 = require "sqlite3"
local utility = require "utility"
local composer = require "composer"
local sharedMem = require "sharedMem"

local selectScene = composer.newScene()

--Create flag to control recognition of clicks on screen
local goThrough = false
local start = false
local move = false
local over = false

local processItem

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

function selectScene:create( event )
  local sceneGroup = self.view
  local phase = event.phase
  local parent = event.parent

  local fPath = system.pathForFile( "SoftPlan_001.db", system.DocumentsDirectory )
  local db = sqlite3.open(fPath)

  --Create an encapsulating box to frame the pop-up window
  local envelopeBox = display.newRect(display.contentCenterX, 0, 30, 30)
  envelopeBox.y = display.contentHeight*0.5
  envelopeBox.height = display.contentHeight*0.8
  envelopeBox.width = display.contentWidth*0.7
  envelopeBox:setFillColor(0.7)

  sceneGroup:insert(envelopeBox)

  local titleBar = display.newRect(display.contentCenterX, 0, envelopeBox.width, 60)
  titleBar.y = envelopeBox.height*0.17 -- (0.5*titleBar.height)
  titleBar:setFillColor(0.95)

  local titleText = display.newText{
    text = "Select the projects to include in the summary:",
    x = display.contentCenterX,
    y = titleBar.y+titleBar.y*0.06,
    height = titleBar.height,
    font = native.systemFont,
    fontSize = 21
  }
  titleText:setFillColor( 0 )

  sceneGroup:insert(titleBar)
  sceneGroup:insert(titleText)

  local buttonBar = display.newRect(display.contentCenterX, 0, envelopeBox.width-10, 70)
  buttonBar.y = envelopeBox.height*1.05 -- (0.5*titleBar.height)
  buttonBar:setFillColor(1)

  sceneGroup:insert(buttonBar)

  --Declare the listview infrastructure
  local function onRowRender( event )

    local row = event.row

    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth

    local projName = display.newText(
      {
        parent = row,
        text = row.params.ProjName,
        x = display.contentWidth/8,
        y = rowHeight * 0.5,
        font = nil,
        fontSize = row.params.FSize,
        width = 150,
        anchorX = 0,
        align = "center"
      } )
    projName:setFillColor( 0 )
    row:insert(projName)


    local projType = display.newText(
      {
        parent = row,
        text = row.params.ProjType,
        x = display.contentWidth*0.45,
        y = rowHeight * 0.5,
        font = nil,
        fontSize = 15,
        width = display.contentWidth*0.3,
        anchorX = 0,
      } )
    projType:setFillColor( 0 )
    row:insert(projType)


    local startDate = display.newText(
      {
        parent = row,
        text = row.params.SDate,
        x = display.contentWidth*0.68,
        y = rowHeight * 0.3,
        font = nil,
        fontSize = 11,
        width = display.contentWidth*0.3,
        anchorX = 0,
      } )
    startDate:setFillColor( 0 )
    row:insert(startDate)


    local endDate = display.newText(
      {
        parent = row,
        text = row.params.EDate,
        x = display.contentWidth*0.68,
        y = rowHeight * 0.7,
        font = nil,
        fontSize = 11,
        width = display.contentWidth*0.3,
        anchorX = 0,
      } )
    endDate:setFillColor( 0 )
    row:insert(endDate)

    row.addItem = display.newImage(row, 'green_plus.png')
    row.addItem:translate(display.contentWidth*0.65,rowHeight * 0.5)
    row.addItem.width = 30
    row.addItem.height = 30

    row.removeItem = display.newImage(row, 'red_minus.png')
    row.removeItem:translate(display.contentWidth*0.65,rowHeight * 0.5)
    row.removeItem.width = 30
    row.removeItem.height = 30

    row.tickItem = display.newImage(row, 'green_tick.png')
    row.tickItem:translate(display.contentWidth*0.03,rowHeight * 0.5)
    row.tickItem.width = 20
    row.tickItem.height = 20

    if (containsKey(sharedMem.PrT, row.params.ProjName)) then
      row.removeItem.isVisible = true
      row.tickItem.isVisible = true
    else
      row.removeItem.isVisible = false
      row.tickItem.isVisible = false
    end

    --Create a function to handle touch instructions and load project parameters
    function row:touch( event )

      if (event.phase == "began") then
        start = true
      end
      if (event.phase == "moved") then
        move = true
      end
      if (event.phase == "ended") then
        over = true
      end
      if (start and move and over) then
        start = false
        move = false
        over = false
      elseif (start and over) then
        --Call the function to add/remove items in PrT
        processItem(event, row)
        start = false
        move = false
        over = false
      end


    end

    row.addItem:addEventListener("touch",row)

    row:addEventListener("touch",row)
    list:insert(row)
  end

  -- Create a tableView
  list = widget.newTableView
  {
    top = titleBar.y + titleBar.height*0.5,
    width = envelopeBox.width-10,
    height = envelopeBox.height - titleBar.height - buttonBar.height,
    onRowRender = onRowRender,
    onRowTouch = onRowTouch,
  }

  list.x = display.contentCenterX

  sceneGroup:insert(list)

  --Iterate through project table and generate rows for the view
  for row in db:nrows("SELECT * FROM Projects;") do

    list:insertRow{
      rowHeight = 60,
      params = {
        ProjName = row.Name,
        ProjType = row.Type,
        SDate = row.StartDate,
        EDate = row.EndDate,
        FSize = 18,
      },
    }

  end
  -------------------End of list view infrastructure------------

  local returnRect = display.newRoundedRect(display.contentCenterX,0,170,50,12)
  returnRect.y = display.contentHeight*0.84
  returnRect.strokeWidth = 2
  returnRect:setStrokeColor(0)
  --returnRect:setFillColor(0.5)

  local returnButton = display.newText( {
    text="Configure Summary",
    width=returnRect.width,
    height=30,
    align='center'
  } )

  returnButton:setFillColor(0)
  returnButton.y = display.contentHeight*0.845
  returnButton.x = display.contentCenterX

  returnRect:addEventListener("touch", onConfigure)

  sceneGroup:insert(returnRect)
  sceneGroup:insert(returnButton)

end


function selectScene:hide( event )
  local sceneGroup = self.view
  local phase = event.phase
  local parent = event.parent  -- Reference to the parent scene object

  if ( phase == "will" ) then
      -- Call the "resumeGame()" function in the parent scene
      populateList()
  end
end

function onConfigure()
  -- By some method such as a "resume" button, hide the overlay
  composer.hideOverlay( "slideDown", 500 )
end

function containsKey(list, key)
  local result = false
  for k, v in pairs(list) do
    if (v.name == key) then
      result = true
    end
  end
  return result
end

function processItem( event, row )
  if not (containsKey(sharedMem.PrT, row.params.ProjName)) then

    local PrTlength = 0
    for k,v in pairs(sharedMem.PrT) do
      PrTlength = PrTlength + 1
    end

    print("Inserting", row.params.ProjName, "into PrT with index", PrTlength+1)

    local dArr = utility.dateToDate(row.params.SDate, row.params.EDate)
    --Scan PrT for a nil location to achieve insertion without overwrite
    local insertSuccess = false
    while not (insertSuccess) do
      if (sharedMem.PrT[PrTlength+1] == nil) then
        sharedMem.PrT[PrTlength+1] = {
          name = row.params.ProjName,
          StartMonth = row.params.SDate,
          EndMonth = row.params.EDate,
          Type = row.params.ProjType,
          isAdd = false,
          dateArray = dArr,
          date = dArr[1],
          dataTable = nil,
          index = PrTlength + 1, --This should be overwritten by the counting function
        }
        row.tickItem.isVisible = true
        row.removeItem.isVisible = true
        insertSuccess = true
      else
        PrTlength = PrTlength + 1
      end
    end
  else
    print("Removing", row.params.ProjName, "from PrT")
    for k, v in pairs(sharedMem.PrT) do
      if (v.name == row.params.ProjName) then
        sharedMem.PrT[k] = nil
      end
    end

    row.tickItem.isVisible = false
    row.removeItem.isVisible = false
  end

  --Calculate index the same way regardless of removal or insertion
  local indexCount = 1
  for k, v in pairs(sharedMem.PrT) do
    if not (v == nil) then
      print("Assigning", indexCount, "to the list item", v.name)
      v.index = indexCount
      indexCount = indexCount + 1
    end
  end

end


selectScene:addEventListener( "hide", selectScene )
selectScene:addEventListener( "create", selectScene )

return selectScene

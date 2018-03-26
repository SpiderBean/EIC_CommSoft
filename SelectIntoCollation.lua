--This is an overlay scene providing a list of projects to be added to the multiview
local widget = require "widget"
local sqlite3 = require "sqlite3"
local composer = require "composer"
local sharedMem = require "sharedMem"

local selectScene = composer.newScene()

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

  -- Create toolbar to go at the top of the screen
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
        width = display.contentWidth*0.3,
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

    local addItem = display.newImage(row, 'green_plus.png')
    addItem:translate(display.contentWidth*0.65,rowHeight * 0.5)
    addItem.width = 30
    addItem.height = 30

    local removeItem = display.newImage(row, 'red_minus.png')
    removeItem:translate(display.contentWidth*0.65,rowHeight * 0.5)
    removeItem.width = 30
    removeItem.height = 30


    local tickItem = display.newImage(row, 'green_tick.png')
    tickItem:translate(display.contentWidth*0.03,rowHeight * 0.5)
    tickItem.width = 20
    tickItem.height = 20

    if (containsKey(sharedMem.PrT, row.params.ProjName)) then
      removeItem.isVisible = true
      tickItem.isVisible = true
    else
      removeItem.isVisible = false
      tickItem.isVisible = false
    end

    --Create a function to handle touch instructions and load project parameters
    function row:touch( event )
      if (event.phase == "ended") then
        --print("The name here is", row.params.ProjName)
        if not (containsKey(sharedMem.PrT, row.params.ProjName)) then
          print("Inserting", row.params.ProjName, "into PrT")
          --table.insert(sharedMem.PrT, row.params.ProjName )
          sharedMem.PrT[row.params.ProjName] = {
            StartMonth = row.params.SDate,
            EndMonth = row.params.EDate,
            Type = row.params.ProjType,
            isAdd = false,
            dataTable = {},
          }
          tickItem.isVisible = true
          removeItem.isVisible = true
        else
          print("Removing", row.params.ProjName, "from PrT")
          sharedMem.PrT[row.params.ProjName] = nil
          tickItem.isVisible = false
          removeItem.isVisible = false
        end
      end
    end

    addItem:addEventListener("touch",row)

    row:addEventListener("touch",row)
    list:insert(row)
  end

  -- Create a tableView
  list = widget.newTableView
  {
    top = titleBar.y + titleBar.height*0.5,
    width = envelopeBox.width-10,
    height = envelopeBox.height - titleBar.height - 5,
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
  returnRect.y = display.contentHeight*0.8
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
  returnButton.y = display.contentHeight*0.805
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
    if (k == key) then
      result = true
    end
  end
  return result
end


selectScene:addEventListener( "hide", selectScene )
selectScene:addEventListener( "create", selectScene )

return selectScene

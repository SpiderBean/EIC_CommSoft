local widget = require "widget"
local sqlite3 = require "sqlite3"
local composer = require "composer"
local sharedMem = require "sharedMem"

-- Create handle for the scene content
local reportCollate = composer.newScene()

--Create a table to keep track of which projects are already on screen
local summaryRegister = {}

-- Define the scene create function which fully defines the screen
function reportCollate:create( event )
	local sceneGroup = self.view

	local fPath = system.pathForFile( "SoftPlan_001.db", system.DocumentsDirectory )
	local db = sqlite3.open(fPath)

  -- Create toolbar to go at the top of the screen
  local titleBar = display.newRect(display.contentCenterX, 0, display.actualContentWidth, 60)

  titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5

  local titleText = display.newText{
    text = "Multi-Project View",
    x = display.contentCenterX,
    y = titleBar.y + titleBar.y*0.2,
    height = titleBar.height,
    font = native.systemFontBold,
    fontSize = 25
  }
  titleText:setFillColor( 0 )

  sceneGroup:insert(titleBar)
  sceneGroup:insert(titleText)

  local headingBar = display.newRect(display.contentCenterX, 0, display.actualContentWidth, 60)
  headingBar.y = titleBar.height + titleBar.height/2
  headingBar:setFillColor(0.9)

  sceneGroup:insert(headingBar)
  ------------------------------------------------------------------------
  -------------------------End of Utility UI------------------------------

  --Create a table to populate the list
  sharedMem.PrT = {}

  --This function is called every time a row is created or returns to the screen
  local function onRowRender( event )

    local row = event.row

    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth

    if (row.params.isDefault) then
      --Define the formatting for the add item to always appear at bottom of list
      local background = display.newRect(display.actualContentWidth/2, 0, display.actualContentWidth, 60)
      background.y = rowHeight * 0.5
      background:setFillColor(0.9)

      local defaultAddRow = display.newText(
        {
          parent = row,
          text = row.params.ProjName,
          x = display.actualContentWidth/2,
          y = rowHeight * 0.5,
          font = nil,
          fontSize = 20,
          width = display.contentWidth*0.3,
          anchorX = 0,
          align = "center"
        } )
      defaultAddRow:setFillColor( 0 )

      row:insert(background)
      row:insert(defaultAddRow)

    else
      ---------------Define the formatting of standard list entries-----------
      local projName = display.newText(
        {
          parent = row,
          text = row.params.ProjName,
          x = display.contentWidth/8,
          y = rowHeight * 0.5,
          font = nil,
          fontSize = 20,
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
          fontSize = 20,
          width = display.contentWidth*0.3,
          anchorX = 0,
        } )
      projType:setFillColor( 0 )
      row:insert(projType)


      local startDate = display.newText(
        {
          parent = row,
          text = row.params.SDate,
          x = display.contentWidth*0.8,
          y = rowHeight * 0.5,
          font = nil,
          fontSize = 20,
          width = display.contentWidth*0.3,
          anchorX = 0,
        } )
      startDate:setFillColor( 0 )
      row:insert(startDate)


      local endDate = display.newText(
        {
          parent = row,
          text = row.params.EDate,
          x = display.contentWidth*0.95,
          y = rowHeight * 0.5,
          font = nil,
          fontSize = 20,
          width = display.contentWidth*0.3,
          anchorX = 0,
        } )
      endDate:setFillColor( 0 )
      row:insert(endDate)

      -----------------End of Standard Entry Formatting----------------
    end

    --Create a function to handle touch instructions and load project parameters
    function row:touch( event )
      local popUpOptions = {
        isModal = true,
        effect = "fromBottom",
        params = {}
      }

			--Ensure that the pop-up window only triggers for the default "add" row
			if (row.params.isDefault) then
	      if (event.phase == "ended") then
	        composer.showOverlay( "SelectIntoCollation", popUpOptions )
	      end
			end
    end

    row:addEventListener("touch",row)
    tableView:insert(row)
  end


  --Create a view to contain item rows for the checklist
  tableView = widget.newTableView( {
    onRowRender = onRowRender,
    top = titleBar.height + headingBar.height,
    height = display.contentHeight - (titleBar.height + headingBar.height),
    width = display.actualContentWidth,
    left = -(display.actualContentWidth - display.contentWidth)*0.5
  } )

  sceneGroup:insert(tableView)

	populateList()



end

function populateList()
	--Delete the previous entries
	tableView:deleteAllRows()
	print("Preparing to print and the PrT is:", dump(sharedMem.PrT))
	--Iterate through project table and generate rows for the view
  for k, v in pairs(sharedMem.PrT) do
		--print("This is k:", k, "and this is v:", v, "therefore nil==v is:", v==nil)
		--print("The isWritten value is:", v.isWritten)

		--Print all entires except for the default add row in one go
		if (not (v == nil)) then
	    tableView:insertRow{
	      rowHeight = 70,
	      params = {
	        ProjName = k,
	        ProjType = v.Type,
	        SDate = v.StartMonth,
	        EDate = v.EndMonth,
	        isDefault = v.isAdd,
	        index = k
	      },

			--If not already on hand, load the project data from the database
			if (v.dataTable == nil) then
				for row in db:nrows("")
	    }
		end

  end
	--Insert the default row at the end of the table
	tableView:insertRow{
		rowHeight = 70,
		params = {
			ProjName = "Add Project +",
			ProjType = 'NA',
			SDate = 'NA',
			EDate = 'NA',
			isDefault = true,
			index = 'NA'
		},
	}
end

-- Pass the scene content to an event listener
reportCollate:addEventListener("create",reportCollate)

--Runtime:addEventListener("orientation",positionVis())


return reportCollate

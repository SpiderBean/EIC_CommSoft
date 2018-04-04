local widget = require "widget"
local sqlite3 = require "sqlite3"
local utility = require "utility"
local composer = require "composer"
local sharedMem = require "sharedMem"
local GUI_Response = require "GUI_Response"

-- Create handle for the scene content
local reportCollate = composer.newScene()

--Create a table to keep track of which projects are already on screen
local summaryRegister = {}

--Initialise database access variables
local fPath = system.pathForFile( "SoftPlan_001.db", system.DocumentsDirectory )
local db = sqlite3.open(fPath)



-- Define the scene create function which fully defines the screen
function reportCollate:create( event )
	local sceneGroup = self.view

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

	local headProjName = display.newText(
		{
			text = "Project",
			x = display.actualContentWidth*0.005,
			y = headingBar.y,
			font = nil,
			fontSize = 20,
			width = 80,
			anchorX = 0,
		} )
	headProjName:setFillColor( 0 )
	sceneGroup:insert(headProjName)

	local headDocsTitle = display.newText(
		{
			text = "Documents and Processes Review",
			x = display.actualContentWidth*0.335,
			y = headingBar.y,
			font = nil,
			fontSize = 20,
			width = 320,
			anchorX = 0,
		} )
	headDocsTitle:setFillColor( 0 )
	sceneGroup:insert(headDocsTitle)

	local headProgTitle = display.newText(
		{
			text = "Site Progress Review",
			x = display.actualContentWidth*0.735,
			y = headingBar.y,
			font = nil,
			fontSize = 20,
			width = 320,
			anchorX = 0,
		} )
	headProgTitle:setFillColor( 0 )
	sceneGroup:insert(headProgTitle)


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

      --Define the formatting for the "add" item which floats at bottom of list
      local background = display.newRect(display.actualContentWidth/2, 0, display.actualContentWidth, 60)
      background.y = rowHeight * 0.5
			background.height = row.height
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
          x = display.contentWidth*0.37,
          y = rowHeight * 0.5,
          font = nil,
          fontSize = 20,
          width = display.contentWidth*0.3,
          anchorX = 0,
        } )
      projType:setFillColor( 0 )
      row:insert(projType)

			local projNo = display.newText(
				{
					parent = row,
					text = row.params.index,
					x = display.contentWidth*0.17,
					y = rowHeight * 0.5,
					font = nil,
					fontSize = 20,
					width = display.contentWidth*0.3,
				} )
			projNo:setFillColor( 0 )
			row:insert(projNo)

			local projDate = display.newText(
				{
					parent = row,
					text = row.params.date,
					x = projType.x - 45,
					y = rowHeight * 0.5,
					font = nil,
					fontSize = 18,
					width = 65,
					align = "center",
				} )
			projDate:setFillColor( 0 )
			projDate:rotate(270)
			row:insert(projDate)

			--Create navigation buttons to increment and decrement the output date
		  local dateInc = display.newRoundedRect(projDate.x, rowHeight*0.8, 15, 15, 4)
		  dateInc.strokeWidth = 2
		  dateInc:setStrokeColor( 0 )
			row:insert(dateInc)

		  local dateDec = display.newRoundedRect(projDate.x, rowHeight*0.2, 15, 15, 4)
		  dateDec.strokeWidth = 2
		  dateDec:setStrokeColor( 0 )
			row:insert(dateDec)

		  local dateIncButton = widget.newButton( {
		    label=">",
		    x = projDate.x,
		    y = rowHeight*0.2,
				width = 45,
				height = 45,
		  } )
			dateIncButton:rotate(270)
			row:insert(dateIncButton)

		  local dateDecButton = widget.newButton( {
		    label="<",
		    x = projDate.x,
		    y = rowHeight*0.8,
				width = 45,
				height = 45,
		  } )
			dateDecButton:rotate(270)
			row:insert(dateDecButton)

			local function onInc( event )
				if (event.phase == "ended") then
					for k, v in pairs(sharedMem.PrT) do
						if (v.name == row.params.ProjName) then
							i = table.indexOf(v.dateArray, v.date)
							if (i < #v.dateArray) then
								v.date = v.dateArray[i+1]
								projDate.text = v.date
								print("Up - Setting the date to", v.date)
								--tableView:reloadData()
								--Set the dataTable to nil to trigger new db access
								v.dataTable = nil
								local y = tableView:getContentPosition()
								populateList(true,y)
							end
						end
					end
				end
			end

			local function onDec( event )
				if (event.phase == "ended") then
					for k, v in pairs(sharedMem.PrT) do
						if (v.name == row.params.ProjName) then
							i = table.indexOf(v.dateArray, v.date)
							print("The value of the index is:", i)
							if (i > 1) then
								v.date = v.dateArray[i-1]
								projDate.text = v.date
								print("Down - Setting the date to", v.date)
								--tableView:reloadData()
								--Set the dataTable to nil to trigger new db access
								v.dataTable = nil
								local y = tableView:getContentPosition()
								populateList(true,y)
							end
						end
					end
				end
			end

			dateIncButton:addEventListener("touch", onInc)
			dateDecButton:addEventListener("touch", onDec)

			local commentButtonImg = display.newImage('comment_bubble.jpg')
		  commentButtonImg.width = 40
		  commentButtonImg.height = 40
		  commentButtonImg.x = projType.x - 130
		  commentButtonImg.y = rowHeight*0.75
			row:insert(commentButtonImg)

			local commentButton = widget.newButton({
				--image = commentButtonImg,
				x = commentButtonImg.x,
				y = commentButtonImg.y,
				height = 60,
				width = 60,
			})
			row:insert(commentButton)

			local function showComment( event )
				local popUpOptions = {
					isModal = true,
					effect = "fromRight",
					params = {}
				}

				if (event.phase=='ended') then
					composer.showOverlay( "ProjectComment", popUpOptions )
				end
			end

			commentButton:addEventListener("touch", showComment)


			------------------------------------------------------------------------
			------------------------Create progress data graphics-------------------
			local numDocs
			local Docs
			--Initialise icons for representing document progress
			if not (sharedMem.PrT == nil) then
				local lightTableDocs = {}
				for k, v in pairs(sharedMem.PrT) do
					if (v.name == row.params.ProjName) then
						numDocs = sharedMem.PrT[k].dataTable.docLength
						Docs = sharedMem.PrT[k].dataTable.docItems
					end
				end

				local xDStart = display.actualContentWidth*0.30
				local xDOffset = 35
				local xDPos
				local i = 0
				if not (Docs == nil) then
					for k, v in pairs(Docs) do
						if not (v == nil) then
							xDPos = xDStart + (xDOffset*i)
							i = i + 1

							lightTableDocs[v] = display.newImage(row,'white_circle.png')
							lightTableDocs[v].x = xDPos
							lightTableDocs[v].y = rowHeight * 0.1
							lightTableDocs[v].height = 20
							lightTableDocs[v].width = 20

							lightTableDocs[v]:setFillColor(0.8)

							local lightLabel = display.newText(
				        {
				          parent = row,
				          text = string.gsub(v, "%(.*%)", ""),
				          x = xDPos,
				          y = rowHeight * 0.5,
				          font = nil,
				          fontSize = 12,
				          width = 135,
				          anchorX = 0,
				        } )
				      lightLabel:setFillColor( 0 )
							lightLabel:rotate(270)

				      row:insert(lightLabel)
						end
					end
				end

				--Iterate over images second time to set colour value for available data
				for k, v in pairs(sharedMem.PrT) do
					if (v.name == row.params.ProjName) then

						for j, u in pairs(v.dataTable.Document) do

							if not (lightTableDocs[u.ItemDescription] == nil) then
							  if (u.Value == 0) then
							    lightTableDocs[u.ItemDescription]:setFillColor(0.8)
							  elseif (u.Value == 1) then
							    lightTableDocs[u.ItemDescription]:setFillColor(1,0,0)
							  elseif (u.Value == 2) then
							    lightTableDocs[u.ItemDescription]:setFillColor(255/256,189/256,0/256)
							  else
							    lightTableDocs[u.ItemDescription]:setFillColor(0,1,0)
							  end
							end

						end
					end
				end


				--Initialise icons for representing general progress data
				local lightTableProg = {}
				local numProg
				local Prog
				for k, v in pairs(sharedMem.PrT) do
					if (v.name == row.params.ProjName) then
						numProg = v.dataTable[progLength]
						Prog = sharedMem.PrT[k].dataTable.progItems
					end
				end

				local xPStart = display.actualContentWidth*0.70
				local xPOffset = 35
				local xPPos
				local j = 0

				--print("Dumping the prog table", dump(Prog))
				for k, v in pairs(Prog) do
					if not (v == nil) then

						xPPos = xPStart + (xPOffset*j)
						j = j + 1

						lightTableProg[v] = display.newImage(row,'white_circle.png')
						lightTableProg[v].x = xPPos
						lightTableProg[v].y = rowHeight * 0.1
						lightTableProg[v].height = 20
						lightTableProg[v].width = 20

						lightTableProg[v]:setFillColor(0.8)

						local lightLabel = display.newText(
							{
								parent = row,
								text = string.gsub(v, "%(.*%)", ""),
								x = xPPos,
								y = rowHeight * 0.5,
								font = nil,
								fontSize = 12,
								width = 135,
								anchorX = 0,
							} )
						lightLabel:setFillColor( 0 )
						lightLabel:rotate(270)

						row:insert(lightLabel)
					end
				end

				--Iterate over images second time to set colour value for available data
				for k, v in pairs(sharedMem.PrT) do
					if (v.name == row.params.ProjName) then
						for j, u in pairs(v.dataTable.Progress) do

							local q = u.ItemDescription
							if not (lightTableProg[u.ItemDescription] == nil) then
								if (u.Value == 0) then
									lightTableProg[u.ItemDescription]:setFillColor(0.8)
								elseif (u.Value == 1) then
									lightTableProg[u.ItemDescription]:setFillColor(1,0,0)
								elseif (u.Value == 2) then
									lightTableProg[u.ItemDescription]:setFillColor(255/256,189/256,0/256)
								else
									lightTableProg[u.ItemDescription]:setFillColor(0,1,0)
								end
							end

						end
					end
				end

			end
			---------------------------End of data graphics-------------------------

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

	populateList(false,0)


------------------------End of Create Function-------------------------
end


------------------------Database Quick-Access Function------------------
local function getProjectValues(date, prName)
	local returnData = {}
	returnData['Document'] = {}
	returnData['Progress'] = {}
	returnData['docItems'] = {}
	returnData['progItems'] = {}
	returnData['docLength'] = 0
	returnData['progLength'] = 0

	--Store all document records in a subtable
	for row in db:nrows("SELECT T1.ItemNumber, T1.ItemDescription, \
											T2.Date, T2.Value\
											FROM TemplateEntries AS T1, ProjectValues AS T2\
											WHERE T1.RowID=T2.ItemID\
											AND T2.ProjectID='" .. prName .."'\
											AND T1.TemplateType='Document'\
											AND T2.Date='" .. date .. "';") do

		returnData.Document[row.ItemNumber] = {
			ItemDescription = row.ItemDescription,
			Value = row.Value,
		}

	end

	--Store all general progress records in a separate subtable
	for row in db:nrows("SELECT T1.ItemNumber, T1.ItemDescription, \
											T2.Date, T2.Value\
											FROM TemplateEntries AS T1, ProjectValues AS T2\
											WHERE T1.RowID=T2.ItemID\
											AND T2.ProjectID='" .. prName .."'\
											AND T1.TemplateType='Progress'\
											AND T2.Date='" .. date .. "';") do

		returnData.Progress[row.ItemNumber] = {
			ItemDescription = row.ItemDescription,
			Value = row.Value,
		}

	end

	--Process two more queries to fetch length of template without data
	for row in db:nrows("SELECT DISTINCT T1.ItemDescription, T1.ItemNumber\
											FROM TemplateEntries AS T1, Projects AS T2\
											WHERE T1.TemplateID=T2.Type\
											AND T2.Name='" .. prName .."'\
											AND T1.TemplateType='Document';") do

		returnData.docItems[row.ItemNumber] = row.ItemDescription
	end

	for row in db:nrows("SELECT DISTINCT T1.ItemDescription, T1.ItemNumber\
											FROM TemplateEntries AS T1, Projects AS T2\
											WHERE T1.TemplateID=T2.Type\
											AND T2.Name='" .. prName .."'\
											AND T1.TemplateType='Progress';") do

		returnData.progItems[row.ItemNumber] = row.ItemDescription
	end

	--Strip out the unneeded data from the item tables and count top-level items
	for k, v in pairs(returnData.docItems) do
		if (string.match(k, "^%d$") or string.match(k, "^%d%d$")) then
			returnData.docLength = returnData.docLength + 1
		else
			returnData.docItems[k] = nil
		end
	end

	for k, v in pairs(returnData.progItems) do
		if (string.match(k, "^%d$") or string.match(k, "^%d%d$")) then
			returnData.progLength = returnData.progLength + 1
		else
			returnData.progItems[k] = nil
		end
	end

	return returnData
end
	---------------------------End DB Function----------------------------

function populateList( scroll, scrollLoc )
	--Delete the previous entries
	tableView:deleteAllRows()

	--Iterate through project table and generate rows for the view
	--table.sort(sharedMem.PrT)
  for k, v in pairs(sharedMem.PrT) do
		--print("This is k:", k, "and this is v:", v, "therefore nil==v is:", v==nil)
		--print("The isWritten value is:", v.isWritten)

		--Print all entires except for the default add row in one go
		if (not (v == nil)) then

			--If not already on hand, load the project data from the database
			if (v.dataTable == nil) then
				--Declare a lookup table to assist with date conversion
				local months = {
					"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
				}

				local nYear, nMonth, nDay = string.match(v.StartMonth, "(%d%d%d%d)%-(%d%d)%-(%d%d)")
		    nMonth = tonumber( nMonth )

				local dateLetters
				for quay, val in pairs(months) do
					if (nMonth == quay) then
						dateLetters = val .. "-" .. string.match(nYear,"^%d%d(%d%d)")
					end
				end

				v.dataTable = getProjectValues(v.date, v.name)

	    end --Conclude initialisation of data table

			--Now that data structures are in place, insert row into the tableview
			tableView:insertRow{
				rowHeight = 200,
				params = {
					ProjName = v.name,
					ProjType = v.Type,
					SDate = v.StartMonth,
					EDate = v.EndMonth,
					date = v.date,
					dateArray = v.dateArray,
					isDefault = v.isAdd,
					index = v.index
				},
			}
  	end --Close if statement filtering out deleted list items
	end --Conclude generation of non-deault list items

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

	if (scroll) then tableView:scrollToY{ y = scrollLoc, time = 0 }	end
end --Close the populateList function

-- Pass the scene content to an event listener
reportCollate:addEventListener("create",reportCollate)

--Runtime:addEventListener("orientation",positionVis())


return reportCollate

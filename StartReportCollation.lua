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

sharedMem.compoundRowCount = 1
sharedMem.compoundRowList = {}



local defaultRowHeight = 200

function copy1(obj)
  if type(obj) ~= 'table' then return obj end
  local res = {}
  for k, v in pairs(obj) do res[copy1(k)] = copy1(v) end
  return res
end

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

	local labelText = display.newText{
		text = "Title:",
		x = 0,
		y = titleBar.y + titleBar.y*0.2,
		height = titleBar.height,
		fontSize = 22
	}
	labelText:setFillColor( 0 )

	sceneGroup:insert(labelText)

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
          y = rowHeight - defaultRowHeight/2,
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
          y = rowHeight - defaultRowHeight/2,
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
					y = rowHeight - defaultRowHeight/2,
					font = nil,
					fontSize = 20,
					width = display.contentWidth*0.3,
				} )
			projNo:setFillColor( 0 )
			row:insert(projNo)

			--print("Dumping dateSubset:", dump(row.params.dateSubset))
			local projDate = display.newText(
				{
					parent = row,
					text = row.params.dateSubset[next(row.params.dateSubset, nil)], --Read the first element
					x = projType.x - 45,
					y = rowHeight - defaultRowHeight/2,
					font = nil,
					fontSize = 18,
					width = 65,
					align = "center",
				} )
			projDate:setFillColor( 0 )
			projDate:rotate(270)
			row:insert(projDate)

			--Create control buttons to add and delete additional data rows
		  local dateInc = display.newRoundedRect(projDate.x - 25, rowHeight - defaultRowHeight*0.65, 15, 15, 4)
		  dateInc.strokeWidth = 2
		  dateInc:setStrokeColor( 0 )
			row:insert(dateInc)

		  local dateDec = display.newRoundedRect(projDate.x - 25, rowHeight - defaultRowHeight*0.35, 15, 15, 4)
		  dateDec.strokeWidth = 2
		  dateDec:setStrokeColor( 0 )
			row:insert(dateDec)

		  local dateIncButton = widget.newButton( {
		    label="+",
		    x = projDate.x - 25,
		    y = rowHeight - defaultRowHeight*0.65,
				width = 45,
				height = 45,
		  } )
			dateIncButton:rotate(270)
			row:insert(dateIncButton)

		  local dateDecButton = widget.newButton( {
		    label="-",
		    x = projDate.x - 25,
		    y = rowHeight - defaultRowHeight*0.35,
				width = 45,
				height = 45,
		  } )
			--dateDecButton:rotate(270)
			row:insert(dateDecButton)


			local function onInc( event )
				if (event.phase == "ended") then
					for k, v in pairs(sharedMem.PrT) do
						if (v.name == row.params.ProjName) then
							local i = table.indexOf(v.dateArray, v.dateSubset[1]) --
							if (i > #v.dateSubset) then --
								print("On addition, the dateSubset is", dump(v.dateSubset))
								v.date = v.dateArray[i-#v.dateSubset] --2-#v.dateSubset
								v.dateSubset[#v.dateSubset+1] = v.dateArray[i-#v.dateSubset]

								print("Adding a data month - Setting the date to", v.date)

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
							local i = table.indexOf(v.dateSubset, v.date)
							print("The value of the v.date for removal is:", v.date)
							print("The value of the index is:", i)
							if (i > 1) then
								v.date = v.dateSubset[i-1]
								v.dateSubset[i] = nil
								print("Deleting one month - Setting the next date to", v.date)
								local y = tableView:getContentPosition()
								populateList(true,y)
							end
						end
					end
				end
			end

			dateIncButton:addEventListener("touch", onInc)
			dateDecButton:addEventListener("touch", onDec)

			--Create navigation buttons to move the current date forward and backward
		  local dateForward = display.newRoundedRect(projDate.x, rowHeight - defaultRowHeight*0.8, 15, 15, 4)
		  dateForward.strokeWidth = 2
		  dateForward:setStrokeColor( 0 )
			row:insert(dateForward)

		  local dateBack = display.newRoundedRect(projDate.x, rowHeight - defaultRowHeight*0.2, 15, 15, 4)
		  dateBack.strokeWidth = 2
		  dateBack:setStrokeColor( 0 )
			row:insert(dateBack)

		  local dateForwardButton = widget.newButton( {
		    label=">",
		    x = projDate.x,
		    y = rowHeight - defaultRowHeight*0.8,
				width = 45,
				height = 45,
		  } )
			dateForwardButton:rotate(270)
			row:insert(dateForwardButton)

		  local dateBackButton = widget.newButton( {
		    label="<",
		    x = projDate.x,
		    y = rowHeight - defaultRowHeight*0.2,
				width = 45,
				height = 45,
		  } )
			dateBackButton:rotate(270)
			row:insert(dateBackButton)


			local function onBack( event )
				if (event.phase == "ended") then
					for k, v in pairs(sharedMem.PrT) do
						if (v.name == row.params.ProjName) then
							local i = table.indexOf(v.dateArray, v.dateSubset[1])
							if (i > #v.dateSubset) then --i < #v.dateArray
								print("\n\nCalled onBack. The index i has the value:", i)
								print("Removing the first element of the dateSubset")
								table.remove(v.dateSubset, 1) --The current date is the first in the subset; delete it
								print("The dateSubset is now:", dump(v.dateSubset))

								print("The dateArray is", dump(v.dateArray))
								print("The date to append has been set:", v.dateArray[i-(#v.dateSubset+1)])
								v.dateSubset[#v.dateSubset+1] = v.dateArray[i-(#v.dateSubset+1)] --To maintain the length of the subset, retrieve the next date
																						 													 --in the sequence from the dateArray and add on the end of the subset
								v.date = v.dateSubset[#v.dateSubset]
								print("The dateSubset after append is:", dump(v.dateSubset))
								print("Stepped back one month - the current date is now", v.dateSubset[1])

								local y = tableView:getContentPosition()
								populateList(true,y)
							end
						end
					end
				end
			end

			local function onForward( event )
				if (event.phase == "ended") then
					for k, v in pairs(sharedMem.PrT) do
						if (v.name == row.params.ProjName) then
							local i = table.indexOf(v.dateArray, v.dateSubset[1])
							if (i < #v.dateArray) then
								table.remove(v.dateSubset) --Remove the last element from the subset
								table.insert(v.dateSubset, 1, v.dateArray[i+1])
								v.date = v.dateSubset[#v.dateSubset]
								print("Stepping forward one month - Setting the next date to", v.date)

								local y = tableView:getContentPosition()
								populateList(true,y)
							end
						end
					end
				end
			end

			dateForwardButton:addEventListener("touch", onBack)
			dateBackButton:addEventListener("touch", onForward)

			local commentButtonImg = display.newImage('comment_bubble.jpg')
		  commentButtonImg.width = 40
		  commentButtonImg.height = 40
		  commentButtonImg.x = projType.x - 300
		  commentButtonImg.y = rowHeight - defaultRowHeight*0.25
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
			local lightTableDocs = {}
			local monthLabelsDocs = {}
			local currProj --A pointer to the project after lookup

			--Initialise icons for representing document progress
			if not (sharedMem.PrT == nil) then

				--Look up the project by name
				for k, v in pairs(sharedMem.PrT) do
					if (v.name == row.params.ProjName) then
						currProj = v
					end
				end

				--Create variables for layout and formatting purposes
				local xDStart = display.actualContentWidth*0.30
				local yDStart = rowHeight - defaultRowHeight * 0.9
				local xDOffset = 35
				local yDOffset = 28
				local xDPos
				local yDPos
				local i_across = 0
				local i_up = 0
				local first = true

				for reg, date in pairs(currProj.dateSubset) do
				numDocs = currProj.dataTable[date].docLength
				Docs = currProj.dataTable[date].docItems

				yDPos = yDStart - (yDOffset*i_up)
				i_up = i_up + 1

				--Initialise the lightTableDocs structure on first iteration
				if (first) then
					for k, v in pairs(Docs) do
						lightTableDocs[v] = {}
						for reg, date in pairs(currProj.dateSubset) do
							lightTableDocs[v][date] = {}
						end
					end
				else
					--Insert date label for every compound month row displayed after first
					monthLabelsDocs[#monthLabelsDocs+1] = display.newText(
						{
							parent = row,
							text = row.params.dateSubset[#monthLabelsDocs+2],
							x = projType.x - 60,
							y = yDPos,
							font = nil,
							fontSize = 16, --18
							width = 65,
							align = "center",
						} )
					monthLabelsDocs[#monthLabelsDocs]:setFillColor( 0 )
					print("Dumping monthLabelsDocs again:", #monthLabelsDocs)
				end

				for k, v in pairs(Docs) do
					if not (v == nil) then
						xDPos = xDStart + (xDOffset*i_across)
						i_across = i_across + 1

						--Create symbols for all project data points by date
						lightTableDocs[v][date] = display.newImage(row,'white_circle.png')
						lightTableDocs[v][date].x = xDPos
						lightTableDocs[v][date].y = yDPos
						lightTableDocs[v][date].height = 20
						lightTableDocs[v][date].width = 20
						lightTableDocs[v][date]:setFillColor(0.8)

						if (first) then
							local lightLabel = display.newText(
				        {
				          parent = row,
				          text = string.gsub(v, "%(.*%)", ""),
				          x = xDPos,
				          y = rowHeight - defaultRowHeight/2,
				          font = nil,
				          fontSize = 12,
				          width = 135,
				          anchorX = 0,
				        } )
				      lightLabel:setFillColor( 0 )
							lightLabel:rotate(270)

				      row:insert(lightLabel)
						end --Finish text labels
					end --Finish checking entries in Docs for nil
				end --Finish Docs for loop
					i_across = 0 --Reset the x offset value for a new internal row
					first = false
				end --Finish date for loop

				--Iterate over images second time to set colour value for available data

				for k, date in pairs(currProj.dateSubset) do

					for k, u in pairs(currProj.dataTable[date].Document) do

						if not (lightTableDocs[u.ItemDescription][date] == nil) then
						  if (u.Value == 0) then
						    lightTableDocs[u.ItemDescription][date]:setFillColor(0.8)
						  elseif (u.Value == 1) then
						    lightTableDocs[u.ItemDescription][date]:setFillColor(1,0,0)
						  elseif (u.Value == 2) then
						    lightTableDocs[u.ItemDescription][date]:setFillColor(255/256,189/256,0/256)
						  else
						    lightTableDocs[u.ItemDescription][date]:setFillColor(0,1,0)
						  end
						end
						print("Dumping from lightTableDocs:", lightTableDocs[u.ItemDescription][date])
						print("The item description is:", u.ItemDescription)
						print("The date is:", date)
					end

				end


				--Initialise icons for representing general progress data--
				local lightTableProg = {}
				local numProg
				local Prog

				local xPStart = display.actualContentWidth*0.70
				local yPStart = rowHeight - defaultRowHeight * 0.9
				local xPOffset = 35
				local yPOffset = 28
				local xPPos
				local yPPos
				local j_across = 0
				local j_up = 0
				local first = true

				for reg, date in pairs(currProj.dateSubset) do
				numProg = currProj.dataTable[date].progLength
				Prog = currProj.dataTable[date].progItems

				--Initialise the lightTableProg structure on first iteration
				if (first) then
					for k, v in pairs(Prog) do
						lightTableProg[v] = {}
						for reg, date in pairs(currProj.dateSubset) do
							lightTableProg[v][date] = {}
						end
					end
				end

				yPPos = yPStart + (yPOffset*j_up)
				j_up = j_up - 1

				for k, v in pairs(Prog) do
					if not (v == nil) then

						xPPos = xPStart + (xPOffset*j_across)
						j_across = j_across + 1

						lightTableProg[v][date] = display.newImage(row,'white_circle.png')
						lightTableProg[v][date].x = xPPos
						lightTableProg[v][date].y = yPPos
						lightTableProg[v][date].height = 20
						lightTableProg[v][date].width = 20
						lightTableProg[v][date]:setFillColor(0.8)

						if (first) then
							local lightLabel = display.newText(
								{
									parent = row,
									text = string.gsub(v, "%(.*%)", ""),
									x = xPPos,
									y = rowHeight - defaultRowHeight/2,
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
					j_across = 0
					first = false
				end

				--Iterate over images second time to set colour value for available data
				for k, date in pairs(currProj.dateSubset) do
				for j, u in pairs(currProj.dataTable[date].Progress) do

					if not (lightTableProg[u.ItemDescription][date] == nil) then
						if (u.Value == 0) then
							lightTableProg[u.ItemDescription][date]:setFillColor(0.8)
						elseif (u.Value == 1) then
							lightTableProg[u.ItemDescription][date]:setFillColor(1,0,0)
						elseif (u.Value == 2) then
							lightTableProg[u.ItemDescription][date]:setFillColor(255/256,189/256,0/256)
						else
							lightTableProg[u.ItemDescription][date]:setFillColor(0,1,0)
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

	for k, v in pairs(returnData.Document) do
		if (string.match(k, "^%d$") or string.match(k, "^%d%d$")) then
			--Nothing
		else
			returnData.Document[k] = nil
		end
	end

	for k, v in pairs(returnData.Progress) do
		if (string.match(k, "^%d$") or string.match(k, "^%d%d$")) then
			--Nothing
		else
			returnData.Progress[k] = nil
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
				--Initialise dataTable to empty list for holding data across multiple months
				v.dataTable = {}

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

				for k, date in pairs(v.dateArray) do
					v.dataTable[date] = getProjectValues(date, v.name)
				end
	    end --Conclude initialisation of data table

			--Now that data structures are in place, insert row into the tableview
			tableView:insertRow{
				rowHeight = defaultRowHeight + 30*(#v.dateSubset-1),
				params = {
					ProjName = v.name,
					ProjType = v.Type,
					SDate = v.StartMonth,
					EDate = v.EndMonth,
					date = v.date,
					dateArray = v.dateArray,
					dateSubset = v.dateSubset,
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

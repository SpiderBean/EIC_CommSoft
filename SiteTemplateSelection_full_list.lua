--Scene containing selection of site templates

local widget = require "widget"
local composer = require "composer"

local sceneSelect = composer.newScene()

--display.setStatusBar( display.HiddenStatusBar )

local fPath = system.pathForFile( "SoftPlan_001.db", system.DocumentsDirectory )
local db = sqlite3.open(fPath)

--import the widget library
local widget = require( "widget" )

local populateList

--Items to show in our list
local listItems = {
	{ title = "Breakfast", collapsed = true, items = { "Coffee", "Bagel", "Cereal", "Toast" } },
	{ title = "Lunch", collapsed = true, items = { "Sandwich", "Taco", "Noodles", "Soup", "Fries" } },
	{ title = "Dinner", collapsed = true, items = { "Pizza", "Burger", "Steak", "Beef", "Lamb" } },
	{ title = "Desert", collapsed = true, items = { "Apple Pie", "Ice Cream", "Cake", "Chocolate" } },
}

-- create a constant for the left spacing of the row content
local LEFT_PADDING = 10

--Set the background to white
display.setDefault( "background", 0.5, 0.13, 0.7 )

--Create a group to hold our widgets & images
local widgetGroup = display.newGroup()

-- The gradient used by the title bar
--local titleGradient = {
--	type = 'gradient',
--	color1 = { 189/255, 203/255, 220/255, 255/255 },
--	color2 = { 89/255, 116/255, 152/255, 255/255 },
--	direction = "down"
--}

-- Create toolbar to go at the top of the screen
local titleBar = display.newRect(display.contentCenterX, 0, display.actualContentWidth, 60)

titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5

local titleText = display.newText{
  text = "Project Templates",
  x = display.contentCenterX,
  y = titleBar.y + titleBar.y*0.2,
  height = titleBar.height,
  font = native.systemFontBold,
  fontSize = 25
}
titleText:setFillColor( 0 )

-- create a shadow underneath the titlebar (for a nice touch)
--------------------------------------------------------------
--local shadow = display.newImage( "shadow.png" )
--shadow.anchorX = 0; shadow.anchorY = 0		-- TopLeft anchor
--shadow.x, shadow.y = 0, titleBar.y + titleBar.contentHeight * 0.5
--shadow.xScale = 320 / shadow.contentWidth
--shadow.alpha = 0.45

--Text to show which item we selected
--local itemSelected = display.newText( "You selected", 0, 0, native.systemFontBold, 24 )
--itemSelected:setFillColor( 0 )
--itemSelected.x = display.contentWidth * 0.5
--itemSelected.y = display.contentCenterY
--widgetGroup:insert( itemSelected )

-- Forward reference for our back button & tableview
local backButton, list
local rowTitles = {}

local function onCategoryTap(event)
    local row = event.target
    print("tapped Category", row.id)

    for k,v in pairs(rowTitles) do rowTitles[k]=nil end

    listItems[row.id].collapsed = not listItems[row.id].collapsed
    list:deleteAllRows()
    populateList()
end

-- Handle row rendering
local function onRowRender( event )
	local phase = event.phase
	local row = event.row
	local isCategory = row.isCategory

	-- in graphics 2.0, the group contentWidth / contentHeight are initially 0, and expand once elements are inserted into the group.
	-- in order to use contentHeight properly, we cache the variable before inserting objects into the group

	local groupContentHeight = row.contentHeight

	local rowTitle = display.newText( row, rowTitles[row.index], 0, 0, nil, 20 )

        --print("ORR called")

	-- in Graphics 2.0, the row.x is the center of the row, no longer the top left.
	rowTitle.x = LEFT_PADDING + 15
  rowTitle.width = 120--display.contentWidth

	-- we also set the anchorX of the text to 0, so the object is x-anchored at the left
	rowTitle.anchorX = 0

	rowTitle.y = groupContentHeight * 0.5
	rowTitle:setFillColor( 0, 0, 0 )

  row.width = display.contentWidth
  row.x = 0

	if isCategory then

            local categoryBtn = display.newRect( row, 0, 0, row.width, row.height )
            categoryBtn.anchorX, categoryBtn.anchorY = 0, 0
            categoryBtn:addEventListener ( "tap", onCategoryTap )
            categoryBtn.alpha = 0
            categoryBtn.isHitTestable = true
            categoryBtn.id = row.id

            local catIndicator = nil
            if listItems[row.id].collapsed then
                catIndicator = display.newImage( row, "rowArrow.png", false )
            else
                catIndicator = display.newImage( row, "rowArrowDown.png", false )
            end
            catIndicator.x = LEFT_PADDING
            catIndicator.anchorX = 0
            catIndicator.y = groupContentHeight * 0.5

        else
		local rowArrow = display.newImage( row, "rowArrow.png", false )

                rowArrow.x = row.contentWidth - LEFT_PADDING

		-- we set the image anchorX to 1, so the object is x-anchored at the right
		rowArrow.anchorX = 1

		-- we set the image anchorX to 1, so the object is x-anchored at the right
		rowArrow.y = groupContentHeight * 0.5
	end
end

-- Handle row touch events
local function onRowTouch( event )
	local phase = event.phase
	local row = event.target

	if "press" == phase then
		print( "Pressed row: " .. row.index )

	elseif "release" == phase then
		-- Update the item selected text
		itemSelected.text = "You selected: " .. rowTitles[row.index]

		--Transition out the list, transition in the item selected text and the back button

		-- The table x origin refers to the center of the table in Graphics 2.0, so we translate with half the object's contentWidth
		transition.to( list, { x = - list.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
		transition.to( itemSelected, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )
		transition.to( backButton, { alpha = 1, time = 400, transition = easing.outQuad } )

		print( "Tapped and/or Released row: " .. row.index )
	end
end

-- Create a tableView
list = widget.newTableView
{
	top = titleBar.height,
	width = display.contentWidth,
	height = display.actualContentHeight,
  --x = 0,
  --y = 0,
	--maskFile = "mask-320x448.png",
	onRowRender = onRowRender,
	onRowTouch = onRowTouch,
}

--Insert widgets/images into a group
--widgetGroup:insert( list )
widgetGroup:insert( titleBar )
widgetGroup:insert( titleText )
--widgetGroup:insert( shadow )


--Handle the back button release event
local function onBackRelease()
	--Transition in the list, transition out the item selected text and the back button

	-- The table x origin refers to the center of the table in Graphics 2.0, so we translate with half the object's contentWidth
	transition.to( list, { x = 0, time = 400, transition = easing.outExpo } )
	transition.to( itemSelected, { x = display.contentWidth + itemSelected.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
	transition.to( backButton, { alpha = 0, time = 400, transition = easing.outQuad } )
end

--Create the back button
backButton = widget.newButton
{
	width = 298,
	height = 56,
	label = "Back",
	labelYOffset = - 1,
	onRelease = onBackRelease
}
backButton.alpha = 0
backButton.x = display.contentCenterX
backButton.y = display.contentHeight - backButton.contentHeight
widgetGroup:insert( backButton )

function populateList()
    for i = 1, #listItems do
	--Add the rows category title
	rowTitles[ #rowTitles + 1 ] = listItems[i].title

	--Insert the category
	list:insertRow{
                id = i,
		rowHeight = 70,
		rowColor =
		{
			default = { 150/255, 160/255, 180/255, 200/255 },
		},
		isCategory = true,
	}
        print(listItems[i].collapsed )
        if not listItems[i].collapsed then
            --Insert the item
            for j = 1, #listItems[i].items do
                    --Add the rows item title
                    rowTitles[ #rowTitles + 1 ] = listItems[i].items[j]

                    --Insert the item
                    list:insertRow{
                            rowHeight = 40,
                            isCategory = false,
                            listener = onRowTouch
                    }
            end
        end
    end

end

populateList()

--]]

-- Pass the scene content to an event listener
sceneSelect:addEventListener("create",sceneSelect)

return sceneSelect

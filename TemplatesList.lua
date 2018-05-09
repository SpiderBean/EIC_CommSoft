local widget = require "widget"
local composer = require "composer"
local sqlite3 = require "sqlite3"
local sharedMem = require "sharedMem"

local sceneSelect = composer.newScene()

function sceneSelect:create( event )
  local sceneGroup = self.view

  local fPath = system.pathForFile( "SoftPlan_001.db", system.DocumentsDirectory )
  local db = sqlite3.open(fPath)

  local populateList

  local listItems = {}

  local function containsPName(table, element)
    for _, value in pairs(table) do
      if value.name == element then
        return true
      end
    end
    return false
  end

  --Read in template menu items from the database and store locally in a table
  --On first pass, enter all parent items with empty item lists
  for row in db:nrows("SELECT Name, Parent FROM Templates;") do
    if (row.Parent == "None") then
      print("Installing", row.Name, "as a root-level template class")
      listItems[row.Name] = {
        name = row.Name,
        collapsed = true,
        items = {},
        level = 0,
      }
    end
  end
  --On second pass, add all child items to their respective parent lists
  for row in db:nrows("SELECT Name, Parent FROM Templates;") do
    local success = false
    --Start by searching listItems for the parent and attach when found
    if containsPName(listItems, row.Parent) then
      print("Adding", row.Name, "as a first-level child of", row.Parent)
      local Parent = listItems[row.Parent]
      Parent.items[row.Name] = { name = row.Name, collapsed = true, items = {}, level = 1 }
      success = true
    else
      --If parent isn't found in listItems, check the children list of each item
      for _, value in pairs(listItems) do
        if (containsPName(value.items, row.Parent)) then
          print("Adding", row.Name, "as a second-level child belonging to", row.Parent)
          local Parent = value.items[row.Parent]
          Parent.items[row.Name] = { name = row.Name, collapsed = true, level = 2 }
          success = true
        end
      end
      --If the parent still hasn't been found, insert template as non-child item for failsafe
      if ((not success) and (not row.Parent == "None")) then
        print("Invalid parent field", row.Parent, "on template object", row.Name)
        listItems[row.Name] = { name = row.Name, collapsed = true, items = {}, level = 0 }
      end
    end
  end

  ------------------------------------------------------------------------

  -- create a constant for the left spacing of the row content
  local LEFT_PADDING = 10

  --Set the background to white
  display.setDefault( "background", 0.9 )

  --Create a group to hold our widgets & images
  local widgetGroup = display.newGroup()

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

  -------------------------------------------------------

  -- Forward reference for our back button & tableview
  local list
  local rowTitles = {}

  ---------------------------------------------------
  local function onCategoryTap(event)
      local row = event.target
      print("tapped Category", row.id)

      print("Row ID:", rowTitles[row.id])

      --Invert the value of the collapse flag
      listItems[rowTitles[row.id]].collapsed = not listItems[rowTitles[row.id]].collapsed
      for k,v in pairs(rowTitles) do rowTitles[k]=nil end

      list:deleteAllRows()
      populateList()
  end


  -- Handle row rendering
  local function onRowRender( event )
  	local phase = event.phase
  	local row = event.row
  	local isCategory = row.isCategory
    --Cache the contentHeight value before row insertion manipulates it
  	local groupContentHeight = row.contentHeight

    print("row.params.title : ", row.params.title)

    local options = {
      parent = row,
      text = row.params.title,
      x = LEFT_PADDING + 150,
      y = groupContentHeight * 0.5,
      fontSize = 20,
      width = 240,
      height = 0,
      align = "left",
    }

  	local rowTitle = display.newText(options)

  	rowTitle:setFillColor( 0, 0, 0 )

    row.width = display.contentWidth

  	if isCategory then

              local categoryBtn = display.newRect( row, 0, 0, row.width, row.height )
              categoryBtn.anchorX, categoryBtn.anchorY = 0, 0
              categoryBtn:addEventListener ( "tap", onCategoryTap )
              categoryBtn.alpha = 0
              categoryBtn.isHitTestable = true
              categoryBtn.id = row.id

              local catIndicator = nil
              if listItems[row.params.title].collapsed then
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

  	if phase == "press" then
  		print( "Pressed row: " .. row.id )
      print(rowTitles[row.id].name)

  	elseif "release" == phase then
  		print( "Tapped and/or Released row: " .. row.id )

      --Set the shared data variables to be used in the datbase query when
      --populating the template in the next scene
      sharedMem.tempID = rowTitles[row.id].name
      sharedMem.tempType = 'Document'
      sharedMem.isLocked = true

      print("The tempId is", sharedMem.tempID, "and the newProject flag is", sharedMem.newProject)

      --Update the database with the type of the newly created project
      if (sharedMem.newProject) then
        local err = db:exec(
          [[UPDATE Projects SET Type="]] .. sharedMem.tempID .. [[" WHERE Name="]] .. sharedMem.projID .. [[";]]
        )
      end

      print("Exiting SiteTemplateSelection and dumping sharedMem:")
      print(dump(sharedMem))
      composer.gotoScene("RenderTemplate")

  	end
  end



  ---------------------------------------------------

  -- Create a tableView
  list = widget.newTableView
  {
    top = titleBar.height,
    width = display.contentWidth,
    height = display.actualContentHeight,
    onRowRender = onRowRender,
    onRowTouch = onRowTouch,
  }

  --Insert widgets/images into a group
  widgetGroup:insert( list )
  widgetGroup:insert( titleBar )
  widgetGroup:insert( titleText )

  ------------------------------------------------------
  function populateList()
    print("Entered populateList")
    --If re-writing this function for removal of "name" field, replace below for loop with a key,value iterator
    local listLength = 0
    for k, v in pairs(listItems) do
      listLength = listLength+1
    end
    print(listLength)

    for k, v in pairs(listItems) do
      print("Entered for loop")
    --Add the rows category title
      rowTitles[ #rowTitles + 1 ] = k

      print("We're executing in here")

      --Insert the category
      list:insertRow{
        isCategory = true,
        rowHeight = 70,
        rowColor = {
          default = { 150/255, 160/255, 180/255, 200/255 },
        },
        params = {
          title = k,
          level = v.level
        },
      }

      print(listItems[k].collapsed )
      if not listItems[k].collapsed then
        --Insert the item
        for n, m in pairs(listItems[k].items) do
                --Add the rows item title
                rowTitles[ #rowTitles + 1 ] = listItems[k].items[n]

                --Insert the item
                list:insertRow{
                        rowHeight = 40,
                        isCategory = false,
                        listener = onRowTouch,
                        params = {
                          title = n,
                          level = m.level
                        },
                }
        end
      end

    end
  end

  populateList()

  sceneGroup:insert(widgetGroup)
end





-- Pass the scene content to an event listener
sceneSelect:addEventListener("create",sceneSelect)

return sceneSelect

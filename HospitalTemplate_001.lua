-- Definition for the Hospital Template scene

local widget = require "widget"
local composer = require "composer"
local sqlite3 = require "sqlite3"

local sceneHospital = composer.newScene()

-- Open the database to load fields
local fPath = system.pathForFile( "SoftPlan_001.db", system.DocumentsDirectory )
local db = sqlite3.open(fPath)


-- Create function to initialise the scene
function sceneHospital:create()
  local sceneGroup = self.view

  -- Every time we render a new row, call this method
  local function onRowRender (event)
    print(event)
    local row = event.row

    local options_id = {
      parent = row,
      text = "Here STRING is live",--row.params.IteDesc,
      x = 50,
      y = row.height / 2,
      font = native.systemFont,
      fontSize = 14
    }

    print("Creating a new row.id where row.params.IteDesc is",row.params.IteDesc)
    row.IteDesc = display.newText( options_id )
    -- Align the label left and vertically centered
    row.IteDesc.anchorX = 0
    --row.id.x = 0
    --row.id.y = row.height * 0.5

    local options_name = {
      parent = row,
      text = "Here, have a string",--row.params.IteNum,
      x = 100,
      y = row.height / 2,
      font = native.systemFont,
      fontSize = 14
    }

    print("Creating a new row.name where row.params.IteNum is",row.params.IteNum)
    row.IteNum = display.newText( options_name )
  end

  -- Define options and create TableView object
  local table_options = {
    top = 0,
    onRowRender = onRowRender(event)
  }
  local tableView = widget.newTableView( table_options )

  --tableView:insertRow{}

  -- Iterate through the HOSPITAL rows in the database; insert as TableView rows
  for row in db:nrows("SELECT ItemNumber, ItemDescription FROM Templates WHERE TemplateID='HOSPITAL';") do

    --print("The item number is",row.ItemNumber," And the item description is", row.ItemDescription)

    --if not (row.ItemNumber == '') then
      --print("Found something worth displaying!")
      -- Designate top-level item numbers as category rows
      --local isCat = true
      --if (string.match(row.ItemNumber, "%d+[^%.]")) then
      --  isCat = true
      --end

      tableView:insertRow({
        --isCategory = isCat,
        rowHeight = 20,
        --rowColor = { default={ 1, 1, 1 }, over={ 1, 0.5, 0, 0.2 } },
        --lineColor = { 0.5, 0.5, 0.5 },
        params = {
          IteNum = row.ItemNumber,
          IteDesc = row.ItemDescription,
        },
      })

    --end

  end

  --sceneGroup:insert(tableView)

end
----------------------------------------------------------------
----------------------------------------------------------------

----------------------------------------------------------
----------------------------------------------------------

-- Pass the scene content to an event listener
sceneHospital:addEventListener("create",sceneHospital)

return sceneHospital

local widget = require "widget"
local composer = require "composer"
local sqlite3 = require "sqlite3"

local sceneHospital = composer.newScene()

-- Open the database to load fields
local fPath = system.pathForFile( "SoftPlan_001.db", system.DocumentsDirectory )
local db = sqlite3.open(fPath)

-- Create a table to store progress data
local ProgressTable = {}

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

-- Helper function for debugging
----------------------------------------
----------------------------------------
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
----------------------------------------
----------------------------------------

local function onRowRender( event )

  local row = event.row

  local rowHeight = row.contentHeight
  local rowWidth = row.contentWidth

  local rowTitle = display.newText( row, "    " .. row.params.IteNum .. "   " .. row.params.IteDesc, 0, 0, nil, 20 )
  rowTitle:setFillColor( 0 )

  rowTitle.anchorX = 0
  rowTitle.x = 0
  rowTitle.y = rowHeight * 0.5

  row.status = display.newCircle(900, 0.5*rowHeight, 20)
  --setStatusColour(row.params.IteNum, row.status)

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
      --setStatusColour(row.params.IteNum, row.status)
    end
  end

  row.status:addEventListener("touch",row)


end


local tableView = widget.newTableView( {
  onRowRender = onRowRender
} )

for row in db:nrows("SELECT ItemNumber, ItemDescription FROM Templates WHERE TemplateID='HOSPITAL';") do


  if not (row.ItemNumber == '') then

    --Create data entry in table
    ProgressTable[row.ItemNumber] = 0

    local isCat = false
    if (string.match(row.ItemNumber, "^%d$") or string.match(row.ItemNumber, "^%d%d$")) then
      isCat = true
    end

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

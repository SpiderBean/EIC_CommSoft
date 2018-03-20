local widget = require "widget"
local composer = require "composer"
local sqlite3 = require "sqlite3"
local sharedMem = require "sharedMem"

local existingProjects = composer.newScene()

local fPath = system.pathForFile( "SoftPlan_001.db", system.DocumentsDirectory )
local db = sqlite3.open(fPath)

--Create flag to control progression to next screen
local goThrough = false
local start = false
local move = false
local over = false

-- Create toolbar to go at the top of the screen
local titleBar = display.newRect(display.contentCenterX, 0, display.actualContentWidth, 60)

titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5

local titleText = display.newText{
  text = "Existing Projects",
  x = display.contentCenterX,
  y = titleBar.y + titleBar.y*0.2,
  height = titleBar.height,
  font = native.systemFontBold,
  fontSize = 25
}
titleText:setFillColor( 0 )



--This function is called every time a row is created or returns to the screen
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
      fontSize = 20,
      width = display.contentWidth*0.3,
      anchorX = 0,
      align = "center"
    } )
  projName:setFillColor( 0 )


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


  --Create a function to handle touch instructions and load project parameters
  function row:touch( event )
    print("Start:", start, "Move:", move, "Over:", over)

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
      print("Setting the shared memory variables now...")

      --Push project records to shared memory
      sharedMem.loadProject = true
      sharedMem.projID = row.params.ProjName
      sharedMem.tempType = 'Document'
      sharedMem.tempID = row.params.ProjType

      composer.gotoScene("RenderTemplate")
    end
  end

  row:addEventListener("touch",row)
  --tableView:insert(row)
end

--Create a view to contain item rows for the checklist
tableView = widget.newTableView( {
  onRowRender = onRowRender,
  top = titleBar.height,
  height = display.contentHeight - titleBar.height
} )

--Iterate through project table and generate rows for the view
for row in db:nrows("SELECT * FROM Projects;") do

  tableView:insertRow{
    rowHeight = 70,
    params = {
      ProjName = row.Name,
      ProjType = row.Type,
      SDate = row.StartDate,
      EDate = row.EndDate,
    },
  }

end

-- Pass the scene content to an event listener
existingProjects:addEventListener("create",existingProjects)

return existingProjects

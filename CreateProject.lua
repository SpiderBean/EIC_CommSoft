local widget = require "widget"
local composer = require "composer"
local sqlite3 = require "sqlite3"
local sharedMem = require "sharedMem"
local windowsText = require "windowsText"
local RGEasyTextField = require "RGEasyTextField"
local native = require "native"

local createProject = composer.newScene()

function createProject:create( event )
  local sceneGroup = self.view

  -- Open the database to load fields
  local fPath = system.pathForFile( "SoftPlan_001.db", system.DocumentsDirectory )
  local db = sqlite3.open(fPath)

  --Create the page title
  local pageTitle = display.newText {
    text = "Enter details for new project",
    x = display.contentCenterX,
    y = display.contentHeight/8,
    font = nil,
    fontSize = 40,
  }
  sceneGroup:insert(pageTitle)

  --Create the labels for each of the text entry fields
  local nameLabel = display.newText {
    text = "Project Name:",
    x = display.contentWidth*0.3,
    y = display.contentHeight*0.3,
    align = "right"
  }
  sceneGroup:insert(nameLabel)

  local startLabel = display.newText {
    text = "Start Date (yyyy-mm-dd):",
    x = display.contentWidth*0.27,
    y = display.contentHeight*0.4,
    align = "right"
  }
  sceneGroup:insert(startLabel)

  local endLabel = display.newText {
    text = "End Date (yyyy-mm-dd):",
    x = display.contentWidth*0.27,
    y = display.contentHeight*0.5,
    align = "right"
  }
  sceneGroup:insert(endLabel)

  --Create the text entry fields

  local group = display.newGroup()

  local function myListener( self, event )
  	print( event.phase, event.target.text )
  	return true
  end

  local projNameEntry = RGEasyTextField.create( group, display.contentCenterX, display.contentHeight*0.3,
  	display.contentWidth/4, 30,
  	{
  		placeholder = "<name>",
  		fill = {1,1,1}, selStroke = { 1, 0 , 1 }, selStrokeWidth = 4,
  		fontColor = {1, 0, 1}, fontSize = 10,
  		listener = myListener
  	} )

    local startDateEntry = RGEasyTextField.create( group, display.contentCenterX, display.contentHeight*0.4,
    	display.contentWidth/4, 30,
    	{
    		placeholder = "<name>",
    		fill = {1,1,1}, selStroke = { 1, 0 , 1 }, selStrokeWidth = 4,
    		fontColor = {1, 0, 1}, fontSize = 10,
    		listener = myListener
    	} )

      local endDateEntry = RGEasyTextField.create( group, display.contentCenterX, display.contentHeight*0.5,
      	display.contentWidth/4, 30,
      	{
      		placeholder = "<name>",
      		fill = {1,1,1}, selStroke = { 1, 0 , 1 }, selStrokeWidth = 4,
      		fontColor = {1, 0, 1}, fontSize = 10,
      		listener = myListener
      	} )

        sceneGroup:insert(group)

  --local nameEntry = native.newTextField(30, display.contentWidth/4)
  --[[

  local nameEntry = native.newTextField( {
    x = display.contentWidth*0.5,
    y = display.contentHeight*0.3,
    width = display.contentWidth/4,
    height = 30,
  } )

  local startEntry = native.newTextField {
    x = display.contentWidth*0.5,
    y = display.contentHeight*0.4,
    width = display.contentWidth/4,
    height = 30,
  }

  local endEntry = native.newTextField {
    x = display.contentWidth*0.5,
    y = display.contentHeight/0.5,
    width = display.contentWidth/4,
    height = 30,
  }

  ]]

  local buttonRect1 = display.newRoundedRect(display.contentCenterX, display.contentHeight*0.7, 400,100, 12)

  local templateButton = widget.newButton( {
    label="Select an Existing Template",
    width=buttonRect1.width,
    height=buttonRect1.height,
    shape = "buttonRect1",
    x = display.contentCenterX,
    y = display.contentHeight*0.7
  } )

  sceneGroup:insert(buttonRect1)
  sceneGroup:insert(templateButton)

  local function onTemplateButton()
    local detailsAvailable = true

    --Check if project information has been provided
    if (projNameEntry.text == '') then
      print("Required field. Please provide a project name")
      detailsAvailable = false
    end

    if (startDateEntry.text == '') then
      print("Required field. Please provide a start date")
      detailsAvailable = false
    end

    if (endDateEntry.text == '') then
      print("Required field. Please provide an end date")
      detailsAvailable = false
    end

    if (detailsAvailable) then
      local dbErr

      dbErr = db:exec(
        [[INSERT INTO Projects (Name, StartDate, EndDate) VALUES ("]] .. projNameEntry.text .. [[", ']] .. startDateEntry.text .. [[', ']] .. endDateEntry.text .. "');"
     )

      if (dbErr) then print("The insertion operation resulted in", dbErr) end

      sharedMem.newProject = true
      sharedMem.projID = projNameEntry.text
      sharedMem.newSDate = startDateEntry.text
      sharedMem.newEDate = endDateEntry.text

      composer.gotoScene( "SiteTemplateSelection_full_list" )
    end

  end

  templateButton:addEventListener("touch",onTemplateButton)


end


-- Pass the scene content to an event listener
createProject:addEventListener("create",createProject)

return createProject

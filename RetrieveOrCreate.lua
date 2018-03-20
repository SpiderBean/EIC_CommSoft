--Start screen: first scene called by main

local widget = require "widget"
local composer = require "composer"

-- Create handle for the scene content
local retrieveOrCreate = composer.newScene()

-- Define the scene create function which fully defines the screen
function retrieveOrCreate:create( event )
	local sceneGroup = self.view

	-- Calculate offsets for positioning the buttons
	local oneThirdDown = display.viewableContentHeight/3
	local twoThirdDown = oneThirdDown*2

	-- Generate images to frame the buttons
	local buttonRect1 = display.newRoundedRect(display.contentCenterX, oneThirdDown,400,100,12)
	local buttonRect2 = display.newRoundedRect(display.contentCenterX, twoThirdDown,400,100,12)

	sceneGroup:insert(buttonRect1)
	sceneGroup:insert(buttonRect2)

	-- Initialise the buttons
	local retrieveButton = widget.newButton( {
		label="Retrieve Existing Project from Database",
		width=buttonRect1.width,
		height=buttonRect1.height,
		shape = "buttonRect1"
	} )

	local createButton = widget.newButton( {
		label="Create New Project",
		width=buttonRect2.width,
		height=buttonRect2.height,
		shape = "buttonRect2"
	} )

	sceneGroup:insert( retrieveButton )
	sceneGroup:insert( createButton )

	-- Position the buttons on screen
	retrieveButton.x = display.contentCenterX
	retrieveButton.y = oneThirdDown

	createButton.x = display.contentCenterX
	createButton.y = twoThirdDown


	-- Initialise event listeners for template buttons:
	local function onRetrieve()
		composer.gotoScene( "ExistingProjects" )
	end

	local function onCreate()
		composer.gotoScene( "CreateProject" )
	end

	-- Connect event listeners to buttons
	retrieveButton:addEventListener("touch",onRetrieve)
	createButton:addEventListener("touch",onCreate)

end

-- Pass the scene content to an event listener
retrieveOrCreate:addEventListener("create",retrieveOrCreate)

--Runtime:addEventListener("orientation",positionVis())


return retrieveOrCreate

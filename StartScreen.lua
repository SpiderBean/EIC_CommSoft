--Start screen: first scene called by main

local widget = require "widget"
local composer = require "composer"

-- Create handle for the scene content
local scene = composer.newScene()

-- Define the scene create function which fully defines the screen
function scene:create( event )
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
	local siteButton = widget.newButton( {
		label="Enter Data for a Single Project",
		width=buttonRect1.width,
		height=buttonRect1.height,
		shape = "buttonRect1"
	} )

	local collationTemplateButton = widget.newButton( {
		label="Create a Multi-Project Summary Report",
		width=buttonRect2.width,
		height=buttonRect2.height,
		shape = "buttonRect2"
	} )

	sceneGroup:insert( siteButton )
	sceneGroup:insert( collationTemplateButton )

	-- Position the buttons on screen
	siteButton.x = display.contentCenterX
	siteButton.y = oneThirdDown

	collationTemplateButton.x = display.contentCenterX
	collationTemplateButton.y = twoThirdDown


	-- Initialise event listeners for template buttons:
	local function onSiteTemplate()
		composer.gotoScene( "SiteTemplateSelection_full_list" )
	end

	local function onCollationTemplate()
		composer.gotoScene( "StartReportCollation" )
	end

	-- Connect event listeners to buttons
	siteButton:addEventListener("touch",onSiteTemplate)
	collationTemplateButton:addEventListener("touch",onCollationTemplate)

end

-- Pass the scene content to an event listener
scene:addEventListener("create",scene)

--Runtime:addEventListener("orientation",positionVis())


return scene

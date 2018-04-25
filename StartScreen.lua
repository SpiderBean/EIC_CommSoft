--Start screen: first scene called by main

local widget = require "widget"
local composer = require "composer"

-- Create handle for the scene content
local scene = composer.newScene()

--Set the background to white
display.setDefault( "background", 1 )

-- Define the scene create function which fully defines the screen
function scene:create( event )
	local sceneGroup = self.view

	local EIClogo = display.newImage('eic_logo_whiteback.png')
	EIClogo.width = 1075*0.2
	EIClogo.height = 360*0.2
	EIClogo.x = EIClogo.width*0.5
	EIClogo.y = EIClogo.height*0.6

	local titleText = display.newText{
		text = "Commissioning Data Tracking Tool",
		x = display.contentCenterX,
		y = EIClogo.y*1.3,
		height = EIClogo.height,
		font = native.systemFontBold,
		fontSize = 25
	}
	titleText:setFillColor( 0 )

	sceneGroup:insert(EIClogo)
	sceneGroup:insert(titleText)

	-- Calculate offsets for positioning the buttons
	local oneThirdDown = display.viewableContentHeight/3
	local twoThirdDown = oneThirdDown*2

	-- Generate images to frame the buttons
	local buttonRect1 = display.newRoundedRect(display.contentCenterX, oneThirdDown,400,100,12)
	buttonRect1:setFillColor(0.4, 0.9, 0.8)
	local buttonRect2 = display.newRoundedRect(display.contentCenterX, twoThirdDown,400,100,12)
	buttonRect2:setFillColor(0.4, 0.9, 0.8)

	sceneGroup:insert(buttonRect1)
	sceneGroup:insert(buttonRect2)

	-- Initialise the buttons
	local siteButton = widget.newButton( {
		label="Enter Data for a Single Project",
		width=buttonRect1.width,
		height=buttonRect1.height,
		shape = "buttonRect1"
	} )
	siteButton:setFillColor(0.4, 0.9, 0.8)

	local collationTemplateButton = widget.newButton( {
		label="Create a Multi-Project Summary Report",
		width=buttonRect2.width,
		height=buttonRect2.height,
		shape = "buttonRect2"
	} )
	collationTemplateButton:setFillColor(0.4, 0.9, 0.8)

	sceneGroup:insert( siteButton )
	sceneGroup:insert( collationTemplateButton )

	-- Position the buttons on screen
	siteButton.x = display.contentCenterX
	siteButton.y = oneThirdDown

	collationTemplateButton.x = display.contentCenterX
	collationTemplateButton.y = twoThirdDown


	-- Initialise event listeners for template buttons:
	local function onSiteTemplate()
		composer.gotoScene( "RetrieveOrCreate" ) --SiteTemplateSelection_full_list
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

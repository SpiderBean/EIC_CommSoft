--Scene containing selection of site templates

local widget = require "widget"
local composer = require "composer"

local sceneSelect = composer.newScene()

-- Create handle for the scene content to be returned
function sceneSelect:create( event )
	local sceneGroup = self.view

  -- Calculate offsets for positioning the buttons
  local oneThirdDown = display.viewableContentHeight/3
  local twoThirdDown = oneThirdDown * 2

  local testMsg = display.newText("Select a template that suits your needs",
    display.contentCenterX,
    display.contentCenterY,
    native.systemFont,32)

  -- Generate images to frame the buttons
  local buttonRect1 = display.newRoundedRect(display.contentCenterX, twoThirdDown,400,100,12)

  local throughButton = widget.newButton( {
		label="Hospital Template",
		width=buttonRect1.width,
		height=buttonRect1.height,
		shape = "buttonRect1"
	} )

  throughButton.x = display.contentCenterX
  throughButton.y = twoThirdDown

  sceneGroup:insert(buttonRect1)
  sceneGroup:insert(throughButton)

  -- Initialise event listeners for template buttons:
  local function onThroughButton()
    --composer.gotoScene( "HospitalTemplate" )
    composer.gotoScene( "HospitalTemplate" )
  end

  -- Connect event listeners to buttons
  throughButton:addEventListener("touch",onThroughButton)

end

-- Pass the scene content to an event listener
sceneSelect:addEventListener("create",sceneSelect)

return sceneSelect

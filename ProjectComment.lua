local widget = require "widget"
local sqlite3 = require "sqlite3"
local utility = require "utility"
local composer = require "composer"
local sharedMem = require "sharedMem"
local RGEasyTextField = require "RGEasyTextField"

local commentScene = composer.newScene()

function commentScene:create( event )
  local sceneGroup = self.view
  local phase = event.phase
  local parent = event.parent

  local fPath = system.pathForFile( "SoftPlan_001.db", system.DocumentsDirectory )
  local db = sqlite3.open(fPath)

  --Create an encapsulating box to frame the pop-up window
  local envelopeBox = display.newRect(display.contentCenterX, 0, 30, 30)
  envelopeBox.y = display.contentHeight*0.5
  envelopeBox.height = display.contentHeight*0.8
  envelopeBox.width = display.contentWidth*0.7
  envelopeBox:setFillColor(0.7)

  sceneGroup:insert(envelopeBox)

  local titleBar = display.newRect(display.contentCenterX, 0, envelopeBox.width, 60)
  titleBar.y = envelopeBox.height*0.17 -- (0.5*titleBar.height)
  titleBar:setFillColor(0.95)

  local titleText = display.newText{
    text = "Comments:",
    x = display.contentCenterX,
    y = titleBar.y+titleBar.y*0.06,
    height = titleBar.height,
    font = native.systemFont,
    fontSize = 21
  }
  titleText:setFillColor( 0 )

  sceneGroup:insert(titleBar)
  sceneGroup:insert(titleText)

  local buttonBar = display.newRect(display.contentCenterX, 0, envelopeBox.width-10, 70)
  buttonBar.y = envelopeBox.height*1.05 -- (0.5*titleBar.height)
  buttonBar:setFillColor(1)

  sceneGroup:insert(buttonBar)

  local returnRect = display.newRoundedRect(display.contentCenterX,0,170,50,12)
  returnRect.y = display.contentHeight*0.84
  returnRect.strokeWidth = 2
  returnRect:setStrokeColor(0)
  --returnRect:setFillColor(0.5)

  local returnButton = display.newText( {
    text="Return",
    width=returnRect.width,
    height=30,
    align='center'
  } )

  returnButton:setFillColor(0)
  returnButton.y = display.contentHeight*0.845
  returnButton.x = display.contentCenterX

  returnRect:addEventListener("touch", onConfigure)

  sceneGroup:insert(returnRect)
  sceneGroup:insert(returnButton)

end

function commentScene:hide( event )
  local sceneGroup = self.view
  local phase = event.phase
  local parent = event.parent  -- Reference to the parent scene object

  if ( phase == "will" ) then
      -- Call the "resumeGame()" function in the parent scene
      onConfigure()
  end
end

function onConfigure()
  -- By some method such as a "resume" button, hide the overlay
  composer.hideOverlay( "slideRight", 500 )
end

commentScene:addEventListener( "hide", commentScene )
commentScene:addEventListener( "create", commentScene )

return commentScene

-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

-- include Corona's "widget" library
local widget = require "widget"
local composer = require "composer"
local sqlite3 = require "sqlite3"
local lfs = require "lfs"

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

-- Create database if not initialised, otherwise generate handle
local fPath = system.pathForFile( "SoftPlan_001.db", system.DocumentsDirectory )
local db = sqlite3.open(fPath)

function onSystemEvent( event )
  if(event.type == "applicationExit") then
    db:close()
  end
end


composer.gotoScene( "StartScreen" )

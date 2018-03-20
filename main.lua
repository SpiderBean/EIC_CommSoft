-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local widget = require "widget"
local composer = require "composer"
local sqlite3 = require "sqlite3"
local lfs = require "lfs"
local sharedMem = require "sharedMem"

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

--Initialise default flags in shared memory
sharedMem.loadProject = false

function onSystemEvent( event )
  if(event.type == "applicationExit") then
    db:close()
  end
end


composer.gotoScene( "StartScreen" )

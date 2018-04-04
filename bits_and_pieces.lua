--Useful scraps of code--







--
local path = system.pathForFile( "test.csv", system.ResourceDirectory )
local file = io.open( path, "r" )
local table = {}
local contents
if file then
  -- nil if no file found
  contents = file:read( "*a" )
  io.close( file )endprint(contents)
  local k = 1local j = string.len(contents)
  while j > 0 do	i = string.find(contents,",")
    if i~= nil then
      table[#table + 1] = string.sub(contents,k,i-1)
      print(table[#table])
      contents = string.sub(contents,i+1,j)
      j = string.len(contents)
    else
      table[#table + 1] = string.sub(contents,k,j)
      print(table[#table])		j = 0	endend



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




if file then
  -- Link the database file to our handle and close it
  SoftPlan = file
  io.close(file)
else
  -- Initialise the database if no existing file found
  SoftPlan = sqlite3.open(SoftPlan)
end


CODE FOR  DYNAMIC DATABASE LOADING FROM CSV
----------------------------------------
----------------------------------------

-- Check existence of template tables
local isTab
for row in db:nrows("SELECT count(*) FROM sqlite_master WHERE type='table';") do
  isTab = row
  print(dump(isTab))
end

-- If no template tables exist in the database, load them from .csv
local resourcePath = system.pathForFile( nil, system.ResourceDirectory )
local MasterTable = {} -- Table to store all .csv tables

if (isTab["count(*)"] == 0) then
  print(isTab["count(*)"])
  for file in lfs.dir(resourcePath) do
    print(file)
    if string.find(file,".csv") then
      local fileN = string.match(file, "(%w+)%.csv")
      newTable = {}
      local tableSetup = [[CREATE TABLE IF NOT EXISTS "]] .. fileN .. [["( ItemNumber INTEGER PRIMARY KEY, ItemDescription)]]
      local nPath = system.pathForFile(file,system.ResourceDirectory)
      local f = io.open(nPath, "r")
      for line in f:lines() do
        local number, description = string.match(line, "([%d%.]*)%,([%w' ']*)")
        if (not (number == '')) then
          newTable[number] = {description}
          print("The number is",number," And the description is",description)
        end
      end
      MasterTable[#MasterTable+1] = {newTable}
      print("Successfully added a new table")
    end
  end
end

print("Now attempting to dump MasterTable")
print(dump(MasterTable[1]))

-- Insert Lua tables into the database
--for i = 1, #MasterTable do
  --for j = 1, #MasterTable[i] do
    --local q = [[INSERT INTO test VALUES ( NULL, "]] .. MasterTable[i]")]]


-- It's difficult to go straight from .csv to SQL within Lua
-- Start by loading the .csv into a Lua table, then load the table to SQL


db:exec[[
  .mode csv
  .import
]]


--function positionVis()
	--local bap = scene.view

	-- Calculate offsets for positioning the buttons
	--local oneThirdDown = display.viewableContentHeight/3
	--local twoThirdDown = oneThirdDown*2

	-- Position the buttons on screen
	--scene.view.siteButton.x = display.contentCenterX
	--scene.siteButton.y = oneThirdDown

	--sceneGroup.collationTemplateButton.x = display.contentCenterX
	--sceneGroup.collationTemplateButton.y = twoThirdDown

--end


 or (ProgressTable[topLevel] > ProgressTable[currentItem])

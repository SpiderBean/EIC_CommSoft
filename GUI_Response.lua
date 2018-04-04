local M = {}

function M.setStatusColour( refTable, indexA, indexB, targetObject )
  if (refTable[indexA][indexB] == 0) then
    targetObject:setFillColor(0.8)
  elseif (refTable[index][sharedMem.outputDate] == 1) then
    targetObject:setFillColor(1,0,0)
  elseif (refTable[index][sharedMem.outputDate] == 2) then
    targetObject:setFillColor(255/256,189/256,0/256)
  else
    targetObject:setFillColor(0,1,0)
  end
end

return M

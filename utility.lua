--Helper function for generating array of months between two dates
local M = {}

M.months = {
  "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
}

function M.dateToDate( startDate, endDate )
  local dateArray = {}

  local sYear, sMonth, sDay = string.match(startDate, "(%d%d%d%d)%-(%d%d)%-(%d%d)")
  sYear = tonumber( sYear )
  sMonth = tonumber( sMonth )
  sDay = tonumber( sDay )

  local eYear, eMonth, eDay = string.match(endDate, "(%d%d%d%d)%-(%d%d)%-(%d%d)")
  eYear = tonumber( eYear )
  eMonth = tonumber( eMonth )
  eDay = tonumber( eDay )

  --This loop must still execute once when sYear and eYear are equal
  for i = sYear, eYear, 1 do
    if (i == sYear) then
      sM = sMonth
    else
      sM = 1
    end

    if (i == eYear) then
      eM = eMonth
    else
      eM = 12
    end

    print("The loop limits are:", sM, eM )
    for j = sM, eM, 1 do
      year = tostring(i)
      local monthName = M.months[j] .. "-" .. string.match(year,"^%d%d(%d%d)")
      dateArray[#dateArray+1] = monthName
    end
  end

  return dateArray
end

return M

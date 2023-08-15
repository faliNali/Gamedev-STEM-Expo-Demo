local Object = require 'Object'

local Flag = Object:new()

function Flag:new(x, y)
    local f = Object:new('flag', x, y)

    return f
end

return Flag
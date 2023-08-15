local DeathScreen = {}

function DeathScreen:new()
    local ds = {}
    setmetatable(ds, self)
    self.__index = self
end
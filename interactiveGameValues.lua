local values = {}

-- default player speed is 150
-- measured in pixels per second
values.playerSpeed = 240

-- default player jump is 220
-- 110 is enough to go over 1 block
values.playerJump = 110

-- here are the default values (don't change them)
-- in case you want to go back to the default gameplay, change the above
-- values back into these values
values.defaults = {}
values.defaults.playerSpeed = 240
values.defaults.playerJump = 110

return values
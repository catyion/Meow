--!strict
local Util = require('./Util')
local Types = require('./Types')

type Settings = Types.Settings

local Lock = Util.Lock

local Defaults = {}

Defaults.RETRY_ATTEMPTS = 5
Defaults.RETRY_RATE = 1
Defaults.LOCK_TIMEOUT = 60
Defaults.AUTOSAVE_RATE = 30
Defaults.STUDIO_FALLBACK = true
Defaults.BIND_TO_CLOSE = true

return Lock<<Settings>>(Defaults)
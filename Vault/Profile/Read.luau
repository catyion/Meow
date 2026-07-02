--!strict
local Util = require('../Util')
local Types = require('../Types')

type Profile<T> = Types.Profile<T>

local Snapshot = Util.Snapshot

return function<T>(self: Profile<T>): T
    return Snapshot(self._envelope.data)
end
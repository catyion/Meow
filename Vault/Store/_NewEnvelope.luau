--!strict
local Util = require('../Util')
local Types = require('../Types')

type Store<T> = Types.Store<T>
type Envelope<T> = Types.Envelope<T>

local Copy = Util.Copy

return function<T>(self: Store<T>): Envelope<T>
    local now = os.time()

    return {
        version = self._version,
        data = Copy<<T>>(self._template),

        metadata = {
            created = now,
            updated = now,
            revision = 0,
        },
    }
end
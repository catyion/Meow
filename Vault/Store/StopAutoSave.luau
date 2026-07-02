--!strict
local Types = require('../Types')

type Store<T> = Types.Store<T>

return function<T>(self: Store<T>)
    self._autosave = false
end

--!strict
local Types = require('../Types')

type Store<T> = Types.Store<T>

return function<T>(self: Store<T>): (boolean, string)
    local result = true
    local msg = ''

    for key, profile in self._profiles do
        local success, err = profile:SaveAsync()

        if not success then
            msg ..= `[{key}] {tostring(err)}\n`
            result = false
        end
    end

    return result, msg
end

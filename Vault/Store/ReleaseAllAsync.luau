--!strict
local Types = require('../Types')

type Array<T> = Types.Array<T>
type Profile<T> = Types.Profile<T>
type Store<T> = Types.Store<T>

return function<T>(self: Store<T>): (boolean, string)
    local result = true
    local msg = ''
    local profiles: Array<Profile<T>> = {}

    for _, profile in self._profiles do
        table.insert(profiles, profile)
    end

    for _, profile in profiles do
        local success, err = profile:ReleaseAsync()

        if not success then
            msg ..= `[{profile._key}] {tostring(err)}\n`
            result = false
        end
    end

    return result, msg
end

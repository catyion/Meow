--!strict
local Profile = require('../Profile')
local Types = require('../Types')

type Profile<T> = Types.Profile<T>
type Store<T> = Types.Store<T>

return function<T>(self: Store<T>, key: string | Player): (Profile<T>?, string?)
    if typeof(key) == 'Instance' and key:IsA('Player') then
        key = tostring(key.UserId)
    end

    if type(key) ~= 'string' then
        return nil, `Profile key not a string: {tostring(key)}`
    end

    if self._profiles[key] then
        return nil, `Profile already created for key: {key}`
    end

    local envelope, err = self:_LoadEnvelopeAsync(key)

    if not envelope then
        return nil, err or `Failed to load envelope for {key}`
    end

    local profile = Profile.new({
        store = self,
        key = key,
        envelope = envelope,
    })

    self._profiles[key] = profile

    return profile, nil
end

--!strict
local Types = require('./Types')

type Envelope<T> = Types.Envelope<T>
type Store<T> = Types.Store<T>
type Profile<T> = Types.Profile<T>

type Config<T> = {
    store: Store<T>,
    key: string,
    envelope: Envelope<T>
}

local Public = {}
local Profile = {}
Profile.__index = Profile

function Public.new<T>(config: Config<T>): Profile<T>
    local self = setmetatable({}, Profile)

    self._envelope = config.envelope
    self._key = config.key
    self._store = config.store
    self._active = true

    self._dirty = 0
    self._saved = 0
    self._saving = false
    self._queued = false

    return self
end

Profile.SaveAsync = require('@self/SaveAsync')
Profile.ReleaseAsync = require('@self/ReleaseAsync')
Profile.Edit = require('@self/Edit')
Profile.Read = require('@self/Read')

Profile.TransactAsync = require('@self/TransactAsync')

Profile.IsActive = require('@self/IsActive')
Profile.IsDirty = require('@self/IsDirty')

return Public
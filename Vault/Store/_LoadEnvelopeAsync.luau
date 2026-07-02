--!strict
local RunService = game:GetService('RunService')

local Util = require('../Util')
local Types = require('../Types')

type Store<T> = Types.Store<T>
type Envelope<T> = Types.Envelope<T>

local Fill = Util.Fill

return function<T>(self: Store<T>, key: string): (Envelope<T>?, string?)
    local success: boolean? = nil
    local err: string? = nil
    local result: Envelope<T>? = nil
    local locked: true? = nil

    for _ = 1, self._settings.RETRY_ATTEMPTS do
        success, err = pcall(function()
            result = self._datastore:UpdateAsync(key, function(envelope: Envelope<T>?)
                if not envelope then
                    envelope = self:_NewEnvelope()
                    envelope.metadata.session = self:_NewSession()
                    return envelope
                end

                if self:_IsLocked(envelope) then
                    locked = true
                    err = `Profile locked for {key}`
                    return nil
                end

                local changed = Fill(envelope.data, self._template)

                if changed then
                    envelope.metadata.revision += 1
                    envelope.metadata.updated = os.time()
                end
                if envelope.version < self._version then
                    --not rn
                    envelope.version = self._version
                    envelope.metadata.revision += 1
                    envelope.metadata.updated = os.time()
                end

                envelope.metadata.session = self:_NewSession()

                return envelope
            end)
        end)

        if success or locked then break end

        task.wait(self._settings.RETRY_RATE)
    end

    if not success then
        if self._settings.STUDIO_FALLBACK and RunService:IsStudio() then
            warn(`DataStore unavailable for key {key}; falling back to template`, err)
            local envelope = self:_NewEnvelope()
            envelope.metadata.session = self:_NewSession()
            
            return envelope, nil
        end

        return nil, `Datastore unavailable for [{key}]; (err: {err})`
    end

    if locked then
        return nil, `Datastore locked for [{key}]; (err: {err})`
    end

    if not result then
        return nil, `Result could not be found for [{key}]; (err: {err})`
    end

    return result, nil
end
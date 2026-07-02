--!strict
local Util = require('../Util')
local Types = require('../Types')

type Profile<T> = Types.Profile<T>
type Envelope<T> = Types.Envelope<T>

local Copy = Util.Copy

return function<T>(self: Profile<T>, callback: (data: T) -> (boolean?, string?), reason: string?): (boolean, string?)
	if not self._active then
		return false, `Cannot transact inactive profile {self._key}`
	end

	if self._saving then
		return false, `Cannot transact while saving profile {self._key}`
	end

	if self:IsDirty() then
		return false, `Cannot transact dirty profile {self._key}; save local edits first`
	end

	self._saving = true

	local result: Envelope<T>? = nil
	local tx_err: string? = nil
	local call_err: string? = nil
	local committed = false

	for _ = 1, self._store._settings.RETRY_ATTEMPTS do
		result = nil
		tx_err = nil
		call_err = nil
		committed = false

		local success, err = pcall(function()
			result = self._store._datastore:UpdateAsync(self._key, function(envelope: Envelope<T>?)
				if not envelope then
					tx_err = `Could not find envelope for {self._key}`
					return nil
				end

				local session = envelope.metadata.session

				if not session then
					tx_err = `Could not find session for {self._key}`
					return nil
				end

				if session.place_id ~= game.PlaceId or session.job_id ~= game.JobId then
					tx_err = `Session found in another server for {self._key}`
					return nil
				end

				local next_envelope = Copy<<Envelope<T>>>(envelope)
				local ok, msg = callback(next_envelope.data)

				if ok == false then
					tx_err = msg or `Transaction cancelled for {self._key}: {reason or 'no reason given'}`
					return nil
				end

				next_envelope.metadata.revision += 1
				next_envelope.metadata.updated = os.time()
				next_envelope.metadata.session = self._store:_NewSession()

				committed = true

				return next_envelope
			end)
		end)

		if success and committed and result then
			break
		end

		if success and tx_err then
			self._saving = false
			return false, tx_err
		end

		call_err = tostring(err)
		task.wait(self._store._settings.RETRY_RATE)
	end

	self._saving = false

	if not committed then
		return false, `Transaction not successful for {self._key}; (err: {tx_err or call_err or 'unknown'})`
	end

	if not result then
		return false, `Transaction not successful for {self._key}; (err: {tx_err or call_err or 'unknown'})`
	end

	self._envelope = result
	self._dirty += 1
	self._saved = self._dirty
	self._queued = false

	return true, nil
end

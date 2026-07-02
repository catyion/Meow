--!strict
local Util = require('../Util')
local Types = require('../Types')

type Store<T> = Types.Store<T>
type Profile<T> = Types.Profile<T>
type Envelope<T> = Types.Envelope<T>

local Copy = Util.Copy

return function<T>(self: Store<T>, profile: Profile<T>): (boolean, string?)
	local revision = profile._dirty
	local snapshot = Copy<<Envelope<T>>>(profile._envelope)

	local success: boolean? = nil
	local err: unknown = nil
	local committed = false

	for _ = 1, self._settings.RETRY_ATTEMPTS do
		committed = false

		success, err = pcall(function()
			self._datastore:UpdateAsync(profile._key, function(envelope: Envelope<T>?)
				if not envelope then
					err = `Could not find envelope for {profile._key}`
					return nil
				end

				local session = envelope.metadata.session

				if not session then
					err = `Could not find session for {profile._key}`
					return nil
				end

				if session.place_id ~= game.PlaceId or session.job_id ~= game.JobId then
					err = `Session found in another server for {profile._key}`
					return nil
				end

				snapshot.metadata.session = self:_NewSession()
				snapshot.metadata.updated = os.time()

				committed = true

				return snapshot
			end)
		end)

		if success and committed then
			break
		end

		if success and not committed then
			return false, "Profile session was lost"
		end

		task.wait(self._settings.RETRY_RATE)
	end

	if not success then
		return false, `Save not successful for {profile._key}; (err: {err})`
	end

	if not committed then
		return false, "Save was not committed"
	end

	if profile._dirty == revision then
		profile._saved = revision
	else
		profile._saved = revision
		profile._queued = true
	end

	return true, nil
end
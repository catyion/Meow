--!strict
local Util = require('../Util')
local Types = require('../Types')

type Store<T> = Types.Store<T>
type Profile<T> = Types.Profile<T>
type Envelope<T> = Types.Envelope<T>

local Copy = Util.Copy

return function<T>(self: Store<T>, profile: Profile<T>): (boolean, string?)
	local snapshot = Copy<<Envelope<T>>>(profile._envelope)

	local success: boolean?
	local err: string?
	local committed = false

	for _ = 1, self._settings.RETRY_ATTEMPTS do
		committed = false

		success, err = pcall(function()
			self._datastore:UpdateAsync(profile._key, function(envelope: Envelope<T>?)
				if not envelope then
					err = `Envelope could not be found to save for {profile._key}`
					return nil
				end

				local session = envelope.metadata.session

				if not session then
					err = `Session could not be found for {profile._key}`
					return nil
				end

				if session.place_id ~= game.PlaceId or session.job_id ~= game.JobId then
					err = `Session found in another server for {profile._key}`
					return nil
				end

				snapshot.metadata.session = nil
				snapshot.metadata.updated = os.time()

				committed = true

				return snapshot
			end)
		end)

		if success and committed then
			break
		end

		if success and not committed then
			return false, 'Profile session was lost'
		end

		task.wait(self._settings.RETRY_RATE)
	end

	if not success then
		return false, `Release not successful for {profile._key}; (err: {err})`
	end

	if not committed then
		return false, 'Release was not committed'
	end

	return true, 'Release successful'
end
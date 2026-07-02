--!strict
local Types = require('../Types')

type Store<T> = Types.Store<T>
type Envelope<T> = Types.Envelope<T>

return function<T>(self: Store<T>, envelope: Envelope<T>): boolean
	local session = envelope.metadata.session

	if not session then
		return false
	end

	if session.place_id == game.PlaceId and session.job_id == game.JobId then
		return false
	end

	return os.time() - session.last_seen < self._settings.LOCK_TIMEOUT
end
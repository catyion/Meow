--!strict
local Types = require('../Types')

type Store<T> = Types.Store<T>
type Session = Types.Session

return function<T>(self: Store<T>): Session
	local now = os.time()

	return {
		place_id = game.PlaceId,
		job_id = game.JobId,
		last_seen = now,
		started = now,
	}
end
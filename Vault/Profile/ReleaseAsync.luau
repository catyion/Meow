--!strict
local Types = require('../Types')

type Profile<T> = Types.Profile<T>

return function<T>(self: Profile<T>): (boolean, string?)
	if not self._active then
		return true, nil
	end

	while self._saving do
		task.wait()
	end

	local success, err = self._store:_ReleaseProfileAsync(self)

	if not success then
		return false, err
	end

	self._active = false
	self._store._profiles[self._key] = nil

	return true, nil
end
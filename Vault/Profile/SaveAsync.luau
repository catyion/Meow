--!strict
local Types = require('../Types')

type Profile<T> = Types.Profile<T>

return function<T>(self: Profile<T>): (boolean, string?)
	if not self._active then
		return false, `Profile is inactive for {self._key}`
	end

	if self._saved >= self._dirty then
		return true, nil
	end

	while self._saved < self._dirty do
		if not self._active then
			return false, `Profile became inactive for {self._key}`
		end

		if self._saving then
			self._queued = true
			task.wait()
		else
			self._saving = true

			local success, err = self._store:_SaveProfileAsync(self)

			self._saving = false

			if not success then
				return false, err
			end

			if self._queued then
				self._queued = false
			end
		end
	end

	return true, nil
end
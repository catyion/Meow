--!strict
local Types = require('../Types')

type Profile<T> = Types.Profile<T>

return function<T>(self: Profile<T>): boolean
	return self._dirty ~= self._saved
end
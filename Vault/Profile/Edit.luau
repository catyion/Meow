--!strict
local Util = require('../Util')
local Types = require('../Types')
type Profile<T> = Types.Profile<T>

local Copy = Util.Copy

return function<T>(self: Profile<T>, callback: (data: T) -> (), reason: string?): (boolean, string?)
    if not self:IsActive() then
		return false, `Cannot mutate inactive profile {self._key}`
    end

    local before = Copy(self._envelope.data)
	local success, err = pcall(callback, self._envelope.data)

	if not success then
		self._envelope.data = before
		
		return false, `Mutation failed for {self._key}: {reason or 'no reason given'} [{err}]`
	end

	self._dirty += 1
	self._envelope.metadata.revision += 1
	self._envelope.metadata.updated = os.time()

	return true, nil
end
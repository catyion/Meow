--!strict
local Types = require('../Types')

type Store<T> = Types.Store<T>

return function<T>(self: Store<T>)
    if self._autosave then
        return
    end

    self._autosave = true

    task.spawn(function()
        while self._autosave do
            local success, err = self:SaveAllAsync()

            if not success then
                warn(err)
            end

            task.wait(self._settings.AUTOSAVE_RATE)
        end
    end)
end

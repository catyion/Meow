--!strict
local Table = {}

local function Copy<S>(source: any): S
    if type(source) ~= 'table' then
        return source
    end

    local copy = table.clone(source)

    for key, value in copy do
        if type(value) == 'table' then
            copy[key] = Copy(value)
        end
    end

    return copy
end

local function Lock<S>(source: any): S
    if type(source) ~= 'table' then
        return source
    end

    for key, value in source do
        if type(value) == 'table' then
            source[key] = Lock(value)
        end
    end

    return table.freeze(source)
end

local function Snapshot<S>(source: any): S
    return Lock(Copy(source))
end

local function Fill(source: any, template: any): boolean
	local changed = false

	if type(source) ~= "table" or type(template) ~= "table" then
		return false
	end

	for key, template_value in template do
		local source_value = source[key]

		if source_value == nil then
			source[key] = Copy(template_value)
			changed = true
		elseif type(source_value) == "table" and type(template_value) == "table" then
			if Fill(source_value, template_value) then
				changed = true
			end
		end
	end

	return changed
end

local function Apply(source: any, patch: any): boolean
	local changed = false

	if type(source) ~= "table" or type(patch) ~= "table" then
		return false
	end

	for key, value in patch do
		if value ~= nil then
			if type(source[key]) == "table" and type(value) == "table" then
				if Apply(source[key], value) then
					changed = true
				end
			else
				source[key] = Copy(value)
				changed = true
			end
		end
	end

	return changed
end

Table.Copy = Copy
Table.Lock = Lock
Table.Snapshot = Snapshot
Table.Fill = Fill
Table.Apply = Apply

return Table

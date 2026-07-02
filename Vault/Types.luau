--!strict
type function Partial(object: type)
	local tag = object.tag

	if tag == "union" or tag == "intersection" then
		local result

		for _, component in object:components() do
			if component.tag == "nil" then
				continue
			end
			if result == nil then
				result = component
				continue
			end

			result = types.unionof(result, component)
		end

		return types.optional(result :: type)
	elseif tag == "table" then
		local result = types.newtable()
		local indexer = object:indexer()

		if indexer ~= nil then
			result:setreadindexer(indexer.index, Partial(indexer.readresult))
			result:setwriteindexer(indexer.index, indexer.writeresult)
		end

		for key, prop in object:properties() do
			local partialRead = Partial(prop.read)
			if prop.read ~= prop.write then
				result:setreadproperty(key, partialRead)
				result:setwriteproperty(key, prop.write)
			else
				result:setproperty(key, partialRead)
			end
		end

		return result
	end

	return types.optional(object)
end

export type Dictionary<K = string, V = Profile<any>> = {[K]: V}
export type Array<T = Profile<any>> = {T}

export type Session = {
	place_id: number,
	job_id: string,
	started: number,
	last_seen: number,
}

export type Metadata = {
	created: number,
	updated: number,
	revision: number,
	session: Session?,
}

export type Envelope<T> = {
	version: number,
	data: T,
	metadata: Metadata,
}

export type Settings = {
	RETRY_ATTEMPTS: number,
	RETRY_RATE: number,
	LOCK_TIMEOUT: number,
	AUTOSAVE_RATE: number,
	STUDIO_FALLBACK: boolean,
	BIND_TO_CLOSE: boolean,
}

export type Options = Partial<Settings>

export type Config<T> = {
	name: string,
	template: T,
	version: number,
	settings: Options?,
}

export type Edit<T> = (data: T) -> ()
export type Tx<T> = (data: T) -> (boolean?, string?)

export type Profile<T> = {
	read _key: string,
	read _store: Store<T>,
	_envelope: Envelope<T>,
	_active: boolean,

	_dirty: number,
	_saved: number,
	_saving: boolean,
	_queued: boolean,

	read SaveAsync: (self: Profile<T>) -> (boolean, string?),
	read ReleaseAsync: (self: Profile<T>) -> (boolean, string?),
	read IsActive: (self: Profile<T>) -> boolean,
	read IsDirty: (self: Profile<T>) -> boolean,
	read Read: (self: Profile<T>) -> T,
	read Edit: (self: Profile<T>, callback: Edit<T>, reason: string?) -> (boolean, string?),
	read TransactAsync: (self: Profile<T>, callback: Tx<T>, reason: string?) -> (boolean, string?),
}

export type Store<T> = {
	read _name: string,
	read _template: T,
	read _version: number,
	read _datastore: DataStore,
	read _settings: Settings,

	_profiles: Dictionary<string, Profile<T>>,
	_autosave: boolean,

	read _IsLocked: (self: Store<T>, envelope: Envelope<T>) -> boolean,
	read _NewSession: (self: Store<T>) -> Session,
	read _NewEnvelope: (self: Store<T>) -> Envelope<T>,
	read _LoadEnvelopeAsync: (self: Store<T>, key: string) -> (Envelope<T>?, string?),
	read _SaveProfileAsync: (self: Store<T>, profile: Profile<T>) -> (boolean, string?),
	read _ReleaseProfileAsync: (self: Store<T>, profile: Profile<T>) -> (boolean, string?),

	read LoadAsync: (self: Store<T>, key: string | Player) -> (Profile<T>?, string?),
	read SaveAllAsync: (self: Store<T>) -> (boolean, string),
	read ReleaseAllAsync: (self: Store<T>) -> (boolean, string),
	read StartAutoSave: (self: Store<T>) -> (),
	read StopAutoSave: (self: Store<T>) -> (),
}

return nil

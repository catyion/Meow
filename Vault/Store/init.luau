--!strict
local DataStoreService = game:GetService('DataStoreService')

local Util = require('./Util')
local Defaults = require('./Defaults')
local Types = require('./Types')

type Store<T> = Types.Store<T>
type StoreConfig<T> = Types.StoreConfig<T>
type Settings = Types.Settings
type Options = Types.Options

local Copy = Util.Copy
local Apply = Util.Apply

local Public = {}
local Store = {}
Store.__index = Store

local function BuildSettings(options: Options?): Settings
    local result = Copy<<Settings>>(Defaults)

    if settings then
        Apply(result, settings)
    end

    return result
end

function Public.new<T>(config: StoreConfig<T>): Store<T>
    local self = setmetatable({}, Store)

    self._name = config.name
	self._template = config.template
	self._version = config.version
    self._datastore = DataStoreService:GetDataStore(config.name)

    self._settings = BuildSettings(config.settings)

    self._profiles = {}
    self._autosave = false

    self:StartAutoSave()

    if self._settings.BIND_TO_CLOSE then
        game:BindToClose(function()
            self:ReleaseAllAsync()
        end)
    end

    return self
end

Store.LoadAsync = require('@self/LoadAsync')
Store.SaveAllAsync = require('@self/SaveAllAsync')
Store.ReleaseAllAsync = require('@self/ReleaseAllAsync')

Store.StartAutoSave = require('@self/StartAutoSave')
Store.StopAutoSave = require('@self/StopAutoSave')

Store._IsLocked = require('@self/_IsLocked')
Store._LoadEnvelopeAsync = require('@self/_LoadEnvelopeAsync')
Store._SaveProfileAsync = require('@self/_SaveProfileAsync')
Store._ReleaseProfileAsync = require('@self/_ReleaseProfileAsync')
Store._NewEnvelope = require('@self/_NewEnvelope')
Store._NewSession = require('@self/_NewSession')

return Public
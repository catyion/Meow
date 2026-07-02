--!strict
local Types = require('@self/Types')

export type Store<T> = Types.Store<T>
export type Profile<T> = Types.Profile<T>
export type StoreConfig<T> = Types.StoreConfig<T>
export type Options = Types.Options

local Vault = require('@self/Store')

return Vault

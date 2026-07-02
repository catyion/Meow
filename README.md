# this readme is ai generated to just make it easier to explain rn. also name is placeholder just for example purposes

# Vault

Minimal Roblox Luau DataStore profile module.

## Current features
- load a profile by key or `Player`
- local edits with `:Edit()`
- atomic single-key writes with `:TransactAsync()`
- session locking
- autosave
- bind-to-close release

## Example
```luau
local Vault = require(path.To.Vault)

local store = Vault.new({
    name = "Players",
    template = {
        coins = 0,
        level = 1,
        xp = 0,
    },
    version = 1,
})

local profile, err = store:LoadAsync("123")
if not profile then
    warn(err)
    return
end

profile:Edit(function(data)
    data.coins += 10
end, "Reward")

local ok, saveErr = profile:SaveAsync()
if not ok then
    warn(saveErr)
end
```

## Planned
- schema/validation hooks
- migrations
- codecs for compressed storage
- larger transaction/ledger systems

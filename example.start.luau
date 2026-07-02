--!strict
local Players = game:GetService("Players")
local Vault = require("./Vault")

local template = {
    coins = 10,
    level = 1,
    xp = 0,
}

type Data = typeof(template)

local store = Vault.new<<Data>>({
    name = "Test",
    template = template,
    version = 1,
    settings = {
        STUDIO_FALLBACK = true,
    },
})

local profiles: {[Player]: Vault.Profile<Data>} = {}

local function onPlayerAdded(player: Player)
    local profile, err = store:LoadAsync(tostring(player.UserId))
    if not profile then
        warn(`Failed to load profile for {player.Name}: {err}`)
        player:Kick("Failed to load data.")
        return
    end

    profiles[player] = profile

    local ok, editErr = profile:Edit(function(data)
        data.coins += 25
    end, "JoinBonus")

    if not ok then
        warn(editErr)
        return
    end

    local data = profile:Read()
    print(player.Name, data.coins, data.level, data.xp)
end

local function onPlayerRemoving(player: Player)
    local profile = profiles[player]
    profiles[player] = nil

    if not profile then
        return
    end

    local ok, err = profile:ReleaseAsync()
    if not ok then
        warn(`Failed to release profile for {player.Name}: {err}`)
    end
end

for _, player in Players:GetPlayers() do
    task.spawn(onPlayerAdded, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
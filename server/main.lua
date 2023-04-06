RPX = exports["rpx-core"]:GetObject()

local playerCoords = {}
local Players_Dead = {}
math.randomseed(os.time())

RegisterServerEvent("redemrp_respawn:server:PayForRespawn", function()
    local src = source
    local Player = RPX.GetPlayer(src)
    if Player then
        Player.func.RemoveMoney("cash", Config.RespawnPrice)
    end
end)


RegisterServerEvent("rpx-spawn:server:ReviveTarget", function(id)
    local src = source
    local Player = RPX.GetPlayer(src)
    if Player.permissiongroup == "superadmin" or Player.permissiongroup == "admin" or Player.permissiongroup == "mod" then
        if id ~= 0 and id ~= nil then
            TriggerClientEvent('rpx-spawn:client:Revive', id)
        else
            TriggerClientEvent('rpx-spawn:client:Revive', src)
        end
    end
end)


AddEventHandler("rpx-spawn:server:ReviveTargetPlayer", function(id)
    local src = source
    if id ~= 0 and id ~= nil then
        local Player = RPX.GetPlayer(id)
        if Player then
            TriggerClientEvent('rpx-spawn:client:Revive', tonumber(id) )
        end
    end
end)

exports["rpx-core"]:CreateCallback("redemrp_respawn:IsPlayerDead", function(source, cb)
    if Player(source).state.isDead then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent("redemrp_respawn:IsPlayerDead", function(playerId, cb)
    if Player(playerId).state.isDead then
        cb(true)
    else
        cb(false)
    end
end)

AddStateBagChangeHandler("isDead", nil, function(bagName, key, value) 
    local source = GetPlayerFromStateBagName(bagName)
    -- Whoops, we don't have a valid entity!
    if source == 0 then return end
    local Player = RPX.GetPlayer(source)
    if Player then
        print("State bag change handler isDead = "..tostring(value).." for "..source)
        Player.func.SetMetaData("isDead", value)
    end
end)
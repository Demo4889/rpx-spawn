local RPX = exports["rpx-core"]:GetObject()

RegisterServerEvent("redemrp_respawn:server:PayForRespawn", function()
    local src = source
    local Player = RPX.GetPlayer(src)
    if Player then
        Player.RemoveMoney("cash", Config.RespawnPrice)
    end
end)

RegisterCommand("revive", function(source, args, rawCommand)
    local src = source
    local Player = RPX.GetPlayer(src)
    if not Player then return end
    if Player.permissiongroup == "superadmin" or Player.permissiongroup == "admin" or Player.permissiongroup == "mod" then
        if args[1] then
            TriggerClientEvent('rpx-spawn:client:Revive', args[1])
        else
            TriggerClientEvent('rpx-spawn:client:Revive', src)
        end
    end
end, false)

AddStateBagChangeHandler("isDead", nil, function(bagName, key, value) 
    local source = GetPlayerFromStateBagName(bagName)
    if source == 0 then return end

    local char = RPX.GetPlayer(source)
    if not char then return end

    print("State bag change handler isDead = "..tostring(value).." for "..source)
    char.SetMetaData("isDead", value)
end)
local newCharacter = false
local pressed = false
local revived = false
local minimaptype = GetResourceKvpInt('minimaptype') == 0 and 2 or 1

RegisterCommand("minimap", function(source, args)
    if minimaptype == 1 then
        SetResourceKvpInt('minimaptype', 2)
        minimaptype = 2
        SetMinimapType(2)
    else
        SetResourceKvpInt('minimaptype', 1)
        minimaptype = 1
        SetMinimapType(1)

    end
end)

RegisterCommand("kys", function(source, args, rawCommand) -- KILL YOURSELF COMMAND
    local src = source
    Citizen.InvokeNative(0x697157CED63F18D4, PlayerPedId(), 500000, false, true, true)
end, false)

RegisterNetEvent("rpx-spawn:client:Revive", function(c)
    DoScreenFadeOut(500)
    Wait(500)
    revived = true
    EndDeathCam()
    DestroyAllCams(true)
    Wait(1000)
    TriggerEvent("rpx-spawn:client:SpawnAtPosition", GetEntityCoords(PlayerPedId()))
end)

RegisterCommand("revive", function(source, args, rawCommand)
    if args[1] ~= nil then
        TriggerServerEvent('rpx-spawn:server:ReviveTarget', tonumber(args[1]))
    else
        TriggerServerEvent('rpx-spawn:server:ReviveTarget', source)
    end
end, false)

RegisterNetEvent("rpx-spawn:client:KillPlayer", function()
    Citizen.InvokeNative(0x697157CED63F18D4, PlayerPedId(), 500000, false, true, true)
end)

local ConfirmingRespawn = false
local onPlayerDead = false
Citizen.CreateThread(function()
    while true do
        Wait(0)
        while IsPlayerDead(PlayerId()) and not revived do
            Wait(1)
            exports['rpx-core']:showDeathNotif("YOU DIED", "Ledger_Sounds", "INFO_HIDE", 4000)
            local timer = GetGameTimer()+Config.RespawnTime
            while timer >= GetGameTimer() and not revived do
                if revived == false then

                    if onPlayerDead == false then
                    
                        DisplayHud(false)
                        DisplayRadar(false)

                        --TriggerServerEvent("redemrp_respawn:DeadTable", "add")
                        LocalPlayer.state:set('isDead', true, true)
                        StartDeathCam()
                        onPlayerDead = true
                    end

                    Wait(1)
                    ProcessCamControls()
                    HideHudAndRadarThisFrame()
                    DrawTxt(Config.LocaleTimer .. " " .. tonumber(string.format("%.0f", (((GetGameTimer() - timer) * -1)/1000))), 0.50, 0.80, 0.7, 0.7, true, 255, 255, 255, 255, true)
                else
                    break
                end
            end
            while true do
                Wait(0)
                ProcessCamControls()
                HideHudAndRadarThisFrame()
                if not ConfirmingRespawn then
                    DrawTxt("Press E to Respawn (~e~$"..Config.RespawnPrice.."~COLOR_WHITE~)", 0.50, 0.45, 0.8, 0.8, true, 255, 255, 255, 255, true)
                else
                    DrawTxt("Are you sure~n~you want to respawn for ~e~$"..Config.RespawnPrice.."~COLOR_WHITE~?~n~(~pa~E~q~) Yes~n~(~pa~BACKSPACE~q~) No", 0.50, 0.45, 0.8, 0.8, true, 255, 255, 255, 255, true)
                end
                if IsControlJustReleased(0, 0xDFF812F9) then
                    if not ConfirmingRespawn then
                        ConfirmingRespawn = true
                    else
                        OpenSpawnSelection()
                        revived = false
                        onPlayerDead = false
                        --TriggerServerEvent("redemrp_respawn:DeadTable", "remove")
                        LocalPlayer.state:set('isDead', false, true)
                        Wait(25)
                        TriggerServerEvent("redemrp_respawn:server:PayForRespawn")
                        --TriggerServerEvent("redemrp_inventory:server:PlayerRespawned")
                        break
                    end
                end
                if IsControlJustReleased(0, 0x156F7119) then
                    if ConfirmingRespawn then
                        ConfirmingRespawn = false
                    end
                end
                if revived then
                    onPlayerDead = false
                    --TriggerServerEvent("redemrp_respawn:DeadTable", "remove")
                    LocalPlayer.state:set('isDead', false, true)
                    break
                end
            end
        end
    end
end)

local SpawnSelectionOpen = false

function OpenSpawnSelection()
    SpawnSelectionOpen = true
    CreateThread(function()
        while SpawnSelectionOpen do
            Wait(0)
            HideHudAndRadarThisFrame()
        end
    end)
    DoScreenFadeOut(100)
    Wait(100)
    ClearFocus()
    RenderScriptCams(false, false, 0, true, false)
    DestroyAllCams(true)
    cam = nil
    Wait(100)

    local pos = vector3(2813.0659, -1335.537, 46.282081)
    SetEntityCoords(PlayerPedId(), pos)

    Wait(50)
    selectcamera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 2827.71, -1357.64, 80.57, 0.00, 0.00, 0.00, GetGameplayCamFov())
    SetCamActive(selectcamera, true)
    RenderScriptCams(true, false, 0, true, false)
    PointCamAtCoord(selectcamera, 2827.71, -1357.64, 80.57+10.0)
    Wait(100)
    DoScreenFadeIn(250)

    SendNUIMessage({
        type = 1
    })
    SetNuiFocus(true, true)
    --AnimpostfxStop("DeathFailMP01")
    --ShakeGameplayCam("DRUNK_SHAKE", 0.0)

    Citizen.InvokeNative(0x71BC8E838B9C6035, PlayerPedId())
end

RegisterNetEvent("rpx-spawn:client:NewCharacterSpawn", function()
    OpenSpawnSelection()
    newCharacter = true
end)


-- TODO: Remove this command
RegisterCommand("respawn", function(source, args)
    OpenSpawnSelection()
end)

RegisterNetEvent("rpx-spawn:client:SpawnAtPosition", function(coords)
    RenderScriptCams(false, true, 100, true, false)
    DestroyCam(selectcamera)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 2
    })
    FreezeEntityPosition(ped, false)

    ShutdownLoadingScreen()
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 59.95, true, false, false)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
    ClearPedTasksImmediately(ped)
    ClearPlayerWantedLevel(PlayerId())
    FreezeEntityPosition(ped, false)
    SetPlayerInvincible(PlayerId(), false)
    SetEntityVisible(ped, true)
    SetEntityCollision(ped, true)
    TriggerEvent('playerSpawned')
    Citizen.InvokeNative(0xF808475FA571D823, true)
    NetworkSetFriendlyFireOption(true)
    RenderScriptCams(false, true, 1000, true, true)
    DestroyAllCams()
	FreezeEntityPosition(PlayerPedId(), false)

    DisplayHud(true)
    DisplayRadar(true)
    DoScreenFadeIn(250)
    revived = false
    SetMinimapType(minimaptype)
    Citizen.InvokeNative(0x4D51E59243281D80, PlayerId(), true, 0, false)
end)

RegisterNUICallback('select', function(data, cb)
    DoScreenFadeOut(250)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 2
    })
    Wait(250)
    RenderScriptCams(false, true, 100, true, false)
    DestroyCam(selectcamera)
    local spawn = data.selected
    local coords = Config[spawn][math.random(#Config[spawn])]
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    FreezeEntityPosition(ped, false)

    ShutdownLoadingScreen()
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 59.95, true, true, false)
    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
    ClearPedTasksImmediately(ped)
    ClearPlayerWantedLevel(PlayerId())
    FreezeEntityPosition(ped, false)
    SetPlayerInvincible(PlayerId(), false)
    SetEntityVisible(ped, true)
    SetEntityCollision(ped, true)
    TriggerEvent('playerSpawned', spawn)
    Citizen.InvokeNative(0xF808475FA571D823, true)
    NetworkSetFriendlyFireOption(true)
    RenderScriptCams(false, true, 1000, true, true)
    DestroyAllCams()
	FreezeEntityPosition(PlayerPedId(), false)

    DisplayHud(true)
    DisplayRadar(true)
    Wait(500)
    DoScreenFadeIn(250)
    SpawnSelectionOpen = false
    if newCharacter then
        Wait(1000)
        exports["rpx-cinematic"]:StartCinematic("Intro")
    end
end)

--=============================================================-- DRAW TEXT SECTION--=============================================================--
function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)


    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
    Citizen.InvokeNative(0xADA9255D, 1);
	SetTextFontForCurrentCommand(7)
    DisplayText(str, x, y)
end

function CreateVarString(p0, p1, variadic)
    return Citizen.InvokeNative(0xFA925AC00EB830B9, p0, p1, variadic, Citizen.ResultAsLong())
end
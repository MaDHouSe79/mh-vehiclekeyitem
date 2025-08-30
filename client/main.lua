local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local isLoggedIn = false
local config = {}

local function Trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

local function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(1)
    end
end

local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(1) end
    end
end

local function HasItem(plate)
    if isLoggedIn then
        for _, itemData in pairs(PlayerData.items) do
            if itemData.name:lower() == "vehiclekey" and Trim(itemData.info.plate) == Trim(plate) then
                return true
            end
        end
    end
    return false
end

local function BlinkVehiclelightsAndToggleDoorLocks(vehicle, state)
	local model = 'prop_cuff_keys_01'
	LoadAnimDict('anim@mp_player_intmenu@key_fob@')
	LoadModel(model)
	local object = CreateObject(model, 0, 0, 0, true, true, true)
	while not DoesEntityExist(object) do Wait(1) end
	AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
	TaskPlayAnim(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, -8.0, -1, 52, 0, false, false, false)
	TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.2)
	SetVehicleLights(vehicle, 2)
	Wait(150)
	SetVehicleLights(vehicle, 0)
	Wait(150)
	SetVehicleLights(vehicle, 2)
	Wait(150)
	SetVehicleLights(vehicle, 0)
	TriggerServerEvent('mh-vehiclekeyitem:server:setVehLockState', VehToNet(vehicle), state)
	SetVehicleDoorsLocked(vehicle, state)
	if IsEntityPlayingAnim(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3) then
		DeleteObject(object)
		StopAnimTask(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0)
	end
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        TriggerServerEvent('mh-vehiclekeyitem:server:onjoin')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        PlayerData = {}
        isLoggedIn = false
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    isLoggedIn = false
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    TriggerServerEvent('mh-vehiclekeyitem:server:onjoin')
end)

RegisterNetEvent('mh-vehiclekeyitem:client:onjoin', function(data)
    config = data
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
end)

RegisterNetEvent('QBCore:Client:UpdateObject', function()
    QBCore = exports['qb-core']:GetCoreObject()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

RegisterNetEvent('mh-vehiclekeyitem:client:GiveKey', function(plate)
    TriggerServerEvent('mh-vehiclekeyitem:client:GiveKey', plate)
end)

RegisterNetEvent('mh-vehiclekeyitem:client:UseVehicleKey', function(item)
    local hasKey, vehicle = false, nil
    if isLoggedIn and item ~= nil and item.name == "vehiclekey" and item.info ~= nil and item.info.plate ~= nil then
        if GetVehiclePedIsIn(PlayerPedId()) ~= 0 then
            vehicle = GetVehiclePedIsIn(PlayerPedId())
            if vehicle ~= -1 and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and Trim(item.info.plate) == Trim(QBCore.Functions.GetPlate(vehicle)) then
                hasKey = true
            end
        else
            vehicle, _ = QBCore.Functions.GetClosestVehicle(GetEntityCoords(PlayerPedId()))
            if vehicle ~= -1 and Trim(item.info.plate) == Trim(QBCore.Functions.GetPlate(vehicle)) then
                hasKey = true
            end
        end
        if vehicle ~= nil and vehicle ~= -1 and hasKey then
            BlinkVehiclelightsAndToggleDoorLocks(vehicle, false)
            TriggerEvent('qb-vehiclekeys:client:AddKeys', item.info.plate)
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn then
            local ped = PlayerPedId()
            if GetVehiclePedIsIn(ped) ~= 0 then
                local vehicle = GetVehiclePedIsIn(ped)
                if GetPedInVehicleSeat(vehicle, -1) == ped then
                    local plate = QBCore.Functions.GetPlate(vehicle)
                    if not HasItem(plate) then
                        TriggerEvent('qb-vehiclekeys:client:RemoveKeys', plate)
                        if GetIsVehicleEngineRunning(vehicle) then
                            sleep = 0
                            SetVehicleEngineOn(vehicle, false, true, false)
                        end
                    end
                end
            else
                local vehicle, distance = QBCore.Functions.GetClosestVehicle(GetEntityCoords(ped))
                if vehicle ~= -1 and distance < 2.6 then
                    sleep = 0
                    local plate = QBCore.Functions.GetPlate(vehicle)
                    if not HasItem(plate) then
                        TriggerEvent('qb-vehiclekeys:client:RemoveKeys', plate)
                    else
                        TriggerEvent('qb-vehiclekeys:client:AddKeys', plate)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
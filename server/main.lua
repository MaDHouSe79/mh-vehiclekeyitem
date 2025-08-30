local QBCore = exports['qb-core']:GetCoreObject()
local VehicleModelName = {}

------------------------------------------------------------------------------------------------
--- you can add your own inventory if you want.
function AddKeyItem(id, item, amount, info)
    if SV_Config.Inventory == "qb-inventory" then
        if GetResourceState("qb-inventory") ~= 'missing' then
            exports['qb-inventory']:AddItem(id, item, amount, false, info, nil)
            TriggerClientEvent('qb-inventory:client:ItemBox', id, QBCore.Shared.Items[item], 'add', amount)
        else
            print("resource "..SV_Config.Inventory.." not found")
        end
        
    -- elseif SV_Config.Inventory == "<your script>" then
    --     if GetResourceState("<your script>") ~= 'missing' then
    --         you can add your own <your script> AddItem export here.
    --     else
    --         print("resource "..SV_Config.Inventory.." not found")
    end
end

function RemoveKeyItem(id, item, amount, slot)
    if SV_Config.Inventory == "qb-inventory" then
        if GetResourceState("qb-inventory") ~= 'missing' then
            exports['qb-inventory']:RemoveItem(id, item, amount, slot, nil)
            TriggerClientEvent('qb-inventory:client:ItemBox', id, QBCore.Shared.Items[item], 'remove', amount)
        else
            print("resource "..SV_Config.Inventory.." not found")
        end

    -- elseif SV_Config.Inventory == "<your script>" then
    --     if GetResourceState("<your script>") ~= 'missing' then
    --         you can add your own <your script> RemoveItem export here.
    --     else
    --         print("resource "..SV_Config.Inventory.." not found")
    end
end

------------------------------------------------------------------------------------------------
--- do not edit below...
local function Trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

local function FirstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

local function Init()
    for k, v in pairs(SV_Config.Vehicles) do
        local hash = GetHashKey(v.model)
        if not VehicleModelName[hash] then
            local data = {name = v.name, brand = v.brand, category = FirstToUpper(v.category)}
            VehicleModelName[hash] = data
        end
    end
end

function IsOwner(src, plate)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local citizenid = Player.PlayerData.citizenid
        local result = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?", {citizenid, plate})[1]
        if result then return true end
    end
    return false
end

local function DoesKeyItemExist(src, plate)
    local found, slot = false, false
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        for _, item in pairs(Player.PlayerData.items) do
            if item.name == "vehiclekey" and Trim(item.info.plate) == Trim(plate) then
                found = true
                slot = item.slot
                break
            end
        end
    end
    return found, slot
end

local function GetVehicleModelName(src)
    local ped = GetPlayerPed(src)
    local model, brand, category = "unknow", "unknow", "unknow"
    Wait(100)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= nil and vehicle ~= -1 then
        if SV_Config.Vehicles[GetEntityModel(vehicle)] then
            model = SV_Config.Vehicles[GetEntityModel(vehicle)].model
            brand = SV_Config.Vehicles[GetEntityModel(vehicle)].brand
            category = SV_Config.Vehicles[GetEntityModel(vehicle)].category
        end
    end
    return model, brand, category
end

local function AddSharedKeyForType(src, info, type)
    local players = QBCore.Functions.GetPlayers()
    for id in pairs(players) do
        if id ~= src then
            local target = QBCore.Functions.GetPlayer(id)
            if target.PlayerData.job.type == type and target.PlayerData.job.onduty then
                local keyItemExist, _ = DoesKeyItemExist(id, info.plate)
                if not keyItemExist then
                    TriggerClientEvent('qb-vehiclekeys:client:AddKeys', id, info.plate)
                    AddKeyItem(id, "vehiclekey", 1, info)
                end
            end
        end
    end
end

local function AddItem(src, plate)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local keyItemExist, _ = DoesKeyItemExist(src, plate)
        if not keyItemExist then
            local model, brand, category = GetVehicleModelName(src)
            Wait(10)
            local info = {plate = plate, model = model, brand = brand, category = category}
            AddKeyItem(src, "vehiclekey", 1, info)
            if Player.PlayerData.job.type == 'leo' or Player.PlayerData.job.type == 'ems' and Player.PlayerData.job.onduty then
                AddSharedKeyForType(src, info, Player.PlayerData.job.type)
            end
        end
    end
end
exports('AddItem', AddItem)

local function RemoveItem(src, plate)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local keyItemExist, slot = DoesKeyItemExist(src, plate)
        if keyItemExist and type(slot) == 'number' then
            RemoveKeyItem(src, "vehiclekey", 1, slot)
        end
    end
end
exports('RemoveItem', RemoveItem)

local function RemoveItems(plate)
    local players = QBCore.Functions.GetPlayers()
    for id in pairs(players) do
        local target = QBCore.Functions.GetPlayer(id)
        if target then
            for _, item in pairs(target.PlayerData.items) do
                if item.name == "vehiclekey" and item.info ~= nil and item.info.plate ~= nil and Trim(item.info.plate:upper()) == Trim(plate:upper()) then
                    TriggerClientEvent('qb-vehiclekeys:client:RemoveKeys', id, Trim(plate))
                    RemoveKeyItem(id, "vehiclekey", 1, item.slot)
                end
            end
        end
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        VehicleModelName = {}
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Init()
    end
end)

AddEventHandler('entityRemoved', function(entity)
    if GetEntityType(entity) == 2 then
        local plate = GetVehicleNumberPlateText(entity)
        if plate ~= nil then RemoveItems(plate) end
    end
end)

RegisterNetEvent('mh-vehiclekeyitem:client:GiveKey', function(plate)
    local src = source
    if IsOwner(src, plate) then AddItem(src, plate) end
end)

RegisterNetEvent('mh-vehiclekeyitem:server:onjoin', function()
    local src = source
    TriggerClientEvent('mh-vehiclekeyitem:client:onjoin', src, SV_Config)
end)

RegisterNetEvent('mh-vehiclekeyitem:server:setVehLockState', function(vehNetId, state)
    SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(vehNetId), state)
end)

QBCore.Functions.CreateUseableItem("vehiclekey", function(source, item)
    local src = source
    TriggerClientEvent('mh-vehiclekeyitem:client:UseVehicleKey', src, item)
end)
--[[ ===================================================== ]] --
--[[         MH Vehicle Key Item Script by MaDHouSe        ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()
local disable = {}

local function IsAdmin(id)
    if Config.IgnoreAdmins then
        if IsPlayerAceAllowed(id, 'god') or IsPlayerAceAllowed(id, 'admin') or IsPlayerAceAllowed(id, 'command') then
            return true
        else
            return false
        end
    end
end

local function isOwner(id, plate)
    local Player = QBCore.Functions.GetPlayer(id)
    local citizenid = Player.PlayerData.citizenid
    local data = MySQL.Sync.fetchAll('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?',
                     {plate, citizenid})[1]
    if data then
        return true
    else
        return false
    end
end

local function isOnDuty(id)
    local Player = QBCore.Functions.GetPlayer(id)
    return Player.PlayerData.job.onduty
end

local function isJob(id)
    local Player = QBCore.Functions.GetPlayer(id)
    if Config.IgnoreForKeyItem[Player.PlayerData.job.name] then
        return true
    end
    return false
end

local function isGang(id)
    local Player = QBCore.Functions.GetPlayer(id)
    if Config.IgnoreForKeyItem[Player.PlayerData.gang.name] then
        return true
    end
    return false
end

local function hasAccess(id)
    if IsAdmin(id) then
        return true
    elseif isJob(id) then
        return true
    elseif isGang(id) then
        return true
    else
        return false
    end
end

local function GetModelName(plate)
    local data = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE plate = ?", {plate})[1]
    if data ~= nil then
        local vehicle = data.vehicle
        if QBCore.Shared.Vehicles[data.vehicle] then
            vehicle = QBCore.Shared.Vehicles[data.vehicle].name
        end
        if vehicle ~= nil then
            return vehicle
        else
            return 'unknow model'
        end
    end
end

local function GetUserVehicles(id)
    local Player = QBCore.Functions.GetPlayer(id)
    if Player then
        MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE citizenid = ?', {Player.PlayerData.citizenid},
            function(result)
                if result[1] ~= nil then
                    return result
                else
                    return nil
                end
            end)
    end
end

local function HaveKeyItem(id, plate)
    local Player = QBCore.Functions.GetPlayer(id)
    if Player then
        local items = exports['qb-inventory']:GetItemsByName(id, Config.KeyItem)
        if items ~= nil then
            for _, v in pairs(items) do
                if v.info.plate ~= nil then
                    if v.info.plate == plate then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function DeleteKey(id, plate)
    local Player = QBCore.Functions.GetPlayer(id)
    if Player then
        local items = exports['qb-inventory']:GetItemsByName(id, Config.KeyItem)
        if items ~= nil then
            for _, item in pairs(items) do
                if item.info.plate ~= nil then
                    if item.info.plate == plate then
                        Player.Functions.RemoveItem(Config.KeyItem, 1, item.slot)
                        TriggerClientEvent('qb-inventory:client:ItemBox', id, QBCore.Shared.Items[Config.KeyItem],
                            'remove', 1)
                    end
                end
            end
        end
    end
end
exports('DeleteKey', DeleteKey)

RegisterServerEvent('mh-vehiclekeyitem:server:DeleteKey', function(plate)
    local src = source
    DeleteKey(src, plate)
end)

local function AddTempVehicleKey(id, plate, model)
    local Player = QBCore.Functions.GetPlayer(id)
    if Player then
        if not HaveKeyItem(id, plate) then
            local info = {}
            info.owner = "NPC-" .. Config.NPCNames[math.random(1, #Config.NPCNames)]
            info.plate = plate
            info.model = model
            info.citizenid = Player.PlayerData.citizenid
            if QBCore.Shared.Vehicles[model] then
                info.model = QBCore.Shared.Vehicles[model].name
            end
            Player.Functions.AddItem(Config.KeyItem, 1, nil, info)
            TriggerClientEvent('qb-inventory:client:ItemBox', id, QBCore.Shared.Items[Config.KeyItem], 'add', 1)
            TriggerClientEvent('mh-vehiclekeyitem:client:DeleteVehicleKey', -1) -- Delete unauthorized vehicle keys
        end
    end
end

local function AddVehicleKey(id, plate)
    local Player = QBCore.Functions.GetPlayer(id)
    if Player then
        if not HaveKeyItem(id, plate) then
            local info = {}
            local model = GetModelName(plate)
            info.owner = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
            info.plate = plate
            info.citizenid = Player.PlayerData.citizenid
            info.model = model
            if QBCore.Shared.Vehicles[model] then
                info.model = QBCore.Shared.Vehicles[model].name
            end
            Player.Functions.AddItem(Config.KeyItem, 1, nil, info)
            TriggerClientEvent('qb-inventory:client:ItemBox', id, QBCore.Shared.Items[Config.KeyItem], 'add', 1)
            TriggerClientEvent('mh-vehiclekeyitem:client:DeleteVehicleKey', -1) -- Delete unauthorized vehicle keys
        end
    end
end

local function RegisterVehicleKeys(id)
    local items = exports['qb-inventory']:GetItemsByName(id, Config.KeyItem)
    if items ~= nil then
        for _, item in pairs(items) do
            if item.info.plate ~= nil then
                MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = ?', {item.info.plate},
                    function(vehicles)
                        if vehicles then
                            for _, vehicle in pairs(vehicles) do
                                if item.info.plate == vehicle.plate then
                                    if item.info.citizenid == vehicle.citizenid then
                                        if vehicle.citizenid == QBCore.Functions.GetPlayer(id).PlayerData.citizenid then
                                            TriggerClientEvent('qb-vehiclekeys:client:AddKeys', id, item.info.plate)
                                            TriggerEvent('mh-vehiclekeyitem:server:DeleteVehicleKey')
                                        else
                                            QBCore.Functions.GetPlayer(id).Functions
                                                .RemoveItem(Config.KeyItem, 1, item.slot)
                                            TriggerClientEvent('qb-inventory:client:ItemBox', id,
                                                QBCore.Shared.Items[Config.KeyItem], 'remove', 1)
                                        end
                                    end
                                end
                            end
                        else
                            if item.info.citizenid ~= QBCore.Functions.GetPlayer(id).PlayerData.citizenid then
                                QBCore.Functions.GetPlayer(id).Functions.RemoveItem(Config.KeyItem, 1, item.slot)
                                TriggerClientEvent('qb-inventory:client:ItemBox', id, QBCore.Shared.Items[Config.KeyItem],
                                    'remove', 1)
                            end
                        end
                    end)
            end
        end
    end
end

local function GetOnlinePlayers()
    local sources = {}
    for k, id in pairs(QBCore.Functions.GetPlayers()) do
        local target = QBCore.Functions.GetPlayer(id)
        local info = {
            source = target.PlayerData.source,
            fullname = target.PlayerData.charinfo.firstname .. " " .. target.PlayerData.charinfo.lastname
        }
        sources[#sources + 1] = info
    end
    return sources
end

QBCore.Functions.CreateUseableItem(Config.KeyItem, function(source, item)
    local src = source
    TriggerClientEvent('mh-vehiclekeyitem:client:UseKey', src, item)
end)

QBCore.Functions.CreateCallback('mh-vehiclekeyitem:server:GetModelName', function(source, cb, plate)
    cb(GetModelName(plate))
end)

QBCore.Functions.CreateCallback('mh-vehiclekeyitem:server:isAdmin', function(source, cb)
    local src = source
    local isAllowed = false
    if IsPlayerAceAllowed(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        isAllowed = true
    end
    cb(isAllowed)
end)

QBCore.Functions.CreateCallback('mh-vehiclekeyitem:server:isOwner', function(source, cb, plate)
    local src = source
    local isAllowed = false
    if isOwner(src, plate) then
        isAllowed = true
    end
    cb(isAllowed)
end)

QBCore.Functions.CreateCallback('mh-vehiclekeyitem:server:hasAccess', function(source, cb)
    local src = source
    local isAllowed = false
    if hasAccess(src) then
        isAllowed = true
    end
    cb(isAllowed)
end)

QBCore.Functions.CreateCallback('mh-vehiclekeyitem:server:IHaveTheKeyItem', function(source, cb, plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local output = false
    if plate ~= nil then
        if not disable[src] then -- must be false at start
            local hasKey = HaveKeyItem(src, plate)
            if hasKey ~= nil then
                output = hasKey
            end
            if IsAdmin(src) then
                output = true
            end
        else
            output = true
        end

    end
    cb(output)
end)

QBCore.Functions.CreateCallback("mh-vehiclekeyitem:server:GetUserVehicles", function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE citizenid = ?', {Player.PlayerData.citizenid},
            function(result)
                if result[1] ~= nil then
                    cb(result)
                else
                    cb(nil)
                end
            end)
    end
end)

QBCore.Functions.CreateCallback("mh-vehiclekeyitem:server:GetOnlinePlayers", function(source, cb)
    cb(GetOnlinePlayers())
end)

RegisterNetEvent('mh-vehiclekeyitem:server:DisableByOtherScript', function(state)
    local src = source
    disable[src] = state
end)

RegisterNetEvent('mh-vehiclekeyitem:server:onjoin', function()
    local src = source
    disable[src] = false
    RegisterVehicleKeys(src)
end)

RegisterNetEvent('mh-vehiclekeyitem:server:CreateTempVehiclekey', function(data)
    local src = source
    if not HaveKeyItem(src, data.plate) then
        AddTempVehicleKey(src, data.plate, data.model)
    end
end)

RegisterNetEvent('mh-vehiclekeyitem:server:CreateNewVehiclekey', function(data)
    local src = source
    if not HaveKeyItem(src, data.plate) then
        AddVehicleKey(src, data.plate, data.model)
    end
end)

RegisterServerEvent('mh-vehiclekeyitem:server:doAction', function(id, plate, vehicle)
    local src = source
    local access = false
    if id and tonumber(id) > 0 then
        if isOwner(src, plate) then -- Vehicle Owner access
            access = true
        else
            -- Job or Admin access
            if hasAccess(src) then
                access = true
            end
            if isJob(src) and isOnDuty(src) then
                access = true
            end
        end
        if access then
            local target = QBCore.Functions.GetPlayer(id)
            local targetlicense = QBCore.Functions.GetIdentifier(id, 'license')
            DeleteKey(src, plate)
            MySQL.update('UPDATE player_vehicles SET citizenid = ?, license = ? WHERE plate = ?',
                {target.PlayerData.citizenid, targetlicense, plate})
            TriggerClientEvent('QBCore:Notify', src, "Het voertuig is met succes overgeschreven", 'success')
            TriggerClientEvent('mh-vehiclekeyitem:client:givenewkey', id)
            TriggerClientEvent('vehiclekeys:client:SetOwner', id, plate)
            TriggerClientEvent('QBCore:Notify', id, "Je bent eigenaar van dit voertuig", 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, "Je bent geen eigenaar van dit voertuig", 'error')
        end
    end
end)

RegisterNetEvent('mh-vehiclekeyitem:server:DeleteVehicleKey', function()
    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(id)
        if Player then
            local items = exports['qb-inventory']:GetItemsByName(id, Config.KeyItem)
            if items ~= nil then
                for _, item in pairs(items) do
                    if item.info.plate ~= nil then
                        MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = ?', {item.info.plate},
                            function(vehicles)
                                if vehicles then
                                    for _, vehicle in pairs(vehicles) do
                                        if item.info.citizenid ~= vehicle.citizenid and item.info.plate == vehicle.plate then
                                            Player.Functions.RemoveItem(Config.KeyItem, 1, item.slot)
                                            TriggerClientEvent('inventory:client:ItemBox', id,
                                                QBCore.Shared.Items[Config.KeyItem], 'remove', 1)
                                        end
                                    end
                                end
                            end)
                    end
                end
            end
        end
    end
end)

--[[ ===================================================== ]]--
--[[         MH Vehicle Key Item Script by MaDHouSe        ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local MenuItemId = nil
local currenVehicle = nil

local function GetVehicleData(vehicle)
	local props = QBCore.Functions.GetVehicleProperties(vehicle)
	if props then
		return GetDisplayNameFromVehicleModel(props.model), props.plate
	else
		return false
	end
end

local function DoIHaveTheVehicleKeyItem(vehicle)
	QBCore.Functions.TriggerCallback('mh-vehiclekeyitem:server:IHaveTheKeyItem', function(result)
		if not result then
			SetVehicleEngineOn(vehicle, false, false, true)
			SetVehicleDoorsLocked(vehicle, 2)
			TriggerEvent('qb-vehiclekeys:client:RemoveKeys', QBCore.Functions.GetPlate(vehicle))
			TriggerServerEvent('mh-vehiclekeyitem:server:DeleteVehicleKey')
		end
	end, QBCore.Functions.GetPlate(vehicle))
end

local function CreateTempKey(vehicle)
	if vehicle then
		local model, plate = GetVehicleData(vehicle)
		TriggerServerEvent('mh-vehiclekeyitem:server:CreateTempVehiclekey', {model = model, plate = plate})
	else
		QBCore.Functions.Notify("Geen voertuig gevonden!", 'error')
	end
end
exports('CreateTempKey', CreateTempKey)

local function DeleteKey(plate)
	TriggerServerEvent('mh-vehiclekeyitem:server:DeleteKey', plate)
end
exports('DeleteKey', DeleteKey)

local function HasKey(plate)
    QBCore.Functions.TriggerCallback('mh-vehiclekeyitem:server:IHaveTheKeyItem', function(result)
        if result then
            return true
        else
            QBCore.Functions.Notify("You have no keys to this vehicle.", 'error')
            return false
        end
    end, plate)
end
exports('HasKey', HasKey)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
	PlayerData = QBCore.Functions.GetPlayerData()
	TriggerServerEvent('mh-vehiclekeyitem:server:onjoin')
	TriggerServerEvent('mh-vehiclekeyitem:server:DeleteVehicleKey')
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    PlayerData = data
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
		PlayerData = QBCore.Functions.GetPlayerData()
        TriggerServerEvent('mh-vehiclekeyitem:server:onjoin')
		TriggerServerEvent('mh-vehiclekeyitem:server:DeleteVehicleKey')
    end
end)

RegisterNetEvent('mh-vehiclekeyitem:client:menu', function()
    local playerlist = {}
	local vehicleList = {}
	QBCore.Functions.TriggerCallback("mh-mygaragemenu:server:getMyVehicles", function(myVehicles)
		if myVehicles ~= nil then
			QBCore.Functions.TriggerCallback('mh-vehiclekeyitem:server:GetOnlinePlayers', function(online)
				for k, vehicle in pairs(myVehicles) do
					vehicleList[#vehicleList + 1] = {value = vehicle.plate, text = vehicle.vehicle.." ("..vehicle.plate..")"}
				end
				for key, v in pairs(online) do
					playerlist[#playerlist + 1] = {value = v.source, text = "(ID:"..v.source..") "..v.fullname}
				end
				local menu = exports["qb-input"]:ShowInput({
					header = "Voertuig Verkoop",
					submitText = "Verkoop je voertuig",
					inputs = {
						{
							text = "Selecteer Speler",
							name = "id",
							type = "select",
							options = playerlist,
							isRequired = true
						},
						{
							text = "Selecteer Voertuig",
							name = "vehicle",
							type = "select",
							options = vehicleList,
							isRequired = true
						},
					}
				})
				if menu then
					if not menu.id or not menu.vehicle then
						return
					else
						local target = GetPlayerFromServerId(menu.id)
						local targetPed = GetPlayerPed(target)
						local vehicle = GetVehiclePedIsIn(targetPed)
						if vehicle then
							TriggerServerEvent('mh-vehiclekeyitem:server:doAction', tonumber(menu.id), tostring(menu.vehicle), vehicle)
						else
							QBCore.Functions.Notify("Je zit niet in een voertuig.")
						end
					end
				end
			end)
		end
	end)
end)

RegisterNetEvent('qb-radialmenu:client:onRadialmenuOpen', function()
	QBCore.Functions.TriggerCallback("mh-vehiclekeyitem:server:hasAccess", function(access)
		if access then
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				local _, plate = GetVehicleData(GetVehiclePedIsIn(PlayerPedId()))
				if plate ~= nil then
					QBCore.Functions.TriggerCallback("mh-vehiclekeyitem:server:isOwner", function(isOwner)
						if isOwner then
							if MenuItemId ~= nil then
								exports['qb-radialmenu']:RemoveOption(MenuItemId)
								MenuItemId = nil
							end
							MenuItemId = exports['qb-radialmenu']:AddOption({
								id = 'mykeys',
								title = "Sleutel Opties",
								icon = 'key',
								type = 'client',
								event = 'mh-vehiclekeyitem:client:menu',
								shouldClose = true
							}, MenuItemId)
						else
							if MenuItemId ~= nil then
								exports['qb-radialmenu']:RemoveOption(MenuItemId)
								MenuItemId = nil
							end
						end
					end, plate)
				else
					if MenuItemId ~= nil then
						exports['qb-radialmenu']:RemoveOption(MenuItemId)
						MenuItemId = nil
					end
				end
			else
				if MenuItemId ~= nil then
					exports['qb-radialmenu']:RemoveOption(MenuItemId)
					MenuItemId = nil
				end
			end
		else
			if MenuItemId ~= nil then
				exports['qb-radialmenu']:RemoveOption(MenuItemId)
				MenuItemId = nil
			end
		end
	end)
end)

RegisterNetEvent('mh-vehiclekeyitem:client:DeleteKey', function(plate)
	TriggerServerEvent('mh-vehiclekeyitem:server:DeleteKey', plate)
end)

RegisterNetEvent('mh-vehiclekeyitem:client:givekey', function(vehicle, plate)
	local ped = PlayerPedId()
	if IsPedInAnyVehicle(ped, false) then
		local pedvehicle = GetVehiclePedIsIn(ped)
		if pedvehicle == vehicle then
			local displaytext, plate = GetVehicleData(pedvehicle)
			TriggerServerEvent('mh-vehiclekeyitem:server:CreateNewVehiclekey', {model = displaytext, plate = plate})
		else
			QBCore.Functions.Notify("Je zit niet in het juiste voertuig..", "error")
		end
	else
		QBCore.Functions.Notify("Je zit niet in een voertuig..", "error")
	end
end)

RegisterNetEvent('mh-vehiclekeyitem:client:givenewkey', function()
	local ped = PlayerPedId()
	if IsPedInAnyVehicle(ped, false) then
		local vehicle = GetVehiclePedIsIn(ped)
		local displaytext, plate = GetVehicleData(vehicle)
		TriggerServerEvent('mh-vehiclekeyitem:server:CreateNewVehiclekey', {model = displaytext, plate = plate})
	else
		QBCore.Functions.Notify("Je zit niet in een voertuig..", "error")
	end
end)

RegisterNetEvent('mh-vehiclekeyitem:client:CreateVehicleOwnerKey', function(vehicle)
	local ped = PlayerPedId()
	local displaytext, plate = GetVehicleData(vehicle)
	TriggerServerEvent('mh-vehiclekeyitem:server:CreateNewVehiclekey', {model = displaytext, plate = plate})
end)

RegisterNetEvent('mh-vehiclekeyitem:client:UseKey', function(item) 
	if item and item.name == Config.KeyItem then
		local vehicle, distance = QBCore.Functions.GetClosestVehicle(GetEntityCoords(PlayerPedId())) 
		if distance <= 2.5 then
			local displaytext, plate = GetVehicleData(vehicle)
			if item.info.plate == plate then
				TriggerEvent('qb-vehiclekeys:client:AddKeys', plate)
				TriggerServerEvent('mh-vehiclekeyitem:server:DeleteVehicleKey')
				QBCore.Functions.Notify(Lang:t('info.you_can_use_the_key', {model = displaytext}), 'success')
			else
				QBCore.Functions.Notify(Lang:t('error.not_have_the_right_key', {model = displaytext}), 'error')
			end
		else
			QBCore.Functions.Notify("Er staat geen voertuig naast je!", 'error')
		end
	end
end)

RegisterKeyMapping('+engine', 'Toggle Engine', 'keyboard', 'G')
RegisterCommand('+engine', function()
    if currenVehicle == nil or GetPedInVehicleSeat(currenVehicle, -1) ~= PlayerPedId() then return end
	if GetIsVehicleEngineRunning(currenVehicle) then
		SetVehicleEngineOn(currenVehicle, false, false, true)
		QBCore.Functions.Notify(Lang:t("info.engine_off"))
	else
		SetVehicleEngineOn(currenVehicle, true, false, true)
		QBCore.Functions.Notify(Lang:t("info.engine_on"))
	end
end)

CreateThread(function()
    while true do
		local sleep = 1000
		if LocalPlayer.state.isLoggedIn then
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				sleep = 500
				if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId() then 
					DoIHaveTheVehicleKeyItem(GetVehiclePedIsIn(PlayerPedId()))
				end
			else
				sleep = 1000
				currenVehicle = nil
			end
		end
		Wait(sleep)
    end
end)

<p align="center">
    <img width="140" src="https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png" />  
    <h1 align="center">Hi 👋, I'm MaDHouSe</h1>
    <h3 align="center">A passionate allround developer </h3>    
</p>

<p align="center">
  <a href="https://github.com/MaDHouSe79/mh-vehiclekeyitem/issues">
    <img src="https://img.shields.io/github/issues/MaDHouSe79/mh-vehiclekeyitem"/> 
  </a>
  <a href="https://github.com/MaDHouSe79/mh-vehiclekeyitem/watchers">
    <img src="https://img.shields.io/github/watchers/MaDHouSe79/mh-vehiclekeyitem"/> 
  </a> 
  <a href="https://github.com/MaDHouSe79/mh-vehiclekeyitem/network/members">
    <img src="https://img.shields.io/github/forks/MaDHouSe79/mh-vehiclekeyitem"/> 
  </a>  
  <a href="https://github.com/MaDHouSe79/mh-vehiclekeyitem/stargazers">
    <img src="https://img.shields.io/github/stars/MaDHouSe79/mh-vehiclekeyitem?color=white"/> 
  </a>
  <a href="https://github.com/MaDHouSe79/mh-vehiclekeyitem/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/MaDHouSe79/mh-vehiclekeyitem?color=black"/> 
  </a>      
</p>

<p align="center">
  <img alig src="https://github-profile-trophy.vercel.app/?username=MaDHouSe79&margin-w=15&column=6" />
</p>


# MH-Vehicle Key Item
- The best Vehicle Key Item for QB-Core Framework
- The vehicle key will act as an item.
- the keys wil be deleted when you take or park you vehicle in to the garage.

# Dependencies:
- [qb-core](https://github.com/qbcore-framework/qb-core) (Required)
- [mh-vehiclekeys](https://github.com/MaDHouSe79/mh-vehiclekeys) (Required)

# Optional
- [Zerio Cardealer](https://store.zerio-scripts.com/package/5041342)
- The zerio-cardealer can be used and can work with mh-vehiclekeyitem.
- make a requat to the owners discord and ask him to implement the triggers 
- that you need to give and remove keys.

# I need help
- i don't help you if you did not read this file.
- you need at least the basics of proramming and how fivem works, or i can't help you.

# Install
- 1: create a folder in resources names `[mh]` and put `mh-vehiclekeyitem` in it.
- 2: add in your `server.cfg` below `ensure [qb]` add `ensure [mh]` below it.
- Add the code to your scripts that needs keys,
- restart the server

# NOTE, DO NOT DO THIS
- do not leave your keys in your vehicle, if you do this, you can't enter the vehicle, and you can get a new key.

# My keys does not work
- you have to use the key next to the vehicle and look at the vehicle.
- open your inventory, dubble click or drag the key item to use.
- you get a message that you can use the key on that vehicle,
- if you to far away from a vehicle, you also get a message.
- don't for get to add the triggers in your scripts that need keys.

# When i Buy a car i don't get a key
- This script is not just a copy and past script.
- You need to edit your server for this script.
- you must edit all the scripts that uses vehicles. (you need to use the triggers i gave you in this readme)
- so jobs/gangs/garages/ and other scripts that need a key must be edit.

# F1 Menu (qb-radialmenu)
- There is a sell menu to sell your vehiclekey to a other player.
- you need to add the job like cardealer (for a real player)
- and add this in to `Config.IgnoreForKeyItem`
- with this, the player get a Key Icone in there F1 menu to sell the vehicle with key. 

# server.cfg
```lua
ensure qb-core
ensure [qb]
ensure [mh]
```

# To edit in qb-garage example (client side)
- park vehicle
```lua
local function CheckPlayers(vehicle, garage)
    for i = -1, 5, 1 do
        local seat = GetPedInVehicleSeat(vehicle, i)
        if seat then
            TaskLeaveVehicle(seat, vehicle, 0)
            if garage then
                SetEntityCoords(seat, garage.takeVehicle.x, garage.takeVehicle.y, garage.takeVehicle.z)
            end
        end
    end
    SetVehicleDoorsLocked(vehicle)
    TriggerEvent('mh-vehiclekeyitem:client:DeleteKey', QBCore.Functions.GetPlate(vehicle))  -- <---- HERE TO ADD
    Wait(1500)
    QBCore.Functions.DeleteVehicle(vehicle)
end
```
- get vehicle
```lua
RegisterNetEvent('qb-garages:client:takeOutGarage', function(data)
    local type = data.type
    local vehicle = data.vehicle
    local garage = data.garage
    local index = data.index
    QBCore.Functions.TriggerCallback('qb-garage:server:IsSpawnOk', function(spawn)
        if spawn then
            local location
            if type == "house" then
                if garage.takeVehicle.h then garage.takeVehicle.w = garage.takeVehicle.h end -- backward compatibility
                location = garage.takeVehicle
            else
                location = garage.spawnPoint
            end
            QBCore.Functions.TriggerCallback('qb-garage:server:spawnvehicle', function(netId, properties)
                local veh = NetToVeh(netId)
                QBCore.Functions.SetVehicleProperties(veh, properties)
                exports['LegacyFuel']:SetFuel(veh, vehicle.fuel)
                doCarDamage(veh, vehicle)
                TriggerServerEvent('qb-garage:server:updateVehicleState', 0, vehicle.plate, index)
                closeMenuFull()
                TriggerEvent('mh-vehiclekeyitem:client:CreateVehicleOwnerKey', veh) -- <---- HERE TO ADD
                TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                SetVehicleEngineOn(veh, true, true)
                if type == "house" then
                    exports['qb-core']:DrawText(Lang:t("info.park_e"), 'left')
                    InputOut = false
                    InputIn = true
                end
            end, vehicle, location, true)
        else
            QBCore.Functions.Notify(Lang:t("error.not_impound"), "error", 5000)
        end
    end, vehicle.plate, type)
end)
```


# Add and removeing keys
You need to add this above in all your script that uses keys or spawn vehicles that you need to use, 
if you dont do this you can't drive this vehicle, the lockpick works also the same.
add the same triggers when you get the keys.


# To add in 
- for the old qb-inventory 
- `resources/[qb]/qb-inventory/html/js/app.js` around line 420
- no weight
```lua
}else if (itemData.name == "vehiclekey") {
    $(".item-info-title").html('<p>' + itemData.info.model + '</p>');
    $(".item-info-description").html('<p>Owner : ' + itemData.info.owner + '</p><p>Plate: ' + itemData.info.plate + '</p>');
```
- with weight
```lua
} else if (itemData.name == "vehiclekey") {
    $(".item-info-title").html('<p>' + itemData.info.model + '</p>');
    $(".item-info-description").html('<p>Eigenaar: ' + itemData.info.owner + '</p><p>Kenteken: ' + itemData.info.plate + '</p>');
    $(".item-info-stats").html('<p>Gewicht: ' + ((itemData.weight * itemData.amount) / 1000).toFixed(1) + ' | Amount: ' + itemData.amount)
```

---------------------
- for the new qb-inventory around line 399
```js
case "vehiclekey":
    return `<p><strong>Owner: </strong><span>${itemData.info.owner}</span></p>
    <p><strong>Model: </strong><span>${itemData.info.model}</span></p>
    <p><strong>Plate: </strong><span>${itemData.info.plate}</span></p>`;
```


# To Add or Edit in qb-inventory/server/main.lua
- in case you don't have it
```lua
-- check if you have this in your inventory
local function GetItemByName(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    item = tostring(item):lower()
    local slot = GetFirstSlotByItem(Player.PlayerData.items, item)
    return Player.PlayerData.items[slot]
end

-- add this if you dont have it
exports("GetItemByName", GetItemByName) -- <--- TO ADD
```

# To Add
- add in `resources/[qb]/qb-core/shared/items.lua`
- add `vehiclekey.png` in `resources/[qb]/qb-inventory/html/images/` folder:


![vehiclekey](https://i.imgur.com/JmRS6v9.png)

- Shared Item (EN) 
```lua
['vehiclekey'] = {['name'] = 'vehiclekey', ['label'] = 'Vehicle Key', ['weight'] = 0, ['type'] = 'item', ['image'] = 'vehiclekey.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'This is a car key, take good care of it, if you lose it you probably won\'t be able to use your car' },
```

- Shared Item (NL)
```lua
['vehiclekey'] = {['name'] = 'vehiclekey', ['label'] = 'Autosleutel', ['weight'] = 0, ['type'] = 'item', ['image'] = 'vehiclekey.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Dit is een autosleutel, zorg er goed voor, als u hem verliest, kunt u uw auto waarschijnlijk niet meer gebruiken' },
```

# Client side to give owner key (only for vehicle owners)
```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId())
TriggerEvent('mh-vehiclekeyitem:client:CreateVehicleOwnerKey', vehicle)
```

# Client side to give temp key (not a vehicle owner)
```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId())
TriggerEvent('mh-vehiclekeyitem:client:CreateTempKey', vehicle)
```

# Client side to delete key
```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId())
local plate = QBCore.Functions.GetPlate(vehicle)
TriggerEvent('mh-vehiclekeyitem:client:DeleteKey', plate)
```

# To check if you have the key item, you can use this in your own vehicle key script
```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId())
QBCore.Functions.TriggerCallback('mh-vehiclekeyitem:server:IHaveTheKeyItem', function(result)
    if result then
        -- your code, you have the key item
    else
        QBCore.Functions.Notify("You have no keys to this vehicle.", 'error')
    end
end, QBCore.Functions.GetPlate(vehicle))
```

# NOTE To gets keys
- you need to add the triggers above in every script that uses vehicles that you use and drive.
- if you don't do this your job vehicles or others vehicles will not drive.

# 🙈 Youtube
- [Youtube](https://www.youtube.com/c/MaDHouSe79)

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)

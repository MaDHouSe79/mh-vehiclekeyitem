<p align="center">
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

# My Youtube Channel
- [Subscribe](https://www.youtube.com/@MaDHouSe79) 

# MH Vehicle Key Item
- One of the best vehicle key item script for qbcore.

# Dependencies:
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-inventory](https://github.com/qbcore-framework/qb-inventory) 2.0
- [qb-vehiclekeys](https://github.com/qbcore-framework/qb-vehiclekeys) 

# Installation:
- Create a folder `[mh]` in `resources`. 
- Put `mh-vehiclekeyitem` in to `resources/[mh]`.
- Add the vehiclekey image in your inventory image folder.
- Load this script after target and polyzone.
- in sever.sfg after `[standalone]` add -> `ensure [mh]`
- After you done with the instructions below, you can restart the server.

# Key Image
![alttext](https://github.com/MaDHouSe79/mh-vehiclekeyitem/blob/main/vehiclekey.png)

# QBCore Shared Item
```lua
vehiclekey = { name = 'vehiclekey', label = 'Vehicle Key', weight = 500, type = 'item', image = 'vehiclekey.png', unique = true, useable = true, shouldClose = true, description = 'A vehicle key.' },
```

# Edit Code in qb-vehiclekeys
- in `qb-vehiclekeys/server/main.lua` around line 77
```lua
function GiveKeys(id, plate)
    local Player = QBCore.Functions.GetPlayer(id)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    if not plate then
        if GetVehiclePedIsIn(GetPlayerPed(id), false) ~= 0 then
            plate = QBCore.Shared.Trim(GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(id), false)))
        else
            return
        end
    end

    if not VehicleList[plate] then VehicleList[plate] = {} end
    VehicleList[plate][citizenid] = true

    exports['mh-vehiclekeyitem']:AddItem(id, plate) -- mh-vehiclekeyitem add here

    TriggerClientEvent('QBCore:Notify', id, Lang:t('notify.vgetkeys'))
    TriggerClientEvent('qb-vehiclekeys:client:AddKeys', id, plate)
    TriggerClientEvent('qb-vehiclekeys:client:GiveKeyItem', id, plate)
end
```

```lua
function RemoveKeys(id, plate)
    local Player = QBCore.Functions.GetPlayer(id)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    if VehicleList[plate] and VehicleList[plate][citizenid] then
        VehicleList[plate][citizenid] = nil
    end
    
    exports['mh-vehiclekeyitem']:RemoveItem(id, plate) -- mh-vehiclekeyitem add here
    
    TriggerClientEvent('qb-vehiclekeys:client:RemoveKeys', id, plate)
end
```

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)

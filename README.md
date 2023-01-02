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
    <img src="https://img.shields.io/github/license/MaDHouSe79/mh-vehiclekeys?color=black"/> 
  </a>      
</p>

<p align="center">
  <img alig src="https://github-profile-trophy.vercel.app/?username=MaDHouSe79&margin-w=15&column=6" />
</p>


# MH-Vehicle Key Item
- The best Vehicle Key Item for QB-Core Framework
- The vehicle key will act as an item.
- the keys wil be deleted when you take or park you vehicle in to the garage.

# NOTE, DO NOT DO THIS
- do not leave your keys in your vehicle, if you do this, you can't enter the vehicle,
- and you can get a new key, if your vehicle is in impound, 
- (don't for get to add the `exports['mh-vehiclekeyitem']:CreateTempKey(vehicle)`)


# My keys does not work
- you have to use the key next to the vehicle.
- open your inventory, dubble click or drag the key item to use.
- you get a message that you can use the key on that vehicle,
- if you to far away from a vehicle, you also get a message.


# Dependencies:
- [qb-core](https://github.com/qbcore-framework/qb-core) (Required)
- [qb-target](https://github.com/BerkieBb/qb-target) (Required)
- [mh-vehiclekeys](https://github.com/MaDHouSe79/mh-vehiclekeys) (Required)


# Install:
- 1. Place `mh-vehiclekeyitem` in to [mh] folder
- 2. Add ensure [mh] to your server.cfg
- 3. Add all everyting below in the scripts.
- 4. after you add all the code, you can restart the server and enjoy this script ;)


# To Add in `qb-garages`:
- 1. Add in to qb-garages client.lua, when you take a vehicle: `exports['mh-vehiclekeyitem']:CreateTempKey(vehicle)`
- 2. Add in to qb-garages client.lua, when you park a vehicle `exports['mh-vehiclekeyitem']:DeleteKey(QBCore.Functions.GetPlate(vehicle))`

# Add and removeing keys
You need to add this above in all your script that uses keys or spawn vehicles that you need to use, 
if you dont do this you can't drive this vehicle, the lockpick works also the same.
add the same exports when you get the keys.


# To add in `resources/[qb]/qb-inventory/html/js/app.js` around line 420
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


# To add in `resources/[qb]/qb-core/shared/items.lua`: (and don't forget to add the image `vehiclekey.png` in `resources/[qb]/qb-inventory/html/images/`) folder
![vehiclekey](https://i.imgur.com/JmRS6v9.png)

- Shared Item (EN) 
```lua
['vehiclekey'] = {['name'] = 'vehiclekey', ['label'] = 'Vehicle Key', ['weight'] = 0, ['type'] = 'item', ['image'] = 'vehiclekey.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'This is a car key, take good care of it, if you lose it you probably won\'t be able to use your car' },
```

- Shared Item (NL)
```lua
['vehiclekey'] = {['name'] = 'vehiclekey', ['label'] = 'Autosleutel', ['weight'] = 0, ['type'] = 'item', ['image'] = 'vehiclekey.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Dit is een autosleutel, zorg er goed voor, als u hem verliest, kunt u uw auto waarschijnlijk niet meer gebruiken' },
```

# To add keys client side
```lua
- to create temp keys
exports['mh-vehiclekeyitem']:CreateTempKey(vehicle)
exports['mh-vehiclekeyitem']:DeleteKey(QBCore.Functions.GetPlate(vehicle))
TriggerServerEvent('mh-vehiclekeyitem:server:DeleteKey', QBCore.Functions.GetPlate(vehicle))

- To create owner keys 
- The new owner must sit inside the vehicle on the driver or codriver seat
TriggerEvent('mh-vehiclekeyitem:client:CreateVehicleOwnerKey', veh)            -- (Client side)
TriggerClientEvent('mh-vehiclekeyitem:client:CreateVehicleOwnerKey', veh)      -- (Server side)
```

# To add keys server side
```lua
TriggerClientEvent('mh-vehiclekeyitem:client:givekey', buyerId, vehice, plate) -- (Client side)
TriggerClientEvent('mh-vehiclekeyitem:client:givekey', buyerId, vehice, plate) -- (Server side)
```

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

# NOTE, DO NOT DO THIS
- do not leave your keys in your vehicle, if you do this, you can't enter the vehicle,
- and you can get a new key, if your vehicle is in impound, 
- (don't for get to add the `exports['mh-vehiclekeyitem']:CreateTempKey(vehicle)`)


# My keys does not work
- you have to use the key next to the vehicle.
- open your inventory, dubble click or drag the key item to use.
- you get a message that you can use the key on that vehicle,
- if you to far away from a vehicle, you also get a message.

# F1 Menu (qb-radialmenu)
- There is a sell menu to sell your vehiclekey to a other player.
- you need to add the job like cardealer (for a real player)
- and add this in to `Config.IgnoreForKeyItem`
- with this, the player get a Key Icone in there F1 menu to sell the vehicle with key. 


# Dependencies:
- [qb-core](https://github.com/qbcore-framework/qb-core) (Required)
- [mh-vehiclekeys](https://github.com/MaDHouSe79/mh-vehiclekeys) (Required)

# Install
- 1: rename mh-vehiclekeys to qb-vehiclekeys and put this folder in [qb]
- 2: create a folder in resources names [mh] and put mh-vehiclekeyitem in it.
- Add the code to your scripts that needs keys,
- restart the server

# server.cfg
```lua
ensure qb-core
ensure [qb]
ensure [mh]
```

# To Add in `qb-garages`:
- 1. Add in to qb-garages client.lua, when you take a vehicle: `exports['mh-vehiclekeyitem']:CreateTempKey(vehicle)`
- 2. Add in to qb-garages client.lua, when you park a vehicle `exports['mh-vehiclekeyitem']:DeleteKey(QBCore.Functions.GetPlate(vehicle))`

# Add and removeing keys
You need to add this above in all your script that uses keys or spawn vehicles that you need to use, 
if you dont do this you can't drive this vehicle, the lockpick works also the same.
add the same exports when you get the keys.


# To add in 
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

-- add this is you dont have it
exports("GetItemByName", GetItemByName) -- <--- TO ADD
```

# To 
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

# To add keys client side
```lua
- To create keys
local vehicle = GetVehiclePedIsIn(PlayerPedId())
exports['mh-vehiclekeyitem']:CreateTempKey(vehicle)

- Delete key
local vehicle = GetVehiclePedIsIn(PlayerPedId())
local plate = QBCore.Functions.GetPlate(vehicle)
exports['mh-vehiclekeyitem']:DeleteKey(plate)
```

# Client side to give owner keys
```lua
TriggerEvent('mh-vehiclekeyitem:client:CreateVehicleOwnerKey', vehicle)
```

# to check if you have the key item, you can use this in your own vehicle key script
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
- or
```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId())
local plate = QBCore.Functions.GetPlate(vehicle)
local hasKeyItem = exports['mh-vehiclekeyitem']:HasKey(plate)
if hasKeyItem then
    -- your code
else
    QBCore.Functions.Notify("You have no keys to this vehicle.", 'error')
end

```


## 🙈 Youtube & Discord
- [Youtube](https://www.youtube.com/@MaDHouSe79) for videos
- [Discord](https://discord.gg/cEMSeE9dgS)

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)

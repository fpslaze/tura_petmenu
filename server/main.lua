local Core = exports.vorp_core:GetCore()


function scriptStarted()
    local resourceName = GetCurrentResourceName()
    local version = GetResourceMetadata(resourceName, "version", 0) or "1.0.0"
    local author  = GetResourceMetadata(resourceName, "author", 0) or "Unknown"

    local line = string.rep("=", 52)

    print("^2" .. line)
    print((" ^5%s ^7wurde erfolgreich gestartet!"):format(resourceName))
    print((" ^3Version:^7 %s"):format(version))
    print((" ^3Author:^7  %s"):format(author))
    print("^2" .. line .. "^0")
end

scriptStarted()

RegisterNetEvent("tura_pets:savePet")
AddEventHandler("tura_pets:savePet", function(model)
    local _source = source
    local User = Core.getUser(_source)
    local identifier = User.getIdentifier()

    MySQL.update(
        'INSERT INTO users_pets (identifier, petModel) VALUES (?, ?) ON DUPLICATE KEY UPDATE petModel = VALUES(petModel)',
        {identifier, model}
    )
end)

local function loadPetForPlayer(playerId)
    local User = Core.getUser(playerId)
    if not User then return end

    local identifier = User.getIdentifier()

    MySQL.scalar(
        'SELECT petModel FROM users_pets WHERE identifier = ?',
        {identifier},
        function(result)
           if result and result ~= "" then
                TriggerClientEvent("tura_pets:loadPet", playerId, result)
            end
        end
    )
end

AddEventHandler("vorp:characterLoaded", function(source)
    loadPetForPlayer(source)
end)

RegisterNetEvent("tura_pets:requestPet")
AddEventHandler("tura_pets:requestPet", function()
    local src = source
    loadPetForPlayer(src)
end)


RegisterNetEvent("tura_pets:getGroup")
AddEventHandler("tura_pets:getGroup", function (group)
    print(group)
end)


RegisterNetEvent("tura_pets:clearPet")
AddEventHandler("tura_pets:clearPet", function()
    local src = source
    local User = Core.getUser(src)
    if not User then return end

    local identifier = User.getIdentifier()

    MySQL.update(
        "UPDATE users_pets SET petModel = NULL WHERE identifier = ?",
        { identifier }
    )
end)


Core.Callback.Register("tura_pets:getPet", function(source, cb)
    local lastPet = loadPetForPlayer(source)
    cb(lastPet)
end)

Core.Callback.Register("tura_pets:getGroup", function(source, cb)
    local User = Core.getUser(source)
    if not User then 
        cb(nil)
        return 
    end

    local Character = User.getUsedCharacter
    if not Character then
        cb(nil)
        return
    end

    local group = Character.group or "user"
    cb(group)
end)


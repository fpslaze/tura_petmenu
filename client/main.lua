-- api's
local Core = exports.vorp_core:GetCore()
local Menu = exports.vorp_menu:GetMenuData()

--entities
local playerId = PlayerId()
local playerGroup = nil
 -- vars
local selected = "Kein Pet ausgewählt"
local selected_defaultString = "Kein Pet ausgewählt"



ConfigSzenarios = {}

ConfigSzenarios = {
    DOGS = {
        { label = "Trinken",                  value = "WORLD_ANIMAL_DOG_DRINK_GROUND" },
        { label = "Schnüffeln",               value = "WORLD_ANIMAL_DOG_SNIFFING_GROUND" },
        { label = "Revier markieren",         value = "WORLD_ANIMAL_DOG_MARK_TERRITORY_A" },
        { label = "Kacken",                   value = "WORLD_ANIMAL_DOG_POOPING" },
        { label = "Knurren",                  value = "WORLD_ANIMAL_DOG_BARK_GROWL" },
        { label = "Bellen (Boden)",           value = "WORLD_ANIMAL_DOG_BARKING_GROUND" },
        { label = "Bellen (nach oben)",       value = "WORLD_ANIMAL_DOG_BARKING_UP" },
        { label = "Bellen (aggressiv)",       value = "WORLD_ANIMAL_DOG_BARKING_VICIOUS" },
        { label = "Betteln",                  value = "WORLD_ANIMAL_DOG_BEGGING" },
        { label = "Graben",                   value = "WORLD_ANIMAL_DOG_DIGGING" },
        { label = "Essen",                    value = "WORLD_ANIMAL_DOG_EATING_GROUND" },
        { label = "Bewachen",                 value = "WORLD_ANIMAL_DOG_GUARD_GROWL" },
        { label = "Heulen",                   value = "WORLD_ANIMAL_DOG_HOWLING" },
        { label = "Heulen (sitzend)",         value = "WORLD_ANIMAL_DOG_HOWLING_SITTING" },
        { label = "Verletzt (am Boden)",      value = "WORLD_ANIMAL_DOG_INJURED_ON_GROUND" },
        { label = "Ausruhen",                 value = "WORLD_ANIMAL_DOG_RESTING" },
        { label = "Rollen",                   value = "WORLD_ANIMAL_DOG_ROLL_GROUND" },
        { label = "Sitzen",                   value = "WORLD_ANIMAL_DOG_SITTING" },
        { label = "Schlafen",                 value = "WORLD_ANIMAL_DOG_SLEEPING" },
    },

    CATS = {
        { label = "Krallen schärfen",         value = "WORLD_ANIMAL_CAT_CLAW_SHARPEN" },
        { label = "Trinken",                  value = "WORLD_ANIMAL_CAT_DRINKING" },
        { label = "Essen",                    value = "WORLD_ANIMAL_CAT_EATING" },
        { label = "Ausruhen",                 value = "WORLD_ANIMAL_CAT_RESTING" },
        { label = "Sitzen",                   value = "WORLD_ANIMAL_CAT_SITTING" },
        { label = "Schlafen",                 value = "WORLD_ANIMAL_CAT_SLEEPING" },
    }
}

---@param pedModel string the model Hash to spawn as an Ped
function spawnAsPet(petModel)
    local model = GetHashKey(petModel)

    if not IsModelValid(model) then return end

    while not HasModelLoaded(model) do 
        RequestModel(model)
        Wait(10)
    end
    
    if HasModelLoaded(model) then
        Citizen.InvokeNative(0xED40380076A31506, playerId, model, false)
        SetPlayerModel(playerId, model, false)
        SetModelAsNoLongerNeeded(model)
        if model == -499992081 then
            SetPedOutfitPreset(PlayerPedId(), 9)
        else
            Citizen.InvokeNative(0x283978A15512B2FE, PlayerPedId(), true)
        end
    end
end

CreateThread(function()
    scriptStarted()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        SetPedUseHorseMapCollision(ped, false)
        SetEntityCollision(ped, true, true)
        SetPedCanRagdoll(ped, true)
        SetEntityDynamic(ped, true)
    end
end)

function openPetMenu()
    Menu.CloseAll()
    local menuElements = {}

    table.insert(menuElements, {
        label = "Aktuelles Pet: " .. selected,
        value = "currentpet",
        desc = "Verwalte dein aktuelles Pet"
    })

      if selected ~= selected_defaultString then
        table.insert(menuElements, {
            label = "Zurücksetzen",
            value = "resetplayer",
            desc = "Wechsel zurück zum Menschen"
        })
      end

    for _, categorie in ipairs(Config.Categories) do
        if isCategoryAllowed(categorie) and categorie.entities and next(categorie.entities) ~= nil then
            table.insert(menuElements, {
                label = categorie.categorieName,
                value = categorie.categorieName,
                desc = categorie.categorieName
            })
        end
    end

    Menu.Open("default", GetCurrentResourceName(), "mainMenu",
    {
        title = "PetMenu",
        subtext = "Kategorien",
        align = "top-left",
        elements = menuElements,
        maxVisibleItems = 7,
        hideRadar = false,
        soundOpen = true,
    },

    function(data, menu)
        for _, v in ipairs(Config.Categories) do
            if data.current.value == v.categorieName then
                openPedList(v.entities)
                return
            end

            if data.current.value == "resetplayer" then
                resetToPlayer()
                Menu.CloseAll()
                return
            end

        end
        if data.current.value == "currentpet" then 
            if selected ~= selected_defaultString then 
                openManagementMenu()
            else
                NotifyPlayer("Pet Menu", "Du hast kein Pet ausgewählt", 4000)
                Menu.CloseAll()
            end
        end
    end,

    function() Menu.CloseAll() end)
end

function openPedList(entities)
    if not entities or next(entities) == nil then return end

    Menu.CloseAll()

    local menuElements = {}

    table.insert(menuElements, {
        label = "Zurück zu Kategorien",
        value = "back",
        desc = "Kehre zurück zu den Kategorien"
    })

    for pedName, pedData in pairs(entities) do
        table.insert(menuElements, {
            label = pedName,
            value = pedData.model,
            desc  = pedData.model
        })
    end

    Menu.Open("default", GetCurrentResourceName(), "petList",
    {
        title = "Peds",
        subtext = "Auswahl",
        align = "top-left",
        elements = menuElements,
        maxVisibleItems = 6,
        hideRadar = true,
        soundOpen = true,
        skipOpenEvent = false,
    },

    function(data, menu)
        if data.current.value == "back" then
            Menu.CloseAll()
            openPetMenu()
            return
        end
        spawnAsPet(data.current.value)
        selected = data.current.label
        saveSelectedPet(data.current.value)
        selectedModel = data.current.value
        selectedScenarios = entities[selected].scenarios or {}

        NotifyPlayer("Pet-Menu", "Du hast das Pet: ".. selected .. " ausgewählt", 4000)
        Menu.CloseAll()
    end,

    function()
        Menu.CloseAll()
    end)
end

function openManagementMenu()
    Menu.CloseAll()

    local menuElements = {

        { 
            label = "Zurück zu Kategorien",
            value = "back",
            desc = "Zurück zu den Kategorien"
        },
        { 
            label = "Animationen",
            value = "animation",
            desc = "Spiele Animationen für "..selected .. " ab.",
            itemHeight = "4vh" 
        }
    }
    

    Menu.Open("default", GetCurrentResourceName() , "OpenMenu",
        {
            title = "Pet Verwaltung",
            subtext = "Verwalte dein Pet und aktiviere Emotes und anderes",
            align = "top-left",
            elements = menuElements,
            maxVisibleItems = 6,
            hideRadar = true,                                        
            soundOpen = true,                                         
            skipOpenEvent = false,                                     

        },
        function(data, menu)
            if data.current.value == "back" then 
                Menu.CloseAll()
                openPetMenu()
            end

            if data.current.value == "animation" then 
                openAnimationMenu()
            end

            if (data.current == "backup") then
                return  _G[data.trigger](any,any) 
            end

            
        end,

        function(data,menu)
            Menu.Close(true, true) 
        end,
        function(data, menu) 
        end,

        function(data,menu) 
           Menu.CloseAll()
        end)
end

function openAnimationMenu()
    Menu.CloseAll()

    local menuElements = {
        {
            label = "Zurück",
            value = "back",
            desc = "Zurück zum Management"
        },
          {
            label = "Scenario abbrechen",
            value = "stopemote",
            desc = "Aktuelles Scenario abbrechen"
        }
    }

    if currentScenario ~= nil then
        table.insert(menuElements, {
            label = "Scenario abbrechen",
            value = "clearScenario",
            desc  = "Aktuelles Scenario stoppen"
        })
    end

    if not selectedScenarios or #selectedScenarios == 0 then
        table.insert(menuElements, {
            label = "Keine Animationen verfügbar",
            value = "none",
            desc = "Dieses Pet hat keine Szenarios"
        })
    else
        for _, scenario in ipairs(selectedScenarios) do
            table.insert(menuElements, {
                label = scenario.label,
                value = scenario.value,
                desc  = "Animation: " .. scenario.label
            })
        end
    end

    Menu.Open("default", GetCurrentResourceName(), "animationMenu",
    {
        title = "Animationsmenu",
        subtext = "Animationen für "..selected,
        align = "top-left",
        elements = menuElements,
        maxVisibleItems = 8,
        hideRadar = true,
        soundOpen = true,
    },

    function(data, menu)

        if data.current.value == "back" then
            openManagementMenu()
            return
        end

        if data.current.value == "stopemote" then 
            ClearPedTasks(PlayerPedId())
            NotifyPlayer("Pet Menu", "Du hast dein Szenario gestoppt!", 4000)
            Menu.CloseAll()
        end

        if data.current.value ~= "none" and data.current.value ~= "stopemote" and data.current.value ~= "back" then
            ClearPedTasks(PlayerPedId())
            Citizen.InvokeNative(0x524B54361229154F, PlayerPedId(), 
                GetHashKey(data.current.value), -1, true, false, false, false)
                NotifyPlayer("Pet Menu", "Du hast Scenario: ".. data.current.label .. " gestartet!", 5000)
                Menu.CloseAll()
            currentScenario = data.current.value
        end

    end,

    function()
        Menu.CloseAll()
    end)
end

function NotifyPlayer(title, desc, timeout)
    Core.NotifyLeft(
        title,
        desc,
        "generic_textures",
        "tick",
        timeout,
        "COLOR_WHITE"
    )
end

RegisterCommand(Config.PetCommand, function()
    if not playerGroup then
        getGroup(function()
            openPetMenu()
        end)
    else
        openPetMenu()
    end
end)


function saveSelectedPet(model)
    TriggerServerEvent("tura_pets:savePet", model)
end

function findEntityKeyByModel(modelName)
    for _, category in ipairs(Config.Categories) do
        for key, data in pairs(category.entities) do
            if data.model == modelName then
                return key, category
            end
        end
    end
    return nil, nil
end

function restorePetModel()
    if selectedModel and selectedModel ~= "" then
        Wait(1000)
        spawnAsPet(selectedModel)
    end
end


RegisterNetEvent("vorp:playerRevived")
AddEventHandler("vorp:playerRevived", restorePetModel)

RegisterNetEvent("vorp_core:revivePlayer")
AddEventHandler("vorp_core:revivePlayer", restorePetModel)

AddEventHandler("playerSpawned", function()
    restorePetModel()
    TriggerEvent("tura_pets:getGroup")
end)

RegisterNetEvent("tura_pets:loadPet")
AddEventHandler("tura_pets:loadPet", function(petModel)
    if petModel ~= nil and petModel ~= "" then
        Wait(1500)
        spawnAsPet(petModel)

        local petKey, petCategorie = findEntityKeyByModel(petModel)
        selected = petKey
        selectedModel = petModel


        if petCategorie and petCategorie.entities[petKey] then
            selectedScenarios = petCategorie.entities[petKey].scenarios or {}
        else
            selectedScenarios = {}
        end
    end
end)



RegisterNetEvent("tura_pets:getGroup")
AddEventHandler("tura_pets:getGroup", function ()
end)

function getGroup(callback)
    Core.Callback.TriggerAsync("tura_pets:getGroup", function(group)
        playerGroup = group
        if callback then
            callback(group)
        end
    end)
end

RegisterCommand("group", function()
    getGroup(function(_g)
        print("group: " .. tostring(_g))
    end)
end)


function isCategoryAllowed(category)
    local hasGroups = category.groups and #category.groups > 0
    local hasUsers  = category.allowedUsers and #category.allowedUsers > 0
    if (not hasGroups) and (not hasUsers) then
        return true
    end

    if hasUsers then
        for _, steam in ipairs(category.allowedUsers) do
            if steam ~= "" then
                if string.lower(steam) == string.lower(GetPlayerIdentifier(PlayerId(), 0) or "") then
                    return true
                end
            end
        end
    end

    if hasGroups then
        if not playerGroup then
            return false
        end

        for _, g in ipairs(category.groups) do
            if tostring(g):lower():gsub("%s+", "") == playerGroup then
                return true
            end
        end
    end

    return false
end


function resetToPlayer()
    ExecuteCommand("rc") 
    TriggerServerEvent("tura_pets:clearPet")
    selected = selected_defaultString
        selectedModel = nil
        selectedScenarios = {}
        currentScenario = nil
    NotifyPlayer("Pet Menu", "Du bist wieder Mensch!", 4000)
end

function Debug(msg)
    if not Config.debugMode then return end

    local prefix = "^6[DEBUG]^0"
    print(("%s » %s"):format(prefix, msg))
end

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

exports("restorePetModel", restorePetModel)
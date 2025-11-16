local Core = exports.vorp_core:GetCore()
local playerId = PlayerId()
local selected = "Kein Pet ausgewählt"
local selected_defaultString = "Kein Pet ausgewählt"

function openPetMenu()
    Menu.CloseAll()
    local menuElements = {}

    table.insert(menuElements, {
        label = "Aktuelles Pet: " .. selected,
        value = "currentpet",
        desc = "Verwalte dein aktuelles Pet"
    })

    for _, categorie in ipairs(Config.Categories) do
        if categorie.entities and next(categorie.entities) ~= nil then
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
          print("current key of MenuElements is " .. data.current.index)
          print("current value of MenuElements is " .. data.current.value)

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

        -- if data.current.value == "clearScenario" then
        --     ClearPedTasks(PlayerPedId())
        --     currentScenario = nil
        --     openAnimationMenu() -- Menü neu laden ohne Stop-Button
        --     return
        -- end

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

function saveSelectedPet(model)
    TriggerServerEvent("tura_pets:savePet", model)
end

---@param model any needing the hash to check if this model is valid to pass collisions in interiors
function isDogModel(model)
    for _, dogModel in ipairs(dogModels) do
        if GetHashKey(dogModel) == model then
            return true
        end
    end
    return false
end

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

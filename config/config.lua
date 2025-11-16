Config = {}

-- is needed to use the command
Config.AdminGroups = {
    "admin", "mod"
}

Config.debugMode = false
Config.PetCommand = "turapets"
Config.NoSelected = "Kein Pet ausgewählt"
Config.steamIds = {
    "steam:110000113d89c03",
}

Config.Categories = {
      {
        categorieName = "Hunde & Katzen",
         groups = {"asdasd"},
         allowedUsers = Config.steamIds, -- do not touch this 
         entities = {
            ["American Foxhound"] = {
                model = "a_c_dogamericanfoxhound_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 

            },
            ["Australian Shepherd"] = {
                model = "a_c_dogaustraliansheperd_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["Bluetick Coonhound"] = {
                model = "a_c_dogbluetickcoonhound_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["Catahoula Cur"] = {
                model = "a_c_dogcatahoulacur_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["Chesapeake Bay Retriever"] = {
                model = "a_c_dogchesbayretriever_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["Collie"] = {
                model = "a_c_dogcollie_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["Hobo Dog"] = {
                model = "a_c_doghobo_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["Hound"] = {
                model = "a_c_doghound_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["American Foxhound MP"] = {
                model = "mp_a_c_dogamericanfoxhound_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["Husky"] = {
                model = "a_c_doghusky_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["Labrador"] = {
                model = "a_c_doglab_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["Lion Dog"] = {
                model = "a_c_doglion_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this  
            },
            ["Poodle"] = {
                model = "a_c_dogpoodle_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["Rufus"] = {
                model = "a_c_dogrufus_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["Street Dog"] = {
                model = "a_c_dogstreet_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["Lostdog"] = {
                model = "re_lostdog_dogs_01",
                scenarios = ConfigSzenarios.DOGS -- do not touch this 
            },
            ["Cat"] = {
                model = "a_c_cat_01",
                scenarios = ConfigSzenarios.CATS -- do not touch this 
            },
        }
    }, 
}


-- DONT CHANGE IF U NOT KNOW WHAT U DOING

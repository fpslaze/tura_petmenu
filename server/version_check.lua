local resourceName = GetCurrentResourceName()
local currentVersion = GetResourceMetadata(resourceName, "version", 0) or "0.0.0"

local GITHUB_USER = "fpslaze"
local GITHUB_REPO = "https://github.com/fpslaze/tura_petmenu"

function CheckVersion()
    PerformHttpRequest(
        ("https://api.github.com/repos/%s/%s/releases/latest"):format(GITHUB_USER, GITHUB_REPO),
        function(status, data, headers)
            if status ~= 200 then
                print("^1[Version Checker]^0 GitHub Anfrage fehlgeschlagen! Status: "..status)
                return
            end

            local body = json.decode(data)
            local latest = body.tag_name or "0.0.0"

            if latest ~= currentVersion then
                print("^3================ VERSION INFO ===============^0")
                print(("  ^6%s^0 ist veraltet!"):format(resourceName))
                print(("  Installiert: ^1%s^0"):format(currentVersion))
                print(("  Neueste Version: ^2%s^0"):format(latest))
                print(("  → Update verfügbar: https://github.com/%s/%s/releases/latest"):format(GITHUB_USER, GITHUB_REPO))
                print("^3============================================^0")
            else
                print(("^2[%s]^0 Läuft auf der neuesten Version (^3%s^0)."):format(resourceName, currentVersion))
            end
        end,
        "GET", "", { ["User-Agent"] = "RedM-Version-Checker" }
    )
end

CreateThread(function()
    Wait(1500)
    CheckVersion()
end)

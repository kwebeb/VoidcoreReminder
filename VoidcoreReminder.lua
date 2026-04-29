-- VoidcoreReminder.lua
-- Warns you when entering a Midnight Season 1 Mythic raid without Nebulous Voidcores

local ADDON_NAME = "VoidcoreReminder"

-- Currency ID for Nebulous Voidcore (ID 3418 from Wowhead)
local NEBULOUS_VOIDCORE_ID = 3418

-- Midnight Season 1 raid names (matched against GetInstanceInfo zone name)
-- Using name-based matching so it works regardless of numeric instance ID
local MIDNIGHT_S1_RAIDS = {
    ["The Voidspire"]        = true,
    ["The Dreamrift"]        = true,
    ["March on Quel'Danas"]  = true,
}

-- Minimum Voidcores to warn about (warn if you have FEWER than this)
-- Raid bosses cost 2 each, so 2 = at least one roll available
local WARN_THRESHOLD = 2

-- Slash command: /voidcore  or  /vcr
local function PrintHelp()
    print("|cff00ccff[VoidcoreReminder]|r Commands:")
    print("  |cffffd700/voidcore check|r  - Manually check your Voidcore count")
    print("  |cffffd700/voidcore thresh <n>|r  - Set warning threshold (default: 2)")
    print("  |cffffd700/voidcore help|r  - Show this message")
end

local function CheckAndWarn(manual)
    local instanceName, _, difficultyID = GetInstanceInfo()
    -- difficultyID 16 = Mythic raid
    local isMythicRaid = (difficultyID == 16)

    if manual then
        -- Manual check: always show status regardless of zone
        local amount = C_CurrencyInfo.GetCurrencyInfo(NEBULOUS_VOIDCORE_ID)
        local count = amount and amount.quantity or 0
        print(string.format(
            "|cff00ccff[VoidcoreReminder]|r You currently have |cffffd700%d|r Nebulous Voidcore(s).",
            count
        ))
        if isMythicRaid and MIDNIGHT_S1_RAIDS[instanceName] then
            print("|cff00ccff[VoidcoreReminder]|r You are in |cffffff00" .. instanceName .. "|r (Mythic).")
        end
        return
    end

    -- Auto check: only fire in Mythic S1 raids
    if not isMythicRaid or not MIDNIGHT_S1_RAIDS[instanceName] then return end

    local amount = C_CurrencyInfo.GetCurrencyInfo(NEBULOUS_VOIDCORE_ID)
    local count = amount and amount.quantity or 0

    if count < WARN_THRESHOLD then
        -- Big visible warning
        print(" ")
        print("|cffff2020=============================================|r")
        print(string.format(
            "|cffff2020[VoidcoreReminder] WARNING:|r You only have |cffffff00%d|r Nebulous Voidcore(s)!",
            count
        ))
        print("|cffff2020  Raid bosses cost 2 cores each for a bonus roll.|r")
        print("|cffff2020  Buy more from Decimus in The Voidstorm before raiding!|r")
        print("|cffff2020=============================================|r")
        print(" ")

        -- Also play an alert sound (Raid Warning sound)
        PlaySound(8959, "Master")  -- RAID_WARNING sound
    else
        -- Quiet confirmation so you know the addon is running
        print(string.format(
            "|cff00ccff[VoidcoreReminder]|r You have |cffffd700%d|r Nebulous Voidcore(s). You're good for %s (Mythic)!",
            count, instanceName
        ))
    end
end

-- Register events
local frame = CreateFrame("Frame", ADDON_NAME .. "Frame", UIParent)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        -- Load saved threshold if present
        if VoidcoreReminderDB and VoidcoreReminderDB.threshold then
            WARN_THRESHOLD = VoidcoreReminderDB.threshold
        else
            VoidcoreReminderDB = { threshold = WARN_THRESHOLD }
        end
        print("|cff00ccff[VoidcoreReminder]|r Loaded. Type |cffffd700/voidcore help|r for commands.")

    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        -- Small delay so GetInstanceInfo returns accurate data after loading screen
        C_Timer.After(2, function()
            CheckAndWarn(false)
        end)
    end
end)

-- Slash commands
SLASH_VOIDCOREREMINDER1 = "/voidcore"
SLASH_VOIDCOREREMINDER2 = "/vcr"

SlashCmdList["VOIDCOREREMINDER"] = function(msg)
    local cmd, arg = msg:match("^(%S*)%s*(.*)$")
    cmd = cmd:lower()

    if cmd == "check" then
        CheckAndWarn(true)
    elseif cmd == "thresh" then
        local n = tonumber(arg)
        if n and n >= 0 then
            WARN_THRESHOLD = n
            VoidcoreReminderDB.threshold = n
            print(string.format(
                "|cff00ccff[VoidcoreReminder]|r Warning threshold set to |cffffd700%d|r Voidcore(s).",
                n
            ))
        else
            print("|cff00ccff[VoidcoreReminder]|r Invalid number. Usage: /voidcore thresh 2")
        end
    else
        PrintHelp()
    end
end

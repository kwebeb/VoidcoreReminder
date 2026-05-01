-- VoidcoreReminder.lua
-- Warns you when entering a Midnight Season 1 Mythic raid without Nebulous Voidcores

local ADDON_NAME = "VoidcoreReminder"

-- Currency ID for Nebulous Voidcore (ID 3418 from Wowhead)
local NEBULOUS_VOIDCORE_ID = 3418

-- Midnight Season 1 raid names (matched against GetInstanceInfo zone name)
local MIDNIGHT_S1_RAIDS = {
    ["The Voidspire"]        = true,
    ["The Dreamrift"]        = true,
    ["March on Quel'Danas"]  = true,
}

-- Warn if you have FEWER than this many cores (raid bosses cost 2 each)
local WARN_THRESHOLD = 2

-- ─── Popup Dialog ────────────────────────────────────────────────────────────

local function CreateWarningDialog()
    if VoidcoreReminderDialog then return end

    local dialog = CreateFrame("Frame", "VoidcoreReminderDialog", UIParent, "BackdropTemplate")
    dialog:SetSize(360, 170)
    dialog:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    dialog:SetFrameStrata("DIALOG")
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    dialog:Hide()

    dialog:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile     = true, tileSize = 32, edgeSize = 32,
        insets   = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    dialog:SetBackdropColor(0, 0, 0, 1)

    -- Title bar texture + text
    local titleBg = dialog:CreateTexture(nil, "ARTWORK")
    titleBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBg:SetPoint("TOP", dialog, "TOP", 0, 12)
    titleBg:SetSize(256, 64)

    local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", dialog, "TOP", 0, 2)
    title:SetText("VoidcoreReminder")

    -- Body message
    dialog.bodyText = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dialog.bodyText:SetPoint("TOP", dialog, "TOP", 0, -36)
    dialog.bodyText:SetWidth(310)
    dialog.bodyText:SetJustifyH("CENTER")
    dialog.bodyText:SetSpacing(4)
    dialog.bodyText:SetText("")

    -- OK button (dismisses the dialog)
    local okBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    okBtn:SetSize(100, 22)
    okBtn:SetPoint("BOTTOM", dialog, "BOTTOM", 0, 16)
    okBtn:SetText("OK")
    okBtn:SetScript("OnClick", function() dialog:Hide() end)

    VoidcoreReminderDialog = dialog
end

local function ShowWarningDialog(count, totalEarned, instanceName)
    CreateWarningDialog()
    local d = VoidcoreReminderDialog

    local msg
    if count == 0 and totalEarned == 0 then
        -- Never collected any this season at all
        msg = string.format(
            "|cffff4040You have 0 Nebulous Voidcores!|r\n\n" ..
            "You haven't collected any this season yet.\n" ..
            "Pick them up from |cffffff00Decimus|r in The Voidstorm\nbefore raiding |cffffff00%s|r.",
            instanceName
        )
    else
        -- Has some but below threshold
        msg = string.format(
            "|cffffff00You only have %d Nebulous Voidcore(s).|r\n\n" ..
            "Raid bosses cost |cffffff002 cores|r each for a bonus roll\nin |cffffff00%s|r.\n\n" ..
            "Consider buying more from |cffffff00Decimus|r.",
            count, instanceName
        )
    end

    d.bodyText:SetText(msg)
    d:Show()
    PlaySound(8959, "Master")  -- Raid Warning sound
end

-- ─── Core Logic ──────────────────────────────────────────────────────────────

local function PrintHelp()
    print("|cff00ccff[VoidcoreReminder]|r Commands:")
    print("  |cffffd700/voidcore check|r        - Manually check your Voidcore count")
    print("  |cffffd700/voidcore thresh <n>|r   - Set warning threshold (default: 2)")
    print("  |cffffd700/voidcore help|r          - Show this message")
end

local function CheckAndWarn(manual)
    local instanceName, _, difficultyID = GetInstanceInfo()
    local isMythicRaid = (difficultyID == 16)

    local info        = C_CurrencyInfo.GetCurrencyInfo(NEBULOUS_VOIDCORE_ID)
    local count       = info and info.quantity or 0
    local totalEarned = info and info.totalEarned or 0

    -- If you have 0 but have earned (and spent) cores before, no warning needed
    local spentAll = (count == 0 and totalEarned > 0)

    if manual then
        print(string.format(
            "|cff00ccff[VoidcoreReminder]|r You currently have |cffffd700%d|r Nebulous Voidcore(s) (%d earned this season).",
            count, totalEarned
        ))
        if spentAll then
            print("|cff00ccff[VoidcoreReminder]|r You've spent all your cores this season — no warning will trigger.")
        end
        if isMythicRaid and MIDNIGHT_S1_RAIDS[instanceName] then
            print("|cff00ccff[VoidcoreReminder]|r You are in |cffffff00" .. instanceName .. "|r (Mythic).")
        end
        return
    end

    -- Auto: only warn inside a Mythic S1 raid
    if not isMythicRaid or not MIDNIGHT_S1_RAIDS[instanceName] then return end

    -- Don't warn if cores were spent intentionally
    if spentAll then return end

    if count < WARN_THRESHOLD then
        ShowWarningDialog(count, totalEarned, instanceName)
    else
        print(string.format(
            "|cff00ccff[VoidcoreReminder]|r You have |cffffd700%d|r Nebulous Voidcore(s). You're good for %s (Mythic)!",
            count, instanceName
        ))
    end
end

-- ─── Events ──────────────────────────────────────────────────────────────────

local frame = CreateFrame("Frame", ADDON_NAME .. "Frame", UIParent)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        if VoidcoreReminderDB and VoidcoreReminderDB.threshold then
            WARN_THRESHOLD = VoidcoreReminderDB.threshold
        else
            VoidcoreReminderDB = { threshold = WARN_THRESHOLD }
        end
        print("|cff00ccff[VoidcoreReminder]|r Loaded. Type |cffffd700/voidcore help|r for commands.")

    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(2, function()
            CheckAndWarn(false)
        end)
    end
end)

-- ─── Slash Commands ───────────────────────────────────────────────────────────

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

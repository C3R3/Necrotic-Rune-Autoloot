-----------------------------
--Necrotic Rune Autolooter --
--Author: Nathan Loosevelt --
--Version: 1.0             --
-----------------------------

local addonName, addon = ...
local AutoLootEnabled = true -- Default to enabled

-- List of item IDs to auto-need
local AutoLootItems = {
    [22484] = true,
    --[22485] = true,
}

-- Load saved setting
local function LoadSavedSettings()
    if AutoLootSettings == nil then
        AutoLootSettings = { enabled = true }
    end
    AutoLootEnabled = AutoLootSettings.enabled
end

local function SaveSettings()
    AutoLootSettings.enabled = AutoLootEnabled
end

local function onEvent(self, event, rollId, ...)
    if not AutoLootEnabled then return end

    if event == "START_LOOT_ROLL" then
        local itemLink = GetLootRollItemLink(rollId)
        if itemLink then
            local itemID = tonumber(itemLink:match("item:(%d+)"))
            if itemID and AutoLootItems[itemID] then
                RollOnLoot(rollId, 1) -- Always Need for listed items
            end
        end
    elseif event == "CONFIRM_LOOT_ROLL" then
        ConfirmLootRoll(rollId, 1) -- Auto-confirm BoP loot
        StaticPopup_Hide("CONFIRM_LOOT_ROLL") -- Hides the pop-up if it appears
    end
end

-- Slash command handler
SLASH_AUTOLOOT1 = "/nr"
SlashCmdList.AUTOLOOT = function(msg)
    if msg == "on" then
        AutoLootEnabled = true
        print("|cff00ff00Autoloot for Necrotic Runes is ENABLED.|r")
    elseif msg == "off" then
        AutoLootEnabled = false
        print("|cffff0000Autoloot for Necrotic Runes is DISABLED.|r")
    else
        print("|cffffff00Usage: /nr on|r or |cffffff00/nr off|r")
    end
    SaveSettings()
end

-- Initialize addon
addon.core = {}
addon.core.frame = CreateFrame("Frame")
addon.core.frame:SetScript("OnEvent", onEvent)
addon.core.frame:RegisterEvent("START_LOOT_ROLL")
addon.core.frame:RegisterEvent("CONFIRM_LOOT_ROLL")

-- Load settings when the player logs in
addon.core.frame:RegisterEvent("ADDON_LOADED")
addon.core.frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        LoadSavedSettings()
    else
        onEvent(self, event, arg1)
    end
end)
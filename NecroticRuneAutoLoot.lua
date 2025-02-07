-----------------------------
-- Necrotic Rune Autolooter --
-- Author: Nathan Loosevelt --
-- Version: 1.2             --
-----------------------------

local addonName, addon = ...
local AutoLootEnabled = true -- Default to enabled
local RollChoices = {} -- Store user's roll choices

-- List of item IDs to auto-need
local AutoLootItems = {
    [22484] = true, -- Necrotic Rune
    --[22485] = true, -- Uncomment if needed
}

-- Load saved settings
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
            -- Extract item ID
            local itemID = tonumber(itemLink:match("item:(%d+)"))

            if itemID then
                if AutoLootItems[itemID] then
                    print("|cff00ff00[Necrotic Rune Autolooter] Rolling NEED on item ID: " .. itemID .. "|r")
                    RollOnLoot(rollId, 1) -- Always Need for listed items
                    RollChoices[rollId] = 1 -- Store that we chose Need
                else
                    print("|cffff0000[Necrotic Rune Autolooter] Not rolling on item ID: " .. itemID .. " (not in list)|r")
                end
            else
                print("|cffff9900[Necrotic Rune Autolooter] ERROR: Could not extract item ID from link: " .. itemLink .. "|r")
            end
        else
            print("|cffff9900[Necrotic Rune Autolooter] ERROR: No item link found for roll ID: " .. rollId .. "|r")
        end

    elseif event == "CONFIRM_LOOT_ROLL" then
        -- Only confirm Need if we actually auto-selected Need
        if RollChoices[rollId] == 1 then
            ConfirmLootRoll(rollId, 1)
            StaticPopup_Hide("CONFIRM_LOOT_ROLL") -- Hide the confirmation popup
        end
    end
end

-- Slash command handler
SLASH_NR1 = "/nr"
SlashCmdList.NR = function(msg)
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

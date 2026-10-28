
local LABEL = { ["Show 10 Man Loot"] = "Show Normal Loot", ["Show 25 Man Loot"] = "Show Heroic Loot" }

local function relabel()
  local button = AtlasLoot10Man25ManSwitch
  local names = button and AtlasLoot_TableNames and AtlasLoot_TableNames[button.lootpage]
  if not (names and names[2] == "AtlasLootWotLK") or string.find(button.lootpage, "^VaultofArchavon") then return end
  local ace = LibStub and LibStub("AceLocale-3.0", true)
  local AL = ace and ace:GetLocale("AtlasLoot", true)
  local text = button:GetText()
  for key, label in pairs(LABEL) do
    if text == key or (AL and text == AL[key]) then
      button:SetText(label)
      return
    end
  end
end

local hooked = false
local function hook()
  if hooked or not (hooksecurefunc and AtlasLoot_ShowItemsFrame) then return end
  hooksecurefunc("AtlasLoot_ShowItemsFrame", relabel)
  hooked = true
end

hook()
if not hooked and CreateFrame then
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ADDON_LOADED")
  frame:SetScript("OnEvent", hook)
end

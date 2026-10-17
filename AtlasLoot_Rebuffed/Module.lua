
local SKIP = { SearchResult = true, WishList = true, FilterList = true, EmptyTable = true }
local PAGE = "WhitemaneLegendaries"
local GLYPHS, GEAR = "WhitemaneGlyphs", "WhitemaneGear"
local function ownPage(id)
  return type(id) == "string" and (string.find(id, "^" .. PAGE) or string.find(id, "^" .. GLYPHS) or string.find(id, "^" .. GEAR)) and true or false
end
local PAGE_TITLE = "Whitemane Legendaries"
local MIN_CUSTOM_ID = 100000

local epicByName = {}
local cacheLegendaries = {}
local check
local selector
local current = { crafting = false, menu = false }
local loggedIn = false

local function better(id, ilvl, old)
  if not old then return true end
  if (ilvl == 200) ~= (old.ilvl == 200) then return ilvl == 200 end
  if ilvl ~= old.ilvl then return ilvl > old.ilvl end
  return id < old.id
end

local function readClientCache()
  epicByName, cacheLegendaries = {}, {}
  for _, id in ipairs(ALR_SCAN_IDS or {}) do
    if id >= MIN_CUSTOM_ID then
      local name, _, quality, ilvl, _, _, _, _, equipLoc = GetItemInfo(id)
      if name then
        if quality == 4 then
          if better(id, ilvl or 0, epicByName[name]) then epicByName[name] = { id = id, ilvl = ilvl or 0 } end
        elseif quality == 5 and equipLoc and equipLoc ~= "" and not string.find(name, "^Test ") then
          table.insert(cacheLegendaries, id)
        end
      end
    end
  end
end

local function twinOf(id, text)
  local shipped = ALR_UPGRADES and ALR_UPGRADES[id]
  if shipped then return shipped[1], shipped[2] end
  local name, _, quality = GetItemInfo(id)
  text = type(text) == "string" and text or ""
  if not quality then quality = tonumber(string.match(text, "^=q(%d)=")) end
  if quality ~= 3 then return nil end
  name = name or string.gsub(text, "^=q%d=", "")
  local twin = epicByName[name]
  if twin then return twin.id, name end
  return nil
end

local function shownAs(id, text)
  local step = ALR_Settings.upgrade or 0
  local chain = step > 0 and ALR_UPGRADE_CHAINS and ALR_UPGRADE_CHAINS[id]
  if chain and #chain > 0 then
    local s = chain[math.min(step, #chain)]
    return s[1], s[2], s[4] or 4
  end
  if ALR_Settings.epic then
    local tid, tname = twinOf(id, text)
    if tid then return tid, tname, 4 end
  end
  return nil
end

local NAME_FIX_OK = GetLocale and (GetLocale() == "enUS" or GetLocale() == "enGB")

local function fixedText(id, text)
  local good = NAME_FIX_OK and ALR_NAME_FIXES and ALR_NAME_FIXES[id]
  if not good or type(text) ~= "string" then return text end
  return (string.match(text, "^=q%d=") or "") .. good
end

local function apply()
  if not AtlasLoot_Data or not loggedIn then return end
  for dataID, data in pairs(AtlasLoot_Data) do
    if type(data) == "table" and not SKIP[dataID] and not ownPage(dataID) then
      for k, entry in pairs(data) do
        if type(k) == "number" and type(entry) == "table" and type(entry.alrStock or entry[2]) == "number" and (entry.alrStock or entry[2]) > 0 then
          local base, btext = entry.alrStock or entry[2], entry.alrText or entry[4]
          btext = fixedText(base, btext)
          if entry.alrStock then entry.alrText = btext else entry[4] = btext end
          local sid, sname, sq = shownAs(base, btext)
          if sid then
            entry.alrStock, entry.alrText = base, btext
            entry[2], entry[4] = sid, "=q" .. sq .. "=" .. sname
          elseif entry.alrStock then
            entry[2], entry[4] = base, btext
            entry.alrStock, entry.alrText = nil, nil
          end
        elseif type(k) == "number" and type(entry) == "table" and type(entry[2]) == "string" and string.sub(entry[2], 1, 1) == "s"
            and tonumber(entry.alrCraft or entry[3]) then
          local base = tonumber(entry.alrCraft or entry[3])
          local btext = entry.alrText or entry[4]
          local tid = ALR_Settings.epic and twinOf(base, btext)
          if tid then
            entry.alrCraft, entry.alrText = entry.alrCraft or entry[3], btext
            entry[3], entry[4] = tostring(tid), "=q4=" .. string.gsub(btext, "^=q%d=", "")
          elseif entry.alrCraft then
            entry[3], entry[4] = entry.alrCraft, btext
            entry.alrCraft, entry.alrText = nil, nil
          end
        end
      end
    end
  end
end

local function pageInfo()
  local r = AtlasLootItemsFrame and AtlasLootItemsFrame.refreshOri
  local id = r and r[1]
  local data = id and AtlasLoot_Data and AtlasLoot_Data[id]
  if current.menu or type(data) ~= "table" or SKIP[id] or ownPage(id) then
    return nil, false, false
  end
  local twins, chains = false, false
  for k, entry in pairs(data) do
    if type(k) == "number" and type(entry) == "table" then
      local base = entry.alrStock or entry[2]
      if type(base) == "number" and base > 0 then
        if twinOf(base, entry.alrText or entry[4]) then twins = true end
        local c = ALR_UPGRADE_CHAINS and ALR_UPGRADE_CHAINS[base]
        if c and #c > 0 then chains = true end
      elseif type(entry[2]) == "string" and string.sub(entry[2], 1, 1) == "s" and tonumber(entry.alrCraft or entry[3]) then
        if twinOf(tonumber(entry.alrCraft or entry[3]), entry.alrText or entry[4]) then twins = true end
      end
    end
  end
  return data, twins, chains
end

local NAME_DIM = 0.45

local function decorate()
  local filter = AtlasLootFilterCheck
  local data, twins, chains = pageInfo()
  if check then
    if twins and (current.crafting or (filter and filter:IsShown())) then check:Show() else check:Hide() end
  end
  if selector then
    local on = chains and filter and filter:IsShown()
    for _, f in ipairs(selector) do if on then f:Show() else f:Hide() end end
  end
  for i = 1, 30 do
    local icon, name = _G["AtlasLootItem_" .. i .. "_Icon"], _G["AtlasLootItem_" .. i .. "_Name"]
    if icon and icon.SetDesaturated then icon:SetDesaturated(nil) end
    if name and name.SetAlpha then name:SetAlpha(1) end
  end
  local step = ALR_Settings.upgrade or 0
  if step == 0 or not chains then return end
  local short = {}
  for k, entry in pairs(data) do
    if type(k) == "number" and type(entry) == "table" then
      local base = entry.alrStock or entry[2]
      if type(base) == "number" and base > 0 then
        local c = ALR_UPGRADE_CHAINS and ALR_UPGRADE_CHAINS[base]
        if not c or #c < step then short[entry[2]] = true end
      end
    end
  end
  for i = 1, 30 do
    local button = _G["AtlasLootItem_" .. i]
    if button and button:IsShown() and short[button.itemID] then
      local icon, name = _G["AtlasLootItem_" .. i .. "_Icon"], _G["AtlasLootItem_" .. i .. "_Name"]
      if icon and icon.SetDesaturated then icon:SetDesaturated(1) end
      if name and name.SetAlpha then name:SetAlpha(NAME_DIM) end
    end
  end
end

local function refresh()
  local r = AtlasLootItemsFrame and AtlasLootItemsFrame.refreshOri
  if r and r[1] and AtlasLootItemsFrame:IsVisible() and AtlasLoot_ShowItemsFrame then
    AtlasLoot_ShowItemsFrame(r[1], r[2], r[3], r[4])
  end
end

local function countTwins()
  local n = 0
  for _ in pairs(ALR_UPGRADES or {}) do n = n + 1 end
  local c = 0
  for _ in pairs(epicByName) do c = c + 1 end
  return n, c
end

local function makeCheck()
  if check or not AtlasLootFilterCheck then return end
  local filter = AtlasLootFilterCheck
  check = CreateFrame("CheckButton", "AtlasLootRebuffedEpicCheck", filter:GetParent(), "OptionsCheckButtonTemplate")
  check:SetPoint("LEFT", AtlasLootFilterCheckText, "RIGHT", 8, 0)
  AtlasLootRebuffedEpicCheckText:SetText("Epic")
  check:SetChecked(ALR_Settings.epic)
  check:SetScript("OnShow", function(self) self:SetFrameLevel(filter:GetFrameLevel() + 2) end)
  check:SetFrameLevel(filter:GetFrameLevel() + 2)
  filter:SetHitRectInsets(0, -(AtlasLootFilterCheckText:GetStringWidth() + 4), 0, 0)
  check:SetScript("OnClick", function(self)
    ALR_Settings.epic = self:GetChecked() and true or false
    apply()
    if ALR_ApplyVendorPrices then ALR_ApplyVendorPrices() end
    refresh()
  end)
  check:SetScript("OnEnter", function(self)
    local shipped, cached = countTwins()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Epic")
    GameTooltip:AddLine("Shows the violet Whitemane version of blue items instead of the blue one (same item level; heroic dungeons 200).", 1, 1, 1, true)
    GameTooltip:AddLine(string.format("Known: %d from the shipped list.", shipped), 0.7, 0.7, 0.7, true)
    GameTooltip:Show()
  end)
  check:SetScript("OnLeave", function() GameTooltip:Hide() end)
  decorate()
  filter:HookScript("OnShow", decorate)
  filter:HookScript("OnHide", decorate)
  if hooksecurefunc and AtlasLoot_ShowItemsFrame then
    hooksecurefunc("AtlasLoot_ShowItemsFrame", function(dataID, dataSource)
      current.crafting = dataSource == "AtlasLootCrafting"
      local names = AtlasLoot_TableNames and AtlasLoot_TableNames[dataID]
      current.menu = names and names[2] == "Menu" or false
      check:ClearAllPoints()
      if current.crafting then
        check:SetPoint("LEFT", filter, "LEFT", 0, 0)
      else
        check:SetPoint("LEFT", AtlasLootFilterCheckText, "RIGHT", 8, 0)
      end
      decorate()
    end)
  end
  if hooksecurefunc and AtlasLoot_GenerateAtlasMenu then
    hooksecurefunc("AtlasLoot_GenerateAtlasMenu", function()
      current.menu = true
      decorate()
    end)
  end
  if ElvUI then
    pcall(function()
      local E = unpack(ElvUI)
      local S = E and E.GetModule and E:GetModule("Skins", true)
      if S and S.HandleCheckBox then S:HandleCheckBox(check) end
    end)
  end
end

local function makeUpgradeSelector()
  if selector or not AtlasLootFilterCheck then return end
  local filter = AtlasLootFilterCheck
  local parent = filter:GetParent()
  local maxStep = ALR_UPGRADE_MAX or 0
  local label = parent:CreateFontString("AtlasLootRebuffedUpgradeLabel", "OVERLAY", "GameFontNormal")
  label:SetPoint("LEFT", parent, "BOTTOMLEFT", 20, 40)
  label:SetText("Upgrade:")
  local down = CreateFrame("Button", "AtlasLootRebuffedUpgradeDown", parent, "UIPanelButtonTemplate")
  down:SetSize(22, 20)
  down:SetText("<")
  down:SetPoint("LEFT", label, "RIGHT", 6, 0)
  local value = parent:CreateFontString("AtlasLootRebuffedUpgradeValue", "OVERLAY", "GameFontHighlight")
  value:SetWidth(26)
  value:SetPoint("LEFT", down, "RIGHT", 4, 0)
  local up = CreateFrame("Button", "AtlasLootRebuffedUpgradeUp", parent, "UIPanelButtonTemplate")
  up:SetSize(22, 20)
  up:SetText(">")
  up:SetPoint("LEFT", value, "RIGHT", 4, 0)
  local function setStep(n)
    n = math.max(0, math.min(maxStep, n))
    ALR_Settings.upgrade = n
    value:SetText("+" .. n)
    apply()
    if ALR_ApplyVendorPrices then ALR_ApplyVendorPrices() end
    refresh()
  end
  down:SetScript("OnClick", function() setStep((ALR_Settings.upgrade or 0) - 1) end)
  up:SetScript("OnClick", function() setStep((ALR_Settings.upgrade or 0) + 1) end)
  local function tip(self)
    local n = 0
    for _ in pairs(ALR_UPGRADE_CHAINS or {}) do n = n + 1 end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Upgrade")
    GameTooltip:AddLine("Shows each item at the chosen Whitemane upgrade step. Example: a T7 piece of item level 213 shows 232 at +3. An item without that step is greyed out and shows its last step. +0 shows AtlasLoot unchanged. Starts at +0 at every login.", 1, 1, 1, true)
    GameTooltip:AddLine(string.format("%d items have upgrade steps. The longest chain has %d steps.", n, maxStep), 0.7, 0.7, 0.7, true)
    GameTooltip:Show()
  end
  for _, b in ipairs({ down, up }) do
    b:SetScript("OnEnter", tip)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
  end
  value:SetText("+" .. math.max(0, math.min(maxStep, ALR_Settings.upgrade or 0)))
  selector = { label, down, value, up }
  decorate()
  filter:HookScript("OnShow", decorate)
  filter:HookScript("OnHide", decorate)
  if ElvUI then
    pcall(function()
      local E = unpack(ElvUI)
      local S = E and E.GetModule and E:GetModule("Skins", true)
      if S and S.HandleButton then S:HandleButton(down); S:HandleButton(up) end
    end)
  end
end

local function buildLegendaries()
  if not AtlasLoot_Data or not AtlasLoot_TableNames then return end
  local seen = {}
  local rows = {}
  for _, row in ipairs(ALR_LEGENDARIES or {}) do
    if not seen[row[1]] then
      seen[row[1]] = true
      table.insert(rows, { row[1], row[2], row[3], row[4] or select(4, GetItemInfo(row[1])) or 0 })
    end
  end
  for _, id in ipairs(cacheLegendaries) do
    if not seen[id] then
      seen[id] = true
      local name, _, _, ilvl = GetItemInfo(id)
      table.insert(rows, { id, "=q5=" .. (name or ("item " .. id)), "", ilvl or 0 })
    end
  end
  local cosmetic, gear = {}, {}
  for _, row in ipairs(rows) do
    if (row[4] or 0) <= 1 then table.insert(cosmetic, row) else table.insert(gear, row) end
  end
  rows = gear
  table.sort(cosmetic, function(a, b) return a[1] < b[1] end)
  local groups, byName = {}, {}
  for _, row in ipairs(rows) do
    local name = string.gsub(row[2], "^=q%d=", "")
    local grp = byName[name]
    if not grp then
      grp = { first = row[1], rows = {} }
      byName[name] = grp
      table.insert(groups, grp)
    end
    if row[1] < grp.first then grp.first = row[1] end
    table.insert(grp.rows, row)
  end
  table.sort(groups, function(a, b) return a.first < b.first end)
  local pages = { {} }
  for _, grp in ipairs(groups) do
    table.sort(grp.rows, function(a, b)
      if a[4] ~= b[4] then return a[4] < b[4] end
      return a[1] < b[1]
    end)
    local cur = pages[#pages]
    if #cur > 0 and #cur + #grp.rows > 30 then
      cur = {}
      table.insert(pages, cur)
    end
    for _, row in ipairs(grp.rows) do
      if #cur == 30 then cur = {}; table.insert(pages, cur) end
      table.insert(cur, row)
    end
  end
  if #cosmetic > 0 then
    local cur = { { 0, "=q6=Cosmetic legendaries", "=ds=Item level 0-1. No stats." } }
    if #pages[1] == 0 then pages[1] = cur else table.insert(pages, cur) end
    for _, row in ipairs(cosmetic) do
      if #cur == 30 then cur = {}; table.insert(pages, cur) end
      table.insert(cur, row)
    end
  end
  for p, list in ipairs(pages) do
    local key = (p == 1) and PAGE or (PAGE .. p)
    local t = { Back = "ALR_WHITEMANEMENU" }
    t.Prev = (p == 1) and "Legendaries" or ((p == 2) and PAGE or (PAGE .. (p - 1)))
    if p < #pages then t.Next = PAGE .. (p + 1) end
    for i, row in ipairs(list) do
      t[i] = { i, row[1], row[1] == 0 and "INV_Misc_Bag_10" or "", row[2], row[3] }
    end
    AtlasLoot_Data[key] = t
    AtlasLoot_TableNames[key] = { (#pages > 1) and (PAGE_TITLE .. " " .. p) or PAGE_TITLE, "AtlasLootWotLK" }
  end
end

local function buildExtraPages()
  if not AtlasLoot_Data or not AtlasLoot_TableNames then return end
  local glyphs, gear = {}, {}
  for _, row in ipairs(ALR_WHITEMANE_ITEMS or {}) do
    if row[5] == "glyph" then table.insert(glyphs, row) else table.insert(gear, row) end
  end
  if #glyphs > 0 then
    local t = { Back = "ALR_WHITEMANEMENU" }
    for i, row in ipairs(glyphs) do
      if i > 30 then break end
      t[i] = { i, row[1], "", row[2], row[3] }
    end
    AtlasLoot_Data[GLYPHS] = t
    AtlasLoot_TableNames[GLYPHS] = { "Whitemane Glyphs", "AtlasLootWotLK" }
  end
  if #gear == 0 then return end
  local pages, cur, lastLevel = {}, {}, nil
  table.insert(pages, cur)
  for _, row in ipairs(gear) do
    if row[4] ~= lastLevel then
      if #cur >= 29 then cur = {}; table.insert(pages, cur) end
      table.insert(cur, { 0, "=q6=Item level " .. row[4], "" })
      lastLevel = row[4]
    end
    if #cur == 30 then cur = {}; table.insert(pages, cur) end
    table.insert(cur, { row[1], row[2], row[3] })
  end
  for p, list in ipairs(pages) do
    local key = (p == 1) and GEAR or (GEAR .. p)
    local t = { Back = "ALR_WHITEMANEMENU" }
    if p > 1 then t.Prev = (p == 2) and GEAR or (GEAR .. (p - 1)) end
    if p < #pages then t.Next = GEAR .. (p + 1) end
    for i, row in ipairs(list) do
      t[i] = { i, row[1], row[1] == 0 and "INV_Misc_Bag_10" or "", row[2], row[3] }
    end
    AtlasLoot_Data[key] = t
    AtlasLoot_TableNames[key] = { (#pages > 1) and ("Whitemane Gear " .. p) or "Whitemane Gear", "AtlasLootWotLK" }
  end
end

local function linkLegendaries()
  local stock = AtlasLoot_Data and AtlasLoot_Data["Legendaries"]
  if stock and AtlasLoot_Data[PAGE] and not stock.Next then stock.Next = PAGE end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, arg1)
  if event == "ADDON_LOADED" then
    if arg1 == "AtlasLoot_Rebuffed" then
      ALR_Settings = ALR_Settings or {}
      if ALR_Settings.epic == nil then ALR_Settings.epic = false end
      if ALR_Settings.upgrade == nil then ALR_Settings.upgrade = 0 end
    elseif loggedIn and type(arg1) == "string" and string.find(arg1, "^AtlasLoot") then
      linkLegendaries()
      apply()
    end
  elseif event == "PLAYER_LOGIN" then
    loggedIn = true
    ALR_Settings.upgrade = 0
    readClientCache()
    buildLegendaries()
    buildExtraPages()
    linkLegendaries()
    makeCheck()
    makeUpgradeSelector()
    apply()
  end
end)

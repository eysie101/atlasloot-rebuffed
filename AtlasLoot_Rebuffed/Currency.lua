
local MENU = "ALR_WHITEMANEMENU"
local PREFIX = "ALR_CUR_"
local SUFFIX = " |cff33ff99Rebuffed|r"

local CURRENCIES = {
  { 131009, "Echo of the Necropolis", "inv_gauntlets_55", 2 },
  { 131010, "Echo of the Titans", "inv_gauntlets_55", 3 },
  { 131011, "Echo of the Crusade", "inv_gauntlets_55", 4 },
  { 131012, "Echo of the Dawn", "INV_Echo_ICC", 5 },
  { 315001, "Echo of Karazhan", "Spell_Shadow_ScourgeBuild", 6 },
  { 131008, "Emblem of Ascension", "inv_gauntlets_55", 17 },
  { 132007, "Emblem of Holy Ascension", "INV_Emblem_Ascension", 18 },
  { 132008, "Emblem of Frostbound Ascension", "INV_Emblem_Ascension", 19 },
  { 131014, "Emblem of Eternity", "INV_Emblem_Eternity", 20 },
  { 315000, "Emblem of Shadow", "INV_Elemental_Primal_Shadow", 21 },
  { 131015, "Scarlet Sigil", "INV_Misc_Token_ScarletCrusade", 8 },
  { 1000001, "Mark of Savagery", "Spell_DeathKnight_BloodTap", 9 },
  { 40752, "Justice", "PVECurrency-Justice", 23 },
  { 40753, "Valor", "PVECurrency-Valor", 24 },
}
local VENDOR_HINT = {
  [131009] = "Echo of Kel'Thuzad in Dalaran",
}

local function lookupAll()
  local all = {}
  for id, rec in pairs(ALR_VENDOR_SHIPPED or {}) do all[id] = rec end
  for id, rec in pairs(ALR_Vendor and ALR_Vendor.items or {}) do all[id] = rec end
  return all
end

local function costOf(rec, cid)
  for _, c in ipairs(rec.cost or {}) do
    if c[1] == cid then return c[2] or 0 end
  end
  return nil
end

local function itemText(id)
  local name, _, quality = GetItemInfo(id)
  return "=q" .. (quality or 4) .. "=" .. (name or ("item " .. id))
end

local function buildPages()
  if not AtlasLoot_Data or not AtlasLoot_TableNames then return end
  local all = lookupAll()
  local menu = { Back = "SETMENU" }
  for _, cur in ipairs(CURRENCIES) do
    local cid, cname, icon, slot = cur[1], cur[2], cur[3], cur[4]
    cname = (GetItemInfo(cid)) or cname
    local rows = {}
    for id, rec in pairs(all) do
      local n = costOf(rec, cid)
      if n then table.insert(rows, { id, n }) end
    end
    table.sort(rows, function(a, b)
      if a[2] ~= b[2] then return a[2] < b[2] end
      return a[1] < b[1]
    end)
    local p = 1
    while AtlasLoot_Data[PREFIX .. cid .. (p == 1 and "" or ("_" .. p))] do
      AtlasLoot_Data[PREFIX .. cid .. (p == 1 and "" or ("_" .. p))] = nil
      p = p + 1
    end
    local npages = math.max(1, math.ceil(#rows / 30))
    for pg = 1, npages do
      local key = PREFIX .. cid .. (pg == 1 and "" or ("_" .. pg))
      local t = { Back = MENU }
      if pg > 1 then t.Prev = PREFIX .. cid .. (pg == 2 and "" or ("_" .. (pg - 1))) end
      if pg < npages then t.Next = PREFIX .. cid .. "_" .. (pg + 1) end
      if #rows == 0 then
        t[1] = { 1, 0, icon, "=q6=No items noted yet", "=ds=" .. (VENDOR_HINT[cid] and ("Open the vendor " .. VENDOR_HINT[cid] .. ".") or ("Open a vendor that accepts " .. cname .. ".")) .. " Its items then appear here." }
      else
        for i = 1, 30 do
          local r = rows[(pg - 1) * 30 + i]
          if not r then break end
          t[i] = { i, r[1], "", itemText(r[1]), "", tostring(r[2]) .. " " .. cname }
        end
      end
      AtlasLoot_Data[key] = t
      AtlasLoot_TableNames[key] = { npages > 1 and (cname .. " " .. pg) or cname, "AtlasLootWotLK" }
    end
    local noted = #rows > 0 and (#rows .. (#rows == 1 and " item" or " items")) or "nothing noted yet"
    table.insert(menu, { slot, PREFIX .. cid, icon, "=ds=" .. cname, "=q5=" .. noted })
  end
  if AtlasLoot_Data["WhitemaneLegendaries"] then
    local n, c, p, page, inCosmetic = 0, 0, "WhitemaneLegendaries", 1, false
    while AtlasLoot_Data[p] do
      for i = 1, 30 do
        local e = AtlasLoot_Data[p][i]
        if type(e) == "table" then
          if e[2] == 0 then inCosmetic = true
          elseif inCosmetic then c = c + 1 else n = n + 1 end
        end
      end
      page = page + 1
      p = "WhitemaneLegendaries" .. page
    end
    table.insert(menu, { 11, "WhitemaneLegendaries", "INV_Staff_Medivh", "=ds=Whitemane Legendaries",
      "=q5=" .. n .. " legendary items" .. (c > 0 and (", " .. c .. " cosmetic") or "") })
  end
  local gear, glyphs = 0, 0
  for _, row in ipairs(ALR_WHITEMANE_ITEMS or {}) do
    if row[5] == "glyph" then glyphs = glyphs + 1 else gear = gear + 1 end
  end
  if AtlasLoot_Data["WhitemaneGear"] then
    table.insert(menu, { 12, "WhitemaneGear", "INV_Chest_Plate16", "=ds=Whitemane Gear", "=q5=" .. gear .. " items, item level 200 and up" })
  end
  if AtlasLoot_Data["WhitemaneGlyphs"] then
    table.insert(menu, { 13, "WhitemaneGlyphs", "INV_Glyph_MajorDruid", "=ds=Whitemane Glyphs", "=q5=" .. glyphs .. " glyphs" })
  end
  AtlasLoot_Data[MENU] = menu
  AtlasLoot_TableNames[MENU] = { "Whitemane", "Menu" }
  local sm = AtlasLoot_Data["SETMENU"]
  if sm then
    local have = false
    for _, e in ipairs(sm) do if e[2] == MENU then have = true end end
    if not have then
      table.insert(sm, 1, { 1, MENU, "INV_Misc_Token_ScarletCrusade", "=ds=Whitemane", "=q5=Legendaries, gear, glyphs and " .. #CURRENCIES .. " currencies" })
    end
  end
  if ALR_ApplyVendorPrices then ALR_ApplyVendorPrices() end
end
ALR_BuildCurrencyPages = buildPages

local function titleSuffix()
  if type(ATLASLOOT_VERSION) ~= "string" or string.find(ATLASLOOT_VERSION, "Rebuffed", 1, true) then return end
  local old = ATLASLOOT_VERSION
  ATLASLOOT_VERSION = old .. SUFFIX
  for _, name in ipairs({ "AtlasLootDefaultFrame", "AtlasLootPanel", "AtlasLootOptionsFrame", "AtlasLootInfo" }) do
    local f = _G[name]
    if f and f.GetRegions then
      for _, r in ipairs({ f:GetRegions() }) do
        if r and r.GetObjectType and r:GetObjectType() == "FontString" and r:GetText() == old then
          r:SetText(ATLASLOOT_VERSION)
        end
      end
    end
  end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
  titleSuffix()
  buildPages()
end)

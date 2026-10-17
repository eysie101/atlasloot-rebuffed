
local EMBLEM_TOKENS = { "#eoftriumph#", "#eofheroism#", "#eoffrost#", "#eofconquest#", "#eofvalor#", "#heroic#" }
local SKIP = { SearchResult = true, WishList = true, FilterList = true, EmptyTable = true }

local state

local function msg(text)
  DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99AtlasLoot Rebuffed:|r " .. text)
end

local function idOf(link)
  return link and tonumber(string.match(link, "item:(%d+)"))
end

local function npcId(guid)
  return guid and tonumber(string.sub(guid, 7, 12), 16)
end

local function readMerchant()
  if not state then return end
  local npc = npcId(UnitGUID("npc"))
  local name = UnitName("npc")
  local n, got = GetMerchantNumItems() or 0, 0
  for i = 1, n do
    local id = idOf(GetMerchantItemLink(i))
    if id then
      local _, _, copper, _, _, _, ext = GetMerchantItemInfo(i)
      local rec = { c = copper or 0, n = name, npc = npc, t = date("%Y-%m-%d") }
      if ext then
        local honor, arena, k = GetMerchantItemCostInfo(i)
        rec.h, rec.a = honor or 0, arena or 0
        rec.cost = {}
        for j = 1, (k or 0) do
          local tex, value, link = GetMerchantItemCostItem(i, j)
          table.insert(rec.cost, { idOf(link), value, tex })
        end
      end
      state.items[id] = rec
      got = got + 1
    end
  end
  if npc and got > 0 then
    state.npcs[npc] = { name = name, zone = GetZoneText(), count = n, t = date("%Y-%m-%d") }
  end
  return got
end

local function priceText(rec)
  local parts = {}
  for _, c in ipairs(rec.cost or {}) do
    local tex = c[3] or (c[1] and GetItemIcon(c[1]))
    table.insert(parts, tostring(c[2]) .. (tex and (" |T" .. tex .. ":0|t") or (" item " .. tostring(c[1]))))
  end
  if rec.h and rec.h > 0 then
    table.insert(parts, rec.h .. " |TInterface\\PVPFrame\\PVP-Currency-" .. (UnitFactionGroup("player") or "Alliance") .. ":0|t")
  end
  if rec.a and rec.a > 0 then
    table.insert(parts, rec.a .. " |TInterface\\PVPFrame\\PVP-ArenaPoints-Icon:0|t")
  end
  if rec.c and rec.c > 0 then
    table.insert(parts, GetCoinTextureString and GetCoinTextureString(rec.c) or (math.floor(rec.c / 10000) .. "g"))
  end
  return table.concat(parts, ", ")
end

local function isEmblemPrice(text)
  if type(text) ~= "string" then return false end
  for _, tok in ipairs(EMBLEM_TOKENS) do
    if string.find(text, tok, 1, true) then return true end
  end
  return false
end

local function lookup(id)
  return (state and state.items[id]) or (ALR_VENDOR_SHIPPED and ALR_VENDOR_SHIPPED[id])
end

local function applyPrices()
  if not AtlasLoot_Data then return end
  for dataID, data in pairs(AtlasLoot_Data) do
    if type(data) == "table" and not SKIP[dataID] then
      for k, entry in pairs(data) do
        if type(k) == "number" and type(entry) == "table" and type(entry[2]) == "number" then
          if entry.alrPrice == nil then entry.alrPrice = entry[6] or false end
          local rec = lookup(entry.alrStock or entry[2]) or lookup(entry[2])
          if rec then
            entry[6] = priceText(rec)
          elseif isEmblemPrice(entry.alrPrice) then
            entry[6] = entry.alrPrice .. " ?"
          elseif entry.alrPrice then
            entry[6] = entry.alrPrice
          end
        end
      end
    end
  end
end
ALR_ApplyVendorPrices = applyPrices

local function refresh()
  local r = AtlasLootItemsFrame and AtlasLootItemsFrame.refreshOri
  if r and r[1] and AtlasLootItemsFrame:IsVisible() and AtlasLoot_ShowItemsFrame then
    AtlasLoot_ShowItemsFrame(r[1], r[2], r[3], r[4])
  end
end

local loggedIn = false
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_UPDATE")
frame:SetScript("OnEvent", function(self, event, arg1)
  if event == "ADDON_LOADED" then
    if arg1 == "AtlasLoot_Rebuffed" then
      ALR_Vendor = ALR_Vendor or {}
      state = ALR_Vendor
      state.version = 1
      state.items = state.items or {}
      state.npcs = state.npcs or {}
    elseif loggedIn and type(arg1) == "string" and string.find(arg1, "^AtlasLoot") then
      applyPrices()
    end
  elseif event == "PLAYER_LOGIN" then
    loggedIn = true
    applyPrices()
  elseif event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" then
    if readMerchant() then
      if ALR_BuildCurrencyPages then ALR_BuildCurrencyPages() end
      applyPrices()
      refresh()
    end
  end
end)

SLASH_ATLASLOOTREBUFFED1 = SLASH_ATLASLOOTREBUFFED1 or "/alr"
local scanCommand = SlashCmdList["ATLASLOOTREBUFFED"]
SlashCmdList["ATLASLOOTREBUFFED"] = function(input)
  local cmd = string.lower(input or "")
  if cmd == "vendor" or cmd == "vendors" then
    local nv, ni = 0, 0
    for _ in pairs(state and state.npcs or {}) do nv = nv + 1 end
    for _ in pairs(state and state.items or {}) do ni = ni + 1 end
    msg(string.format("%d vendor%s noted, %d items. Opening a vendor reads its prices. No server query is sent.",
      nv, nv == 1 and "" or "s", ni))
    for _, v in pairs(state and state.npcs or {}) do
      msg(string.format("  %s (%s): %d items, %s", tostring(v.name), tostring(v.zone), v.count or 0, tostring(v.t)))
    end
  elseif scanCommand then
    scanCommand(input)
  else
    msg("command: /alr vendor lists the vendors whose prices were read")
  end
end

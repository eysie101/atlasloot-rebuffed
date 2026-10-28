AtlasLoot Rebuffed 0.2.27

Whitemane Rebuffed items inside AtlasLoot Enhanced.
The addon is a folder of its own. It changes no AtlasLoot file.
Delete the folder and AtlasLoot is as before.
This is the share edition. It has no scan.


REQUIREMENTS

AtlasLoot Enhanced for WotLK 3.3.5.
It needs the folders AtlasLoot and AtlasLoot_WrathoftheLichKing.
Crafting pages also need the folder AtlasLoot_Crafting.


INSTALL

1. Copy the folder AtlasLoot_Rebuffed into <WoW folder>\Interface\AddOns.
2. Start WoW, or restart it if it runs.

<WoW folder> is the folder of your WoW client.


EPIC CHECKBOX

The checkbox Epic sits right of AtlasLoot's checkbox Filter.

- It shows only on pages with at least one blue item that has a violet version.
- Ticked, a blue item shows its violet Whitemane version of the same name.
- Name, colour, icon, tooltip, wishlist and dressing room then use the violet item.
- With several violet versions of one name, item level 200 wins, else the highest.
- 1819 blue items have a violet version.
- The setting is saved per account.

Crafting pages:

- AtlasLoot hides Filter there. Epic takes its place.
- 143 crafted blue items have a violet version.
- The recipe name stays and turns violet. The icon and the dressing room use the violet item.
- The wishlist stores the recipe.
- The tooltip on hover shows the recipe.
- For the violet item in that tooltip, set AtlasLoot's option 'Treat Crafted Items:' to 'As Items'.
- Whether crafting can give the violet version is not known.


UPGRADE SELECTOR

'Upgrade: < +0 >' sits on the left of the Filter row.

- It shows only on pages with at least one item that has upgrade steps.
- '>' raises the step by 1. '<' lowers it by 1. The highest step is 5.
- Each item shows its upgrade of that step.
- An item without that step is greyed out: grey icon, dimmed name. It shows its last step, or the item itself.
- '+0' shows no upgrade and greys out nothing.
- 380 items have upgrade steps.
- It starts at +0 at every login.


ASCENDED SELECTOR

'Ascended: < 0 >' sits right of the upgrade selector.

- It shows only on pages with at least one item that has an Ascended version.
- '>' and '<' step through 0, I, II and III.
- I comes with Ulduar, II with Trial of the Crusader, III with Icecrown Citadel.
- Each item shows its Ascended version of that tier. It wins over Epic and the upgrade step.
- An item without that version is greyed out.
- '0' shows no Ascended version and greys out nothing.
- 350 items have Ascended versions.
- It starts at 0 at every login.


WHITEMANE LEGENDARIES

- AtlasLoot's page 'Legendary Items' has a Next button to them.
- 35 items. The cosmetic ones, item level 0 or 1, follow on their own page.
- AtlasLoot's search finds them.


WHITEMANE GEAR AND GLYPHS

Whitemane items that AtlasLoot itself does not list.

- Whitemane Gear: 183 items, grouped by item level: item level 200 and up, and the Secondhand set (item level 187,
  one piece per slot and armour class, relics, weapons).
- Whitemane Glyphs: 5 glyphs.
- Both are in Collections, Whitemane. AtlasLoot's search finds them.

The glyphs are also on AtlasLoot's own crafting pages:

- Crafting, Inscription, then Major Glyph or Minor Glyph of their class. 5 glyphs.
- They follow the stock glyphs. A full page gets a second page behind Next.
- Their source reads Whitemane. A glyph without a recipe in the client reads 'Whitemane, no recipe'.
  Once a vendor has shown its price, the price stands there instead.


VENDOR PRICES

- Open a vendor. The addon reads the prices from its window and saves them.
- No query goes to the server.
- AtlasLoot then shows that price for the item on its loot pages.
- Search results and the wishlist keep AtlasLoot's own price.
- An emblem price that no vendor has shown yet gets a '?'. It is AtlasLoot's old price.
- /alr vendor lists the vendors read so far.


COLLECTIONS, WHITEMANE

- AtlasLoot's tab Collections has a new first entry: Whitemane.
- It lists Whitemane Legendaries, Whitemane Gear, Whitemane Glyphs and 14 currencies.
- A currency page lists the items that a vendor sold for it, cheapest first.
- Open such a vendor once. The page fills at once.
- The AtlasLoot title bar ends in 'Rebuffed'.


RAID SIZE BUTTON

AtlasLoot's button that switches between the loot of 10 and 25 players.

- In the level-80 raids it reads 'Show Normal Loot' and 'Show Heroic Loot'. Whitemane calls the loot of 25 players Heroic.
- 'Show Normal Loot' opens the page for 10 players, 'Show Heroic Loot' the page for 25 players.
- In Vault of Archavon it stays 'Show 10 Man Loot' and 'Show 25 Man Loot'.


CORRECTED ITEM NAMES

- For 67 items AtlasLoot's name differs from the game's. The game's name is shown.
- Example: 'Valorous Crypstalker Tunic' becomes 'Valorous Cryptstalker Tunic'.
- This works on English clients only.


REMOVE

Delete the folder <WoW folder>\Interface\AddOns\AtlasLoot_Rebuffed.
The saved settings are in <WoW folder>\WTF\Account\<ACCOUNT>\SavedVariables\AtlasLoot_Rebuffed.lua.

<ACCOUNT> is the folder of your WoW account.

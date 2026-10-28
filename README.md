# AtlasLoot Rebuffed

Whitemane Rebuffed AtlasLoot Module

Works with the AtlasLoot of the Whitemane launcher: AtlasLoot Enhanced for WotLK 3.3.5.
The addon is a folder of its own. It changes no AtlasLoot file.

## Changes

- **Rare->Epic checkbox**: a blue item shows its violet Whitemane version. Also on crafting pages.
- **Upgrade selector**: `Upgrade: < +0 >` shows each item at the chosen upgrade step (up to +5). Items without that step are greyed out.
- **Ascended selector**: `Ascended: < 0 >` shows each dungeon item as its Ascended I / II / III version (Ulduar / Trial of the Crusader / Icecrown Citadel). Items without that version are greyed out.
- **Whitemane**: legendaries, gear, glyphs, 14 currencies (in Collections; the legendaries also after AtlasLoot's "Legendary Items"; the glyphs also on the Crafting > Inscription pages). The gear pages list the items of item level 200 and up and the Secondhand set.
- **Vendor prices**: read from the vendors you open. No query goes to the server. `/alr vendor` lists them.
- **Item names**: the game's name where AtlasLoot's differs (66 items, English clients).
- **Raid size button**: `Show Normal Loot` / `Show Heroic Loot` instead of 10 / 25 Man in the level-80 raids. Vault of Archavon keeps 10 / 25.

## Install

1. Copy the folder `AtlasLoot_Rebuffed` into `<WoW folder>\Interface\AddOns`.
2. Start WoW, or restart it.

## Remove

Delete the folder `AtlasLoot_Rebuffed`. AtlasLoot is as before.

## Whitemane changelog

What the Whitemane client updates brought, as far as the client data shows it. Item names, stats and prices are
server-side; the addon shows them once the items have been seen in game.

### 2026-10-21

- Paragon: 32 account perks in 8 groups of 4. Well Rested, Daily Planner, Field Medicine, High Alert; Lure Master,
  Flesh Wound, Flight Mastery, Spirit Journey; Ground Training, Master Gatherer, Kitchen Nightmares, Domination
  Stride; Bottomless Pockets, Gourmand, Working Overtime, Bartering; Gotta Go Fast, Ancestral Wisdom, Diplomacy, No
  Time to Dismount; Nimble Hands, Quality Seeker, Nothing Up My Sleeve, Adaptive Riding; Portable Workshop, Witness
  to Glory, Talented, Anywhere Is Home; Justice Mastery, Conquest Mastery, Honor Mastery, Valor Mastery. A reward
  table with 17 steps.
- Master Riding.
- Mount tooltips show ground and flight speed by riding skill (441 mounts).
- The Secondhand set: 99 green items of item level 187 for level 80, one piece per slot and armour class, necks,
  rings, trinkets, cloaks, relics, weapons and a Secondhand Rose, plus a Secondhand Armor Kit and a Secondhand Weapon
  Kit per class (containers). The set is on the Whitemane Gear pages.
- 23 new vendor prices in arena points or honor, plus Mark of Savagery; one in Echoes.
- 14 new relic and set effects: Increased Flash of Light Healing, Seal Cost Reduced, Improved Moonfire, Devotion
  Armor Increased, Increased Lesser Healing Wave, Reduced Stormstrike Cost, Claw and Rake Damage Bonus, Increased
  Rejuvenation Healing, Increased Lightning Damage, Increased Scourge Strike / Icy Touch / Death Coil Damage, Attack
  Power, Heal.
- 52 companions in the Companions skill line, Corefire Imp to Stardust (added since the client data of 2026-10-13).

### 2026-10-15

- 1,278 new item ids: 853 Ascended dungeon versions (I / II / III), 371 in the 131xxxx range, 54 in 43xxxx-46xxxx.
- 255 new spells (item effects) and 328 appearances.

### 2026-10-13, first comparison with the stock 3.3.5 client

- Legendaries with their own effects: Doomhammer (Lava Surge), Armata Strigoi (Scream of the Damned), Atiesh,
  Warglaives of Azzinoth, Stormcoil (Chain Lightning proc), Thunderfury (Thunderblade), Scythe of the Cat God (Fiery
  Swiftness).
- Warrior Protection talents Painkiller, Blood and Thunder, Unbroken Rage; Focused Rage and Critical Block removed;
  Titan's Grip without damage penalty.
- Glyphs: Stars, Omen of Clarity, Reckoning, Shattering Throw, Quick Pain; Glyph of Flametongue gives 2% spell crit
  per weapon.
- 12 currencies: Emblem of Ascension, Emblem of Eternity, Scarlet Sigil, four Echoes, Emblem of Holy Ascension,
  Emblem of Frostbound Ascension, Emblem of Shadow, Echo of Karazhan, Mark of Savagery.
- Tier upgrades for T7-25 Valorous (five steps) and T8-25 Conqueror's (one step).

Details: [AtlasLoot_Rebuffed/README.txt](AtlasLoot_Rebuffed/README.txt).

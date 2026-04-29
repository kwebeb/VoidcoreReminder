# VoidcoreReminder

A lightweight World of Warcraft addon that warns you when you enter a Midnight Season 1 Mythic raid without enough **Nebulous Voidcores** — so you never waste a boss kill by forgetting your bonus rolls.

---

## What It Does

When you zone into any Midnight Season 1 raid on **Mythic difficulty**, VoidcoreReminder automatically checks your Nebulous Voidcore currency. If you're below the warning threshold (default: 2), a **WoW-style popup dialog** appears with an alert sound reminding you to stock up before you pull.

- 🔴 **0 cores** — red warning popup, tells you that you can't bonus roll at all
- 🟡 **Below threshold** — yellow warning popup, tells you how many you have and that bosses cost 2 each
- 🟢 **Enough cores** — quiet chat confirmation so you know the addon is running

The popup is draggable and dismissed with a single OK click.

---

## Supported Raids

All three Midnight Season 1 raids are covered:

- The Voidspire
- The Dreamrift
- March on Quel'Danas

The addon only fires on **Mythic difficulty** (difficulty ID 16). It will not interrupt your LFR, Normal, or Heroic runs.

---

## Installation

1. Download the latest release and unzip it, or clone this repository
2. Copy the `VoidcoreReminder` folder into your addons directory:
   ```
   World of Warcraft/_retail_/Interface/AddOns/VoidcoreReminder/
   ```
3. Make sure the folder contains both `VoidcoreReminder.toc` and `VoidcoreReminder.lua`
4. Launch WoW (or type `/reload` if the game is already running)
5. Enable the addon in the AddOns menu on the character select screen

---

## Slash Commands

| Command | Description |
|---|---|
| `/voidcore check` | Manually check your current Voidcore count anywhere |
| `/voidcore thresh <n>` | Change the warning threshold (default: 2) |
| `/voidcore help` | Show all available commands |
| `/vcr` | Shorthand alias for all of the above |

**Example:** `/voidcore thresh 4` will warn you if you have fewer than 4 cores (enough for 2 boss rolls).

---

## About Nebulous Voidcores

Nebulous Voidcores are the bonus roll currency introduced in Patch 12.0.5 as part of the Voidforge system. They let you roll for an extra piece of loot after defeating a boss or completing other Midnight Season 1 content.

- Raid bosses cost **2 Voidcores** per bonus roll
- You earn up to **2 per week** from Decimus in The Voidstorm (cumulative if you miss weeks)
- An additional core is available weekly from Vaultkeeper Elysa for 6 Thalassian Tokens of Merit

More info: [Nebulous Voidcores guide on Method.gg](https://www.method.gg/guides/midnight-nebulous-voidcores-bonus-rolls)

---

## Compatibility

- **WoW Version:** Midnight (Interface 120005, Patch 12.0.5)
- No dependencies required
- Compatible with other loot addons (RCLootCouncil, etc.)

---

## Contributing

Pull requests are welcome! If a new raid season adds more raids, you can add them to the `MIDNIGHT_S1_RAIDS` table at the top of `VoidcoreReminder.lua`:

```lua
local MIDNIGHT_S1_RAIDS = {
    ["The Voidspire"]        = true,
    ["The Dreamrift"]        = true,
    ["March on Quel'Danas"]  = true,
    -- Add new raids here
}
```

---

## License

MIT — free to use, modify, and distribute.

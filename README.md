# PhobiaUI

Lightweight, self-contained UI library for exploit-style Luau scripts. Tabs, rounded cards, animated toggles, a draggable window, a rebindable show/hide keybind, and a per-card color picker (presets + RGB sliders) — all built on the `Drawing` API, no `Instance.new` UI required.

Single file, no dependencies, MIT-licensed. Load it with `loadstring` and build your menu in a few lines.

## Compatibility

PhobiaUI only needs these globals to exist in your executor:

- `Drawing.new("Square" | "Text" | "Line")` with the standard properties (`Position`, `Size`, `Color`, `Filled`, `Corner`, `ZIndex`, `Transparency`, `Visible`, `Thickness`, `Text`, `FontSize`, `Center`, `Outline`, `From`, `To`)
- `setrobloxinput(bool)`, `iskeypressed(vk)`, `keypress(vk)`, `keyrelease(vk)`
- `ismouse1pressed()`, `GetMouseLocation()` returning a `Vector2`
- Standard Roblox globals: `game`, `Vector2.new`, `Color3.new`

This is the same de-facto `Drawing` + input convention used by most mainstream Roblox executors. It does **not** create any real `Instance` (no `ScreenGui`, no `Frame`) — everything is drawn directly, so it works even in environments where `Instance.new` for GUI objects is blocked or unavailable. If your executor is missing any of the functions above, check its docs for the equivalent name (some executors use slightly different names for the input-simulation functions).

## Install

Host `PhobiaUI.lua` somewhere raw-servable (a GitHub repo's raw URL is the usual choice) and load it with `loadstring`:

```lua
local PhobiaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/<user>/<repo>/main/PhobiaUI.lua"))()
```

`PhobiaUI` is a table with one function on it: `PhobiaUI.CreateWindow(Opts)`. Everything else (tabs, cards, toggles) hangs off the window it returns.

## Quick start

```lua
local PhobiaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/<user>/<repo>/main/PhobiaUI.lua"))()

local Window = PhobiaUI.CreateWindow({
    Title = "MYCHEAT",
    Tabs = { "Combat", "Visuals" },
})

Window.Combat:AddCard("Aimbot", {
    Default = false,
    ColorPicker = true,
    DefaultColor = { 0.35, 0.85, 0.95 },
    Items = {
        { Label = "FOV Circle", Default = true },
        { Label = "Silent",     Default = false },
    },
    OnToggle = function(Enabled)
        -- fires when the "Aimbot" checkbox itself is toggled
    end,
    OnColorChange = function(Color) -- Color is a Color3
        -- fires whenever the user picks a preset or drags a slider
    end,
})

Window.Visuals:AddToggle("ESP", false, function(Enabled)
    -- fires when this standalone toggle changes
end)
```

That's the whole thing. Insert (default) shows/hides the window; click-drag the title bar to move it; click a card's color swatch to open the picker.

## API

### `PhobiaUI.CreateWindow(Opts) -> Window`

`Opts` (all optional):

| Field | Type | Default | Meaning |
|---|---|---|---|
| `Title` | string | `"PHOBIA"` | Text shown next to the badge dot in the title bar |
| `Tabs` | `{string}` | `{"General"}` | Tab names, in order |
| `Size` | `Vector2` | `Vector2.new(380, 370)` | Window size in pixels |
| `Position` | `Vector2` | `Vector2.new(60, 60)` | Initial top-left position |
| `MenuKey` | number (VK code) | `0x2D` (Insert) | Default show/hide keybind — rebindable in-game by clicking the box top-right of the title bar |
| `Accent` | `Color3` | purple | Accent color used for the tab underline and checkbox fill |
| `PanelBg`, `TitleBg`, `TabBarBg`, `BorderColor`, `TextColor`, `MutedText` | `Color3` | dark theme | Override any chrome color |

Returns a `Window` object. Index it by tab name to get that tab's handle: `Window.Combat`, `Window["My Tab"]`, etc. Equivalent to `Window:GetTab("Combat")`.

### `Window:GetTab(Name) -> Tab`
Same as `Window[Name]`.

### `Window:SetVisible(bool)` / `Window:IsVisible() -> bool`
Read/set menu visibility from code (in addition to the in-game keybind).

### `Tab:AddCard(Title, Opts) -> CardHandle`

Adds a rounded card to the tab. Cards auto-flow into a 2-column grid — you never set X/Y yourself, just keep calling `AddCard`/`AddToggle` on a tab and they stack in order.

`Opts` (all optional):

| Field | Type | Meaning |
|---|---|---|
| `Default` | bool | Initial state of the card's own header checkbox |
| `OnToggle` | `function(bool)` | Fires when the header checkbox is clicked |
| `ColorPicker` | bool | If true, adds a color swatch to the card header that opens the picker |
| `DefaultColor` | `{r, g, b}` (0–1 floats) | Initial picker color, only used if `ColorPicker = true` |
| `OnColorChange` | `function(Color3)` | Fires on every preset click or slider drag while this card's picker is open |
| `Items` | array of `{Label, Default, OnToggle}` | Sub-checkboxes listed inside the card, stacked vertically. Each behaves like a small independent toggle — always clickable, not gated by the header checkbox. |

Returns `{ GetEnabled, SetEnabled, GetColor }` — plain functions, e.g. `Card.GetEnabled()`.

### `Tab:AddToggle(Label, Default, OnChange) -> ToggleHandle`

A single standalone checkbox+label, not wrapped in a card — same auto-grid placement as `AddCard`. Returns `{ GetEnabled, SetEnabled }`.

## Notes on the color picker

Each card with `ColorPicker = true` gets its own independent color, but there is only **one** floating picker popup shared by the whole window — clicking a different card's swatch just moves the same popup over and reloads it with that card's current color. This keeps the library cheap regardless of how many color-enabled cards you add.

The picker has 8 presets plus R/G/B sliders (drag the handles) for any arbitrary color, and a Close button.

## Design notes / for anyone (or anything) generating code against this library

- All identifiers are PascalCase, no abbreviations beyond the ones documented above.
- There is no `Instance.new`-based UI anywhere — safe in Luau sandboxes that block creating real GUI instances.
- `AddCard`/`AddToggle` calls are **order-dependent** within a tab — they fill column 1, then column 2, then wrap to a new row. Don't try to position things manually.
- Callbacks (`OnToggle`, `OnColorChange`) receive the **new** value directly; you don't need to re-read `GetEnabled()`/`GetColor()` inside them (though you can).
- The library drives its own animation and input polling via a single `RunService.Heartbeat` connection created inside `CreateWindow` — you don't need to pump anything yourself.
- Do not call `PhobiaUI.CreateWindow` more than once unless you intend to show two independent windows at once; each call wires up its own Heartbeat loop and hitbox list.

## License

MIT. Use it, fork it, ship it in your own project.

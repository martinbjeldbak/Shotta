# Screenshotter
[![Release](https://github.com/martinbjeldbak/screenshotter/actions/workflows/release.yml/badge.svg)](https://github.com/martinbjeldbak/screenshotter/actions/workflows/release.yml)
[![Lint](https://github.com/martinbjeldbak/screenshotter/actions/workflows/lint.yml/badge.svg)](https://github.com/martinbjeldbak/screenshotter/actions/workflows/lint.yml)

Automatically take screenshots of moments within Azeroth so you can cherish
them forever.

## Installing

Currently [WoWUp] is the only known supported addon client because it supports
installing Addons directly from GitHub. I have not released this to Curseforge,
WoWInterface, Wago, etc. yet.

Go to `Get Addons`, then `Install from URL` and paste in the link to this
repository:

- <https://github.com/martinbjeldbak/screenshotter>

then click `Import`, you should see the below screen

![Screenshot of WoWUp client installing this Addon](https://github.com/martinbjeldbak/screenshotter/assets/823316/25b92bbd-03aa-422d-abe9-10f68a0b1752)

Simply click `Install` and you're done! You will be prompted to update on any future releases. For more details, see the WoWUp guide [here][wowup-get-addons]

## Usage


## Contributing

### TODO

- [ ] UI Button: Reset all event state
- [ ]Settings are global: make profile or chracter-specific bindings
- [x] [Timer](https://wowpedia.fandom.com/wiki/API_C_Timer.After) after ie 10s after readcheck
- [ ] Add slash command to open up options (if possible?)
- [ ] Consider using [AceDB](https://www.wowace.com/projects/ace3)

### Event ideas

not sure if any of these are possible

- [ ] Boss/Rare/elite kills
- [ ] Every x minutes
- [ ] When joining a party (with a friend)
- [ ] When close to a friend
- [ ] When emoting with a friend/target
- [ ] When emoting at all
- [ ] Low health
- [ ] Trade windows

Full event list [here](https://wowwiki-archive.fandom.com/wiki/Events_A-Z_(full_list))

### Consider events

- [`CHAT_MSG_BN_INLINE_TOAST_ALERT`](https://wowpedia.fandom.com/wiki/CHAT_MSG_BN_INLINE_TOAST_ALERT)

## Resources

- [WoW API](https://github.com/Gethe/wow-ui-source)

### Similar addons

- [Memoria](https://www.curseforge.com/wow/addons/memoria)
- [Multishot](https://www.wowinterface.com/downloads/info9590-MultishotScreenshot.html)

[WoWUp]: https://wowup.io/
[wowup-get-addons]: https://wowup.io/guide/get-addons/overview

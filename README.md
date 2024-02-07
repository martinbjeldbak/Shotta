# Shotta
[![Release](https://github.com/martinbjeldbak/screenshotter/actions/workflows/release.yml/badge.svg)](https://github.com/martinbjeldbak/screenshotter/actions/workflows/release.yml)
[![Lint](https://github.com/martinbjeldbak/screenshotter/actions/workflows/lint.yml/badge.svg)](https://github.com/martinbjeldbak/screenshotter/actions/workflows/lint.yml)

(_screen_)-shotta, mate. Automatically take screenshots of moments within
Azeroth so you can cherish them forever.

![Shotta overview](.previews/overview.jpg)

> [!IMPORTANT]
> This has only been tested in WoW Classic, but it should work in all client versions

## Features

Ever wished you had more pictures of your adventures throughout Azeroth and
beyond? Look no further!

Shotta will automatically take screenshots

- at regular intervals
- at specific events
- when you're alone
- when you're with your friends
- when you down a boss

It runs with zero dependencies and minimal code.

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

Once installed, there will be an addon loaded message in the chat, see

![Addon loaded](./.previews/screenshot-taken.png)

You can then open the menu and start configuring the events you want to
screenshot by typing `/ss` or `/screenshotter` in the chat

![Addon menu](./.previews/menu.png)

Click the boxes you are interested in and they will trigger on the next time
that event occurs!

For example, on level up

![Leveled up screenshot confirmation](./.previews/level-up.png)

I get this sweet screenshot

![Leveled up screenshot](./.previews/level-up-screenshot.jpg)

## Contributing

First of all, thanks for helping contribute! There are many ways you can help contribute

- filing feature request, bugs, or general issues using <https://github.com/martinbjeldbak/screenshotter/issues/new>
- code contributions 
- translation strings for each supported language

If you wish to run this addon locally, I highly recommend setting up a symlink
to the cloned repository directory following the guide here:
<https://wowpedia.fandom.com/wiki/Symlinking_AddOn_folders>, this will make it
so that you only need to reload the UI with `/reload` to see your changes.

### TODO

- [ ] More translation strings, see `localization.core.lua`
- [ ] UI Button: Reset state to default
- [ ] Settings are global: make profile or chracter-specific bindings
- [x] [Timer](https://wowpedia.fandom.com/wiki/API_C_Timer.After) after ie 10s after readcheck
- [x] Add slash command to open up options (if possible?)
- [x] ~~Consider using [AceDB](https://www.wowace.com/projects/ace3)~~ too complicated, extra dependency

### Event ideas

not sure if any of these are possible

- [ ] Boss/Rare/elite kills
- [x] Every 5/10 minutes
- [ ] When joining a party (with a friend)
- [ ] When close to a friend
- [ ] When emoting with a friend/target
- [ ] When emoting at all
- [ ] Low health
- [x] Trade windows
- [ ] More customizable every x minutes with [slider](https://wowpedia.fandom.com/wiki/API_Slider_SetStepsPerPage)
- [ ] Reputation gains
- [ ] PvP: Arena endings
- [ ] PvP: Battleground endings
- [ ] PvE: Mythic+ dungion runs

Full event list [here](https://wowwiki-archive.fandom.com/wiki/Events_A-Z_(full_list))

### Consider events

- [`CHAT_MSG_BN_INLINE_TOAST_ALERT`](https://wowpedia.fandom.com/wiki/CHAT_MSG_BN_INLINE_TOAST_ALERT)
- [`CHAT_MSG_LOOT`](https://wowpedia.fandom.com/wiki/CHAT_MSG_LOOT)

## Resources

- [WoW API](https://github.com/Gethe/wow-ui-source)

### Similar addons

- [Memoria](https://www.curseforge.com/wow/addons/memoria), simpler triggers
- [Multishot](https://www.wowinterface.com/downloads/info9590-MultishotScreenshot.html), not updated since april 2015

[WoWUp]: https://wowup.io/
[wowup-get-addons]: https://wowup.io/guide/get-addons/overview

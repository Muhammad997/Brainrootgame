# Brainrootgame

[![roblox-brainrot-01 competition](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/Muhammad997/Brainrootgame/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard)
[![reward](https://make.fun/badge/roblox-brainrot-01/Muhammad997/Brainrootgame/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

Brainrot 3D METEOR is a 3D Roblox game built with Rojo and Luau, published as
https://www.roblox.com/games/114862844166484/Brainrot-3D-METEOR (place 114862844166484, universe 8330546890).
Its world lives in Workspace as real Part geometry — a grass baseplate, a neon road, a conveyor belt that
spawns collectable brainrot characters, and two fenced bases with six slots each — rather than as screen frames.
Players start with $550, buy brainrots from the conveyor (Telolet Bus, Durian Interstellar, Rendang Meteor,
Kopi Luwak Cosmic and more, priced from common to Secret rarity), and earn money per second from what they own.
They can lock a base for 30 seconds (60-second cooldown), steal brainrots from other bases on an 8-second
cooldown, and rebirth for $100,000 to gain a 1.25x income multiplier, with a HUD showing money, income per
second, multiplier, brainrot count, lock timers and status messages.

## Run it

    mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

main.ts (Node 22, standard library only) copies game.rbxl, src/, screenshots/ and PLAY.json into out/ — skipping
every name that starts with a dot — and writes out/dossier.json with the vendored make.fun library.

---

Made for [make.fun](https://make.fun/?ref=tgfrrtv0).

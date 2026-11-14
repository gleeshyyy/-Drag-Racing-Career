# Dragless Rivalry — HTML Edition

A responsive, browser-based drag-racing career simulator. The original Godot work remains preserved on its existing branches.

## Run locally
Open `index.html` in a modern mobile or desktop browser. No build step or server is required.

## Implemented systems
- Responsive title screen, driver creation, opening story and career journal.
- Local browser save with migration defaults for older career data.
- Career dashboard: cash, wins, reputation, driver level, vehicle condition and navigation.
- Drag race: staging tree, reaction timing, false starts, three gear shifts, quarter-mile ET and rival comparison.
- Race entry fees are charged at staging; leaving a staged race stops the race timer and does not refund the entry.
- Side-view and optional top-down race camera.
- Garage with four vehicles, ownership, vehicle-specific tuning persistence, performance upgrades, repairs and personal best.
- Career management: sponsor contract, weekly challenges, milestones, race history and weekly living costs.
- Court-ordered child support: automatic payment every four career weeks, arrears tracking and manual partial repayment.
- Story choices involving Jasper, Jax, Viper and Rex, with one-time decisions and a journal.
- Eight-round championship season with a fixed event calendar, player/rival points, missed-round forfeits, standings, title rewards and past-season records.
- Midnight Invitational side event unlocked at 40 reputation, with a $1,000 entry fee and $4,000 winner payout; it does not alter championship standings.

## Automated validation
GitHub Actions runs:
- JavaScript syntax validation.
- Career logic smoke tests for fresh saves, vehicle tuning, race entry/cancellation, season scoring, forfeits, sponsor completion, child-support deductions and arrears.
- Chromium browser smoke tests at a mobile viewport for career creation, screen navigation, camera switching, racing, local saves and horizontal overflow.

Automated checks do not replace testing on a real Android phone. Device testing is the final release gate.

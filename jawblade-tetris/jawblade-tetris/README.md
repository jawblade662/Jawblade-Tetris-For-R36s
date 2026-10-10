# Jawblade Tetris

A self-contained LÖVE 11.5 falling-block arcade game packaged for PortMaster.

## Install on an R36S

1. Make sure PortMaster is installed and its `love_11.5` runtime is available (PortMaster can fetch it when online).
2. Extract this ZIP into the `ports` directory on the SD card's ROMS partition, keeping the included folder structure.
3. Launch **Jawblade Tetris** from the Ports list.

The game renders at a 640×480 logical resolution and scales to the handheld's screen. It uses the shared PortMaster LÖVE runtime; it does not bundle an engine binary.

## Controls

- D-pad: navigate menu / move blocks
- A: select / rotate
- B: hard drop / return to menu after game over
- Right shoulder: rotate the other direction
- Start: select menu item / return to menu during play
- Keyboard: arrows move, Z/Space rotate, Enter hard drop, Escape menu

Menu contains Start and Exit. Clearing lines raises score and level; the fall speed increases as levels rise.

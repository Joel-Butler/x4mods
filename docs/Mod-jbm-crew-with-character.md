# Crew with Character mod

## Status - incomplete

## Overview
This mod is an attempt to make the crew element of X4 more interactive with some fun and potential rewards along the way.

## Attempt 1:
* On dock there is a random chance of a 'drunk and disorderly' issue for one of your crew members requiring either your direct interaction, or an offload to your captain.

### Proposed Dev Stages
#### In progress
1. Can we get debug output listing available crew on a docked ship?
    * Debug output so far includes actors, see note 2. for next steps below.

#### Todo
2. Can we then randomly assign an interactive mission requring a trip to the local Brig for release of this crew?
  * Randomize cost
  * Minor reward of +1 morale to ship.
  * If ignored, zero effect for now apart from a loss of said crew member. 



### Notes
1. Struggling with which area crew is stored. So far it appears this may be stored as a ware based on the information held in menu_playerinfo.lua which seems to iterate over ship wares to identify crew.
2. Crew *can* be actors, but only crew within the player's active room appear to be active - which makes sense from an efficiency standpoint.



# JBM Metrics

## Status - Working Alpha

## Overview
This mod is my attempt to build out useful business metrics I'd want to help oversee my growing X4 empire. 

## Requirements
* Python (need to be able to install required additional python modules)
* Pip install of [prometheus client](https://pypi.org/project/prometheus-client/)

## Current State:
* Using [SirNukes Mod Support APIs](https://github.com/bvbohnen/x4-projects/tree/master/extensions/sn_mod_support_apis) (specifically the Named Pipes API) this mod hosts a prometheus-friendly metrics server. 

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



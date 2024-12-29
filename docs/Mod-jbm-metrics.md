# JBM Metrics

## Status - Working Alpha

## Overview
This mod is my attempt to build out useful business metrics I'd want to help oversee my growing X4 empire. 

## Credits and other sources
* [SirNukes](https://github.com/bvbohnen) - the Mod Support API interface is how the metric data is exposed.
* [Mycu](https://github.com/mycumycu) - Inspecting the the mod side of the [X4 External App](https://github.com/mycumycu/X4-External-App) helped me puzzle out wrapping data written to the pipe in JSON format, and lead me to using 
* [David Kolf's JSON module](http://dkolf.de/src/dkjson-lua.fsl) for encapsulation of Lua data sent to the python pipes server.

## Requirements and Installation
* There are several ways to set this up:
    1. I have no interest in the plumbing, I just want this up and running with minimal effort:
        * Install the mod. 
        * Run the modified SirNukes executable attached in releases - this simply adds prometheus-client as a library available to the executable. 
        * Run the install scripts that provision grafana and prometheus.
    2. I'd like to roll my own:
        * Python (need to be able to install required additional python modules).
        * I have a script that can help with the below, but you're also welcome to install these by hand or re-use existing copies: 
            * Pip install of [prometheus client](https://pypi.org/project/prometheus-client/), as well as the prerequisites for SirNukes Mod Support API python script of pywin32 and pynput.
            * The source (Python) script of [X4_Python_Pipe_Server](https://github.com/bvbohnen/x4-projects/tree/master/X4_Python_Pipe_Server)
        * Working installations of grafana and prometheus either leveraging the script proveded or by providing your own. 

## Current State:
* Using [SirNukes Mod Support APIs](https://github.com/bvbohnen/x4-projects/tree/master/extensions/sn_mod_support_apis) (specifically the Named Pipes API) this mod hosts a prometheus-friendly metrics server. 

### Proposed Dev Stages
#### In progress
* Nothing right now - focused on deploying a working mod :-)

#### Todo
1. Menu toggle to enable/disable metric feed - sometimes we want a few extra CPU cycles and the metrics can wait. 
2. Granular transactional metrics per station to display individual station profit/loss over time. 
3. Alert callbacks from prometheus to X4 to pause game on critical business events (loss of rep, loss of capital ships and so on...). 




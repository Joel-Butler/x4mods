# X4 Mods

## Metadata
|Key       |Value       |
|---       |---         |
|Created By|Joel Butler |
|Version   |1.0.0       |
|Repo:     |[Joel-Butler/x4mods](https://github.com/Joel-Butler/x4mods)|

## Overview
This module leverages [SirNukes Mod Support APIs](https://github.com/bvbohnen/x4-projects/tree/master/extensions/sn_mod_support_apis) (specifically the Named Pipes API) to expose metrics related to the game that I believe would benefit an up and coming business in the X4 universe, and provide these in a time-series format that is usable by Prometheus, and visualised in Grafana. 

## Requirements
1. Windows - to my knowledge the named pipes API does not work with Linux. 
2. Python - the executable version of the named pipes server doesn't have the prometheus client installed.
3. SirNukes API server in python format (I've made a script to help download this.)
3. Pip install of [prometheus client](https://pypi.org/project/prometheus-client/). 
4. Available ports:
    1. metrics: 8000
    2. (optional) prometheus: 9090
    3. (optional) grafana: 3000

## Operation
When enabled, this mod hosts a metrics server on port 8000 and uses lua UI calls to post metric information in JSON format to the metrics server for consumption. 
As most people are not going to have a server with prometheus and grafana handy, a script within the mod can optionally assist in the install and configuration of a local instance of prometheus and grafana.

## Installing Prometheus and Grafana
Run setup_metrics_server.ps1 from the 'resources\metrics_server' folder of this mod and select an appropriate location for install. You will be able to launch the services from this location when you would like to gather metrics. 
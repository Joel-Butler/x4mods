# X4 Mod Archive

## Overview
This is both my platform and my archive of X4 Mods.

## [Repo](https://github.com/Joel-Butler/x4mods/)
https://github.com/Joel-Butler/x4mods/

## Mods

|Mod                        |Description                                         |Status         |
|-----                      |-----                                               |-----          |
|[Metrics](Mod-jbm-metrics.md)|A feed of prometheus style time series metrics that can be used to monitor your space empire.|Alpha|
|[Jbm-test](Mod-Jbm-test.md)| A playground for module tweaking and testing.      |In Development |
|[Crew with Character](Mod-jbm-crew-with-character.md)|Some adjustments to crew behavior I think will add some fun and rewards to being more attached to your ship crew. | In Development |

## Tools and Scripts
1. generatecats.bat - a batch file able to generate from a working install of X4 (and the presence of the X4 Catalog tool) the extracted resources required for modding.

2. webserver.bat - assuming successful export of cat data to .\cats and the presence of python this will run a local webserver allowing interactive use of the two html files present in the extracts - built from discussions on [Egosoft's forum](https://forum.egosoft.com/viewtopic.php?f=181&t=432098#p4997854) and an example hosted [here](https://github.com/temetvince/template-x4-mod)

3. Build.bat - creates an output folder stripping unncessary files such as XSD.

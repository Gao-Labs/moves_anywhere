---
output:
  pdf_document: default
  html_document: default
---
# README `demos`

- Author: Tim Fraser

This README discusses demos for `moves_anywhere`. See below for Frequently Asked Questions of interest.

## Frequently Asked Questions

### What Input Tables Can't Be Run Together?

Sometimes, if you run two custom input tables together, MOVES will reject it, telling you to only upload 1 VMT table, etc. While the MOVES graphical user interface (GUI) prevents you from making such choices, `moves_anywhere` by design has no GUI, and so such errors become possible. Here's a breakdown of what types of tables can be submitted in a single run. (This guide may be updated over time.)

- Source Type Population
  - [ ] sourcetypeyear

- Vehicle Type VMT (1 of the following)
  - [ ] hpmsvtypeyear
  - [ ] hpmsvtypeday
  - [ ] sourcetypeyearvmt
  - [ ] sourcetypedayvmt

- IM Programs
  - [ ] imcoverage

- Age Distribution
  - [ ] sourcetypeagedistribution

- Average Speed Distribution
  - [ ] avgspeeddistribution

- Fuel
  - [ ] fuelSupply
  - [ ] fuelFormulation
  - [ ] fuelUsageFraction
  - [ ] avft

- Meteorology
  - [ ] zoneMonthHour

- Roads
  - [ ] roadTypeDistribution

### Remaining Questions

- Is it 'right' to grab the default data for `sourcetypeyear`, which is a national-level tally? Does MOVES adjust it to county level at all? *Answer*: No. You should supply this with *real* county-level data.

- How did CATSERVER data get generated? *Answer*: CATSERVER V1 was run using an early version of `catr` and `MOVES 3.1`. We did not supply any custom input tables, but the command line was able to perform a custom run even without custom tables supplied. Now, `moves_anywhere` runs a specific procedure to generate any required tables not provided from defaults, or adapt them. This is written in the `adapt.r` script in `image/adapt.r`.

- Why do some areas have very high values?





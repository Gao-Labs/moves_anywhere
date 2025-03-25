# README `moves_anywhere:v2`

-   Description: This is the official README for MOVES Anywhere v2, designed to run MOVES 5.0.
-   Maintainer: Tim Fraser [tmf77\@cornell.edu](mailto:tmf77@cornell.edu){.email}

MOVES Anywhere is a program run on the docker image `tmf77/docker_moves:v2`.

Unlike `v1`, MOVES Anywhere `v2` has a base set of packages installed, and then uses mounted scripts, folders, and environmental variables to customize runs.

- [x] Is it necessary to filter the `year` table by `yearID`? --> YES
- [x] Is it necessary to filter the `state` table by `stateID`? --> NO
- [x] Does allowing multiple `regionIDs` affect the current problem? --> NO
- [x] Is it necessary to adapt the default `totalidlefraction` table? --> NO
  - [x] Is it necessary to filter `totalidlefraction` table by `idleRegionID`? --> NO
  - [x] Is it necessary to filter `totalidlefraction` table by `countyTypeID`? --> NO
  - [x] Is it necessary to filter `totalidlefraction` table by `monthID`? --> NO
  - [x] Is it necessary to filter `totalidlefraction` table by `dayID`? --> NO
- [x] Does NOT adapting default `totalidlefraction` table cause the current problem? --> NO
- [x] Is all of this because it is preaggregated Yearly? --> No
- [ ] Is all of this because I need to run it hourly, not yearly? --> NO/kind of
- [ ] Is this because I added VOC, which requires EVAP, which requires hourly? --> PROBABLY





- [ ] Is it necessary to filter the `idleregion` table by `idleRegionID` -->

- [ ] Is it necessary to filter `imcoverage` table by `stateID`? -->
- [ ] Is it necessary to filter `imcoverage` table by `countyID`? -->
- [ ] Is it necessary to filter `imcoverage` table by `yearID`? -->


- [ ] Is it necessary to filter `zone` table by `zoneID`? -->
- [ ] Is it necessary to filter `zone` table by `countyID`? -->

- [ ] Is it necessary to filter `zonemonthhour` table by `zoneID`? -->
- [ ] Is it necessary to filter `zonemonthhour` table by `monthID`? -->
- [ ] Is it necessary to filter `zonemonthhour` table by `hourID`? -->


- [ ] Is it necessary to filter `zoneroadtype` table by `zoneID`? -->
- [ ] Is it necessary to filter `zoneroadtype` table by `roadTypeID`? -->

- [ ] Is it necessary to filter `regioncounty` table by `regionID` -->
- [ ] Is it necessary to filter `regioncounty` table by `countyID` -->
- [ ] Is it necessary to filter `regioncounty` table by `regionCodeID` -->
- [ ] Is it necessary to filter `regioncounty` table by `fuelYearID` -->

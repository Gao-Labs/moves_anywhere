# MOVES Anywhere Guide

-   Lead Developer: Tim Fraser, PhD
-   Contributors: Erin Murphy, Junna Chen, Mahak Bindal, Shungo Najima, Carl Closs
-   Institution: Gao Labs \@ Cornell University
-   Description: A Docker-based solution to run MOVES anywhere - on Windows, Mac, or Linux

Welcome to `moves_anywhere`! This software suite includes several tools to help you run the Environmental Protection Agency's [MO]{.underline}tor [V]{.underline}ehicle [E]{.underline}missions [S]{.underline}imulator (MOVES) more easily. Developed by Tim Fraser and colleagues at Gao Labs at Cornell University, `moves_anywhere` aims to solve several common problems for planners, engineers, and researchers who need to know how many tons of emissions are produced from on-road transportation sources in their county or state. These problems include:

-   Writing runspec.xml documents faster (a recipe for your MOVES run)

-   Running MOVES on any OS (Windows, Mac, or Linux), using a Docker container.

-   Running MOVES with custom inputs when you have *some (or none)* of the required custom input tables, but not all.

-   Post-processing MOVES inventory output data into the more dataviz-friendly "CAT Format", developed for Cornell's Climate Action in Transportation (CAT) team's research.

-   Uploading CAT Formatted Data to a Google Cloud SQL server using a Docker container.

-   And more!

*Note: This is a living document that will be updated continuously as development on `moves_anywhere` integrations continues, so be sure to check back for updates.*

## Key Terms in `moves_anywhere`

`moves_anywhere`: a software suite containing several tools for making it easier to run MOVES. Here is a list of key terms to help users and developers keep those tools straight!

-   `MOVES`: The Environmental Protection Agency's [[MO]{.underline}tor [V]{.underline}ehicle [E]{.underline}missions [S]{.underline}imulator (MOVES)](https://www.epa.gov/moves) software. Used for estimating emissions from onroad transportation sources, for about \~100 types of pollutants. Originally developed for Windows. The most up-to-date information can be found on the [MOVES Github Repository](https://github.com/USEPA/EPA_MOVES_Model).

    -   From [Github](https://github.com/USEPA/EPA_MOVES_Model), MOVES can be downloaded and implemented on linux, provided a fair amount of familiarity with Linux, Go, Java, and command line coding.

    -   `moves_anywhere` is powered by `MOVES v4.0`, downloaded from Github.

-   `runspec`: A runspec file is a `.xml` file that lists every specification about your MOVES `run`, including the **area** (eg. Tompkins County), **level** of analysis (eg. county/state), **year**(s) under analysis (eg. 2025), **pollutants** (eg. CO2 equivalent = id 98), **sourcetypes**, **fueltypes**, and **roadtypes**, and level of **geographic aggregation** and **temporal aggregation** for results. See here for the [**EPA's guide "Anatomy of a Runspec"**](https://github.com/USEPA/EPA_MOVES_Model/blob/master/docs/AnatomyOfARunspec.md) on interpreting a runspec document.

-   `MOVES runs`:

    -   `run`: a run refers to running the MOVES software 1 time, using 1 runspec file. In `moves_anywhere`, this usually describes emissions for 1 county-year.

    -   `scenario`: A bundle of MOVES `runs` for the same geographic area over time, often with distinct custom input tables for each year. (Eg. Tompkins County for 2020, 2025, and 2030.)

    -   `default MOVES run`: A MOVES run that sources any required data directly from the MOVES `default input database`. In the MOVES GUI, under Domain/Scale, also called `Default Scale`. Produces approximate estimates of emissions in an area. For Emissions Reporting purposes, we should *always* use a `custom MOVES run`, which better reflects on-the-ground vehicle fleet activity and conditions.

    -   `custom MOVES run`: A MOVES run for 1 county-year that draws on a set of \~40 specific `custom input tables` provided by the user in the form of a `custom input database`. Also draws on some background data from `default input database`. In the MOVES GUI, under Domain/Scale called `County Scale`. MOVES GUI provides `County Data Manager` to help users fill in the many required `custom input tables`.

-   `input tables`:

    -   `default input tables`: Several hundred tables of default data for MOVES processing, which comes with moves. Stored as a MariaDB database, commonly referred to as the `default input database`. of several hundred default input tables and tables for internal MOVES processing that come with MOVES.

        -   Contains all tables needed to perform a `default MOVES run`. Contains *some* but *not all* of the possible tables that can be provided in a `custom MOVES run`.

        -   Current default input database version is named **movesdb20240104**. Available for download [**here in MariaDB format**](https://github.com/USEPA/EPA_MOVES_Model/blob/master/database/Setup/movesdb20240104.zip). Installed automatically when MOVES is installed.

    -   `custom input tables`: About \~40 input tables required by MOVES to perform a `custom MOVES run`. Provided to MOVES as a `custom input database`.

<!-- -->

-   `catr`: an R package containing tools in the R programming language for running various `moves_anywhere` processes.

    -   `adapt`(): an R function that adapts the MOVES default input database

## How does MOVES Anywhere write Runspecs?

## `custom input tables` required by MOVES

There are XX total custom input tables required by MOVES. This includes YY user-supplied tables, for which there are no defaults, and ZZ optional user-supplied tables, for which there are defaults. One of the key challenges of using MOVES is that unless someone crafts all YY user-supplied tables, MOVES [**refuses**]{.underline} to perform a `custom run`. This was extremely difficult as a user and developer working with MOVES.

So, the first step of the `moves_anywhere` team was to develop a strategy to populate these required `custom input tables` with 'good-enough' values, by borrowing relevant values from the default database and/or transforming them where needed. This was to make it possible that *even if* you don't have **all** the possible input data about your scenario, you can still run MOVES. We refer to this process as the `adapt()` function in the `catr` package, which adapts the `default input database` and any supplied `custom input tables` into a fully operational `custom input database`*.*

-   Any of the remaining \~200 tables in the MOVES default input database can also be updated. See [here](https://github.com/USEPA/EPA_MOVES_Model/blob/master/docs/MOVESDatabaseTables.md) for a full list of all MOVES database tables.

`adapt()`

### [User-Supplied Tables Required by County Data Manager]

| Menu                           | Table                                                         | Notes                      | Adaptation                                                                                                                                                                                                                                                           |
|-----------------|-----------------|-----------------|----------------------|
| **Vehicle Type VMT**           | `monthVMTFraction`                                            | If VMT is **Annual**       |                                                                                                                                                                                                                                                                      |
| **Vehicle Type VMT**           | `dayVMTFraction`                                              | If VMT is **Annual**       |                                                                                                                                                                                                                                                                      |
| **Vehicle Type VMT**           | `hourVMTFraction`                                             | If **Annual** or **Daily** |                                                                                                                                                                                                                                                                      |
| **Vehicle Type VMT**           | `SourceTypeYearVMT` OR `HPMSVtypeYear`                        | If VMT is **Annual**       |                                                                                                                                                                                                                                                                      |
| **Vehicle Type VMT**           | `SourceTypeDayVMT` OR `HPMSVTypeDay`[^moves_anywhere_guide-1] | If VMT is **Daily**        |                                                                                                                                                                                                                                                                      |
| **Source Type Population**     | `sourceTypeYear`                                              |                            | Using national-level default `sourceTypeYear`, interpolated and population-weighted.[^moves_anywhere_guide-2]                                                                                                                                                        |
| **Fuel**                       | `AVFT`                                                        |                            | Using [`samplevehiclepopulation`](https://github.com/USEPA/EPA_MOVES_Model/blob/master/docs/MOVESDatabaseTables.md#samplevehiclepopulation), group by `sourceTypeID`, `modelYearID`, `fuelTypeID`, and `engTechID` and sum `stmyFraction` to make `fuelEngFraction`. |
| **Fuel**                       | `FuelSupply`                                                  |                            | Filter by `fuelRegionID`, `fuelYearID`, `monthGroupID`                                                                                                                                                                                                               |
| **Fuel**                       | `FuelUsageFraction`                                           |                            | Filter by `countyID`, `fuelYearID`                                                                                                                                                                                                                                   |
| **Fuel**                       | `FuelFormulation`[^moves_anywhere_guide-3]                    | (*Avoid*)                  | Untouched                                                                                                                                                                                                                                                            |
| **Average Speed Distribution** | `avgSpeedDistribution`                                        |                            | Filter by `hourDayID`                                                                                                                                                                                                                                                |
| **Age Distribution**           | `sourceTypeAgeDistribution`                                   |                            | Filter by `yearID`                                                                                                                                                                                                                                                   |
| **Road Type Distribution**     | `roadTypeDistribution`                                        |                            | Untouched                                                                                                                                                                                                                                                            |
| **I/M Programs**               | `IMCoverage`                                                  |                            | Filter by `stateID`, `countyID`, `yearID`                                                                                                                                                                                                                            |
| **Meteorology Data**           | `zoneMonthHour`                                               |                            | Filter by `zoneID`, `monthID`, `hourID`                                                                                                                                                                                                                              |

: **Table: User Supplied Tables Required by County Data Manager**

[^moves_anywhere_guide-1]: A `custom input database` can only have 1 of these four VMT tables: `sourcetypeyearvmt,` `hpmsvtypeyear,` `sourcetypedayvmt`, or `hpmsvtypeday`. If a year-level table `sourcetypeyearvmt` or `hpmsvtypeyear` is chosen, then other year-relevant VMT tables can be uploaded, namely, `monthVMTFraction`, `dayVMTFraction`, and `hourVMTFraction`. However, if day-level table `sourcetypedayvmt` or `hpmsvtypeday` is chosen, then other day-relevant VMT tables can be uploaded, namely `hourVMTFraction`.

[^moves_anywhere_guide-2]: In the `default input database`, `sourceTypeYear` is recorded at the `nation` level for the year `2020`, recording the number of vehicles (`sourceTypePopulation`) per `sourceTypeID`. To adapt these values to the county level, we keep that same split of `sourcetypes` (eg. 20% cars, 10% buses), but we downweight each `sourceTypePopulation` by multiplying it by the ratio of *county population vs. national population.* This estimates what a true vehicle population might look like in the county, supposing that the number of vehicles is related to population. Naturally, this is an imperfect estimate, but it provides much more realistic values for `sourceTypePopulation` than otherwise available.

[^moves_anywhere_guide-3]: According to recent EPA guidance, because fuel properties can be quite variable, the EPA does not consider single or yearly station samples adequate for substitution. In other words, just don't touch this table, and take all the contents of the fuel supply table. Read more in [**Section 4.8.1 Fuel Formulation and Fuel Supply Guidance (2020).**](https://www.epa.gov/sites/default/files/2020-11/documents/420b20052.pdf)

| Menu              | Table                           | Notes | Adaptation                                                   |
|----------------|--------------------|----------------|---------------------|
| **Starts**        | `startsHourFraction`            |       | Filter by `dayID` and `hourID`                               |
| **Starts**        | `starts`                        |       | Filter by `yearID`                                           |
| **Starts**        | `startsPerDay`                  |       | Filter by `dayID`                                            |
| **Starts**        | `StartsPerDayPerVehicle`        |       | Filter by `dayID`                                            |
| **Starts**        | `startsMonthAdjust`             |       | Untouched                                                    |
| **Starts**        | `startsAgeAdjustment`           |       | Untouched                                                    |
| **Starts**        | `startsOpModeDistribution`      |       | Filter by `opModeID`, `dayID`, `hourID`                      |
| **Hotelling**     | `hotellingActivityDistribution` |       | Filter by `zoneID`                                           |
| **Hotelling**     | `hotellingHours`                |       | Untouched                                                    |
| **Hotelling**     | `hotellingHourFraction`         |       | Untouched                                                    |
| **Hotelling**     | `hotellingAgeFraction`          |       | Untouched                                                    |
| **Hotelling**     | `hotellingMonthAdjust`          |       | Untouched                                                    |
| **Idle**          | `totalIdleFraction`             |       | Filter by `idleRegionID`, `countyTypeID`, `monthID`, `dayID` |
| Idle              | `idleModelYearGrouping`         |       | Untouched                                                    |
| Idle              | `idleMonthAdjust`               |       | Untouched                                                    |
| **Idle**          | `idleDayAdjust`                 |       | Untouched                                                    |
| **Retrofit Data** | `onRoadRetrofit`                |       | Untouched                                                    |
|                   |                                 |       |                                                              |

: **Table: Optional Tables for County Data Manager**

### [Optional Tables for County Data Manager]

### [Optional Generic Tables for County Data Manager]

-   

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

There are up to 39\~41 total custom input tables that must be edited to use `moves_anywhere` with MOVES 4.0. This includes 13\~15 [**required**]{.underline} **user-supplied tables**, which users must supply in the traditional County Data Manager user interface (**Table 1**), and 17 [**optional**]{.underline} **user-supplied tables**, for which MOVES typically automatically sources defaults if not supplied (**Table 2**). Further, **9 background tables** must be updated to reflect the geography, time frame, regions, etc. on the run (**Table 3**). Any of the remaining \~200 tables in the MOVES default input database can also be updated. See [here](#0) for a full list of all MOVES database tables.

One of the key challenges of using MOVES is that unless someone crafts all **required user-supplied tables**, MOVES [**refuses**]{.underline} to perform a `custom run`. This was extremely difficult as a user and developer working with MOVES, and was the motivation for creating the `adapt()` function.

`adapt()`: So, the first step of the `moves_anywhere` team was to develop a strategy to populate these required `custom input tables` with 'good-enough' values, by borrowing relevant values from the default database and/or transforming them where needed. This was to make it possible that *even if* you don't have **all** the possible input data about your scenario, you can still run MOVES. We refer to this process as the `adapt()` function in the `catr` package, which adapts the `default input database` and any supplied `custom input tables` into a fully operational `custom input database`*.*

#### Table 1: User-Supplied Tables Required by County Data Manager

+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Menu                           | Table                                            | Adaptation                                                                                                                                                                                                                                                           |
+================================+==================================================+======================================================================================================================================================================================================================================================================+
| **Vehicle Type VMT**           | `monthVMTFraction`                               | Used if VMT is **Annual**                                                                                                                                                                                                                                            |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Vehicle Type VMT**           | `dayVMTFraction`                                 | Used if VMT is **Annual**                                                                                                                                                                                                                                            |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Vehicle Type VMT**           | `hourVMTFraction`                                | Used if VMT is **Annual** or **Daily**                                                                                                                                                                                                                               |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Vehicle Type VMT**           | `SourceTypeYearVMT` OR `HPMSVtypeYear`           | Used if VMT is **Annual.** If no VMT tables provided, existing `HPMSVtypeYear` table is population re-weighted and used.                                                                                                                                             |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Vehicle Type VMT**           | `SourceTypeDayVMT` OR `HPMSVTypeDay`<sup>1</sup> | Used if VMT is **Daily.** If no VMT tables provided, existing `HPMStypeYear` table is population re-weighted and used.                                                                                                                                               |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Source Type Population**     | `sourceTypeYear`                                 | Using national-level default `sourceTypeYear`, [interpolated and population-weighted]{.underline}<sup>2</sup>                                                                                                                                                        |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Fuel**                       | `AVFT`                                           | Using [`samplevehiclepopulation`](https://github.com/USEPA/EPA_MOVES_Model/blob/master/docs/MOVESDatabaseTables.md#samplevehiclepopulation), group by `sourceTypeID`, `modelYearID`, `fuelTypeID`, and `engTechID` and sum `stmyFraction` to make `fuelEngFraction`. |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Fuel**                       | `FuelSupply`                                     | Filter by `fuelRegionID`, `fuelYearID`, `monthGroupID`                                                                                                                                                                                                               |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Fuel**                       | `FuelUsageFraction`                              | Filter by `countyID`, `fuelYearID`                                                                                                                                                                                                                                   |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Fuel**                       | `FuelFormulation`<sup>3</sup>                    | Untouched                                                                                                                                                                                                                                                            |
|                                |                                                  |                                                                                                                                                                                                                                                                      |
|                                |                                                  | (*Avoid Tinkering*)                                                                                                                                                                                                                                                  |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Average Speed Distribution** | `avgSpeedDistribution`                           | Filter by `hourDayID`                                                                                                                                                                                                                                                |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Age Distribution**           | `sourceTypeAgeDistribution`                      | Filter by `yearID`                                                                                                                                                                                                                                                   |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Road Type Distribution**     | `roadTypeDistribution`                           | Untouched                                                                                                                                                                                                                                                            |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **I/M Programs**               | `IMCoverage`                                     | Filter by `stateID`, `countyID`, `yearID`                                                                                                                                                                                                                            |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Meteorology Data**           | `zoneMonthHour`                                  | Filter by `zoneID`, `monthID`, `hourID`                                                                                                                                                                                                                              |
+--------------------------------+--------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

### Adaptations of Note from Table 1

Several of the table adaptations outlined in **Table 1** deserve extra attention, as they could not be handled just by filtering, for example.

#### **Issue 1: VMT data**

A `custom input database` can only have 1 of these four VMT tables: `sourcetypeyearvmt,` `hpmsvtypeyear,` `sourcetypedayvmt`, or `hpmsvtypeday`. If a year-level table `sourcetypeyearvmt` or `hpmsvtypeyear` is chosen, then other year-relevant VMT tables can be uploaded, namely, `monthVMTFraction`, `dayVMTFraction`, and `hourVMTFraction`. However, if day-level table `sourcetypedayvmt` or `hpmsvtypeday` is chosen, then other day-relevant VMT tables can be uploaded, namely `hourVMTFraction`.

#### **Issue 2 - Population Projection** 

Some tables required adjustments using population projections, discussed further in **Item 3.** To do so, we assembled a county dataset from 1990 to 2060 of population projections, listed in `catr::projections`. We rely on the following data:

-   For the years 1990 to 2020, we use county-level estimates for every US county, sourced from the National Historical Geographic Information Systems' IPUMS database, which records various census data historically over time. We use decennial census estimates for 1990, 2000, 2010, and 2020, and fill in missing years 2008-2019 using American Community Survey 5-year average estimates (ACS-5). For example, 2008 is represented by 2006-2010, 2009 is represented by 2007-2011, etc.

-   For the years 2021 to 2060, we use county-level population projections developed by Matt Hauer (2019) and published in *Nature: Scientific Data*. Hauer outlines 5 potential Shared Socioeconomic Pathways (SSPs) as population change scenarios for every county between 2015 and 2100, each depicting certain population change patterns depending on broader national socioeconomic conditions. These senarios include "Sustainability", "Middle of the Road", "Regional Equity", "Inequality", and "Fossil-Fuel Development". To be conservative, we use their population projections for a "Middle of the Road" scenario (SSP #2).

    -   **Paper Citation:** Hauer, M. Population projections for U.S. counties by age, sex, and race controlled to shared socioeconomic pathway. *Sci Data* **6**, 190005 (2019). <https://doi.org/10.1038/sdata.2019.5>

    -   **Data set citation**: Hauer, M., and Center for International Earth Science Information
        Network (CIESIN), Columbia University. 2021. Georeferenced U.S. County-Level
        Population Projections, Total and by Sex, Race and Age, Based on the SSPs, 2020-2100.
        Palisades, NY: NASA Socioeconomic Data and Applications Center (SEDAC).
        <https://doi.org/10.7927/dv72-s254.>

-   Any gaps (eg. 1991 to 1999) are filled in using linear interpolation between available data for each specific county over time. (The American Community Survey did not begin until 2006.)

-   Our final population projections dataset is built into the `catr` package under `catr::projections`, a 347,985 row dataset with 5 variables including the county `geoid`, `year`, estimated `pop`ulation, `total` national population projected in that year, and the `fraction` represented by the county `pop` divided by the national `total` population. See **Figure 1** for an example of these population projections.

![**Figure 1:** Population Projections in `catr::projections`](img/projections.png)

#### **Issue 3**: Population Weighting and Linear Interpolation 

In several cases, default input tables contain nation-level estimates for the year `2020`. Examples include `sourceTypeYear`, which measures `sourceTypePopulation` by vehicle type, and `HPMSVtypeYear`, which measures VMT by vehicle types. To adapt these values to the county level, we keep that same split of the stratifying variable (`sourcetypes)` (eg. 20% cars, 10% buses), but re-weight the data using the ratio of county population vs. national population projections (see **Issue 2**), for any year between 1990 and 2060.

**Example:** Building a Custom `sourceTypeYear` Table using Population Projections

-   `sourceTypeYear`**:** In the `default input database`, `sourceTypeYear` is recorded at the `nation` level for the year `2020`, recording the number of vehicles (`sourceTypePopulation`) per `sourceTypeID`. But, we down-weight the metric (`sourceTypePopulation`) for each level of the stratifying variable (each `sourceTypeID`) by multiplying it by the ratio of *county population vs. national population.* This estimates what a true vehicle population might look like in the county, supposing that the number of vehicles is related to population. Naturally, this is an imperfect estimate, but it provides much more realistic values for `sourceTypePopulation` than otherwise available.

#### **Issue 4** - **Fuel Inputs**

According to recent EPA guidance, because fuel properties can be quite variable, the EPA does not consider single or yearly station samples adequate for substitution. In other words, just don't touch FuelFormulations table, and take all the contents of the fuel supply table. Read more in [**Section 4.8.1 Fuel Formulation and Fuel Supply Guidance (2020).**](https://www.epa.gov/sites/default/files/2020-11/documents/420b20052.pdf)

#### **Table 2: Optional Tables for County Data Manager**

+-------------------+---------------------------------+--------------------------------------------------------------+
| Menu              | Table                           | Adaptation                                                   |
+===================+=================================+==============================================================+
| **Starts**        | `startsHourFraction`            | Filter by `dayID` and `hourID`                               |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Starts**        | `starts`                        | Filter by `yearID`                                           |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Starts**        | `startsPerDay`                  | Filter by `dayID`                                            |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Starts**        | `StartsPerDayPerVehicle`        | Filter by `dayID`                                            |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Starts**        | `startsMonthAdjust`             | Untouched                                                    |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Starts**        | `startsAgeAdjustment`           | Untouched                                                    |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Starts**        | `startsOpModeDistribution`      | Filter by `opModeID`, `dayID`, `hourID`                      |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Hotelling**     | `hotellingActivityDistribution` | Filter by `zoneID`                                           |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Hotelling**     | `hotellingHours`                | Untouched                                                    |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Hotelling**     | `hotellingHourFraction`         | Untouched                                                    |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Hotelling**     | `hotellingAgeFraction`          | Untouched                                                    |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Hotelling**     | `hotellingMonthAdjust`          | Untouched                                                    |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Idle**          | `totalIdleFraction`             | Filter by `idleRegionID`, `countyTypeID`, `monthID`, `dayID` |
+-------------------+---------------------------------+--------------------------------------------------------------+
| Idle              | `idleModelYearGrouping`         | Untouched                                                    |
+-------------------+---------------------------------+--------------------------------------------------------------+
| Idle              | `idleMonthAdjust`               | Untouched                                                    |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Idle**          | `idleDayAdjust`                 | Untouched                                                    |
+-------------------+---------------------------------+--------------------------------------------------------------+
| **Retrofit Data** | `onRoadRetrofit`                | Untouched                                                    |
+-------------------+---------------------------------+--------------------------------------------------------------+

#### Table 3: Generic Tables to be Updated

+---------------+-------------------------+------------------------------------+
| Menu          | Table                   | Adaptation                         |
+===============+=========================+====================================+
| Generic       | `year`                  | Filter by `yearID`                 |
+---------------+-------------------------+------------------------------------+
| Generic       | `county`                | Filter by `countyID`               |
+---------------+-------------------------+------------------------------------+
| Generic       | `state`                 | Filter by `stateID`                |
+---------------+-------------------------+------------------------------------+
| Generic       | `idleRegion`            | Filter by `idleRegionID`           |
+---------------+-------------------------+------------------------------------+
| Generic       | `zone`                  | Filter by `countyID`               |
+---------------+-------------------------+------------------------------------+
| Generic       | `zoneRoadType`          | Filter by `zoneID`                 |
+---------------+-------------------------+------------------------------------+
| Generic       | `regionCounty`          | Filter by `countyID`, `fuelYearID` |
+---------------+-------------------------+------------------------------------+
| Generic       | `pollutantProcessAssoc` | Filter by `pollutantID`            |
+---------------+-------------------------+------------------------------------+
| Generic       | `opModePolProcAssoc`    | Filter by `polProcessID`           |
+---------------+-------------------------+------------------------------------+

### 

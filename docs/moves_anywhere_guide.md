# MOVES Anywhere Guide

-   Lead Developer: Tim Fraser, PhD
-   Contributors: Erin Murphy, Junna Chen, Mahak Bindal, Shungo Najima, Carl Closs
-   Institution: Gao Labs \@ Cornell University
-   Description: A Docker-based solution to run MOVES anywhere - on Windows, Mac, or Linux

## 0. Welcome

Welcome to `moves_anywhere`! This software suite includes several tools to help you run the Environmental Protection Agency's [MO]{.underline}tor [V]{.underline}ehicle [E]{.underline}missions [S]{.underline}imulator (MOVES) more easily. Developed by Tim Fraser and colleagues at Gao Labs at Cornell University, `moves_anywhere` aims to solve several common problems for planners, engineers, and researchers who need to know how many tons of emissions are produced from on-road transportation sources in their county or state. These problems include:

-   Writing runspec.xml documents faster (a recipe for your MOVES run)

-   Running MOVES on any OS (Windows, Mac, or Linux), using a Docker container.

-   Running MOVES with custom inputs when you have *some (or none)* of the required custom input tables, but not all.

-   Post-processing MOVES inventory output data into the more dataviz-friendly "CAT Format", developed for Cornell's Climate Action in Transportation (CAT) team's research.

-   Uploading CAT Formatted Data to a Google Cloud SQL server using a Docker container.

-   And more!

*Note: This is a living document that will be updated continuously as development on `moves_anywhere` integrations continues, so be sure to check back for updates.*

## 1. Key Terms in `moves_anywhere`

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

-   `catr`: an R package containing tools in the R programming language for running various `moves_anywhere` processes.

    -   `adapt`(): an R function that adapts the MOVES default input database
    -   `custom_rs()`: an R function that writes customized runspec documents.
    -   `postprocess_format()`: An R function that combines a `movesoutput` and `movesactivityoutput` table from a your outputdatabase into a `data.csv` file.
    -   Others Example Helper Functions:
        -   `translate_rs()`: an R function that extracts important metadata from a runspec into an `R` list object.
        -   `connect()`: an R function that helps you quickly connect to your output or input database.
        -   and more!

-   `CAT Format`*:* This format refers to the act of joining an aggregating a `movesoutput` table and `movesactivityoutput` table from your output database. CAT Format has 16 types of aggregation possible, each with their own unique id called the `by` field. `by` can therefore range from aggregation id `by = 1` to `by = 16`. Each set of aggregated data can therefore be bundled atop each other, as long as they are differentiated by a `by` column, enabling easy filtering of ready-to-use data. This means that emissions and activity variables can be seen for each county year at different levels of aggregation.

    -   For example, `by=16` means completely aggregated, showing the total emissions and vehicle miles travel among other metrics for a given pollutant in a given year in a given county. `by = 8` shows total emissions and activity metrics for giving pollutants and it given a year in a given county disaggregated by sourcetype, meaning type of vehicle. `by = 1` means total emissions and activity metrics for a given pollutant in a given year in a given county completely disaggregated by source type, fuel type, regulatory class, and road type.

    -   For a detailed explanation of CAT Format, please see this markdown document!

## 2. `moves_anywhere` process

### 2.1 Process Overview

`moves_anywhere` follows the following process:

1.  First, a runspec is made, named `rs_custom.xml`. The catr package's custom_rs function can swiftly produce run specs from a limited set of inputs.

2.  Then, a bucket (eg. folder) is made to hold the runspec and any custom input tables.

3.  Any other custom input tables are placed into the bucket, where their names match their respective tables exactly, with no spaces, typically lowercase, written as `.csv` files. For example, the `sourceTypeYear` table would be saved in the bucket as `sourcetypeyear.csv`.

4.  The runspec `rs_custom.xml` is placed in the bucket.

5.  Then, a container is made from the 'moves' docker image (from `image_moves/`), where the bucket has been mounted to that container to the file path `cat-api/inputs/`. Any changes that the container makes to the contents of that folder occur to the contents of the bucket itself.

6.  Upon starting the moves container, this container runs the `bash` shell script `cat-api/launch.sh`. This script conducts settings, preprocessing, invokes moves, and then conducts data postprocessing.

7.  For members of the CAT research team, data can be optionally uploaded to the CATSERVER `orderdata` Cloud SQL server, dubbed `catcloud`.

### 2.2 Understanding the `moves` docker image

Let's take a closer look at step 6 from above, where the magic happens in the container.

#### *2.2.1 Settings*

Settings involves starting up the MySQL server on the container and loading environmental variables necessary for running moves from the setenv.sh script.

#### *2.2.2 Preprocessing*

Preprocessing involves using the runspec and user supplied custom input tables to run the adapt.r function. As discussed earlier, adapt() imports into the default input database any provided custom input tables. Then, if a given custom input table was not supplied, it develops suitable approximations from the default input data and save these as custom input tables. Additionally, it filters other relevant tables to reflect the metadata of that moves run, fixing the county, year, region, etc. At the end, the resulting database still bears the same name as its original form as a default input database, but it is now a custom input database, it must be listed in the runspec as such.

#### *2.2.3 Running MOVES*

Running moves involves compiling Go and Java, then directing moves to run using the specific runspec from the bucket. A typical county moves runtime for 1 county-year fairies depending on CPU. We have found that a virtual machine with 4GB of RAM and 1 CPU can run moves in inventory mode in 5-10 minutes. With more CPU, that number can decrease to about 2 minutes. A running moves in rate mode may require upwards of 30 minutes for a large number of pollutants.

#### *2.2.4 Post-processing*

-   At the conclusion of the moves container's process, it has written its output files to the aptly named output database `"moves"`. These tables will only exist as long as the container runs, so they must be collected from the database and written to file in the bucket as `csv`s.

-   The `postprocess.r` script extracts relevant tables depending on what type of run was specified in your `runspec`.

    -   If your `runspec` specified an **Emissions Inventory** run, the `movesoutput` and `movesactivityoutput` tables are extracted from your output database. They are saved to the mounted `/inputs` bucket as `movesoutput.csv` and `movesactivityoutput.csv`.

        -   Additionally, if a `parameter.json` is provided in the `inputs/` folder, then `catr` will run some formatting functions, combining these two tables into the more dataviz friendly CAT Format and save it as `data.csv` in the bucket.

    -   If your `runspec` specified an **Emissions Rates** run, the `rateperhour`, `ratepervehicle`, `rateperdistance`, `rateperstart`, `startspervehicle`, `rateperprofile`, and `movesrun` tables are extracted and saved to the mounted `/inputs` bucket as `rateperhour.csv`, `ratepervehicle.csv`, `rateperdistance.csv`, `rateperstart.csv`, `startspervehicle.csv`, `rateperprofile.csv`, and `movesrun.csv`.

## 3. Configuring your `/inputs` bucket

### 3.1 Basic Requirements

All docker images used in `moves_anywhere` involve a folder/bucket that gets mounted to the path `/cat-api/inputs` in the container. This is the location where we can pass files to the container, and receive new outputted files from the container. Your bucket may contain the following information:

-   **Mandatory Inputs**

    -   `/inputs/rs_custom.xml`: a runspec file.

-   **Optional Inputs**

    -   `/inputs/your_custom_input_table_here.csv`: any custom input tables can be added here, where the file should share the name of your custom input table, followed by `.csv`. For example, `sourceTypeYear` should be `sourcetypeyear.csv`.

    -   `/inputs/parameters.json`: The Cornell CAT system uses a `parameters.json` for several extra functionalities of `moves_anywhere`, like having `catr` aggregate data into a `data.csv` or having the file uploaded to `catcloud`. A `parameters.json` is not otherwise required.

-   **Potential Outputs**

    -   `/inputs/movesoutput.csv`: a summary of a `emissionsQuant` by `pollutantID`, `sourceTypeID`, `roadTypeID`, `fuelTypeID`, `countyID`, etc. **[Inventory mode only]**

    -   `/inputs/movesactivityoutput.csv`: a summary of `activity` metrics by `activityTypeID`, and any other stratification variables. **[Inventory mode only]**

    -   `/inputs/data.csv`: a CAT-formatted aggregated data table, according to the specifications requested in `parameters.json`. **[Inventory mode only]**

    -   `/inputs/rateperhour.csv` **[Rate mode only]**

    -   `/inputs/ratepervehicle.csv` **[Rate mode only]**

    -   `/inputs/rateperdistance.csv` **[Rate mode only]**

    -   `/inputs/rateperstart.csv` **[Rate mode only]**

    -   `/inputs/startspervehicle.csv` **[Rate mode only]**

    -   `/inputs/rateperprofile.csv` **[Rate mode only]**

    -   `/inputs/movesrun.csv` **[Rate mode only; may be added for Inventory mode in future.]**

        -   For detailed descriptions of these tables and their variables, see the [**MOVES documentation on Database Tables on Github.**](https://github.com/USEPA/EPA_MOVES_Model/blob/master/docs/MOVESDatabaseTables.md)

### 3.2 `custom input tables` required by MOVES

There are up to 39\~41 total custom input tables that must be edited to use `moves_anywhere` with MOVES 4.0. This includes 13\~15 [**required**]{.underline} **user-supplied tables**, which users must supply in the traditional County Data Manager user interface (**Table 1**), and 17 [**optional**]{.underline} **user-supplied tables**, for which MOVES typically automatically sources defaults if not supplied (**Table 2**). Further, **9 background tables** must be updated to reflect the geography, time frame, regions, etc. on the run (**Table 3**). Any of the remaining \~200 tables in the MOVES default input database can also be updated. See [here](#0) for a full list of all MOVES database tables.

One of the key challenges of using MOVES is that unless someone crafts all **required user-supplied tables**, MOVES [**refuses**]{.underline} to perform a `custom run`. This was extremely difficult as a user and developer working with MOVES, and was the motivation for creating the `adapt()` function.

`adapt()`: So, the first step of the `moves_anywhere` team was to develop a strategy to populate these required `custom input tables` with 'good-enough' values, by borrowing relevant values from the default database and/or transforming them where needed. This was to make it possible that *even if* you don't have **all** the possible input data about your scenario, you can still run MOVES. We refer to this process as the `adapt()` function in the `catr` package, which adapts the `default input database` and any supplied `custom input tables` into a fully operational `custom input database`*.*

#### Table 1: User-Supplied Tables Required by County Data Manager

| Menu                           | Table                        | Adaptation                                                                                                                                                                                                                                                           |
| ------------------------ | ---------------- | --------------------------------------------------- |
| **Vehicle Type VMT**          | `monthVMTFraction`           | Used if VMT is **Annual**                                                                                                                                                                                                                                            |
| **Vehicle Type VMT**          | `dayVMTFraction`             | Used if VMT is **Annual**                                                                                                                                                                                                                                            |
| **Vehicle Type VMT**          | `hourVMTFraction`            | Used if VMT is **Annual** or **Daily**                                                                                                                                                                                                                               |
| **Vehicle Type VMT**          | `SourceTypeYearVMT`          | OR `HPMSVtypeYear`           | Used if VMT is **Annual.** If no VMT tables provided, existing `HPMSVtypeYear` table is population re-weighted and used.                                                                                                                                             |
| **Vehicle Type VMT**          | `SourceTypeDayVMT`           | OR `HPMSVTypeDay`<sup>1</sup>| Used if VMT is **Daily.** If no VMT tables provided, existing `HPMStypeYear` table is population re-weighted and used.                                                                                                                                               |
| **Source Type Population**    | `sourceTypeYear`             | Using national-level default `sourceTypeYear`, [interpolated and population-weighted]<sup>2</sup>                                                                                                                                                                    |
| **Fuel**                      | `AVFT`                       | Using [`samplevehiclepopulation`](https://github.com/USEPA/EPA_MOVES_Model/blob/master/docs/MOVESDatabaseTables.md#samplevehiclepopulation), group by `sourceTypeID`, `modelYearID`, `fuelTypeID`, and `engTechID` and sum `stmyFraction` to make `fuelEngFraction`. |
| **Fuel**                      | `FuelSupply`                 | Filter by `fuelRegionID`, `fuelYearID`, `monthGroupID`                                                                                                                                                                                                               |
| **Fuel**                      | `FuelUsageFraction`          | Filter by `countyID`, `fuelYearID`                                                                                                                                                                                                                                   |
| **Fuel**                      | `FuelFormulation`<sup>3</sup>| Untouched                                                                                                                                                                                                                                                            |
|                                |                              | (*Avoid Tinkering*)                                                                                                                                                                                                                                                  |
| **Average Speed Distribution**| `avgSpeedDistribution`       | Filter by `hourDayID`                                                                                                                                                                                                                                                |
| **Age Distribution**          | `sourceTypeAgeDistribution`  | Filter by `yearID`                                                                                                                                                                                                                                                   |
| **Road Type Distribution**    | `roadTypeDistribution`       | Untouched                                                                                                                                                                                                                                                            |
| **I/M Programs**              | `IMCoverage`                 | Filter by `stateID`, `countyID`, `yearID`                                                                                                                                                                                                                            |
| **Meteorology Data**          | `zoneMonthHour`              | Filter by `zoneID`, `monthID`, `hourID`                                                                                                                                                                                                                              |

#### **Table 2: Optional Tables for County Data Manager**

| Menu          | Table                  | Adaptation     |
| ------        | ---------------------- | -------------- |
| **Starts**    | `startsHourFraction`   | Filter by `dayID` and `hourID` |
| **Starts**    | `starts`               | Filter by `yearID` |
| **Starts**    | `startsPerDay`         | Filter by `dayID` |
| **Starts**    | `StartsPerDayPerVehicle` | Filter by `dayID` |
| **Starts**    | `startsMonthAdjust`    | Untouched |
| **Starts**    | `startsAgeAdjustment`  | Untouched |
| **Starts**    | `startsOpModeDistribution` | Filter by `opModeID`, `dayID`, `hourID` |
| **Hotelling** | `hotellingActivityDistribution` | Filter by `zoneID` |
| **Hotelling** | `hotellingHours`       | Untouched |
| **Hotelling** | `hotellingHourFraction` | Untouched |
| **Hotelling** | `hotellingAgeFraction` | Untouched |
| **Hotelling** | `hotellingMonthAdjust` | Untouched |
| **Idle**      | `totalIdleFraction`    | Filter by `idleRegionID`, `countyTypeID`, `monthID`, `dayID` |
| **Idle**      | `idleModelYearGrouping` | Untouched |
| **Idle**      | `idleMonthAdjust`      | Untouched |
| **Idle**      | `idleDayAdjust`        | Untouched |
| **Retrofit Data** | `onRoadRetrofit`   | Untouched |

#### Table 3: Generic Tables to be Updated

| Menu          | Table                   | Adaptation                         |
| ------------- | ----------------------- | ---------------------------------- |
| Generic       | `year`                  | Filter by `yearID`                 |
| Generic       | `county`                | Filter by `countyID`               |
| Generic       | `state`                 | Filter by `stateID`                |
| Generic       | `idleRegion`            | Filter by `idleRegionID`           |
| Generic       | `zone`                  | Filter by `countyID`               |
| Generic       | `zoneRoadType`          | Filter by `zoneID`                 |
| Generic       | `regionCounty`          | Filter by `countyID`, `fuelYearID` |
| Generic       | `pollutantProcessAssoc` | Filter by `pollutantID`            |
| Generic       | `opModePolProcAssoc`    | Filter by `polProcessID`           |


### Adaptations of Note

Several of the table adaptations outlined in **Table 1** deserve extra attention, as they could not be handled just by filtering, for example.

#### **Issue 1: VMT data**

A `custom input database` can only have 1 of these four VMT tables: `sourcetypeyearvmt,` `hpmsvtypeyear,` `sourcetypedayvmt`, or `hpmsvtypeday`. If a year-level table `sourcetypeyearvmt` or `hpmsvtypeyear` is chosen, then other year-relevant VMT tables can be uploaded, namely, `monthVMTFraction`, `dayVMTFraction`, and `hourVMTFraction`. However, if day-level table `sourcetypedayvmt` or `hpmsvtypeday` is chosen, then other day-relevant VMT tables can be uploaded, namely `hourVMTFraction`.

#### **Issue 2: Population Projection**

Some tables required adjustments using population projections, discussed further in **Item 3.** To do so, we assembled a county dataset from 1990 to 2060 of population projections, listed in `catr::projections`. We rely on the following data:

-   For the years 1990 to 2020, we use county-level estimates for every US county, sourced from the National Historical Geographic Information Systems' IPUMS database, which records various census data historically over time. We use decennial census estimates for 1990, 2000, 2010, and 2020, and fill in missing years 2008-2019 using American Community Survey 5-year average estimates (ACS-5). For example, 2008 is represented by 2006-2010, 2009 is represented by 2007-2011, etc.

-   For the years 2021 to 2060, we use county-level population projections developed by Matt Hauer (2019) and published in *Nature: Scientific Data*. Hauer outlines 5 potential Shared Socioeconomic Pathways (SSPs) as population change scenarios for every county between 2015 and 2100, each depicting certain population change patterns depending on broader national socioeconomic conditions. These senarios include "Sustainability", "Middle of the Road", "Regional Equity", "Inequality", and "Fossil-Fuel Development". To be conservative, we use their population projections for a "Middle of the Road" scenario (SSP #2).

    -   **Paper Citation:** Hauer, M. Population projections for U.S. counties by age, sex, and race controlled to shared socioeconomic pathway. *Sci Data* **6**, 190005 (2019). <https://doi.org/10.1038/sdata.2019.5>

    -   **Data set citation**: Hauer, M., and Center for International Earth Science Information Network (CIESIN), Columbia University. 2021. Georeferenced U.S. County-Level Population Projections, Total and by Sex, Race and Age, Based on the SSPs, 2020-2100. Palisades, NY: NASA Socioeconomic Data and Applications Center (SEDAC). <https://doi.org/10.7927/dv72-s254.>

-   Any gaps (eg. 1991 to 1999) are filled in using linear interpolation between available data for each specific county over time. (The American Community Survey did not begin until 2006.)

-   Our final population projections dataset is built into the `catr` package under `catr::projections`, a 347,985 row dataset with 5 variables including the county `geoid`, `year`, estimated `pop`ulation, `total` national population projected in that year, and the `fraction` represented by the county `pop` divided by the national `total` population. See **Figure 1** for an example of these population projections.

![**Figure 1:** Population Projections in `catr::projections`](img/projections.png)

#### **Issue 3**: Population Weighting and Linear Interpolation

In several cases, default input tables contain nation-level estimates for the year `2020`. Examples include `sourceTypeYear`, which measures `sourceTypePopulation` by vehicle type, and `HPMSVtypeYear`, which measures VMT by vehicle types. To adapt these values to the county level, we keep that same split of the stratifying variable (`sourcetypes)` (eg. 20% cars, 10% buses), but re-weight the data using the ratio of county population vs. national population projections (see **Issue 2**), for any year between 1990 and 2060.

**Example:** Building a Custom `sourceTypeYear` Table using Population Projections

-   `sourceTypeYear`**:** In the `default input database`, `sourceTypeYear` is recorded at the `nation` level for the year `2020`, recording the number of vehicles (`sourceTypePopulation`) per `sourceTypeID`. But, we down-weight the metric (`sourceTypePopulation`) for each level of the stratifying variable (each `sourceTypeID`) by multiplying it by the ratio of *county population vs. national population.* This estimates what a true vehicle population might look like in the county, supposing that the number of vehicles is related to population. Naturally, this is an imperfect estimate, but it provides much more realistic values for `sourceTypePopulation` than otherwise available.

#### **Issue 4**: **Fuel Inputs**

According to recent EPA guidance, because fuel properties can be quite variable, the EPA does not consider single or yearly station samples adequate for substitution. In other words, just don't touch FuelFormulations table, and take all the contents of the fuel supply table. Read more in [**Section 4.8.1 Fuel Formulation and Fuel Supply Guidance (2020).**](https://www.epa.gov/sites/default/files/2020-11/documents/420b20052.pdf)

## 

## 4. How does `catr` write Runspecs and Parameters?

### 4.1 How does `catr` write `runspec` files?

`moves_anywhere` uses the `catr` package and its function `custom_rs()` to write runspec.xml files, based off a template stored in `catr::rs_template`. It programmatically replaces runspec contents, according to several parameters. [See `catr/R/custom_rs.R` for a detailed explanation and source code](https://github.com/Gao-Labs/moves_anywhere/blob/main/catr/R/custom_rs.R).

To write a runspec, you need your...

-   `.geoid` (eg. `"36109"`) - geographic area of analysis, using US FIPS codes.

-   `.year` (eg. `2020`) - year of analysis

-   `.level` (eg. `"county"`, `"state"`) - level of analysis

-   `.default` (eg. FALSE) - is it a default run or a custom run? (ie. county data manager style)

-   `.path` output path for your runspec

-   `.rate` (eg. FALSE) - is it an inventory mode run (`FALSE`) or an emissions rates mode run (`TRUE`).

-   `.geoaggregation` (eg. `"county"`, `"link"`, `"state"`) should your results be aggregated/disaggregated to a different geographic level afterwards?

-   `.timeaggregation` (eg. `"year"`, `"hour"`) should your results be aggregated/disaggregated to a different temporal level?

### 4.2 How does `catr` write `parameters.json` files?

`moves_anywhere` can write a `parameters.json` file from any `runspec` file, plus a few optional values, using `catr` package and its function `rs_to_parameters()`.


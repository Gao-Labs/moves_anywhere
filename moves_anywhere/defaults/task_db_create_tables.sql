CREATE TABLE IF NOT EXISTS avft (
    sourceTypeID SMALLINT(6) NOT NULL,
    modelYearID SMALLINT(6) NOT NULL,
    fuelTypeID SMALLINT(6) NOT NULL,
    engTechID SMALLINT(6) NOT NULL,
    fuelEngFraction DOUBLE NOT NULL COMMENT 'fraction of vehicles within source type and model year which are the fuel type and engine technology combination',
    PRIMARY KEY (sourceTypeID, modelYearID, fuelTypeID, engTechID)
);

CREATE TABLE IF NOT EXISTS avgSpeedDistribution (
    sourceTypeID SMALLINT(6) NOT NULL,
    roadTypeID SMALLINT(6) NOT NULL,
    hourDayID SMALLINT(6) NOT NULL,
    avgSpeedBinID SMALLINT(6) NOT NULL,
    avgSpeedFraction FLOAT DEFAULT NULL COMMENT 'fraction of SHO in the average speed bin. Sums to 1 for each source type, road type, and hourDay combination',
    PRIMARY KEY (sourceTypeID, roadTypeID, hourDayID, avgSpeedBinID)
);

CREATE TABLE IF NOT EXISTS dayVMTFraction (
    sourceTypeID SMALLINT(6) NOT NULL,
    monthID SMALLINT(6) NOT NULL,
    roadTypeID SMALLINT(6) NOT NULL,
    dayID SMALLINT(6) NOT NULL,
    dayVMTFraction FLOAT DEFAULT NULL COMMENT 'Fraction of VMT for each type of day, which sums to 1 within each source type, month, and road type combination',
    PRIMARY KEY (sourceTypeID, monthID, roadTypeID, dayID)
);

CREATE TABLE IF NOT EXISTS fuelFormulation (
    fuelFormulationID INT(11) NOT NULL DEFAULT 0 COMMENT 'IDs < 100 are reserved for base fuel properties (see baseFuel table)',
    fuelSubtypeID SMALLINT(6) NOT NULL DEFAULT 0,
    RVP FLOAT DEFAULT NULL COMMENT 'the Reid Vapor Pressure of the given fuel formulation in PSI',
    sulfurLevel FLOAT NOT NULL DEFAULT 30 COMMENT 'the sulfur level of the given fuel formulation in ppm',
    ETOHVolume FLOAT DEFAULT NULL COMMENT 'the volume percentage of ethanol content of the given fuel formulation',
    MTBEVolume FLOAT DEFAULT NULL COMMENT 'not used',
    ETBEVolume FLOAT DEFAULT NULL COMMENT 'not used',
    TAMEVolume FLOAT DEFAULT NULL COMMENT 'not used',
    aromaticContent FLOAT DEFAULT NULL COMMENT 'the volume percentage of aromatics content of the given fuel formulation',
    olefinContent FLOAT DEFAULT NULL COMMENT 'the volume percentage of olefinic content of the given fuel formulation',
    benzeneContent FLOAT DEFAULT NULL COMMENT 'the volume percentage of benzene content of the given fuel formulation',
    e200 FLOAT DEFAULT NULL COMMENT 'the E200 distillation metric of the given fuel formulation in percentage',
    e300 FLOAT DEFAULT NULL COMMENT 'the E300 distillation metric of the given fuel formulation in percentage',
    volToWtPercentOxy FLOAT DEFAULT NULL COMMENT 'the ratio of volume to percentage oxygenate content for the given fuel formulation',
    BioDieselEsterVolume FLOAT DEFAULT NULL COMMENT 'the volume percentage of biodiesel content of the given fuel formulation',
    CetaneIndex FLOAT DEFAULT NULL COMMENT 'the cetane index of the given fuel formulation',
    PAHContent FLOAT DEFAULT NULL COMMENT 'the poly-aromatic hydrocarbon content of the given fuel formulation in percentage',
    T50 FLOAT DEFAULT NULL COMMENT 'the T50 distillation metric of the given fuel formulation in degrees F',
    T90 FLOAT DEFAULT NULL COMMENT 'the T90 distillation metric of the given fuel formulation in degrees F',
    PRIMARY KEY (fuelFormulationID, fuelSubtypeID)
);

CREATE TABLE IF NOT EXISTS fuelSupply (
    fuelRegionID INT(11) NOT NULL DEFAULT 0 COMMENT 'see regioncounty table',
    fuelYearID SMALLINT(6) NOT NULL DEFAULT 0,
    monthGroupID SMALLINT(6) NOT NULL DEFAULT 0,
    fuelFormulationID INT(11) NOT NULL DEFAULT 0 COMMENT 'see fuelformulation table',
    marketShare FLOAT DEFAULT NULL COMMENT 'the volume fraction of a given fuel formulation used in the fuel region. Should sum to 1 for every month, for each fuel type present.',
    marketShareCV FLOAT DEFAULT NULL COMMENT 'not used',
    PRIMARY KEY (fuelRegionID, fuelYearID, monthGroupID, fuelFormulationID)
);

CREATE TABLE IF NOT EXISTS fuelUsageFraction (
    countyID INT(11) NOT NULL,
    fuelYearID INT(11) NOT NULL,
    modelYearGroupID INT(11) NOT NULL,
    sourceBinFuelTypeID SMALLINT(6) NOT NULL COMMENT 'the fuel type originally associated with the given source bin',
    fuelSupplyFuelTypeID SMALLINT(6) NOT NULL COMMENT 'the fuel type actually used in the vehicle for this source bin',
    usageFraction DOUBLE DEFAULT NULL COMMENT 'the fraction of vehicles using the given sourceBin fuel type and fuelSupply fuel type combination. Should sum to 1 for a given sourceBinFuelType.',
    PRIMARY KEY (countyID, fuelYearID, modelYearGroupID, sourceBinFuelTypeID, fuelSupplyFuelTypeID)
);

CREATE TABLE IF NOT EXISTS hotellingActivityDistribution (
    zoneID INT(11) NOT NULL,
    fuelTypeID SMALLINT(6) NOT NULL,
    beginModelYearID SMALLINT(6) NOT NULL,
    endModelYearID SMALLINT(6) NOT NULL,
    opModeID SMALLINT(6) NOT NULL COMMENT 'this table only contains the hotelling operating modes (200, 201, 203, and 204)',
    opModeFraction FLOAT NOT NULL COMMENT 'fraction of time spent in each operating mode, summing to 1 for each zone, fuel type, and model year group',
    PRIMARY KEY (zoneID, fuelTypeID, beginModelYearID, endModelYearID, opModeID)
);

CREATE TABLE IF NOT EXISTS hourVMTFraction (
    sourceTypeID SMALLINT(6) NOT NULL DEFAULT 0,
    roadTypeID SMALLINT(6) NOT NULL DEFAULT 0,
    dayID SMALLINT(6) NOT NULL DEFAULT 0,
    hourID SMALLINT(6) NOT NULL DEFAULT 0,
    hourVMTFraction FLOAT DEFAULT NULL COMMENT 'fraction of VMT allocated to each hour within every source type, road type, and day type',
    PRIMARY KEY (sourceTypeID, roadTypeID, dayID, hourID)
);

CREATE TABLE IF NOT EXISTS imCoverage (
    polProcessID INT(11) NOT NULL DEFAULT 0,
    stateID SMALLINT(6) NOT NULL DEFAULT 0,
    countyID INT(11) NOT NULL DEFAULT 0,
    yearID SMALLINT(6) NOT NULL DEFAULT 0,
    sourceTypeID SMALLINT(6) NOT NULL DEFAULT 0,
    fuelTypeID SMALLINT(6) NOT NULL DEFAULT 0,
    IMProgramID SMALLINT(6) NOT NULL DEFAULT 0,
    begModelYearID SMALLINT(6) NOT NULL DEFAULT 0,
    endModelYearID SMALLINT(6) NOT NULL DEFAULT 0,
    inspectFreq SMALLINT(6) DEFAULT NULL COMMENT 'Inspection frequency associated with the IMProgramID which is annual, biennial, or continuous/monthly. Note that there are currently no emission benefits assigned to the continuous option.',
    testStandardsID SMALLINT(6) NOT NULL DEFAULT 0,
    useIMyn CHAR(1) NOT NULL DEFAULT 'Y' COMMENT 'This allows uses to turn off ("N") or on ("Y") the portion of the I/M program described in that row of the table.',
    complianceFactor FLOAT DEFAULT NULL COMMENT 'The compliance factor is entered as a decimal number from 0 to 100 and represents the percentage of vehicles within a source type that actually receive the benefits of the program.',
    PRIMARY KEY (polProcessID, stateID, countyID, yearID, sourceTypeID, fuelTypeID, IMProgramID)
);

CREATE TABLE IF NOT EXISTS monthVMTFraction (
    sourceTypeID SMALLINT(6) NOT NULL DEFAULT 0,
    monthID SMALLINT(6) NOT NULL DEFAULT 0,
    monthVMTFraction FLOAT DEFAULT NULL COMMENT 'fraction of VMT allocated to each month, summing to 1 for each source type',
    PRIMARY KEY (sourceTypeID, monthID)
);

CREATE TABLE IF NOT EXISTS roadTypeDistribution (
    sourceTypeID SMALLINT(6) NOT NULL DEFAULT 0,
    roadTypeID SMALLINT(6) NOT NULL DEFAULT 0,
    roadTypeVMTFraction FLOAT DEFAULT NULL COMMENT 'fraction of VMT on each road type per source type',
    PRIMARY KEY (sourceTypeID, roadTypeID)
);


CREATE TABLE IF NOT EXISTS sourceTypeYear (
    yearID SMALLINT(6) NOT NULL,
    sourceTypeID SMALLINT(6) NOT NULL,
    salesGrowthFactor DOUBLE DEFAULT NULL,
    sourceTypePopulation DOUBLE DEFAULT NULL,
    migrationrate DOUBLE DEFAULT NULL,
    PRIMARY KEY (yearID, sourceTypeID)
);

CREATE TABLE IF NOT EXISTS sourceTypeYearVMT (
    yearID SMALLINT(6) NOT NULL,
    sourceTypeID SMALLINT(6) NOT NULL,
    VMT DOUBLE NOT NULL COMMENT 'Total VMT for each source type within a year',
    PRIMARY KEY (yearID, sourceTypeID)
);

CREATE TABLE IF NOT EXISTS sourceTypeAgeDistribution (
    sourceTypeID SMALLINT(6) NOT NULL DEFAULT 0,
    yearID SMALLINT(6) NOT NULL DEFAULT 0,
    ageID SMALLINT(6) NOT NULL DEFAULT 0,
    ageFraction DOUBLE DEFAULT NULL COMMENT 'fraction of vehicles of each age for each source type and year',
    PRIMARY KEY (sourceTypeID, yearID, ageID)
);

CREATE TABLE IF NOT EXISTS startsHourFraction (
    dayID SMALLINT(6) NOT NULL DEFAULT 0,
    hourID SMALLINT(6) NOT NULL DEFAULT 0,
    sourceTypeID SMALLINT(6) NOT NULL DEFAULT 0,
    allocationFraction DOUBLE NOT NULL COMMENT 'fraction of starts in the given hour, which should always sum to 1 for each day, source type combination',
    PRIMARY KEY (dayID, hourID, sourceTypeID)
);

CREATE TABLE IF NOT EXISTS startsPerDayPerVehicle (
    dayID SMALLINT(6) NOT NULL DEFAULT 0,
    sourceTypeID SMALLINT(6) NOT NULL DEFAULT 0,
    startsPerDayPerVehicle DOUBLE DEFAULT NULL COMMENT 'per typical day',
    PRIMARY KEY (dayID, sourceTypeID)
);

CREATE TABLE IF NOT EXISTS startsPerVehicle (
    sourceTypeID SMALLINT(6) NOT NULL DEFAULT 0,
    hourDayID SMALLINT(6) NOT NULL DEFAULT 0,
    startsPerVehicle FLOAT DEFAULT NULL,
    startsPerVehicleCV FLOAT DEFAULT NULL COMMENT 'not used',
    PRIMARY KEY (sourceTypeID, hourDayID)
);

CREATE TABLE IF NOT EXISTS totalIdleFraction (
    sourceTypeID INT(11) NOT NULL DEFAULT 0,
    minModelYearID INT(11) NOT NULL DEFAULT 0,
    maxModelYearID INT(11) NOT NULL DEFAULT 0,
    monthID INT(11) NOT NULL DEFAULT 0,
    dayID INT(11) NOT NULL DEFAULT 0,
    idleRegionID INT(11) NOT NULL DEFAULT 0,
    countyTypeID INT(11) NOT NULL DEFAULT 0,
    totalIdleFraction DOUBLE DEFAULT NULL COMMENT 'fraction of total SHO which is off-network idle activity',
    PRIMARY KEY (sourceTypeID, minModelYearID, maxModelYearID, monthID, dayID, idleRegionID, countyTypeID)
);

CREATE TABLE IF NOT EXISTS zoneMonthHour (
    monthID SMALLINT(6) NOT NULL DEFAULT 0,
    zoneID INT(11) NOT NULL DEFAULT 0,
    hourID SMALLINT(6) NOT NULL DEFAULT 0,
    temperature DOUBLE DEFAULT NULL COMMENT 'average temperature for the month and hour in Fahrenheit',
    relHumidity DOUBLE DEFAULT NULL,
    heatIndex DOUBLE DEFAULT NULL COMMENT 'used during MOVES runtime only, in Fahrenheit',
    specificHumidity DOUBLE DEFAULT NULL COMMENT 'used during MOVES runtime only, in grams of water per kilogram of dry air',
    molWaterFraction DOUBLE DEFAULT NULL COMMENT 'used during MOVES runtime only, in moles of water per mole of ambient air',
    PRIMARY KEY (monthID, zoneID, hourID)
);

-- https://github.com/USEPA/EPA_MOVES_Model/blob/master/database/CreateDefault.sql
-- Accessed March 12, 2025

-- Author Wesley Faler
-- Author Harvey Michaels
-- Author ahuang
-- Author Ed Glover
-- Author John Covey
-- Version 2018-03-06



CREATE TABLE IF NOT EXISTS  AgeCategory (
       ageID                SMALLINT NOT NULL,
       ageGroupID           SMALLINT,
       ageCategoryName      CHAR(50) NULL,
       key (ageGroupID, ageID),
       key (ageID, ageGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKAgeCategory ON AgeCategory
(
       ageID                          ASC
);

CREATE TABLE IF NOT EXISTS  AgeGroup (
	ageGroupID   SMALLINT NOT NULL,
	ageGroupName CHAR(50)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKAgeGroup ON AgeGroup
(
       ageGroupID   ASC
);

CREATE TABLE IF NOT EXISTS  ATBaseEmissions 
(
	polProcessID			int		NOT NULL	default '0',
	monthGroupID			int(11)			NOT NULL	default '0',
	atBaseEmissions			float			NOT NULL	default '0',
	dataSourceID			smallint(6)		NULL		default NULL,
	primary key (polProcessID, monthGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  ActivityType (
	activityTypeID       SMALLINT UNSIGNED NOT NULL,
	activityType         CHAR(20) NOT NULL,
	activityTypeDesc     CHAR(50) NULL DEFAULT NULL,
	PRIMARY KEY (activityTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  ATRatio (
	fuelTypeID int not null,
	fuelFormulationID int(11) not null,
	polProcessID int not null,
	minModelYearID int not null,
	maxModelYearID int not null,
	ageID int not null,
	monthGroupID int not null,
	atRatio double null,
  PRIMARY KEY (fuelTypeID, fuelFormulationID, polProcessID, minModelYearID, maxModelYearID, ageID, monthGroupID),
	key atratio_key1 (fuelFormulationID, polProcessID, minModelYearID),
	key atratio_key2 (polProcessID, fuelTypeID, monthGroupID, minModelYearID, ageID, maxModelYearID, fuelFormulationID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  ATRatioGas2
(
  polProcessID int NOT NULL default '0',
  sourceTypeID smallint(6) NOT NULL default '0',
  fuelSubtypeID smallint(6) default NULL,
  ATRatio float default NULL,
  ATRatioCV float default NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKATRatioGas2 ON ATRatioGas2
(
	polProcessID,
	sourceTypeID,
	fuelSubtypeID
);

CREATE TABLE IF NOT EXISTS  ATRatioNonGas
(
  polProcessID int NOT NULL DEFAULT '0',
  sourceTypeID smallint(6) NOT NULL DEFAULT '0',
  fuelSubtypeID smallint(6) NOT NULL DEFAULT '0',
  modelYearGroupID int(11) NOT NULL DEFAULT '0',
  ATRatio double DEFAULT NULL,
  ATRatioCV double DEFAULT NULL,
  dataSourceId smallint(6) DEFAULT NULL,
  PRIMARY KEY (polProcessID,sourceTypeID,fuelSubtypeID,modelYearGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  AverageTankGasoline (
	zoneID int(11) NOT NULL,
	fuelTypeID smallint(6) NOT NULL,
	fuelYearID int NOT NULL,
	monthGroupID smallint(6) NOT NULL,
	ETOHVolume float default NULL,
	RVP float NULL,
	isUserInput char(1) NOT NULL default 'N',
	PRIMARY KEY  (zoneID,fuelTypeID,fuelYearID,monthGroupID),
	index(isUserInput)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  AverageTankTemperature (
	tankTemperatureGroupID SMALLINT NOT NULL,
	zoneID INTEGER NOT NULL,
	monthID SMALLINT NOT NULL,
	hourDayID SMALLINT NOT NULL,
	opModeID SMALLINT NOT NULL,
	averageTankTemperature FLOAT,
	averageTankTemperatureCV FLOAT
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKAverageTankTemperature ON AverageTankTemperature (
	tankTemperatureGroupID ASC,
	zoneID ASC,
	monthID ASC,
	hourDayID ASC,
	opModeID ASC
);

CREATE TABLE IF NOT EXISTS  avft (
	sourceTypeID smallint(6) not null,
	modelYearID smallint unsigned not null,
	fuelTypeID smallint(6) not null,
	engTechID smallint not null,
	fuelEngFraction double not null,
	primary key (sourceTypeID, modelYearID, fuelTypeID, engTechID),
	key (sourceTypeID),
	key (modelYearID),
	key (fuelTypeID),
	key (engTechID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  AvgSpeedBin (
       avgSpeedBinID        SMALLINT NOT NULL,
       avgBinSpeed          FLOAT NULL,
       avgSpeedBinDesc      CHAR(50) NULL,
       opModeIDTirewear		SMALLINT(6) NULL default NULL,
       opModeIDRunning		SMALLINT(6) NULL default NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKAvgSpeedBin ON AvgSpeedBin
(
       avgSpeedBinID                  ASC
);

CREATE TABLE IF NOT EXISTS  AvgSpeedDistribution (
       sourceTypeID         SMALLINT NOT NULL,
       roadTypeID           SMALLINT NOT NULL,
       hourDayID            SMALLINT NOT NULL,
       avgSpeedBinID        SMALLINT NOT NULL,
       avgSpeedFraction     FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE AvgSpeedDistribution ADD (
       KEY (sourceTypeID),
       KEY (roadTypeID),
       KEY (hourDayID),
       KEY (avgSpeedBinID)
);

CREATE UNIQUE INDEX XPKAvgSpeedDistribution ON AvgSpeedDistribution
(
       sourceTypeID                   ASC,
       roadTypeID                     ASC,
       hourDayID                      ASC,
       avgSpeedBinID                  ASC
);

CREATE TABLE IF NOT EXISTS  BaseFuel
(
	calculationEngine varchar(100) not null,
	fuelTypeID smallint(6) not null,
	modelYearGroupID int(11) not null default '0',
	fuelFormulationID int(11) not null,
	description varchar(255) not null default '',
	dataSourceID smallint(6) not null,
	primary key (calculationEngine, fuelTypeID, modelYearGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  ColdSoakInitialHourFraction (
	sourceTypeID smallint(6) NOT NULL,
	zoneID int(11) NOT NULL,
	monthID smallint(6) NOT NULL,
	hourDayID smallint(6) NOT NULL,
	initialHourDayID smallint(6) NOT NULL,
	coldSoakInitialHourFraction float NOT NULL,
	isUserInput char(1) NOT NULL default 'N',
	PRIMARY KEY  (sourceTypeID,zoneID,monthID,hourDayID,initialHourDayID),
	index (isUserInput)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  ColdSoakTankTemperature (
  zoneID int(11) NOT NULL,
  monthID smallint(6) NOT NULL,
  hourID smallint(6) NOT NULL,
  coldSoakTankTemperature float NOT NULL,
  PRIMARY KEY  (zoneID,monthID,hourID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  ComplexModelParameterName 
(
	cmpID   		smallint(6)  	NOT NULL   	default '0' primary key,
	cmpName			char(25),
	cmpExpression   varchar(500) not null
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  ComplexModelParameters 
(
	polProcessID			int     		NOT NULL	default '0',		
	fuelModelID   			smallint(6)  	NOT NULL   	default '0',
	cmpID 					smallint(6)  	NOT NULL   	default '0',	
	coeff1					float			NULL		default NULL,	
	coeff2					float			NULL		default NULL,	
	coeff3					float			NULL		default NULL,
	dataSourceID			smallint(6)		NULL		default NULL,
	primary key (polProcessID, fuelModelID, cmpID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  County (
       countyID             INTEGER NOT NULL,
       stateID              SMALLINT NOT NULL,
       countyName           CHAR(50) NULL,
       altitude             CHAR(1) NULL,
       GPAFract             FLOAT NULL,
       barometricPressure   FLOAT NULL,
       barometricPressureCV FLOAT NULL,
       countyTypeID int not null default '0',
       msa 					CHAR(255),
       key (countyID, stateID),
       key (stateID, countyID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKCounty ON County
(
       countyID                       ASC
);

CREATE TABLE IF NOT EXISTS  countyType (
	countyTypeID int not null primary key,
	countyTypeDescription varchar(255) not null default ''
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  CountyYear (
       countyID             INTEGER NOT NULL,
       yearID               SMALLINT NOT NULL,
	   refuelingVaporProgramAdjust FLOAT NOT NULL DEFAULT 0.0,
	   refuelingSpillProgramAdjust FLOAT NOT NULL DEFAULT 0.0,
	   key (yearID, countyID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE CountyYear ADD (
       KEY (countyID),
       KEY (yearID)
);

CREATE UNIQUE INDEX XPKCountyYear ON CountyYear
(
       countyID                       ASC,
       yearID                         ASC
);

CREATE TABLE IF NOT EXISTS  CrankcaseEmissionRatio (
	polProcessID			int NOT NULL,
	minModelYearID			smallint(6) NOT NULL,
	maxModelYearID			smallint(6) NOT NULL,
	sourceTypeID			smallint(6) NOT NULL,
	regClassID			    smallint(6) NOT NULL,
	fuelTypeID				smallint(6) NOT NULL,	
	crankcaseRatio			float NOT NULL,
	crankcaseRatioCV		float NULL,
	primary key (polProcessID, minModelYearID, maxModelYearID, sourceTypeID, regClassID, fuelTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci'; 

CREATE TABLE IF NOT EXISTS  criteriaRatio (
	fuelTypeID int not null,
	fuelFormulationID int(11) not null,
	polProcessID int not null,
	pollutantID int not null,
	processID int not null,
	sourceTypeID int not null,
	modelYearID int not null,
	ageID int not null,
	ratio double null,
	ratioGPA double null,
	ratioNoSulfur double null,
	key crFuelFormulation (polProcessID, fuelFormulationID),
	key crCommon (polProcessID, modelYearID, ageID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  CumTVVCoeffs (
	regClassID smallint(6) NOT NULL,
	modelYearGroupID int(11) NOT NULL,
	ageGroupID smallint(6) NOT NULL,
	polProcessID int NOT NULL,
	tvvTermA float NULL,
	tvvTermB float NULL,
	tvvTermC float NULL,
	tvvTermACV float NULL,
	tvvTermBCV float NULL,
	tvvTermCCV float NULL,
	tvvTermAIM float NULL,
	tvvTermBIM float NULL,
	tvvTermCIM float NULL,
	tvvTermAIMCV float NULL,
	tvvTermBIMCV float NULL,
	tvvTermCIMCV float NULL,
	backPurgeFactor double,
	averageCanisterCapacity double,
	tvvEquation varchar(4096) not null default '',
	leakEquation varchar(4096) not null default '',
	leakFraction double,
	tankSize double,
	tankFillFraction double,
	leakFractionIM double,
	PRIMARY KEY  (regClassID,modelYearGroupID,ageGroupID,polProcessID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  DataSource (
       dataSourceId         SMALLINT NOT NULL,
       Author               CHAR(25) NULL,
       Date                 DATE NULL,
       Sponsor              CHAR(30) NULL,
       DocumentId           CHAR(150) NULL,
       QualityLevel         CHAR(1) NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKDataSou ON DataSource
(
       dataSourceId                   ASC
);


CREATE TABLE IF NOT EXISTS  DayOfAnyWeek (
       dayID                SMALLINT NOT NULL,
       dayName              CHAR(10) NULL,
       noOfRealDays         FLOAT NOT NULL DEFAULT 1.0
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKDayOfAnyWeek ON DayOfAnyWeek
(
       dayID                          ASC
);


CREATE TABLE IF NOT EXISTS  DayVMTFraction (
       sourceTypeID         SMALLINT NOT NULL,
       monthID              SMALLINT NOT NULL,
       roadTypeID           SMALLINT NOT NULL,
       dayID                SMALLINT NOT NULL,
       dayVMTFraction       FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE DayVMTFraction ADD (
       KEY (sourceTypeID),
       KEY (monthID),
       KEY (roadTypeID),
       KEY (dayID)
);

CREATE UNIQUE INDEX XPKDayVMTFraction ON DayVMTFraction
(
       sourceTypeID                   ASC,
       monthID                        ASC,
       roadTypeID                     ASC,
       dayID                          ASC
);

CREATE TABLE IF NOT EXISTS  dioxinemissionrate (
  polProcessID int NOT NULL DEFAULT '0',
  fuelTypeID smallint(6) NOT NULL DEFAULT '0',
  modelYearGroupID int(11) NOT NULL DEFAULT '0',
  units char(30) DEFAULT NULL,
  meanBaseRate double DEFAULT NULL,
  meanBaseRateCV double DEFAULT NULL,
  dataSourceId smallint(6) DEFAULT NULL,
  PRIMARY KEY (polProcessID,fuelTypeID,modelYearGroupID),
  UNIQUE KEY XPKDioxinEmissionRate (polProcessID,fuelTypeID,modelYearGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  DriveSchedule (
       driveScheduleID      SMALLINT NOT NULL,
       averageSpeed         FLOAT NOT NULL,
       driveScheduleName    CHARACTER(50) NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKDriveSchedule ON DriveSchedule
(
       driveScheduleID                ASC
);


CREATE TABLE IF NOT EXISTS  DriveScheduleAssoc (
       sourceTypeID         SMALLINT NOT NULL,
       roadTypeID           SMALLINT NOT NULL,
       driveScheduleID      SMALLINT NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE DriveScheduleAssoc ADD (
        KEY (sourceTypeID),
        KEY (roadTypeID),
        KEY (driveScheduleID)
);

CREATE UNIQUE INDEX XPKDriveScheduleAssoc ON DriveScheduleAssoc
(
       sourceTypeID                   ASC,
       roadTypeID                     ASC,
       driveScheduleID                ASC
);


CREATE TABLE IF NOT EXISTS  DriveScheduleSecond (
       driveScheduleID      SMALLINT NOT NULL,
       second               SMALLINT NOT NULL,
       speed                FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE DriveScheduleSecond ADD (
        KEY (driveScheduleID),
        KEY (second)
);

CREATE UNIQUE INDEX XPKDriveScheduleSecond ON DriveScheduleSecond
(
       driveScheduleID                ASC,
       second                         ASC
);

CREATE TABLE IF NOT EXISTS  driveScheduleSecondLink (
	linkID integer not null,
	secondID smallint not null,
	speed float null,
	grade float not null default 0.0,
	primary key (linkID, secondID),
	key (secondID, linkID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  e10FuelProperties (
	fuelRegionID int not null,
	fuelYearID int not null,
	monthGroupID smallint not null,
	RVP double null,
	sulfurLevel double null,
	ETOHVolume double null,
	MTBEVolume double null,
	ETBEVolume double null,
	TAMEVolume double null,
	aromaticContent double null,
	olefinContent double null,
	benzeneContent double null,
	e200 double null,
	e300 double null,
	BioDieselEsterVolume double null,
	CetaneIndex double null,
	PAHContent double null,
	T50 double null,
	T90 double null,
	primary key (fuelRegionID, fuelYearID, monthGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  EmissionProcess (
       processID            SMALLINT NOT NULL,
       processName          CHAR(50) NULL,
       SCCProcID            CHAR(1) NULL,
       occursOnRealRoads    CHAR(1) DEFAULT "Y" NOT NULL,
       shortName			VARCHAR(50) NULL,
       processDisplayGroupID smallint(6) unsigned DEFAULT NULL,
       isAffectedByOnroad tinyint(1) DEFAULT '1',
       isAffectedByNonroad tinyint(1) DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKEmissionProcess ON EmissionProcess
(
       processID                      ASC
);


CREATE TABLE IF NOT EXISTS  EmissionRate (
       sourceBinID          BIGINT NOT NULL,
       polProcessID         int NOT NULL,
       opModeID             SMALLINT NOT NULL,
       meanBaseRate         FLOAT NULL,
       meanBaseRateCV       FLOAT NULL,
       meanBaseRateIM   	FLOAT NULL,
       meanBaseRateIMCV     FLOAT NULL,
       dataSourceId         SMALLINT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE EmissionRate ADD (
        KEY (sourceBinID),
        KEY (polProcessID),
        KEY (opModeID)
);

CREATE UNIQUE INDEX XPKEmissionRate ON EmissionRate
(
       sourceBinID                    ASC,
       polProcessID                   ASC,
       opModeID                       ASC
);

CREATE TABLE IF NOT EXISTS  EmissionRateAdjustment
(
	polProcessID			int(11)			not null,
	sourceTypeID			smallint(6)		not null,
	regClassID				smallint(6)		not null,
	fuelTypeID				smallint(6)		not null,
	beginModelYearID		smallint(6)		not null,
	endModelYearID			smallint(6)		not null,
	emissionRateAdjustment	double null default NULL,
	dataSourceID			smallint(6) NULL default NULL,
	primary key (polProcessID, sourceTypeID, fuelTypeID, regClassID, beginModelYearID, endModelYearID),
	key (polProcessID, beginModelYearID, endModelYearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  EmissionRateByAge (
       sourceBinID          BIGINT NOT NULL,
       polProcessID         int NOT NULL,
       opModeID             SMALLINT NOT NULL,
       ageGroupID           SMALLINT NOT NULL,
       meanBaseRate         FLOAT NULL,
       meanBaseRateCV       FLOAT NULL,
       meanBaseRateIM       FLOAT NULL,
       meanBaseRateIMCV     FLOAT NULL,
       dataSourceId         SMALLINT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE EmissionRateByAge ADD (
        KEY (sourceBinID),
        KEY (polProcessID),
        KEY (opModeID),
        KEY (ageGroupID)
);
        
CREATE UNIQUE INDEX XPKEmissionRateByAge ON EmissionRateByAge
(
       sourceBinID                    ASC,
       polProcessID                   ASC,
       opModeID                       ASC,
       ageGroupID                     ASC
);

CREATE TABLE IF NOT EXISTS  EmissionRateByAgeLEV (
       sourceBinID          BIGINT NOT NULL,
       polProcessID         int NOT NULL,
       opModeID             SMALLINT NOT NULL,
       ageGroupID           SMALLINT NOT NULL,
       meanBaseRate         FLOAT NULL,
       meanBaseRateCV       FLOAT NULL,
       meanBaseRateIM       FLOAT NULL,
       meanBaseRateIMCV     FLOAT NULL,
       dataSourceId         SMALLINT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE EmissionRateByAgeLEV ADD (
        KEY (sourceBinID),
        KEY (polProcessID),
        KEY (opModeID),
        KEY (ageGroupID)
);
        
CREATE UNIQUE INDEX XPKEmissionRateByAgeLEV ON EmissionRateByAgeLEV
(
       sourceBinID                    ASC,
       polProcessID                   ASC,
       opModeID                       ASC,
       ageGroupID                     ASC
);

CREATE TABLE IF NOT EXISTS  EmissionRateByAgeNLEV (
       sourceBinID          BIGINT NOT NULL,
       polProcessID         int NOT NULL,
       opModeID             SMALLINT NOT NULL,
       ageGroupID           SMALLINT NOT NULL,
       meanBaseRate         FLOAT NULL,
       meanBaseRateCV       FLOAT NULL,
       meanBaseRateIM       FLOAT NULL,
       meanBaseRateIMCV     FLOAT NULL,
       dataSourceId         SMALLINT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE EmissionRateByAgeNLEV ADD (
        KEY (sourceBinID),
        KEY (polProcessID),
        KEY (opModeID),
        KEY (ageGroupID)
);
        
CREATE UNIQUE INDEX XPKEmissionRateByAgeNLEV ON EmissionRateByAgeNLEV
(
       sourceBinID                    ASC,
       polProcessID                   ASC,
       opModeID                       ASC,
       ageGroupID                     ASC
);

CREATE TABLE IF NOT EXISTS  EngineSize (
       engSizeID            SMALLINT NOT NULL,
       engSizeName          CHARACTER(50) NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKEngineSize ON EngineSize
(
       engSizeID                      ASC
);

CREATE TABLE IF NOT EXISTS  enginetech (
  engTechID smallint(6) NOT NULL DEFAULT '0',
  tierID smallint(6) DEFAULT '99',
  strokes smallint(6) DEFAULT '99',
  engTechName char(50) DEFAULT NULL,
  engTechDesc char(80) DEFAULT NULL,
  PRIMARY KEY (engTechID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  ETOHBin 
(
	etohThreshID			smallint(6)		NOT NULL	default '0' primary key,
	etohThreshLow			float			NULL		default NULL,
	etohThreshHigh			float			NULL		default NULL,
	etohNominalValue		float			NULL		default NULL	
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  evapTemperatureAdjustment (
	processID smallint(6) not null,
	tempAdjustTerm3 double not null default 0,
	tempAdjustTerm2 double not null default 0,
	tempAdjustTerm1 double not null default 0,
	tempAdjustConstant double not null default 0,
	primary key (processID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  evapRVPTemperatureAdjustment (
	processID smallint(6) not null,
	fuelTypeID smallint(6) not null,
	RVP double not null,
	adjustTerm3 double not null default 0,
	adjustTerm2 double not null default 0,
	adjustTerm1 double not null default 0,
	adjustConstant double not null default 0,
	primary key (processID, fuelTypeID, RVP),
	key (RVP, processID, fuelTypeID),
	key (RVP, fuelTypeID, processID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  evefficiency
(
	polProcessID			int(11)			not null,
	sourceTypeID			smallint(6)		not null,
	regClassID				smallint(6)		not null,
	ageGroupID				smallint(6)		not null,
	beginModelYearID		smallint(6)		not null,
	endModelYearID			smallint(6)		not null,
	batteryEfficiency       double null default NULL,
	chargingEfficiency		double null default NULL,
	primary key (polProcessID, sourceTypeID, ageGroupID, regClassID, beginModelYearID, endModelYearID),
	key (polProcessID, beginModelYearID, endModelYearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  FleetAvgAdjustment (
	polProcessID INT(11) NOT NULL,
	beginModelYearID SMALLINT(6) NOT NULL,
	endModelYearID SMALLINT(6) NOT NULL,
	fleetAvgGroupID SMALLINT(6) NOT NULL,
	evMultiplier DOUBLE NOT NULL DEFAULT '1',
	adjustmentCap DOUBLE NULL DEFAULT NULL,
	PRIMARY KEY (polProcessID, beginModelYearID, endModelYearID, fleetAvgGroupID),
	KEY (beginModelYearID, endModelYearID, polProcessID, fleetAvgGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  FleetAvgGroup (
       fleetAvgGroupID   SMALLINT NOT NULL,
       fleetAvgGroupDesc CHAR(50) DEFAULT '',		
       primary key (fleetAvgGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  FuelEngTechAssoc (
       sourceTypeID         SMALLINT NOT NULL,
       fuelTypeID           SMALLINT NOT NULL,
       engTechID            SMALLINT NOT NULL,
       category             CHAR(50) NOT NULL,
       categoryDisplayOrder SMALLINT NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKFuelEngTechAssoc ON FuelEngTechAssoc
(
       sourceTypeID                   ASC,
       fuelTypeID                     ASC,
       engTechID                      ASC
);
  
CREATE TABLE IF NOT EXISTS  FuelFormulation (
    fuelFormulationID int(11) NOT NULL PRIMARY KEY,
    fuelSubtypeID SMALLINT NOT NULL,
    RVP FLOAT NULL,
    sulfurLevel FLOAT NULL,
    ETOHVolume FLOAT NULL,
    MTBEVolume FLOAT NULL,
    ETBEVolume FLOAT NULL,
    TAMEVolume FLOAT NULL,
    aromaticContent FLOAT NULL,
    olefinContent FLOAT NULL,
    benzeneContent FLOAT NULL,
    e200 FLOAT NULL,
    e300 FLOAT NULL,
	volToWtPercentOxy FLOAT NULL,
	BioDieselEsterVolume float DEFAULT NULL,
	CetaneIndex float DEFAULT NULL,
	PAHContent float DEFAULT NULL,
	T50 float DEFAULT NULL,
	T90 float DEFAULT NULL,
	key (fuelSubTypeID, fuelFormulationID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  FuelModelName 
(
	fuelModelID   			smallint(6)  	NOT NULL   	default '0' primary key,
	fuelModelName			varchar(50) not null,
	fuelModelAbbreviation	varchar(10) not null,
	calculationEngines      varchar(200) not null default ''
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  FuelModelWtFactor 
(
	fuelModelID				smallint(6)		NOT NULL	default '0',
	modelYearGroupID		int(11)			NOT NULL	default '0',
	ageID					smallint(6)		NOT NULL	default '0',
	fuelModelWtFactor		float			NULL		default NULL,
	dataSourceID			smallint(6)		NULL		default NULL,
	primary key (fuelModelID, modelYearGroupID, ageID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  FuelParameterName 
(
	fuelParameterID   		smallint(6)  	NOT NULL   	default '0' primary key,
	fuelParameterName		varchar(25)		NOT NULL    default '',
	fuelParameterUnits      varchar(20)     NOT NULL    default '',
	fuelParameterExpression varchar(500)    NOT NULL    default ''
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  FuelSubtype (
       fuelSubtypeID        SMALLINT NOT NULL,
       fuelTypeID           SMALLINT NOT NULL,
       fuelSubtypeDesc      CHAR(50) NULL,
       fuelSubtypePetroleumFraction FLOAT NULL,
       fuelSubtypePetroleumFractionCV FLOAT NULL,
       fuelSubtypeFossilFraction FLOAT NULL,
       fuelSubtypeFossilFractionCV FLOAT NULL,
       carbonContent        FLOAT NULL,
       oxidationFraction    FLOAT NULL,
       carbonContentCV      FLOAT NULL,
       oxidationFractionCV  FLOAT NULL,
	   energyContent		FLOAT NULL,
       key (fuelTypeID, fuelSubtypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKFuelSubtype ON FuelSubtype
(
       fuelSubtypeID                  ASC
);


CREATE TABLE IF NOT EXISTS  FuelSupply (
       fuelRegionID         INTEGER NOT NULL,
       fuelYearID           INT NOT NULL,
       monthGroupID         SMALLINT NOT NULL,
       fuelFormulationID    int(11) NOT NULL,
       marketShare          FLOAT NULL,
       marketShareCV        FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE FuelSupply ADD (
        KEY (fuelRegionID),
        KEY (fuelYearID),
        KEY (monthGroupID),
        KEY (fuelFormulationID)
);

CREATE UNIQUE INDEX XPKFuelSupply ON FuelSupply
(
       fuelRegionID                   ASC,
       fuelyearID                     ASC,
       monthGroupID                   ASC,
       fuelFormulationID              ASC
);

CREATE TABLE IF NOT EXISTS  FuelSupplyYear (
    fuelYearID INT NOT NULL PRIMARY KEY
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  FuelType (
       fuelTypeID           SMALLINT NOT NULL,
       defaultFormulationID SMALLINT NOT NULL,
       fuelTypeDesc         CHAR(50) NULL,
 	   fuelDensity				FLOAT	NULL,
 	   subjectToEvapCalculations CHAR(1) NOT NULL DEFAULT 'N'
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKFuelType ON FuelType
(
       fuelTypeID                     ASC
);

ALTER TABLE FuelType ADD (
	KEY (subjectToEvapCalculations, fuelTypeID)
);

CREATE TABLE IF NOT EXISTS  fuelUsageFraction (
	countyID int(11) not null,
	fuelYearID int not null,
	modelYearGroupID int(11) not null,
	sourceBinFuelTypeID smallint(6) not null,
	fuelSupplyFuelTypeID smallint(6) not null,
	usageFraction double,
	primary key (countyID, fuelYearID, modelYearGroupID, sourceBinFuelTypeID, fuelSupplyFuelTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  fuelWizardFactors (
	adjustedParameter		varchar(4)		not null,
	minLevel			double			not null,
	maxLevel			double			not null,
	functionType		varchar(4)		not null,
	monthGroupID		smallint(6)		not null,
	fuelTypeID			smallint(6)		not null,
	RVP_factor			double			null,
	sulf_factor			double			null,
	ETOH_factor			double			null,
	arom_factor			double			null,
	olef_factor			double			null,
	benz_factor			double			null,
	e200_factor			double			null,
	e300_factor			double			null,
	T50_factor			double			null,
	T90_factor			double			null,
	units				varchar(6)		null,
	dataSourceId		smallint(6)		null,
	primary key	(fuelTypeID, monthGroupID, adjustedParameter, minLevel, maxLevel, functionType)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  FullACAdjustment (
       sourceTypeID         SMALLINT NOT NULL,
       polProcessID         int NOT NULL,
       opModeID             SMALLINT NOT NULL,
       fullACAdjustment     FLOAT NULL,
       fullACAdjustmentCV   FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE FullACAdjustment ADD (
        KEY (sourceTypeID),
        KEY (polProcessID),
        KEY (opModeID)
);

CREATE UNIQUE INDEX XPKFullACAdjustment ON FullACAdjustment
(
       sourceTypeID                   ASC,
       polProcessID                   ASC,
       opModeID                       ASC
);

CREATE TABLE IF NOT EXISTS  generalFuelRatio (
	fuelTypeID int not null,
	fuelFormulationID int(11) not null,
	polProcessID int not null,
	pollutantID int not null,
	processID int not null,
	minModelYearID int not null default '1950',
	maxModelYearID int not null default '2060',
	minAgeID int not null default '0',
	maxAgeID int not null default '40',
	sourceTypeID int not null,
	fuelEffectRatio double not null default '0',
	fuelEffectRatioGPA double not null default '0'
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  generalFuelRatioExpression (
	fuelTypeID int not null,
	polProcessID int not null,
	minModelYearID int not null default '1950',
	maxModelYearID int not null default '2060',
	minAgeID int not null default '0',
	maxAgeID int not null default '40',
	sourceTypeID int not null default '0',
	fuelEffectRatioExpression VARCHAR(8183) not null default '',
	fuelEffectRatioGPAExpression VARCHAR(8183) not null default ''
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  GREETManfAndDisposal (
       GREETVehicleType     SMALLINT NOT NULL,
       modelYearID          SMALLINT NOT NULL,
       pollutantID          SMALLINT NOT NULL,
       EmissionStage        CHAR(4) NOT NULL,
       emissionPerVehicle   FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE GREETManfAndDisposal ADD (
        KEY (GREETVehicleType),
        KEY (modelYearID),
        KEY (pollutantID),
        KEY (emissionStage)
);

CREATE UNIQUE INDEX XPKGREETManfAndDisposal ON GREETManfAndDisposal
(
       GREETVehicleType               ASC,
       modelYearID                   DESC,
       pollutantID                    ASC,
       EmissionStage                  ASC
);


CREATE TABLE IF NOT EXISTS  GREETWellToPump (
       yearID               SMALLINT NOT NULL,
       pollutantID          SMALLINT NOT NULL,
       fuelSubtypeID        SMALLINT NOT NULL,
       emissionRate         FLOAT NULL,
       emissionRateUncertainty FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE GREETWellToPump ADD (
        KEY (yearID),
        KEY (pollutantID),
        KEY (fuelSubtypeID)
);

CREATE UNIQUE INDEX XPKGREETWellToPump ON GREETWellToPump
(
       yearID                         ASC,
       pollutantID                    ASC,
       fuelSubtypeID                  ASC
);


CREATE TABLE IF NOT EXISTS  Grid (
       gridID               INTEGER NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKGrid ON Grid
(
       gridID                         ASC
);


CREATE TABLE IF NOT EXISTS  GridZoneAssoc (
       zoneID               INTEGER NOT NULL,
       gridID               INTEGER NOT NULL,
       gridAllocFactor      FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE GridZoneAssoc ADD (
        KEY (zoneID),
        KEY (gridID)
);

CREATE UNIQUE INDEX XPKGridZoneAssoc ON GridZoneAssoc
(
       zoneID                         ASC,
       gridID                         ASC
);

CREATE TABLE IF NOT EXISTS  HCPermeationCoeff 
(
	polProcessID			int     		NOT NULL	default '0',
	etohThreshID			smallint(6)		NOT NULL	default '0',
	fuelMYGroupID			int(11)			NOT NULL	default '0',
	fuelAdjustment			float			NULL		default NULL,
	fuelAdjustmentGPA		float			NULL		default NULL,
	dataSourceID			smallint(6)		NULL		default NULL,
	primary key (polProcessID, etohThreshID, fuelMYGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  HCSpeciation (
  polProcessID int NOT NULL DEFAULT '0',
  fuelSubtypeID smallint(6) NOT NULL DEFAULT '0',
  regClassID smallint(6) NOT NULL DEFAULT '0',
  beginModelYearID smallint(6) NOT NULL DEFAULT '0',
  endModelYearID smallint(6) NOT NULL DEFAULT '0',
  speciationConstant double NOT NULL DEFAULT '0',
  oxySpeciation double NOT NULL DEFAULT '0',
  dataSourceID smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (polProcessID,fuelSubtypeID,regClassID,beginModelYearID,endModelYearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  hotellingActivityDistribution (
	zoneID				int not null,
	fuelTypeID          smallint not null,
	beginModelYearID 	smallint not null,
	endModelYearID 		smallint not null,
	opModeID 			int not null,
	opModeFraction 		double not null,
	primary key 		(zoneID, fuelTypeID, beginModelYearID, endModelYearID, opModeID),
	key					(zoneID, fuelTypeID, opModeID, beginModelYearID, endModelYearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  hotellingAgeFraction (
	zoneID int not null,
	ageID smallint not null,
	ageFraction double not null,
	primary key (zoneID, ageID),
	key (ageID, zoneID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  hotellingCalendarYear (
	yearID smallint not null,
	hotellingRate double not null,
	primary key (yearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  hotellingHours (
	sourceTypeID         SMALLINT NOT NULL,
	fuelTypeID			 SMALLINT NOT NULL,
	hourDayID            SMALLINT NOT NULL,
	monthID              SMALLINT NOT NULL,
	yearID               SMALLINT NOT NULL,
	ageID                SMALLINT NOT NULL,
	zoneID               INTEGER NOT NULL,
	hotellingHours       DOUBLE NULL,
	isUserInput 		 CHAR(1) DEFAULT 'N' NOT NULL,
	primary key 		(sourceTypeID, fuelTypeID, hourDayID, monthID, yearID, ageID, zoneID),
	key (sourceTypeID),
	KEY (fuelTypeID),
	KEY (hourDayID),
	KEY (monthID),
	KEY (yearID),
	KEY (ageID),
	KEY (zoneID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  hotellingHourFraction (
	zoneID int not null,
	dayID smallint not null,
	hourID smallint not null,
	hourFraction double not null,
	primary key (zoneID, dayID, hourID),
	key (hourID, dayID, zoneID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  hotellingHoursPerDay (
	yearID smallint not null,
	zoneID int not null,
	dayID smallint not null,
	hotellingHoursPerDay double not null,
	primary key (yearID, zoneID, dayID),
	key (zoneID, yearID, dayID),
	key (dayID, yearID, zoneID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  hotellingMonthAdjust (
	zoneID int not null,
	monthID smallint not null,
	monthAdjustment double not null,
	primary key (zoneID, monthID),
	key (monthID, zoneID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  HourDay (
       hourDayID            SMALLINT NOT NULL,
       dayID                SMALLINT NOT NULL,
       hourID               SMALLINT NOT NULL,
       key (dayID, hourID, hourDayID),
       key (hourID, dayID, hourDayID),
       key (hourDayID, dayID, hourID),
       key (hourDayID, hourID, dayID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE HourDay ADD (
        KEY (dayID),
        KEY (hourID)
);

CREATE UNIQUE INDEX XPKHourDay ON HourDay
(
       hourDayID                      ASC
);


CREATE TABLE IF NOT EXISTS  HourOfAnyDay (
       hourID               SMALLINT NOT NULL,
       hourName             CHAR(50) NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKHourOfAnyDay ON HourOfAnyDay
(
       hourID                         ASC
);


CREATE TABLE IF NOT EXISTS  HourVMTFraction (
       sourceTypeID         SMALLINT NOT NULL,
       roadTypeID           SMALLINT NOT NULL,
       dayID                SMALLINT NOT NULL,
       hourID               SMALLINT NOT NULL,
       hourVMTFraction      FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE HourVMTFraction ADD (
        KEY (sourceTypeID),
        KEY (roadTypeID),
        KEY (dayID),
        KEY (hourID)
);

CREATE UNIQUE INDEX XPKHourVMTFraction ON HourVMTFraction
(
       sourceTypeID                   ASC,
       roadTypeID                     ASC,
       dayID                          ASC,
       hourID                         ASC
);


CREATE TABLE IF NOT EXISTS  HPMSVtype (
       HPMSVtypeID          SMALLINT NOT NULL,
       HPMSVtypeName        CHARACTER(50) NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKHPMSVtype ON HPMSVtype
(
       HPMSVtypeID                    ASC
);

CREATE TABLE IF NOT EXISTS  HPMSVtypeDay (
	yearID smallint not null,
	monthID smallint not null,
	dayID smallint not null,
	HPMSVtypeID smallint not null,
	VMT double not null,
	primary key (yearID, monthID, dayID, HPMSVtypeID),
	key (HPMSVtypeID, yearID, monthID, dayID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  HPMSVtypeYear (
       HPMSVtypeID          SMALLINT NOT NULL,
       yearID               SMALLINT NOT NULL,
       VMTGrowthFactor      FLOAT NULL,
       HPMSBaseYearVMT      FLOAT NULL,
       key (yearID, HPMSVtypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE HPMSVtypeYear ADD (
        KEY (HPMSVtypeID),
        KEY (yearID)
);

CREATE UNIQUE INDEX XPKHPMSVtypeYear ON HPMSVtypeYear
(
       HPMSVtypeID                    ASC,
       yearID                         ASC
);

CREATE TABLE IF NOT EXISTS  idleDayAdjust (
	sourceTypeID smallint not null,
	dayID smallint not null,
	idleDayAdjust double not null,
	primary key (sourceTypeID, dayID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  idleModelYearGrouping (
	sourceTypeID smallint not null,
	minModelYearID smallint not null,
	maxModelYearID smallint not null,
	totalIdleFraction double not null,
	primary key (sourceTypeID, minModelYearID, maxModelYearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  idleMonthAdjust (
	sourceTypeID smallint not null,
	monthID smallint not null,
	idleMonthAdjust double not null,
	primary key (sourceTypeID, monthID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  idleRegion (
	idleRegionID int not null primary key,
	idleRegionDescription varchar(255) not null default ''
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  IMCoverage (
       polProcessID int NOT NULL,
       stateID INT,
       countyID INT NOT NULL,
       yearID SMALLINT NOT NULL,
       sourceTypeID SMALLINT NOT NULL,
       fuelTypeID SMALLINT NOT NULL,
       IMProgramID SMALLINT NOT NULL,
	   inspectFreq smallint(6) NULL,
	   testStandardsID smallint NULL,
       begModelYearID SMALLINT,
       endModelYearID SMALLINT,
       useIMyn CHAR(1) NOT NULL DEFAULT 'Y',
       complianceFactor FLOAT DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKIMCoverage ON IMCoverage
(
       polProcessID   ASC,
       countyID       ASC,
       yearID         ASC,
       sourceTypeID   ASC,
       fuelTypeID     ASC,
       IMProgramID	  ASC
);

CREATE TABLE IF NOT EXISTS  IMFactor
(
	polProcessID int NOT NULL,
	inspectFreq smallint(6) NOT NULL,
	testStandardsID smallint(6) NOT NULL,
	sourceTypeID smallint(6) NOT NULL,
	fuelTypeID smallint(6) NOT NULL,
	IMModelYearGroupID int(8) NOT NULL,
	ageGroupID smallint(6) NOT NULL,
	IMFactor float NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKIMFactor ON IMFactor
(
	polProcessID	ASC,
	inspectFreq		ASC,
	testStandardsID ASC,
	sourceTypeID	ASC,
	fuelTypeID		ASC,
	IMModelYearGroupID	ASC,
	ageGroupID ASC
);

CREATE TABLE IF NOT EXISTS  imInspectFreq
(
  inspectFreq smallint(6) NOT NULL primary key,
  inspectFreqDesc char(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  IMModelYearGroup (
  IMModelYearGroupID int(8) NOT NULL,
  IMModelYearGroupDesc char(40) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKIMModelYearGroup ON IMModelYearGroup
(
	IMModelYearGroupID ASC
);

CREATE TABLE IF NOT EXISTS  IMTestStandards
(
  testStandardsID smallint(6) NOT NULL,
  testStandardsDesc char(50) NOT NULL,
  shortName varchar(50) default NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKIMTestStandards ON IMTestStandards
(
	testStandardsID ASC
);


CREATE TABLE IF NOT EXISTS  startsOpModeDistribution (
  dayID smallint(6) NOT NULL DEFAULT 0,
  hourID smallint(6) NOT NULL DEFAULT 0,
  sourceTypeID smallint(6) NOT NULL DEFAULT 0,
  ageID smallint(6) NOT NULL DEFAULT 0,
  opModeID smallint(6) NOT NULL DEFAULT 0,
  opModeFraction double DEFAULT NULL,
  PRIMARY KEY (dayid,hourid,sourceTypeID,ageID,opmodeid),
  KEY dayID (dayID),
  KEY hourid (hourID),
  KEY sourceTypeID (sourceTypeID),
  KEY ageID (ageID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  integratedSpeciesSet  (
	mechanismID					smallint(6)		not null,
	integratedSpeciesSetID		smallint(6)		not null,
	pollutantID					smallint(6)		not null,
	useISSyn					varchar(2)		null,
	primary key (mechanismID, integratedSpeciesSetID, pollutantID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  integratedSpeciesSetName  (
	integratedSpeciesSetID				smallint(6)		not null,	
	integratedSpeciesSetName			varchar(40)		null,
	primary key (integratedSpeciesSetID),
	key (integratedSpeciesSetName)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  Link (
       linkID               INTEGER NOT NULL,
       countyID             INTEGER NOT NULL,
       zoneID               INTEGER NULL,
       roadTypeID           SMALLINT NOT NULL,
       linkLength           FLOAT NULL,
       linkVolume           FLOAT NULL,
       linkAvgSpeed			float null,
       linkDescription		varchar(50) null,
       linkAvgGrade			float null
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE Link ADD (
        KEY (countyID),
        KEY (zoneID),
        KEY (roadTypeID)
);

CREATE UNIQUE INDEX XPKLink ON Link
(
       linkID                         ASC
);


CREATE TABLE IF NOT EXISTS  LinkAverageSpeed (
       linkID               INTEGER NOT NULL,
       averageSpeed         FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKLinkAverageSpeed ON LinkAverageSpeed
(
       linkID                         ASC
);


CREATE TABLE IF NOT EXISTS  LinkHourVMTFraction (
       linkID               INTEGER NOT NULL,
       monthID              SMALLINT NOT NULL,
       sourceTypeID         SMALLINT NOT NULL,
       dayID                SMALLINT NOT NULL,
       hourID               SMALLINT NOT NULL,
       VMTFraction          FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE LinkHourVMTFraction ADD (
        KEY (linkID),
        KEY (monthID),
        KEY (sourceTypeID),
        KEY (dayID),
        KEY (hourID)
);

CREATE UNIQUE INDEX XPKLinkHourVMTFraction ON LinkHourVMTFraction
(
       linkID                         ASC,
       monthID                        ASC,
       sourceTypeID                   ASC,
       dayID                          ASC,
       hourID                         ASC
);

CREATE TABLE IF NOT EXISTS  linkSourceTypeHour (
	linkID integer not null,
	sourceTypeID smallint not null,
	sourceTypeHourFraction float null,
	primary key (linkID, sourceTypeID),
	key (sourceTypeID, linkID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  M6SulfurCoeff (
	pollutantID int not null,
	minModelYearID int not null,
	maxModelYearID int not null,
	minSulfur double not null,
	sulfurLongCoeff double,
	sulfurIRFactor double,
	maxIRFactorSulfur double,
	key(pollutantID, minModelYearID, maxModelYearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  MeanFuelParameters 
(
	polProcessID			int     		NOT NULL	default '0',	
	fuelTypeID				smallint(6)		NOT NULL	default '0'	,
	modelYearGroupID		int(11)			NOT NULL	default '0',	
	fuelParameterID		   	smallint(6)  	NOT NULL   	default '0',	
	baseValue				float			NULL		default NULL,	
	centeringValue			float			NULL		default NULL,	
	stdDevValue				float			NULL		default NULL,
	dataSourceID			smallint(6)		NULL		default NULL,
	primary key (polProcessID, fuelTypeID, modelYearGroupID, fuelParameterID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  mechanismName  (
	mechanismID				smallint(6)		not null,	
	mechanismName			varchar(40)		null,
	primary key (mechanismID),
	key (mechanismName)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  metalemissionrate (
  polProcessID int NOT NULL DEFAULT '0',
  fuelTypeID smallint(6) NOT NULL DEFAULT '0',
  sourceTypeID smallint(6) NOT NULL DEFAULT '0',
  modelYearGroupID int(11) NOT NULL DEFAULT '0',
  units char(20) DEFAULT NULL,
  meanBaseRate double DEFAULT NULL,
  meanBaseRateCV double DEFAULT NULL,
  dataSourceId smallint(6) DEFAULT NULL,
  PRIMARY KEY (polProcessID,fuelTypeID,sourceTypeID,modelYearGroupID),
  UNIQUE KEY XPKMetalEmissionRate (polProcessID,fuelTypeID,sourceTypeID,modelYearGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  methaneTHCRatio (
  processID smallint(6) NOT NULL DEFAULT '0',
  fuelSubtypeID smallint(6) NOT NULL DEFAULT '0',
  regClassID smallint(6) NOT NULL DEFAULT '0',
  beginModelYearID smallint(6) NOT NULL DEFAULT '0',
  endModelYearID smallint(6) NOT NULL DEFAULT '0',
  CH4THCRatio double DEFAULT NULL,
  dataSourceID smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (processID,fuelSubtypeID,regClassID,beginModelYearID,endModelYearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  minorhapratio (
  polProcessID int NOT NULL DEFAULT '0',
  fuelTypeID smallint(6) NOT NULL DEFAULT '0',
  fuelSubtypeID smallint(6) NOT NULL DEFAULT '0',
  modelYearGroupID int(11) NOT NULL DEFAULT '0',
  atRatio double DEFAULT NULL,
  atRatioCV double DEFAULT NULL,
  dataSourceId smallint(6) DEFAULT NULL,
  PRIMARY KEY (fuelTypeID,fuelSubtypeID,polProcessID,modelYearGroupID),
  UNIQUE KEY XPKMinorHAPRatio (fuelTypeID,fuelSubtypeID,polProcessID,modelYearGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  ModelYear (
       modelYearID          SMALLINT NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKModelYear ON ModelYear
(
       modelYearID                    ASC
);

CREATE TABLE IF NOT EXISTS  ModelYearGroup (
       modelYearGroupID     INTEGER NOT NULL,
       shortModYrGroupID    SMALLINT NULL,
       modelYearGroupName   CHARACTER(50) NULL,
       modelYearGroupStartYear SMALLINT(6) DEFAULT NULL,
       modelYearGroupEndYear SMALLINT(6) DEFAULT NULL,
       PRIMARY KEY (modelYearGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  FuelModelYearGroup (
       fuelMYGroupID        INT NOT NULL,
       fuelMYGroupName      CHAR(100) NULL,
       fuelMYGroupFunction	CHAR(200) NULL,
       maxSulfurLevel		FLOAT NULL,
       maxSulfurLevelCV		FLOAT NULL,
       maxSulfurLevelGPA	FLOAT NULL,
       maxSulfurLevelGPACV	FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKFuelModelYearGroup ON FuelModelYearGroup
(
       fuelMYGroupID  	    ASC
);


CREATE TABLE IF NOT EXISTS  modelYearCutPoints (
	cutPointName varchar(100) not null,
	modelYearID smallint(6) not null,
	primary key (cutPointName)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  modelYearMapping (
	startUserModelYear smallint(6) not null,
	endUserModelYear smallint(6) not null,
	startStandardModelYear smallint(6) not null,
	endStandardModelYear smallint(6) not null,
	primary key (startUserModelYear, endUserModelYear)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  MonthGroupHour (
       monthGroupID         SMALLINT NOT NULL,
       hourID               SMALLINT NOT NULL,
       ACActivityTermA      FLOAT NULL,
       ACActivityTermACV    FLOAT NULL,
       ACActivityTermB      FLOAT NULL,
       ACActivityTermBCV    FLOAT NULL,
       ACActivityTermC      FLOAT NULL,
       ACActivityTermCCV    FLOAT NULL,
       key (hourID, monthGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE MonthGroupHour ADD (
        KEY (monthGroupID),
        KEY (hourID)
);

CREATE UNIQUE INDEX XPKMonthGroupHour ON MonthGroupHour
(
       monthGroupID                   ASC,
       hourID                         ASC
);


CREATE TABLE IF NOT EXISTS  MonthGroupOfAnyYear (
       monthGroupID         SMALLINT NOT NULL,
       monthGroupName       CHAR(50) NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKMonthGroupOfAnyYear ON MonthGroupOfAnyYear
(
       monthGroupID                   ASC
);


CREATE TABLE IF NOT EXISTS  MonthofAnyYear (
       monthID              SMALLINT NOT NULL,
       monthName            CHAR(10) NULL,
       noOfDays             SMALLINT NULL,
       monthGroupID         SMALLINT NOT NULL,
       key (monthGroupID, monthID),
       key (monthID, monthGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE MonthofAnyYear ADD (
        KEY (monthGroupID)
);

CREATE UNIQUE INDEX XPKMonthofAnyYear ON MonthofAnyYear
(
       monthID                        ASC
);


CREATE TABLE IF NOT EXISTS  MonthVMTFraction (
       sourceTypeID         SMALLINT NOT NULL,
       monthID              SMALLINT NOT NULL,
       monthVMTFraction     FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE MonthVMTFraction ADD (
        KEY (sourceTypeID),
        KEY (monthID)
);

CREATE UNIQUE INDEX XPKMonthVMTFraction ON MonthVMTFraction
(
       sourceTypeID                   ASC,
       monthID                        ASC
);

CREATE TABLE IF NOT EXISTS  NONO2Ratio  (
	polProcessID			int     		NOT NULL,
	sourceTypeID			SMALLINT(6)		NOT NULL,
	fuelTypeID				SMALLINT(6) 	NOT NULL,
	modelYearGroupID		INT(11)     	NOT NULL,
	NOxRatio				float			NULL,
	NOxRatioCV				float			NULL,
	dataSourceId			smallint(6)		NULL,
	PRIMARY KEY 			(polProcessID, sourceTypeID, fueltypeID, modelYearGroupID)								
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci'; 

CREATE UNIQUE INDEX XPKNONO2Ratio ON NONO2Ratio  
(
       polProcessID   		ASC,
       sourceTypeID			ASC,
       fueltypeID			ASC,
       modelYearGroupID		ASC
);

CREATE TABLE IF NOT EXISTS  noxhumidityadjust (
	fuelTypeID 			SMALLINT(5) NOT NULL,
    humidityNOxEq 		VARCHAR(10) NULL,
    humidityTermA 		DOUBLE 		NULL,
    humidityTermB 		DOUBLE 		NULL,
    humidityLowBound 	DOUBLE 		NULL,
    humidityUpBound 	DOUBLE 		NULL,
    humidityUnits 		VARCHAR(25) NULL,
    PRIMARY KEY (fuelTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrAgeCategory(
  ageID SMALLINT(6) NOT NULL,
  ageCategoryName CHAR(50) DEFAULT NULL,
  PRIMARY KEY (ageID),
  UNIQUE INDEX XPKNRAgeCategory (ageID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nratratio (
  pollutantID smallint(6) NOT NULL,
  processID smallint(6) NOT NULL,
  engTechID smallint(6) NOT NULL,
  fuelSubtypeID smallint(6) NOT NULL,
  nrHPCategory char(1) NOT NULL,
  atRatio double DEFAULT NULL,
  atRatioCV double DEFAULT NULL,
  dataSourceId smallint(6) DEFAULT NULL,
  PRIMARY KEY (pollutantID,processID,engTechID,fuelSubtypeID,nrHPCategory)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrBaseYearEquipPopulation(
  sourceTypeID SMALLINT(6) NOT NULL,
  stateID SMALLINT(6) NOT NULL,
  population FLOAT DEFAULT NULL,
  NRBaseYearID SMALLINT(6) NOT NULL,
  PRIMARY KEY (sourceTypeID, stateID),
  UNIQUE INDEX XPKNRBaseYearEquipPopulation (sourceTypeID, stateID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrCrankcaseEmissionRate (
  polProcessID int NOT NULL,
  SCC char(10) NOT NULL,
  hpMin smallint(6) NOT NULL,
  hpMax smallint(6) NOT NULL,
  modelYearID smallint(6) NOT NULL,
  engTechID smallint(6) NOT NULL,
  meanBaseRate float DEFAULT NULL,
  units varchar(12) DEFAULT NULL,
  dataSourceID smallint(6) NOT NULL,
  PRIMARY KEY (polProcessID,SCC,hpMin,hpMax,modelYearID,engTechID),
  INDEX INDEX1 (polProcessID),
  INDEX XPFnrCrankCaseEmissionRatio (polProcessID),
  UNIQUE INDEX XPKNRProcessEmissionRate (polProcessID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrDayAllocation(
  scc CHAR(10) NOT NULL,
  dayID SMALLINT(6) NOT NULL,
  dayFraction FLOAT NOT NULL,
  PRIMARY KEY (scc, dayID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrDeterioration(
  polProcessID int NOT NULL,
  engTechID SMALLINT(6) NOT NULL,
  DFCoefficient FLOAT DEFAULT NULL,
  DFAgeExponent FLOAT DEFAULT NULL,
  emissionCap SMALLINT(6) NOT NULL,
  PRIMARY KEY (polProcessID, engTechID),
  UNIQUE INDEX XPKNRDeterioration (polProcessID, engTechID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrdioxinemissionrate (
  pollutantID smallint(6) NOT NULL,
  processID smallint(6) NOT NULL,
  fuelTypeID smallint(6) NOT NULL,
  engtechID smallint(6) NOT NULL,
  nrHPCategory char(1) NOT NULL,
  units char(30) DEFAULT NULL,
  meanBaseRate double DEFAULT NULL,
  meanBaseRateCV double DEFAULT NULL,
  dataSourceID smallint(6) DEFAULT NULL,
  PRIMARY KEY (pollutantID,processID,fuelTypeID,engtechID,nrHPCategory)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS   nrEmissionRate (
  polProcessID int NOT NULL,
  SCC char(10) NOT NULL,
  hpMin smallint(6) NOT NULL,
  hpMax smallint(6) NOT NULL,
  modelYearID smallint(6) NOT NULL,
  engTechID smallint(6) NOT NULL,
  meanBaseRate float DEFAULT NULL,
  units varchar(12) DEFAULT NULL,
  dataSourceID smallint(6) NOT NULL,
  PRIMARY KEY (polProcessID,SCC,hpMin,hpMax,modelYearID,engTechID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS   nrEngtechFraction (
  SCC char(10) NOT NULL,
  hpMin smallint(6) NOT NULL,
  hpMax smallint(6) NOT NULL,
  modelYearID smallint(6) NOT NULL,
  processGroupID smallint(6) NOT NULL,
  engTechID smallint(6) NOT NULL,
  NREngTechFraction float DEFAULT NULL,
  PRIMARY KEY (SCC,hpMin,hpMax,modelYearID,processGroupID,engTechID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrEquipmentType(
  NREquipTypeID SMALLINT(6) NOT NULL,
  description CHAR(40) DEFAULT NULL,
  sectorID SMALLINT(6) NOT NULL,
  useDefaultScrappage CHAR(1) DEFAULT NULL,
  surrogateID SMALLINT(6) DEFAULT NULL,
  PRIMARY KEY (NREquipTypeID),
  UNIQUE INDEX XPKNREquipmentType (NREquipTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS   nrEvapEmissionRate (
  polProcessID int NOT NULL,
  SCC char(10) NOT NULL,
  hpMin smallint(6) NOT NULL,
  hpMax smallint(6) NOT NULL,
  modelYearID smallint(6) NOT NULL,
  engTechID smallint(6) NOT NULL,
  meanBaseRate float DEFAULT NULL,
  units varchar(12) DEFAULT NULL,
  dataSourceID smallint(6) NOT NULL,
  PRIMARY KEY (polProcessID,SCC,hpMin,hpMax,modelYearID,engTechID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrFuelSupply (
  fuelRegionID int(11) NOT NULL DEFAULT '0',
  fuelYearID int(11) NOT NULL DEFAULT '0',
  monthGroupID smallint(6) NOT NULL DEFAULT '0',
  fuelFormulationID int(11) NOT NULL DEFAULT '0',
  marketShare float DEFAULT NULL,
  marketShareCV float DEFAULT NULL,
  PRIMARY KEY (fuelRegionID,fuelFormulationID,monthGroupID,fuelYearID),
  KEY countyID (fuelRegionID),
  KEY yearID (fuelYearID),
  KEY monthGroupID (monthGroupID),
  KEY fuelSubtypeID (fuelFormulationID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrFuelType(
  fuelTypeID SMALLINT(6) NOT NULL DEFAULT 0,
  defaultFormulationID SMALLINT(6) NOT NULL DEFAULT 0,
  fuelTypeDesc CHAR(50) DEFAULT NULL,
  fuelDensity FLOAT DEFAULT NULL,
  subjectToEvapCalculations CHAR(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (fuelTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS   nrFuelSubtype (
  fuelSubtypeID smallint(6) NOT NULL DEFAULT '0',
  fuelTypeID smallint(6) NOT NULL DEFAULT '0',
  fuelSubtypeDesc char(50) DEFAULT NULL,
  fuelSubtypePetroleumFraction float DEFAULT NULL,
  fuelSubtypePetroleumFractionCV float DEFAULT NULL,
  fuelSubtypeFossilFraction float DEFAULT NULL,
  fuelSubtypeFossilFractionCV float DEFAULT NULL,
  carbonContent float DEFAULT NULL,
  oxidationFraction float DEFAULT NULL,
  carbonContentCV float DEFAULT NULL,
  oxidationFractionCV float DEFAULT NULL,
  energyContent float DEFAULT NULL,
  PRIMARY KEY (fuelSubtypeID),
  KEY fuelTypeID (fuelTypeID,fuelSubtypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrGrowthIndex(
  growthPatternID SMALLINT(6) NOT NULL,
  yearID SMALLINT(6) NOT NULL,
  growthIndex SMALLINT(6) DEFAULT NULL,
  PRIMARY KEY (growthPatternID, yearID),
  UNIQUE INDEX XPKNRGrowthIndex (growthPatternID, yearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrGrowthPattern(
  growthPatternID SMALLINT(6) NOT NULL,
  description CHAR(80) DEFAULT NULL,
  PRIMARY KEY (growthPatternID),
  UNIQUE INDEX XPKNRGrowthPattern (growthPatternID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrGrowthPatternFinder(
  SCC CHAR(10) NOT NULL,
  stateID SMALLINT(6) NOT NULL,
  growthPatternID SMALLINT(6) NOT NULL,
  PRIMARY KEY (SCC, stateID),
  UNIQUE INDEX XPKNRGrowthPatternFinder (SCC, stateID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrhcspeciation (
  pollutantID smallint(6) NOT NULL,
  processID smallint(6) NOT NULL,
  engTechID smallint(6) NOT NULL,
  fuelSubtypeID smallint(6) NOT NULL,
  nrHPCategory char(1) NOT NULL,
  speciationConstant double DEFAULT NULL,
  speciationConstantCV double DEFAULT NULL,
  dataSourceId smallint(6) DEFAULT NULL,
  PRIMARY KEY (pollutantID,processID,engTechID,fuelSubtypeID,nrHPCategory)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrHourAllocation(
  NRHourAllocPatternID SMALLINT(6) NOT NULL,
  hourID SMALLINT(6) NOT NULL,
  hourFraction FLOAT NOT NULL,
  PRIMARY KEY (NRHourAllocPatternID, hourID),
  UNIQUE INDEX XPKNRHourAllocation (NRHourAllocPatternID, hourID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrHourAllocPattern(
  NRHourAllocPatternID SMALLINT(6) NOT NULL,
  description CHAR(255) NOT NULL,
  PRIMARY KEY (NRHourAllocPatternID),
  UNIQUE INDEX XPKNRHourAllocPattern (NRHourAllocPatternID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrHourPatternFinder(
  NREquipTypeID SMALLINT(6) NOT NULL,
  NRHourAllocPatternID SMALLINT(6) DEFAULT NULL,
  PRIMARY KEY (NREquipTypeID),
  UNIQUE INDEX XPKNRHourPatternFinder (NREquipTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrhpcategory (
  nrhprangebinid smallint(6) NOT NULL,
  engtechid smallint(6) NOT NULL,
  nrhpcategory char(1) DEFAULT NULL,
  PRIMARY KEY (nrhprangebinid,engtechid)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrHPRangeBin(
  NRHPRangeBinID SMALLINT(6) NOT NULL,
  binName CHAR(20) DEFAULT NULL,
  hpMin SMALLINT(6) DEFAULT NULL,
  hpMax SMALLINT(6) DEFAULT NULL,
  engSizeID SMALLINT(6) NOT NULL,
  PRIMARY KEY (NRHPRangeBinID),
  UNIQUE INDEX XPKNRHPRangeBin (NRHPRangeBinID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrintegratedspecies (
  pollutantID smallint(6) NOT NULL,
  PRIMARY KEY (pollutantID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrmetalemissionrate (
  pollutantID smallint(6) NOT NULL,
  processID smallint(6) NOT NULL,
  fuelTypeID smallint(6) NOT NULL,
  engTechID smallint(6) NOT NULL,
  nrHPCategory char(1) NOT NULL,
  units char(12) DEFAULT NULL,
  meanBaseRate double DEFAULT NULL,
  meanBaseRateCV double DEFAULT NULL,
  dataSourceId smallint(6) DEFAULT NULL,
  PRIMARY KEY (pollutantID,processID,fuelTypeID,engTechID,nrHPCategory)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrmethanethcratio (
  processID smallint(6) NOT NULL,
  engTechID smallint(6) NOT NULL,
  fuelSubtypeID smallint(6) NOT NULL,
  nrHPCategory char(1) NOT NULL,
  CH4THCRatio double DEFAULT NULL,
  CH4THCRatioCV double DEFAULT NULL,
  dataSourceId smallint(6) DEFAULT NULL,
  PRIMARY KEY (processID,fuelSubtypeID,engTechID,nrHPCategory)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrMonthAllocation(
  SCC CHAR(10) NOT NULL,
  stateID SMALLINT(6) NOT NULL,
  monthID SMALLINT(6) NOT NULL,
  monthFraction FLOAT NOT NULL,
  PRIMARY KEY (SCC, stateID, monthID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrpahgasratio (
  pollutantID smallint(6) NOT NULL,
  processid smallint(6) NOT NULL,
  fuelTypeID smallint(6) NOT NULL,
  engTechID smallint(6) NOT NULL,
  nrHPCategory char(1) NOT NULL,
  atratio double DEFAULT NULL,
  atratioCV double DEFAULT NULL,
  dataSourceId smallint(6) DEFAULT NULL,
  PRIMARY KEY (pollutantID,processid,fuelTypeID,engTechID,nrHPCategory)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrpahparticleratio (
  pollutantID smallint(6) NOT NULL,
  processid smallint(6) NOT NULL,
  fuelTypeID smallint(6) NOT NULL,
  engTechID smallint(6) NOT NULL,
  nrHPCategory char(1) NOT NULL,
  atratio double DEFAULT NULL,
  atratioCV double DEFAULT NULL,
  datasourceId smallint(6) DEFAULT NULL,
  PRIMARY KEY (pollutantID,processid,fuelTypeID,engTechID,nrHPCategory)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS   nrRetrofitFactors (
  retrofitStartYear smallint(6) NOT NULL,
  retrofitEndYear smallint(6) NOT NULL,
  StartModelYear smallint(6) NOT NULL,
  EndModelYear smallint(6) NOT NULL,
  SCC char(10) NOT NULL,
  engTechID smallint(6) NOT NULL,
  hpMin smallint(6) NOT NULL,
  hpMax smallint(6) NOT NULL,
  pollutantID smallint(6) NOT NULL,
  retrofitID smallint(6) NOT NULL,
  annualFractionRetrofit float DEFAULT NULL,
  retrofitEffectiveFraction float DEFAULT NULL,
  PRIMARY KEY (SCC,engTechID,hpMin,hpMax,pollutantID,retrofitID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrrocspeciation (
  fuelSubtypeID smallint(6) NOT NULL,
  tierID smallint(6) NOT NULL,
  strokes smallint(6) NOT NULL,
  engTechID int(11) NOT NULL,
  processID int(11) NOT NULL,
  pmSpeciationProfileID varchar(10) DEFAULT NULL,
  CROCCode varchar(10) DEFAULT NULL,
  CROCOMRatio double DEFAULT NULL,
  togSpeciationProfileID varchar(10) DEFAULT NULL,
  GROCCode varchar(10) DEFAULT NULL,
  GROCNMOGRatio double DEFAULT NULL,
  PRIMARY KEY (fuelSubtypeID,tierID,strokes,engTechID,processID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrSCC(
  SCC CHAR(10) NOT NULL,
  NREquipTypeID SMALLINT(6) NOT NULL,
  description CHAR(40) DEFAULT NULL,
  fuelTypeID SMALLINT(6) NOT NULL,
  PRIMARY KEY (SCC),
  UNIQUE INDEX XPKNRSCC (SCC)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrScrappageCurve(
  NREquipTypeID SMALLINT(6) NOT NULL,
  fractionLifeused FLOAT NOT NULL,
  percentageScrapped FLOAT DEFAULT NULL,
  PRIMARY KEY (NREquipTypeID, fractionLifeused),
  UNIQUE INDEX XPKNRScrappageCurve (NREquipTypeID, fractionLifeused)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrSourceUseType (
  sourceTypeID smallint(6) NOT NULL,
  SCC char(10) NOT NULL,
  NRHPRangeBinID smallint(6) NOT NULL,
  medianLifeFullLoad float DEFAULT NULL,
  hoursUsedPerYear float DEFAULT NULL,
  loadFactor float DEFAULT NULL,
  hpAvg float DEFAULT NULL,
  isPumpFilled char(1) DEFAULT NULL,
  tankUnits char(7) DEFAULT NULL,
  tankSize float DEFAULT NULL,
  tankFillFrac float DEFAULT NULL,
  tankMetalFrac float DEFAULT NULL,
  hoseLength float DEFAULT NULL,
  hoseDiameter float DEFAULT NULL,
  hoseMetalFrac float DEFAULT NULL,
  marineFillNeckHoseLength float DEFAULT NULL,
  marineFillNeckHoseDiameter float DEFAULT NULL,
  marineSupplyHoseLength float DEFAULT NULL,
  marineSupplyHoseDiameter float DEFAULT NULL,
  marineVentHoseLength float DEFAULT NULL,
  marineVentHoseDiameter float DEFAULT NULL,
  hotSoaksPerSHO float DEFAULT NULL,
  nonInstMarineTankFrac float DEFAULT NULL,
  marineInstPlasticTankTrailFrac float NOT NULL,
  marineInstPlasticTankWaterFrac float DEFAULT NULL,
  marineInstMetalTankTrailerFrac float DEFAULT NULL,
  marineInstMetalTankWaterFrac float DEFAULT NULL,
  e10TankPermeationAdjFac float DEFAULT NULL,
  e10HosePermeationAdjFac float DEFAULT NULL,
  e10MarineFillNeckPermAdjFac float DEFAULT NULL,
  e10MarineSupplyHosePermAdjFac float DEFAULT NULL,
  e10MarineVentHosePermAdjFac float DEFAULT NULL,
  PRIMARY KEY (sourceTypeID),
  UNIQUE KEY XPKNRSourceUseType (sourceTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrStateSurrogate(
  surrogateID SMALLINT(6) NOT NULL DEFAULT 0,
  stateID SMALLINT(6) NOT NULL DEFAULT 0,
  countyID INT(11) NOT NULL DEFAULT 0,
  surrogateQuant FLOAT NOT NULL DEFAULT 0,
  surrogateYearID SMALLINT(6) NOT NULL DEFAULT 2002,
  PRIMARY KEY (surrogateID, stateID, countyID, surrogateYearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrSulfurAdjustment (
  fuelTypeID smallint(6) NOT NULL,
  engTechID smallint(6) NOT NULL,
  PMBaseSulfur float NOT NULL,
  sulfatePMConversionFactor float NOT NULL,
  PRIMARY KEY (fuelTypeID,engTechID),
  UNIQUE KEY XPKNRSulfurAdjustment (fuelTypeID,engTechID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrSurrogate(
  surrogateID SMALLINT(6) NOT NULL,
  description CHAR(255) DEFAULT NULL,
  surrogateAbbr CHAR(3) DEFAULT NULL,
  PRIMARY KEY (surrogateID),
  UNIQUE INDEX XPKNRSurrogate (surrogateID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  nrUSMonthAllocation(
  SCC CHAR(10) NOT NULL,
  stateID SMALLINT(6) NOT NULL,
  monthID SMALLINT(6) NOT NULL,
  monthFraction FLOAT NOT NULL,
  PRIMARY KEY (SCC, stateID, monthID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  offNetworkLink (
	sourceTypeID smallint not null,
	vehiclePopulation float null,
	startFraction float null,
	extendedIdleFraction float null,
	parkedVehicleFraction float null,
    zoneID integer not null default '0',
	primary key (zoneID, sourceTypeID),
	key (sourceTypeID, zoneID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  OMDGPolProcessRepresented (
	polProcessID int not null,
	representingPolProcessID int not null,
	primary key (polProcessID),
	key (representingPolProcessID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  onRoadRetrofit (
  pollutantID               smallint(6) not null,
  processID                 smallint(6) not null,
  fuelTypeID                smallint(6) not null,
  sourceTypeID              smallint(6) not null,
  retrofitYearID            smallint(6) not null,
  beginModelYearID          smallint(6) not null,
  endModelYearID            smallint(6) not null,
  cumFractionRetrofit       double not null default 0,
  retrofitEffectiveFraction double not null default 0,
  primary key (pollutantID, processID, fuelTypeID, sourceTypeID, retrofitYearID, beginModelYearID, endModelYearID),
  key (retrofitYearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  OperatingMode (
       opModeID             SMALLINT NOT NULL,
       opModeName           CHARACTER(50) NULL,
       VSPLower             FLOAT NULL,
       VSPUpper             FLOAT NULL,
       speedLower           FLOAT NULL,
       speedUpper           FLOAT NULL,
       brakeRate1Sec        FLOAT NULL,
       brakeRate3Sec        FLOAT NULL,
       minSoakTime          SMALLINT NULL,
       maxSoakTime          SMALLINT NULL	
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKOperatingMode ON OperatingMode
(
       opModeID                       ASC
);


CREATE TABLE IF NOT EXISTS  OpModeDistribution (
       sourceTypeID         SMALLINT NOT NULL,
       hourDayID            SMALLINT NOT NULL,
       linkID               INTEGER NOT NULL,
       polProcessID         int NOT NULL,
       opModeID             SMALLINT NOT NULL,
       opModeFraction       FLOAT NULL,
       opModeFractionCV     FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE OpModeDistribution ADD (
        KEY (sourceTypeID),
        KEY (hourDayID),
        KEY (linkID),
        KEY (polProcessID),
        KEY (opModeID)
);

CREATE UNIQUE INDEX XPKOpModeDistribution ON OpModeDistribution
(
       sourceTypeID                   ASC,
       hourDayID                      ASC,
       linkID                         ASC,
       polProcessID                   ASC,
       opModeID                       ASC
);


CREATE TABLE IF NOT EXISTS  OpModePolProcAssoc (
       polProcessID         int NOT NULL,
       opModeID             SMALLINT NOT NULL,
       key (opModeID, polProcessID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE OpModePolProcAssoc ADD (
        KEY (polProcessID),
        KEY (opModeID)
);

CREATE UNIQUE INDEX XPKOpModePolProcAssoc ON OpModePolProcAssoc
(
       polProcessID                   ASC,
       opModeID                       ASC
);

CREATE TABLE IF NOT EXISTS  OxyThreshName 
(
	oxyThreshID				smallint(6)		NOT NULL	default '0' primary key,
	oxyThreshName			CHAR(100)		NULL		default NULL	
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  pahGasRatio (
  polProcessID int NOT NULL DEFAULT '0',
  fuelTypeID smallint(6) NOT NULL DEFAULT '0',
  modelYearGroupID int(11) NOT NULL DEFAULT '0',
  atRatio double DEFAULT NULL,
  atRatioCV double DEFAULT NULL,
  dataSourceId smallint(6) DEFAULT NULL,
  PRIMARY KEY (polProcessID,fuelTypeID,modelYearGroupID),
  UNIQUE KEY XPKPAHGasRatio (polProcessID,fuelTypeID,modelYearGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  pahParticleRatio (
  polProcessID int NOT NULL DEFAULT '0',
  fuelTypeID smallint(6) NOT NULL DEFAULT '0',
  modelYearGroupID int(11) NOT NULL DEFAULT '0',
  atRatio double DEFAULT NULL,
  atRatioCV double DEFAULT NULL,
  dataSourceId smallint(6) DEFAULT NULL,
  PRIMARY KEY (polProcessID,fuelTypeID,modelYearGroupID),
  UNIQUE KEY XPKPAParticleHRatio (polProcessID,fuelTypeID,modelYearGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  PM10EmissionRatio (
	polProcessID			int NOT NULL,
	sourceTypeID			smallint(6) NOT NULL,
	fuelTypeID				smallint(6) NOT NULL,
	minModelYearID			smallint(6) NOT NULL,
	maxModelYearID			smallint(6) NOT NULL,
	PM10PM25Ratio			float NOT NULL,
	PM10PM25RatioCV			float NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci'; 

CREATE UNIQUE INDEX XPKPM10EmissionRatio ON PM10EmissionRatio
(
	polProcessID ASC,
	sourceTypeID ASC,
	fuelTypeID ASC,
	minModelYearID ASC,
	maxModelYearID ASC
);

CREATE TABLE IF NOT EXISTS  PMSpeciation (
	processID smallint not null,
	inputPollutantID smallint not null,
	sourceTypeID smallint not null,
	fuelTypeID smallint not null,
	minModelYearID smallint not null,
	maxModelYearID smallint not null,
	outputPollutantID smallint not null,
	pmSpeciationFraction double not null,
	primary key (processID, inputPollutantID, sourceTypeID, fuelTypeID, minModelYearID, maxModelYearID, outputPollutantID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  Pollutant (
       pollutantID          SMALLINT NOT NULL,
       pollutantName        CHAR(50) NULL,
       energyOrMass         CHAR(6) NULL,
       GlobalWarmingPotential  SMALLINT NULL,
       NEIPollutantCode     CHAR(10) NULL,
       pollutantDisplayGroupID SMALLINT NULL,
       shortName			VARCHAR(50) NULL,
       isAffectedByOnroad tinyint(1) DEFAULT '1',
       isAffectedByNonroad tinyint(1) DEFAULT '0',
       primary key (pollutantID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  PollutantProcessAssoc (
       polProcessID         int NOT NULL,
       processID            SMALLINT NOT NULL,
       pollutantID          SMALLINT NOT NULL,
       isAffectedByExhaustIM CHAR(1) NOT NULL DEFAULT "N",
       isAffectedByEvapIM CHAR(1) NOT NULL DEFAULT "N",
       chainedto1 int NULL DEFAULT NULL,
       chainedto2 int NULL DEFAULT NULL,
       isAffectedByOnroad TINYINT(1) NOT NULL DEFAULT 1,
       isAffectedByNonroad TINYINT(1) NOT NULL DEFAULT 0,
       nrChainedTo1 int NULL DEFAULT NULL,
       nrChainedTo2 int NULL DEFAULT NULL,
       key (processID, pollutantID, polProcessID),
       key (pollutantID, processID, polProcessID),
       key (polProcessID, processID, pollutantID),
       key (polProcessID, pollutantID, processID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE PollutantProcessAssoc ADD (
        KEY (processID),
        KEY (pollutantID)
);

CREATE UNIQUE INDEX XPKPollutantProcessAssoc ON PollutantProcessAssoc
(
       polProcessID                   ASC
);

CREATE TABLE IF NOT EXISTS  PollutantProcessModelYear (
    polProcessID int NOT NULL ,
    modelYearID SMALLINT NOT NULL ,
    modelYearGroupID INT NOT NULL ,
    fuelMYGroupID INTEGER NULL,
    IMModelYearGroupID INTEGER NULL,
    key (modelYearID, polProcessID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE PollutantProcessModelYear ADD (
        KEY (polProcessID),
        KEY (modelYearID)
);

CREATE UNIQUE INDEX XPKPollutantProcessModelYear ON PollutantProcessModelYear
(
       polProcessID                   ASC,
       modelYearID                    ASC
);

CREATE TABLE IF NOT EXISTS  processDisplayGroup(
  processDisplayGroupID SMALLINT(6) NOT NULL,
  processDisplayGroupName CHAR(50) NOT NULL,
  displayAsGroup CHAR(1) NOT NULL,
  PRIMARY KEY (processDisplayGroupID),
  UNIQUE INDEX XPKProcessDisplayGroup (processDisplayGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  processGroupID(
  processGroupID SMALLINT(6) NOT NULL,
  processGroupName CHAR(15) NOT NULL,
  PRIMARY KEY (processGroupID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  RefuelingControlTechnology (
       processID               SMALLINT NOT NULL,
       modelYearID             SMALLINT NOT NULL,
       regClassID              SMALLINT NOT NULL,
	   sourceTypeID            SMALLINT NOT NULL,
       fuelTypeID         	   SMALLINT NOT NULL,
       ageID                   SMALLINT NOT NULL,
       refuelingTechAdjustment FLOAT NOT NULL DEFAULT 0.0,
       controlledRefuelingRate FLOAT NOT NULL DEFAULT 0.0
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  RefuelingFactors (
       fuelTypeID           SMALLINT NOT NULL PRIMARY KEY,
       defaultFormulationID SMALLINT NULL,
       vaporTermA           FLOAT NOT NULL DEFAULT 0,
       vaporTermB           FLOAT NOT NULL DEFAULT 0,
       vaporTermC           FLOAT NOT NULL DEFAULT 0,
       vaporTermD           FLOAT NOT NULL DEFAULT 0,
       vaporTermE           FLOAT NOT NULL DEFAULT 0,
       vaporTermF           FLOAT NOT NULL DEFAULT 0,
       vaporLowTLimit       FLOAT NOT NULL DEFAULT 0,
       vaporHighTLimit      FLOAT NOT NULL DEFAULT 0,
       tankTDiffLimit       FLOAT NOT NULL DEFAULT 0,
       minimumRefuelingVaporLoss FLOAT NOT NULL DEFAULT 0,
       refuelingSpillRate   FLOAT NOT NULL DEFAULT 0,
       refuelingSpillRateCV FLOAT NOT NULL DEFAULT 0,
       displacedVaporRateCV FLOAT NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKRefuelingFactors ON RefuelingFactors
(
       fuelTypeID                     ASC
);

CREATE TABLE IF NOT EXISTS  RegulatoryClass (
    regClassID SMALLINT NOT NULL PRIMARY KEY,
    regClassName CHAR(25) NULL ,
    regClassDesc CHAR(100) NULL ,
    fleetAvgGroupID SMALLINT(6) NOT NULL DEFAULT '0',
    key (fleetAvgGroupID)
    ) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';
    
CREATE UNIQUE INDEX XPKRegulatoryClass ON RegulatoryClass
(
       regClassID                     ASC
);

CREATE TABLE IF NOT EXISTS  region (
	regionID int not null,
	VV smallint(6),
	WW smallint(6),
	XX smallint(6),
	YY smallint(6),
	ZZ smallint(6),
	description varchar(150),
	primary key (regionID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  regionCode (
	regionCodeID int not null,
	regionCodeDescription varchar(200) not null default '',
	primary key (regionCodeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  regionCounty (
	regionID int not null,
	countyID int not null,
	regionCodeID int not null,
	fuelYearID int not null,
	primary key (regionID, countyID, regionCodeID, fuelYearID),
	key (countyID, fuelYearID, regionCodeID, regionID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  RetrofitInputAssociations (
	listName varchar(20) not null,
	commonName varchar(50) not null,
	primary key (listName, commonName),
	idealName varchar(50) not null
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKRetrofitInputAssociations on RetrofitInputAssociations
(
	listName ASC,
	commonName ASC
);

CREATE TABLE IF NOT EXISTS  roadidlefraction (
    dayID int,
    sourceTypeID int,
    roadTypeID int,
    avgSpeedBinID int,
    roadidlefraction double,
    primary key (dayID,sourceTypeID,roadTypeID,avgSpeedBinID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  RoadType (
       roadTypeID           SMALLINT NOT NULL,
       roadDesc             CHAR(50) NULL,
       isAffectedByOnroad TINYINT(1) DEFAULT 1,
       isAffectedByNonroad TINYINT(1) DEFAULT 0,
       shouldDisplay TINYINT(1) DEFAULT 1,
       primary key (roadTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  RoadTypeDistribution (
       sourceTypeID         SMALLINT NOT NULL,
       roadTypeID           SMALLINT NOT NULL,
       roadTypeVMTFraction  FLOAT NULL,
       key (roadTypeID, sourceTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE RoadTypeDistribution ADD (
        KEY (sourceTypeID),
        KEY (roadTypeID)
);

CREATE UNIQUE INDEX XPKRoadTypeDistribution ON RoadTypeDistribution
(
       sourceTypeID                   ASC,
       roadTypeID                     ASC
);

CREATE TABLE IF NOT EXISTS  rocspeciation (
	fuelSubtypeID smallint(6),
    regClassID smallint(6),
    processID smallint(6),
    minModelYearID int(11),
    maxModelYearID int(11),
    pmSpeciationProfileID varchar(10),
    CROCCode varchar(10),
    CROCOMRatio double,
    togSpeciationProfileID varchar(10),
    GROCCode varchar(10),
	GROCNMOGRatio double,
    PRIMARY KEY (fuelSubtypeID,regClassID,processID,minModelYearID,maxModelYearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  SampleVehicleDay (
       vehID         	    INTEGER NOT NULL,
       dayID				SMALLINT NOT NULL,
       sourceTypeID         SMALLINT NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKSampleVehicle ON SampleVehicleDay
(
       vehID  	            ASC,
       dayID				ASC
);

CREATE TABLE IF NOT EXISTS  sampleVehicleSoaking (
	soakDayID smallint not null,
	sourceTypeID smallint not null,
	dayID smallint not null,
	hourID smallint not null,
	soakFraction double,
	primary key (soakDayID, sourceTypeID, dayID, hourID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  sampleVehicleSoakingDay (
	soakDayID smallint not null,
	sourceTypeID smallint not null,
	dayID smallint not null,
	F double,
	primary key (soakDayID, sourceTypeID, dayID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  sampleVehicleSoakingDayBasis (
	soakDayID smallint not null,
	dayID smallint not null,
	F double,
	primary key (soakDayID, dayID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  sampleVehicleSoakingDayUsed (
	soakDayID smallint not null,
	sourceTypeID smallint not null,
	dayID smallint not null,
	F double,
	primary key (soakDayID, sourceTypeID, dayID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  sampleVehicleSoakingDayBasisUsed (
	soakDayID smallint not null,
	dayID smallint not null,
	F double,
	primary key (soakDayID, dayID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  SampleVehicleTrip (
      	vehID         	   	INTEGER NOT NULL,
		dayID				SMALLINT NOT NULL, 
      	tripID		       	SMALLINT NOT NULL,
      	hourID				SMALLINT NULL,
      	priorTripID			SMALLINT NULL,
      	keyOnTime			INT NULL,
      	keyOffTime			INT NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKSampleVehicleTrip ON SampleVehicleTrip
(
       vehID  	            ASC,
       dayID				ASC,
       tripID				ASC
);

ALTER TABLE SampleVehicleTrip ADD (
		KEY (vehID),
		KEY (dayID),
		KEY (tripID)
);

CREATE TABLE IF NOT EXISTS  sampleVehiclePopulation (
	sourceTypeModelYearID int(10) unsigned NOT NULL,
	sourceTypeID smallint(6) NOT NULL DEFAULT '0',
	modelYearID smallint(6) NOT NULL DEFAULT '0',
	fuelTypeID smallint(5) unsigned NOT NULL,
	engTechID smallint(6) NOT NULL,
	regClassID smallint(5) unsigned NOT NULL,
	stmyFuelEngFraction double NOT NULL,
	stmyFraction double NOT NULL,
	PRIMARY KEY (sourceTypeModelYearID,fuelTypeID,engTechID,regClassID),
	key stmyft (sourceTypeID, modelYearID, fuelTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  scc (
  SCC char(10) NOT NULL DEFAULT '',
  fuelTypeID smallint(6) NOT NULL DEFAULT '0',
  sourceTypeID smallint(6) NOT NULL DEFAULT '0',
  roadTypeID smallint(6) NOT NULL DEFAULT '0',
  processID smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (SCC),
  KEY fuelTypeID (fuelTypeID),
  KEY sourceTypeID (sourceTypeID),
  KEY roadTypeID (roadTypeID),
  KEY processID (processID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  Sector (
  sectorID smallint(6) NOT NULL,
  description char(40) DEFAULT NULL,
  PRIMARY KEY (sectorID),
  UNIQUE KEY XPKSector (sectorID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  SHO (
       hourDayID            SMALLINT NOT NULL,
       monthID              SMALLINT NOT NULL,
       yearID               SMALLINT NOT NULL,
       ageID                SMALLINT NOT NULL,
       linkID               INTEGER NOT NULL,
       sourceTypeID         SMALLINT NOT NULL,
       SHO                  FLOAT NULL,
       SHOCV                FLOAT NULL,
       distance             FLOAT NULL,
       key (linkID, yearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE SHO ADD (
        KEY (hourDayID),
        KEY (monthID),
        KEY (yearID),
        KEY (ageID),
        KEY (linkID),
        KEY (sourceTypeID)
);

CREATE UNIQUE INDEX XPKSHO ON SHO
(
       hourDayID                      ASC,
       monthID                        ASC,
       yearID                         ASC,
       ageID                          ASC,
       linkID                         ASC,
       sourceTypeID                   ASC
);

CREATE TABLE IF NOT EXISTS  SizeWeightFraction (
       sourceTypeModelYearID INTEGER NOT NULL,
       fuelTypeID           SMALLINT NOT NULL,
       engTechID            SMALLINT NOT NULL,
       engSizeID            SMALLINT NOT NULL,
       weightClassID        SMALLINT NOT NULL,
       sizeWeightFraction   FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE SizeWeightFraction ADD (
        KEY (sourceTypeModelyearID),
        KEY (fuelTypeID),
        KEY (engTechID),
        KEY (engSizeID),
        KEY (weightClassID)
);

CREATE UNIQUE INDEX XPKSizeWeightFraction ON SizeWeightFraction
(
       sourceTypeModelYearID          ASC,
       fuelTypeID                     ASC,
       engTechID                      ASC,
       engSizeID                      ASC,
       weightClassID                  ASC
);

CREATE TABLE IF NOT EXISTS  SoakActivityFraction (
	sourceTypeID SMALLINT NOT NULL,
	zoneID INTEGER NOT NULL,
	monthID SMALLINT NOT NULL,
	hourDayID SMALLINT NOT NULL,
	opModeID SMALLINT NOT NULL,
	soakActivityFraction FLOAT,
	soakActivityFractionCV FLOAT
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKSoakActivityFraction ON SoakActivityFraction (
	sourceTypeID ASC,
	zoneID ASC,
	monthID ASC,
	hourDayID ASC,
	opModeID ASC
);

CREATE TABLE IF NOT EXISTS  SourceBin (
       sourceBinID          BIGINT NOT NULL,
       engSizeID            SMALLINT NULL,
       fuelTypeID           SMALLINT NOT NULL,
       engTechID            SMALLINT NOT NULL,
       regClassID           SMALLINT NULL,
       modelYearGroupID     INTEGER NULL,
       weightClassID        SMALLINT NULL,
       key (sourceBinID, fuelTypeID, modelYearGroupID),
       key (sourceBinID, modelYearGroupID, fuelTypeID),
       key (fuelTypeID, modelYearGroupID, sourceBinID),
       key (fuelTypeID, sourceBinID, modelYearGroupID),
       key (modelYearGroupID, fuelTypeID, sourceBinID),
       key (modelYearGroupID, sourceBinID, fuelTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE SourceBin ADD (
        KEY (fuelTypeID),
        KEY (modelYearGroupID)
);

CREATE UNIQUE INDEX XPKSourceBin ON SourceBin
(
       sourceBinID                    ASC
);


CREATE TABLE IF NOT EXISTS  SourceBinDistribution (
       sourceTypeModelYearID INTEGER NOT NULL,
       polProcessID         int NOT NULL,
       sourceBinID          BIGINT NOT NULL,
       sourceBinActivityFraction FLOAT NULL,
       sourceBinActivityFractionCV FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE SourceBinDistribution ADD (
        KEY (sourceTypeModelYearID),
        KEY (polProcessID),
        KEY (sourceBinID)
);

CREATE UNIQUE INDEX XPKSourceBinDistribution ON SourceBinDistribution
(
       sourceTypeModelYearID          ASC,
       polProcessID                   ASC,
       sourceBinID                    ASC
);

CREATE TABLE IF NOT EXISTS  SourceHours (
       hourDayID            SMALLINT NOT NULL,
       monthID              SMALLINT NOT NULL,
       yearID               SMALLINT NOT NULL,
       ageID                SMALLINT NOT NULL,
       linkID               INTEGER NOT NULL,
       sourceTypeID         SMALLINT NOT NULL,
       sourceHours          FLOAT NULL,
       sourceHoursCV        FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE SourceHours ADD (
        KEY (hourDayID),
        KEY (monthID),
        KEY (yearID),
        KEY (ageID),
        KEY (linkID),
        KEY (sourceTypeID)
);

CREATE UNIQUE INDEX XPKSourceHours ON SourceHours
(
       hourDayID                      ASC,
       monthID                        ASC,
       yearID                         ASC,
       ageID                          ASC,
       linkID                         ASC,
       sourceTypeID                   ASC
);

CREATE TABLE IF NOT EXISTS  SourceTypeAge (
       ageID                SMALLINT NOT NULL,
       sourceTypeID         SMALLINT NOT NULL,
       survivalRate         FLOAT NULL,
       relativeMAR          FLOAT NULL,
       functioningACFraction FLOAT NULL,
       functioningACFractionCV FLOAT NULL,
       key (sourceTypeID, ageID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE SourceTypeAge ADD (
        KEY (ageID),
        KEY (sourceTypeID)
);

CREATE UNIQUE INDEX XPKSourceTypeAge ON SourceTypeAge
(
       ageID                          ASC,
       sourceTypeID                   ASC
);


CREATE TABLE IF NOT EXISTS  SourceTypeAgeDistribution (
       sourceTypeID         SMALLINT NOT NULL,
       yearID               SMALLINT NOT NULL,
       ageID                SMALLINT NOT NULL,
       ageFraction          FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE SourceTypeAgeDistribution ADD (
        KEY (sourceTypeID),
        KEY (yearID),
        KEY (ageID)
);

CREATE UNIQUE INDEX XPKSourceTypeAgeDistribution ON SourceTypeAgeDistribution
(
       sourceTypeID                   ASC,
       yearID                         ASC,
       ageID                          ASC
);

CREATE TABLE IF NOT EXISTS  SourceTypeDayVMT (
	yearID smallint not null,
	monthID smallint not null,
	dayID smallint not null,
	sourceTypeID smallint not null,
	VMT double not null,
	primary key (yearID, monthID, dayID, sourceTypeID),
	key (sourceTypeID, yearID, monthID, dayID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  SourceTypeHour (
       sourceTypeID         SMALLINT NOT NULL,
       hourDayID            SMALLINT NOT NULL,
       idleSHOFactor        FLOAT NULL,
       hotellingdist        DOUBLE DEFAULT NULL,
       primary key (sourceTypeID, hourDayID),
       key (hourDayID, sourceTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';


CREATE TABLE IF NOT EXISTS  SourceTypeModelYear (
       sourceTypeModelYearID INTEGER NOT NULL,
       modelYearID          SMALLINT NOT NULL,
       sourceTypeID         SMALLINT NOT NULL,
       ACPenetrationFraction FLOAT NULL,
       ACPenetrationFractionCV FLOAT NULL,
       key (sourceTypeModelYearID, modelYearID, sourceTypeID),
       key (sourceTypeModelYearID, sourceTypeID, modelYearID),
       key (sourceTypeID, modelYearID, sourceTypeModelYearID),
       key (modelYearID, sourceTypeID, sourceTypeModelYearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE SourceTypeModelYear ADD (
        KEY (modelYearID),
        KEY (sourceTypeID)
);

CREATE UNIQUE INDEX XPKSourceTypeModelYear ON SourceTypeModelYear
(
       sourceTypeModelYearID          ASC
);

CREATE TABLE IF NOT EXISTS  SourceTypeModelYearGroup (
	sourceTypeID SMALLINT NOT NULL,
	modelYearGroupID INTEGER NOT NULL,
	tankTemperatureGroupID SMALLINT NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKSourceTypeModelYearGroup ON SourceTypeModelYearGroup (
	sourceTypeID ASC,
	modelYearGroupID ASC	
);

CREATE TABLE IF NOT EXISTS  SourceTypePolProcess (
       sourceTypeID         SMALLINT NOT NULL,
       polProcessID         int NOT NULL,
       isSizeWeightReqd     CHAR(1) NULL,
       isRegClassReqd       CHAR(1) NULL,
       isMYGroupReqd        CHAR(1) NULL,
       key (polProcessId, sourceTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE SourceTypePolProcess ADD (
        KEY (sourceTypeID),
        KEY (polProcessID)
);

CREATE UNIQUE INDEX XPKSourceTypePolProcess ON SourceTypePolProcess
(
       sourceTypeID                   ASC,
       polProcessID                   ASC
);

CREATE TABLE IF NOT EXISTS  SourceTypeTechAdjustment (
       processID            SMALLINT NOT NULL,
       sourceTypeID         SMALLINT NOT NULL,
       modelYearID          SMALLINT NOT NULL,
       refuelingTechAdjustment FLOAT NOT NULL DEFAULT 0.0
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE SourceTypeTechAdjustment ADD (
       KEY (processID),
       KEY (sourceTypeID),
       KEY (modelYearID)
);

CREATE UNIQUE INDEX XPKSourceTypeTechAdjustment ON SourceTypeTechAdjustment
(
       processID    ASC,
       sourceTypeID ASC,
       modelYearID  ASC
);

ALTER TABLE RefuelingControlTechnology ADD (
       KEY (processID),
       KEY (regClassID),
       KEY (sourceTypeID),
       KEY (modelYearID)
);

CREATE UNIQUE INDEX XPKSourceTypeTechAdjustment ON RefuelingControlTechnology
(
       processID    ASC,
	   regClassID   ASC,
       sourceTypeID ASC,
       modelYearID  ASC
);

CREATE TABLE IF NOT EXISTS  SourceTypeYear (
       yearID               SMALLINT NOT NULL,
       sourceTypeID         SMALLINT NOT NULL,
       salesGrowthFactor    FLOAT NULL,
       sourceTypePopulation FLOAT NULL,
       migrationRate        FLOAT NULL,
       key (sourceTypeID, yearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE SourceTypeYear ADD (
        KEY (yearID),
        KEY (sourceTypeID)
);

CREATE UNIQUE INDEX XPKSourceTypeYear ON SourceTypeYear
(
       yearID                         ASC,
       sourceTypeID                   ASC
);

CREATE TABLE IF NOT EXISTS  SourceTypeYearVMT (
	yearID smallint not null,
	sourceTypeID smallint not null,
	VMT double not null,
	primary key (yearID, sourceTypeID),
	key (sourceTypeID, yearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  SourceUseType (
       sourceTypeID         SMALLINT NOT NULL,
       HPMSVtypeID          SMALLINT NOT NULL,
       sourceTypeName       CHAR(50) NULL,

       key (sourceTypeID, HPMSVtypeID),
       key (HPMSVtypeID, sourceTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE SourceUseType ADD (
        KEY (HPMSVtypeID)
);

CREATE UNIQUE INDEX XPKSourceUseType ON SourceUseType
(
       sourceTypeID                   ASC
);

CREATE TABLE IF NOT EXISTS  sourceUseTypePhysics (
	sourceTypeID smallint not null,
	regClassID smallint not null,
	beginModelYearID smallint not null,
	endModelYearID smallint not null,

	rollingTermA float DEFAULT NULL,
	rotatingTermB float DEFAULT NULL,
	dragTermC float DEFAULT NULL,
	sourceMass float DEFAULT NULL,
	fixedMassFactor float DEFAULT NULL,

	primary key (sourceTypeID, regClassID, beginModelYearID, endModelYearID),
	key (beginModelYearID, endModelYearID, sourceTypeID, regClassID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  Starts (
       hourDayID            SMALLINT NOT NULL,
       monthID              SMALLINT NOT NULL,
       yearID               SMALLINT NOT NULL,
       ageID                SMALLINT NOT NULL,
       zoneID               INTEGER NOT NULL,
       sourceTypeID         SMALLINT NOT NULL,
       starts               FLOAT NULL,
       startsCV             FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE Starts ADD (
        KEY (hourDayID),
        KEY (monthID),
        KEY (yearID),
        KEY (ageID),
        KEY (zoneID),
        KEY (sourceTypeID)
);

CREATE UNIQUE INDEX XPKStarts ON Starts
(
       hourDayID                      ASC,
       monthID                        ASC,
       yearID                         ASC,
       ageID                          ASC,
       zoneID                         ASC,
       sourceTypeID                   ASC
);

CREATE TABLE IF NOT EXISTS  startsAgeAdjustment (
  sourceTypeID smallint(6) NOT NULL DEFAULT 0,
  ageID smallint(6) NOT NULL DEFAULT 0,
  ageAdjustment double DEFAULT NULL,
  PRIMARY KEY (sourceTypeID,ageID),
  KEY sourceTypeID (sourceTypeID),
  KEY ageID (ageID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  startsHourFraction (
  dayID smallint(6) NOT NULL,
  hourID smallint(6) NOT NULL,
  sourceTypeID smallint(6) NOT NULL DEFAULT '0',
  allocationFraction double NOT NULL,
  PRIMARY KEY (dayID,hourID,sourceTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  startsMonthAdjust (
    monthID smallint(6) NOT NULL,
    sourceTypeID smallint(6) NOT NULL DEFAULT '0',
    monthAdjustment double NOT NULL,
    PRIMARY KEY (monthID,sourceTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  startsPerDay (
  dayID smallint(6) NOT NULL DEFAULT 0,
  sourceTypeID smallint(6) NOT NULL DEFAULT 0,
  startsPerDay double DEFAULT NULL,
  PRIMARY KEY (sourceTypeID,dayID),
  KEY hourDayID (dayID),
  KEY sourceTypeID (sourceTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  startsPerDayPerVehicle (
  dayID smallint(6) NOT NULL DEFAULT 0,
  sourceTypeID smallint(6) NOT NULL DEFAULT 0,
  startsPerDayPerVehicle double DEFAULT NULL,
  PRIMARY KEY (sourceTypeID,dayID),
  KEY hourDayID (dayID),
  KEY sourceTypeID (sourceTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  StartsPerVehicle (
       sourceTypeID    		SMALLINT NOT NULL,
       hourDayID			SMALLINT NOT NULL,
       startsPerVehicle		FLOAT NULL,
       startsPerVehicleCV	FLOAT NULL,
       key (hourDayID, sourceTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKStartsPerVehicle ON StartsPerVehicle
(
       sourceTypeID         ASC,
       hourDayID		    ASC
);

ALTER TABLE StartsPerVehicle ADD (
		KEY (sourceTypeID),
		KEY (hourDayID)
);

CREATE TABLE IF NOT EXISTS  StartTempAdjustment (
       fuelTypeID    		SMALLINT NOT NULL,
       polProcessID			int NOT NULL,
       modelYearGroupID		INTEGER NOT NULL,
       opModeID             SMALLINT NOT NULL,
       startTempEquationType VARCHAR(4) NULL,
       tempAdjustTermA		FLOAT NULL,
       tempAdjustTermACV	FLOAT NULL,
       tempAdjustTermB		FLOAT NULL,
       tempAdjustTermBCV	FLOAT NULL,
       tempAdjustTermC		FLOAT NULL,
       tempAdjustTermCCV	FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKStartTempAdjustment ON StartTempAdjustment
(
       fuelTypeID   		ASC,
       polProcessID			ASC,
       modelYearGroupID		ASC,
       opModeID				ASC
);

ALTER TABLE StartTempAdjustment ADD (
		KEY (fuelTypeID),
		KEY (polProcessID),
		KEY (modelYearGroupID),
		KEY (opModeID)
);

CREATE TABLE IF NOT EXISTS  State (
       stateID              SMALLINT NOT NULL,
       stateName            CHAR(25) NULL,
       stateAbbr            CHAR(2) NULL,
       idleRegionID 		INTEGER DEFAULT '0' NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKState ON State
(
       stateID                        ASC
);

CREATE TABLE IF NOT EXISTS  SulfateEmissionRate  (
	polProcessID			int	NOT NULL,
	fuelTypeID				SMALLINT(6) NOT NULL,
	modelYearGroupID		INT(11)     NOT NULL,
	meanBaseRate			float	NULL,
	meanBaseRateCV			float	NULL,
	dataSourceId			SMALLINT(6),
	PRIMARY KEY 			(polProcessID, fueltypeID, modelYearGroupID)								
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci'; 

CREATE UNIQUE INDEX XPKSulfateEmissionRate ON SulfateEmissionRate 
(
       polProcessID   		ASC,
       fueltypeID			ASC,
       modelYearGroupID		ASC
);

CREATE TABLE IF NOT EXISTS  SulfateFractions (
	processID smallint not null,
	fuelTypeID smallint not null,
	sourceTypeID smallint not null,
	minModelYearID smallint not null,
	maxModelYearID smallint not null,
	SulfatenonECPMFraction double not null,
	H2OnonECPMFraction double not null,
	BaseFuelSulfurLevel double not null,
	BaseFuelSulfateFraction double not null,
	dataSourceID smallint(6) NOT NULL DEFAULT '0',
	primary key (processID, fuelTypeID, sourceTypeID, minModelYearID, maxModelYearID),
	key (processID, sourceTypeID, fuelTypeID, minModelYearID, maxModelYearID),
	key (processID, minModelYearID, maxModelYearID, fuelTypeID, sourceTypeID),
	key (processID, minModelYearID, maxModelYearID, sourceTypeID, fuelTypeID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  SulfurBase  (
	modelYearGroupID	int(11)		NOT NULL	default '0' primary key,
	sulfurBase			float		NULL		default	NULL,
	sulfurBasis			float		NULL		default '30.0',
	sulfurGPAMax		float		NULL		default '330.0'
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci'; 

CREATE TABLE IF NOT EXISTS  sulfurCapAmount (
	fuelTypeID int not null primary key,
	sulfurCap double
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  SulfurModelCoeff  (
	processID				smallint(6),
	pollutantID				smallint(6),
	M6emitterID				smallint(6),
	sourceTypeID			smallint(6),
	fuelMYGroupID			INT(8),
	sulfurFunctionID		smallint(6),
	sulfurCoeff				float,
	lowSulfurCoeff			double,
	PRIMARY KEY 			(processID, pollutantID, M6emitterID, sourceTypeID, fuelMYGroupID)								
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci'; 

CREATE TABLE IF NOT EXISTS  SulfurModelName  (
	M6EmitterID				smallint(6),
	sulfurFunctionID		smallint(6),
	M6emitterName			CHAR(10),
	sulfurFunctionName		CHAR(10),
	PRIMARY KEY 			(M6EmitterID, sulfurFunctionID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci'; 

CREATE TABLE IF NOT EXISTS  TankVaporGenCoeffs (
	ethanolLevelID smallint(6) NOT NULL,
	altitude char(1) NOT NULL,
	tvgTermA float NULL,
	tvgTermB float NULL,
	tvgTermC float NULL,
	PRIMARY KEY  (ethanolLevelID,altitude)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  TankTemperatureGroup (
	tankTemperatureGroupID SMALLINT NOT NULL,
	tankTemperatureGroupName CHAR(50)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKTankTemperatureGroup ON TankTemperatureGroup (
	tankTemperatureGroupID ASC
);

CREATE TABLE IF NOT EXISTS  TankTemperatureRise (
	tankTemperatureGroupID SMALLINT NOT NULL,
	tankTemperatureRiseTermA FLOAT,
	tankTemperatureRiseTermACV FLOAT,
	tankTemperatureRiseTermB FLOAT,
	tankTemperatureRiseTermBCV FLOAT
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKTankTemperatureRise ON TankTemperatureRise (
	tankTemperatureGroupID ASC
);

CREATE TABLE IF NOT EXISTS  TemperatureAdjustment (
       polProcessID         int NOT NULL,
       fuelTypeID           SMALLINT NOT NULL,
       regClassID           SMALLINT NOT NULL DEFAULT '0',
       minModelYearID		SMALLINT NOT NULL DEFAULT '1950',
       maxModelYearID		SMALLINT NOT NULL DEFAULT '2060',
       tempAdjustTermA      FLOAT NULL,
       tempAdjustTermB      FLOAT NULL,
       tempAdjustTermC      FLOAT NULL,
       key (fuelTypeID, polProcessID, regClassID, minModelYearID, maxModelYearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE TemperatureAdjustment ADD (
        KEY (polProcessID),
        KEY (fuelTypeID),
        KEY (regClassID),
        KEY (minModelYearID, maxModelYearID)
);

CREATE UNIQUE INDEX XPKTemperatureAdjustment ON TemperatureAdjustment
(
       polProcessID                   ASC,
       fuelTypeID                     ASC,
       regClassID                     ASC,
       minModelYearID				  ASC,
       maxModelYearID				  ASC
);

CREATE TABLE IF NOT EXISTS  TemperatureProfileID (
       temperatureProfileID BIGINT NOT NULL PRIMARY KEY,
       zoneID               INTEGER NOT NULL,
       monthID              SMALLINT NOT NULL,
       key (zoneID, monthID, temperatureProfileID),
       key (monthID, zoneID, temperatureProfileID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  TOGSpeciationProfileName (
	TOGSpeciationProfileID			varchar(10)		not null default '0',
	TOGSpeciationProfileName		varchar(100)	null,
	dataSourceId					int				null,
	primary key (TOGspeciationProfileID),
	key (TOGSpeciationProfileName)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  totalIdleFraction (
	idleRegionID int not null,
	countyTypeID int not null,
	sourceTypeID smallint not null,
	monthID smallint not null,
	dayID smallint not null,
	minModelYearID smallint not null,
	maxModelYearID smallint not null,
	totalIdleFraction double not null,
	primary key (idleRegionID, countyTypeID, sourceTypeID, monthID, dayID, minModelYearID, maxModelYearID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE TABLE IF NOT EXISTS  WeightClass (
       weightClassID        SMALLINT NOT NULL,
       weightClassName      CHAR(50) NULL,
       midpointWeight       FLOAT NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE UNIQUE INDEX XPKWeightClass ON WeightClass
(
       weightClassID                  ASC
);


CREATE TABLE IF NOT EXISTS  Year (
       yearID               SMALLINT NOT NULL,
       isBaseYear           CHAR(1) NULL,
       fuelYearID           int NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE Year ADD (
        KEY (isBaseYear)
);

CREATE UNIQUE INDEX XPKYear ON Year
(
       yearID                         ASC
);


CREATE TABLE IF NOT EXISTS  Zone (
       zoneID               INTEGER NOT NULL,
       countyID             INTEGER NOT NULL,
       startAllocFactor     DOUBLE NULL,
       idleAllocFactor      DOUBLE NULL,
       SHPAllocFactor        DOUBLE NULL,
       key (zoneID, countyID),
       key (countyID, zoneID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE Zone ADD (
        KEY (countyID)
);

CREATE UNIQUE INDEX XPKZone ON Zone
(
       zoneID                         ASC
);

CREATE TABLE IF NOT EXISTS  ZoneMonthHour (
       monthID              SMALLINT NOT NULL,
       zoneID               INTEGER NOT NULL,
       hourID               SMALLINT NOT NULL,
       temperature          DOUBLE NULL,
       relHumidity          DOUBLE NULL,
       heatIndex            DOUBLE NULL,
       specificHumidity     DOUBLE NULL,
       molWaterFraction     DOUBLE NULL
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE ZoneMonthHour ADD (
        KEY (monthID),
        KEY (zoneID),
        KEY (hourID)
);

CREATE UNIQUE INDEX XPKZoneMonthHour ON ZoneMonthHour
(
       monthID                        ASC,
       zoneID                         ASC,
       hourID                         ASC
);


CREATE TABLE IF NOT EXISTS  ZoneRoadType (
       zoneID               INTEGER NOT NULL,
       roadTypeID           SMALLINT NOT NULL,
       SHOAllocFactor       DOUBLE NULL,
       key (roadTypeID, zoneID)
) ENGINE=MyISAM DEFAULT CHARSET='utf8mb4' COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE ZoneRoadType ADD (
        KEY (zoneID),
        KEY (roadTypeID)
);

CREATE UNIQUE INDEX XPKZoneRoadType ON ZoneRoadType
(
       zoneID                         ASC,
       roadTypeID                     ASC
);

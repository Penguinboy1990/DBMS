-- Jack Saunders
-- Database Management Systems Homework 3
-- 10/26/2026

-- Set up database
create database HW4new;
use HW4new;

set SQL_SAFE_UPDATES = 0;
set FOREIGN_KEY_CHECKS = 0;

-- creating tables with primary keys, composite primary keys, and foreign keys
-- created one at a time, then imported the CSV file upon creating THAT table
-- Table: countries
create table countries (
    countrycode varchar(3) not null, 
    countryname varchar(45) not null,
    continent varchar(45) not null,
    primary key (countrycode)
);

-- Table: organizations
create table organizations(
	OrgID int primary key,
    OrgName varchar(45),
    HeadquartersCountry varchar(3),
    OrgType varchar(45)
);

-- Table: launch_sites
create table launch_sites(
	SiteID int primary key,
    SiteName varchar(45),
    CountryCode varchar(3),
    Status varchar(45),
    foreign key (CountryCode) references countries(CountryCode)
);

-- Table: rockets
create table rockets(
	RocketID int primary key,
	RocketName varchar(45),
	OrgID int,
	PayloadCapacityKg int,
	OperationalStatus varchar(45),
	foreign key (OrgID) references organizations(OrgID)
);

-- Table: missions
create table missions(
	MissionID int primary key,
    MissionName varchar(45),
    RocketID int,
    SiteID int,
    Destination varchar(45),
    LaunchYear int,
    Outcome varchar(45),
    foreign key (RocketID) references rockets(RocketID),
    foreign key (SiteID) references launch_sites(SiteID)
);

-- Table: payloads
create table payloads(
	PayloadID int primary key,
    MissionID int,
    PayloadName varchar(45),
    PayloadType varchar(45),
    MassKg double,
    foreign key (MissionID) references missions(MissionID)
);


-- Testing all the tables / CSV files
select * from countries;
select * from organizations;
select * from launch_sites;
select * from rockets;
select * from missions;
select * from payloads;
-- ========================

-- 1) Retrieve the mission name, rocket name, organization name,
-- launch site name, destination, launch year, and outcome for
-- all space missions without using table aliases. Sort the results
-- in descending order by launch year and ascending order by mission name.
select missions.MissionName, missions.Destination, missions.LaunchYear,
missions.outcome, launch_sites.SiteName, organizations.Orgname, rockets.RocketName
from missions
join rockets on missions.RocketID = rockets.RocketID
join organizations on rockets.OrgID = organizations.OrgID
join launch_sites on launch_sites.SiteID = missions.SiteID
order by LaunchYear desc, MissionName asc;

-- 2) Retrieve the mission name, rocket name, payload name, payload type,
-- and payload mass (in kg) for all payloads launched in 2024 without using
-- table aliases. Sort the results in descending order by payload mass.
select missions.MissionName, rockets.RocketName, payloads.PayloadName,
payloads.PayloadType, payloads.MassKg
from payloads
join missions on payloads.MissionID = missions.MissionID
join rockets on missions.RocketID = rockets.RocketID
where missions.LaunchYear = 2024
order by payloads.MassKg desc;

-- 3) Retrieve all launch sites along with their matching mission names, rockets,
-- and launch years for missions that took place in 2024 without using table
-- aliases, ensuring that launch sites with no recorded 2024 missions still
-- appear in the results with null values for the mission fields. Sort the
-- results in alphabetical order by launch site name.
select launch_sites.sitename, missions.missionname,
rockets.rocketname, missions.launchyear
from launch_sites
left join missions on launch_sites.siteid = missions.siteid 
    and missions.launchyear = 2024
left join rockets on missions.rocketid = rockets.rocketid
order by launch_sites.sitename asc;

-- 4) Write a SQL query using a Common Table Expression (CTE) to calculate the
-- total payload mass (in kg) deployed by each organization across all missions
-- without using table aliases. Retrieve the organization name, headquarters
-- country, organization type, and total payload mass, and sort the results in
-- descending order by total payload mass.
with Org_Payload_Summary as (
    select rockets.OrgID, SUM(payloads.MassKg) as Total_Payload_Mass
    from payloads
    join missions on payloads.MissionID = missions.MissionID
    join rockets on missions.RocketID = rockets.RocketID
    group by rockets.OrgID
)
select organizations.OrgName, organizations.HeadquartersCountry,
    organizations.OrgType, org_payload_summary.Total_Payload_Mass
from organizations left join Org_Payload_Summary 
    on organizations.OrgID = Org_Payload_Summary.OrgID
order by Total_Payload_Mass desc;

-- 5) Write a SQL query using two separate Common Table Expressions (CTEs)—one to
-- calculate total missions by country code and another to calculate total payload
-- mass by country code without using table aliases. Then, combine these CTEs with
-- the countries table to display the country name, total number of missions, and
-- total payload mass (in kg). Sort the results in descending order by total payload mass.
with mission_counts as (select launch_sites.countrycode,
        COUNT(missions.missionid) as total_missions
    from launch_sites
    join missions on launch_sites.siteid = missions.siteid
    group by launch_sites.countrycode
),
payload_masses as (select launch_sites.countrycode,
        SUM(payloads.masskg) as total_payload_mass
    from launch_sites
    join missions on launch_sites.siteid = missions.siteid
    join payloads on missions.missionid = payloads.missionid
    group by launch_sites.countrycode
)
select countries.countryname,
    coalesce(mission_counts.total_missions, 0) as total_missions,
    coalesce(payload_masses.total_payload_mass, 0) as total_payload_mass
from countries
left join mission_counts on countries.countrycode = mission_counts.countrycode
left join payload_masses on countries.countrycode = payload_masses.countrycode
order by total_missions desc, total_payload_mass desc;
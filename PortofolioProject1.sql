--First thing first before copy the two CSV tables coviddeaths and covidvaccinations from
--my PC/local machine is to create them here in PostgreSQL : 

CREATE TABLE CovidDeaths (  iso_code VARCHAR (20),
				   continent TEXT,
				   location TEXT,
				   date	DATE,
				   population BIGINT,
				   total_cases INT,	
				   new_cases INT, 
				   new_cases_smoothed INT ,	
				   total_deaths INT ,	 
				   new_deaths DECIMAl,
				   new_deaths_smoothed DECIMAL,	
				   total_cases_per_million DECIMAL,	
				   new_cases_per_million DECIMAL,
				   new_cases_smoothed_per_million DECIMAL,	
				   total_deaths_per_million DECIMAL,
				   new_deaths_per_million DECIMAL,	
				   new_deaths_smoothed_per_million DECIMAL,
				   reproduction_rate DECIMAL,
				   icu_patients DECIMAL,	
				   icu_patients_per_million DECIMAL,
				   hosp_patients DECIMAL,
				   hosp_patients_per_million DECIMAL,
				   weekly_icu_admissions DECIMAL,
				   weekly_icu_admissions_per_million DECIMAL,
				   weekly_hosp_admissions DECIMAL,
				   weekly_hosp_admissions_per_million DECIMAL,
				   total_testsD DECIMAL	)	  
 
 
 --Test query created table CovidDeaths 
 
 SELECT * FROM CovidDeaths 
 
 CREATE TABLE CovidVaccinations (iso_code VARCHAR (20),	
                                 continent TEXT,
				 location TEXT,	
				 date DATE,	
				 total_tests NUMERIC,
				 new_tests NUMERIC,
				 total_tests_per_thousand DECIMAL,
				 new_tests_per_thousand	DECIMAL,
				 new_tests_smoothed NUMERIC,
				 new_tests_smoothed_per_thousand DECIMAL,
				 positive_rate DECIMAL,
				 tests_per_case DECIMAL,
				 tests_units TEXT,	
				 total_vaccinations NUMERIC,
				 people_vaccinated NUMERIC,
				 people_fully_vaccinated NUMERIC,
				 total_boosters	NUMERIC,
				 new_vaccinations NUMERIC,	
				 new_vaccinations_smoothed NUMERIC,	
				 total_vaccinations_per_hundred	DECIMAL,
				 people_vaccinated_per_hundred	DECIMAL,
				 people_fully_vaccinated_per_hundred DECIMAL,
				 total_boosters_per_hundred DECIMAL,
				 new_vaccinations_smoothed_per_million NUMERIC,	
				 new_people_vaccinated_smoothed	NUMERIC,
				 new_people_vaccinated_smoothed_per_hundred DECIMAL,
				 stringency_index DECIMAL,	
				 population_density DECIMAL,
				 median_age DECIMAL,
				 aged_65_older DECIMAL,  	
				 aged_70_older	DECIMAL,
				 gdp_per_capita	DECIMAL,
				 extreme_poverty DECIMAL,	
				 cardiovasc_death_rate DECIMAL,
				 diabetes_prevalence DECIMAL,
				 female_smokers DECIMAL,
				 male_smokers DECIMAL,	
				 handwashing_facilities	DECIMAL,
				 hospital_beds_per_thousand DECIMAL,
				 life_expectancy DECIMAL,	
				 human_development_index DECIMAL,
				 excess_mortality_cumulative_absolute DECIMAL,
				 excess_mortality_cumulative DECIMAL,
				 excess_mortality DECIMAL,
				 excess_mortality_cumulative_per_million DECIMAL )
 	
--Test query created table covidvaccinations

SELECT * FROM covidvaccinations

SELECT * FROM coviddeaths
ORDER BY 3,4 ;

--Select Data that are going to be using 

SELECT location,date, total_cases,new_cases,total_deaths,population 
FROM coviddeaths 
ORDER BY 1,2

--Looking total_cases versus total_deaths
--This percentage shows the dying probability in each country if you contact covid desease
SELECT DISTINCT location,date, total_cases,total_deaths,
(total_deaths/total_cases) * 100 AS percentage_of_daily_deaths_by_cases
FROM coviddeaths 
WHERE total_cases IS NOT NULL AND total_deaths IS NOT NULL --AND location = 'Romania'
ORDER BY 1,2

--Looking the total covid cases versus population
--Shows what percentage of population got covid

SELECT DISTINCT location,date,population, total_cases,
(total_cases/population) * 100 AS percentage_of_daily_cases_by_population 
FROM coviddeaths 
WHERE total_cases IS NOT NULL AND population IS NOT NULL --AND location = 'Romania'
ORDER BY 1,2

--Looking at the countries with highest rate of infection compared to population

SELECT location,population,MAX(total_cases) AS highest_infection_no_cases,
MAX((total_cases/population)) * 100 AS max_infection_rate 
FROM coviddeaths 
WHERE total_cases IS NOT NULL AND population IS NOT NULL 
GROUP BY location,population
ORDER BY max_infection_rate DESC

--Looking at the countries with the highest total_deaths 

SELECT location,MAX(total_deaths)AS highest_total_deaths
FROM coviddeaths 
WHERE total_deaths IS NOT NULL AND population IS NOT NULL AND location IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY highest_total_deaths DESC


SELECT location AS continent,MAX (total_deaths) highest_continent_deaths FROM coviddeaths
WHERE continent IS NULL AND location IS NOT NULL 
GROUP BY location
ORDER BY highest_continent_deaths DESC

--Establish maximum total deaths excepting the North America Continent by population 

SELECT continent, MAX(total_deaths) highest_continent_deaths FROM coviddeaths
WHERE continent <> 'North America'AND (location IS NOT NULL AND continent IS NOT NULL )
GROUP BY continent

--Establish maximum total deaths on the North America Continent by population 

SELECT continent, SUM ( max_total_deaths_north_america) max_total_death
FROM ( SELECT continent,location, MAX (total_deaths) max_total_deaths_north_america FROM coviddeaths
WHERE continent = 'North America'
GROUP BY location,continent )s
GROUP BY s.continent

--Looking at the continents with the hightest total_deaths 

SELECT continent, MAX(total_deaths) highest_continent_deaths FROM coviddeaths
WHERE continent <> 'North America'AND (location IS NOT NULL AND continent IS NOT NULL )
GROUP BY continent

UNION ALL

SELECT continent, SUM(max_total_deaths_north_america) AS max_total_death
FROM (
    SELECT continent, location, MAX(total_deaths) AS max_total_deaths_north_america
    FROM coviddeaths
    WHERE continent = 'North America'
    GROUP BY location, continent
) AS s
GROUP BY s.continent
ORDER BY highest_continent_deaths DESC;

--Looking at the countries with the hightest total_deaths 
--Shows Countries with hightest death rate reported to the highest total_deaths

SELECT location,MAX(total_deaths)AS highest_total_deaths_each_country,
MAX((total_deaths/population) )* 100 AS mortality_rate 
FROM coviddeaths 
WHERE total_deaths IS NOT NULL AND population IS NOT NULL-- AND location = 'World'
GROUP BY location
ORDER BY mortality_rate DESC

--Global number for highest death number

SELECT 'world' AS continent,
SUM (highest_continent_deaths ) AS world_highest_death
INTO world_info_covid FROM ( SELECT continent, MAX(total_deaths) highest_continent_deaths FROM coviddeaths
WHERE continent <> 'North America'AND (location IS NOT NULL AND continent IS NOT NULL )
GROUP BY continent

UNION ALL

SELECT continent, SUM(max_total_deaths_north_america) AS max_total_death
FROM (
    SELECT continent, location, MAX(total_deaths) AS max_total_deaths_north_america
    FROM coviddeaths
    WHERE continent = 'North America'
    GROUP BY location, continent
) AS s
GROUP BY s.continent
ORDER BY highest_continent_deaths DESC )AS subquery;

SELECT * FROM world_info_covid 

--Global numbers for total cases ,for total deaths and for total daily rate o deaths

SELECT date, SUM (new_cases) AS total_daily_world_cases,SUM (new_deaths) AS total_daily_world_deaths,
(SUM(new_deaths)/SUM(new_cases))* 100 AS total_daily_death_world_rate FROM coviddeaths
WHERE continent IS NOT NULL AND new_cases!=0 AND new_deaths !=0
AND date <> '2020-01-05'
GROUP BY date
ORDER BY 1;

--Global numbers for entire period 

SELECT SUM (new_cases) AS total_world_cases,SUM (new_deaths) AS total_world_deaths,
(SUM(new_deaths)/SUM(new_cases))* 100 AS total_world_deaths_rate FROM coviddeaths
WHERE continent IS NOT NULL AND new_cases!=0 AND new_deaths !=0
AND date <> '2020-01-05';

--Looking at total population versus vaccinations on location /continent by date 

SELECT DISTINCT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations 
,ROUND (((SUM (vac.new_vaccinations) OVER ( PARTITION BY dea.location ) )/4),0 ) AS total_vaccinations_by_location
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent IS NOT NULL AND dea.location IS NOT NULL AND vac.new_vaccinations IS NOT NULL 
ORDER BY 2,3 ;


CREATE TABLE PercentPopulationVaccinated (continent TEXT,
										  location TEXT,
										  population NUMERIC,
										  date DATE,
										 total_vaccinations_by_location NUMERIC,
										 vaccinations_rate NUMERIC (20,2) )

INSERT INTO PercentPopulationVaccinated 

--Looking at the total population of each location/country and the vaccination_rate by location

SELECT s.continent,s.location,s.population,s.date,s.total_vaccinations_by_location,
ROUND ((( s.total_vaccinations_by_location/s.population)*100),2) AS vaccinations_rate
FROM (SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations 
,ROUND (((SUM (vac.new_vaccinations) OVER ( PARTITION BY dea.location ) )/4),0 ) AS total_vaccinations_by_location
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent IS NOT NULL AND dea.location IS NOT NULL AND vac.new_vaccinations IS NOT NULL 
AND dea.population IS NOT NULL
ORDER BY 2,3 ) s
WHERE s.population <> 0 AND s.total_vaccinations_by_location <> 0;

--Creating Views for Store Data for later visualizations :

CREATE VIEW view_PercentPopulationVaccinated AS
SELECT s.continent,s.location,s.population,s.date,s.total_vaccinations_by_location,
ROUND ((( s.total_vaccinations_by_location/s.population)*100),2) AS vaccinations_rate
FROM (SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations 
,ROUND (((SUM (vac.new_vaccinations) OVER ( PARTITION BY dea.location ) )/4),0 ) AS total_vaccinations_by_location
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent IS NOT NULL AND dea.location IS NOT NULL AND vac.new_vaccinations IS NOT NULL 
AND dea.population IS NOT NULL
ORDER BY 2,3 ) s
WHERE s.population <> 0 AND s.total_vaccinations_by_location <> 0;


SELECT * FROM view_PercentPopulationVaccinated 

--Global numbers for total cases ,for total deaths and for total daily rate o deaths

CREATE VIEW daily_deaths_world_rate AS 
SELECT date, SUM (new_cases) AS total_daily_world_cases,SUM (new_deaths) AS total_daily_world_deaths,
(SUM(new_deaths)/SUM(new_cases))* 100 AS total_daily_deaths_world_rate FROM coviddeaths
WHERE continent IS NOT NULL AND new_cases!=0 AND new_deaths !=0
AND date <> '2020-01-05'
GROUP BY date
ORDER BY 1;

--Looking at the countries with the highest total_deaths 
--Shows Countries with hightest death rate reported to the highest total_deaths

CREATE VIEW mortality_rate AS 
SELECT location,MAX(total_deaths)AS highest_total_deaths_each_country,
MAX((total_deaths/population) )* 100 AS mortality_rate 
FROM coviddeaths 
WHERE total_deaths IS NOT NULL AND population IS NOT NULL-- AND location = 'World'
GROUP BY location
ORDER BY mortality_rate DESC

--Looking at the continents with the hightest total_deaths 

CREATE VIEW Highest_Continent_Deaths AS 
SELECT continent, MAX(total_deaths) highest_continent_deaths FROM coviddeaths
WHERE continent <> 'North America'AND (location IS NOT NULL AND continent IS NOT NULL )
GROUP BY continent

--Looking total_cases versus total_deaths
--This percentage shows the dying probability in each country if you contact covid desease

CREATE VIEW Percentage_Of_DailyDeaths_by_Cases AS
SELECT DISTINCT location,date, total_cases,total_deaths,
(total_deaths/total_cases) * 100 AS percentage_of_daily_deaths_by_cases
FROM coviddeaths 
WHERE total_cases IS NOT NULL AND total_deaths IS NOT NULL --AND location = 'Romania'
ORDER BY 1,2

--Looking the total covid cases versus population
--Shows what percentage of population got covid

CREATE VIEW Percentage_Of_Daily_Cases_by_population AS
SELECT DISTINCT location,date,population, total_cases,
(total_cases/population) * 100 AS percentage_of_daily_cases_by_population 
FROM coviddeaths 
WHERE total_cases IS NOT NULL AND population IS NOT NULL --AND location = 'Romania'
ORDER BY 1,2

--Looking at the countries with highest rate of infection compared to population

CREATE VIEW Infection_rate AS 
SELECT location,population,MAX(total_cases) AS highest_infection_no_cases,
MAX((total_cases/population)) * 100 AS max_infection_rate 
FROM coviddeaths 
WHERE total_cases IS NOT NULL AND population IS NOT NULL 
GROUP BY location,population
ORDER BY max_infection_rate DESC

--Looking at the countries with the highest total_deaths 

CREATE VIEW highest_continent_deaths AS 
SELECT continent, MAX(total_deaths) highest_continent_deaths FROM coviddeaths
WHERE continent <> 'North America'AND (location IS NOT NULL AND continent IS NOT NULL )
GROUP BY continent

UNION ALL

SELECT continent, SUM(max_total_deaths_north_america) AS max_total_death
FROM (
    SELECT continent, location, MAX(total_deaths) AS max_total_deaths_north_america
    FROM coviddeaths
    WHERE continent = 'North America'
    GROUP BY location, continent
) AS s
GROUP BY s.continent
ORDER BY highest_continent_deaths DESC;



CREATE TABLE coviddeaths(
iso_code VARCHAR(50),
continent VARCHAR(50),	
location VARCHAR(200),
date DATE,	
population DECIMAL,
total_cases DECIMAL,
new_cases DECIMAL,
new_cases_smoothed DECIMAL,
total_deaths DECIMAL,	
new_deaths DECIMAL,	
new_deaths_smoothed DECIMAL,		
total_cases_per_million DECIMAL,	
new_cases_per_million DECIMAL,	
new_cases_smoothed_per_million DECIMAL,	
total_deaths_per_million	DECIMAL,
new_deaths_per_million DECIMAL,	
new_deaths_smoothed_per_million DECIMAL,	
reproduction_rate DECIMAL,
icu_patients DECIMAL,	
icu_patients_per_million	DECIMAL,
hosp_patients DECIMAL,	
hosp_patients_per_million	DECIMAL,
weekly_icu_admissions DECIMAL,	
weekly_icu_admissions_per_million	DECIMAL,
weekly_hosp_admissions DECIMAL,	
weekly_hosp_admissions_per_million DECIMAL
);

SELECT * FROM coviddeaths;

CREATE TABLE covidvac(
iso_code	 VARCHAR(50),
continent VARCHAR(50),	
location VARCHAR(200),
date DATE,	
new_tests BIGINT,	
total_tests BIGINT,	
total_tests_per_thousand DECIMAL,
new_tests_per_thousand DECIMAL,	
new_tests_smoothed BIGINT,	
new_tests_smoothed_per_thousand DECIMAL,	
positive_rate DECIMAL,	
tests_per_case DECIMAL,	
tests_units VARCHAR(200),	
total_vaccinations BIGINT,	
people_vaccinated BIGINT,	
people_fully_vaccinated BIGINT,	
total_boosters BIGINT,	
new_vaccinations	BIGINT,
new_vaccinations_smoothed	BIGINT,
total_vaccinations_per_hundred DECIMAL,	
people_vaccinated_per_hundred DECIMAL,	
people_fully_vaccinated_per_hundred DECIMAL,	
total_boosters_per_hundred DECIMAL,	
new_vaccinations_smoothed_per_million BIGINT,	
stringency_index	DECIMAL,
population_density DECIMAL,	
median_age DECIMAL,	
aged_65_older DECIMAL,	
aged_70_older DECIMAL,	
gdp_per_capita DECIMAL,	
extreme_poverty DECIMAL,	
cardiovasc_death_rate DECIMAL,	
diabetes_prevalence DECIMAL,	
female_smokers DECIMAL,	
male_smokers DECIMAL,	
handwashing_facilities DECIMAL,	
hospital_beds_per_thousand DECIMAL,	
life_expectancy	DECIMAL,
human_development_index DECIMAL,
excess_mortality_cumulative_absolute DECIMAL,	
excess_mortality_cumulative DECIMAL,	
excess_mortality	DECIMAL,
excess_mortality_cumulative_per_million DECIMAL
);

SELECT * FROM covidvac;

--total deaths vs total cases
SELECT location, date, total_cases, total_deaths,(total_deaths * 100/total_cases) AS deaths_percentage
FROM coviddeaths
WHERE location LIKE '%Kingdom%';

--countries with highest infection rate compared to population (percentage)
SELECT location, population, MAX(total_cases) AS highest_infection_count, (MAX(total_cases) * 100/population) AS infection_percentage
FROM coviddeaths
GROUP BY location, population
HAVING MAX(total_cases) IS NOT NULL
ORDER BY infection_percentage DESC;

--countries with highest death count (absolute value)
SELECT location, MAX (total_deaths) AS death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
HAVING MAX (total_deaths) IS NOT NULL
ORDER BY MAX (total_deaths) DESC;

--continents with highest death count (absolute value)
SELECT continent, MAX (total_deaths) AS death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
HAVING MAX (total_deaths) IS NOT NULL
ORDER BY MAX (total_deaths) DESC;

--global death rate each day
SELECT date, SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, (SUM(new_deaths)*100/SUM(new_cases)) AS total_death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_cases) IS NOT NULL
ORDER BY date;

--global total cases 
SELECT SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, (SUM(new_deaths)*100/SUM(new_cases)) AS total_death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL;

--joining two tables
SELECT * FROM covidvac
FULL OUTER JOIN coviddeaths
ON covidvac.location = coviddeaths.location
AND covidvac.date = coviddeaths.date

--accumulated number of vaccinated people
--with temp table
CREATE VIEW pop_vac AS
SELECT coviddeaths.continent,coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvac.new_vaccinations, SUM(covidvac.new_vaccinations)
OVER(PARTITION BY coviddeaths.location ORDER BY coviddeaths.location,coviddeaths.date) AS accu_people_vaccinated
FROM covidvac
FULL OUTER JOIN coviddeaths
ON covidvac.location = coviddeaths.location AND covidvac.date = coviddeaths.date
WHERE coviddeaths.continent IS NOT NULL;

SELECT *,(accu_people_vaccinated* 100 /population) * 100 AS accu_people_vaccinated_rate
FROM pop_vac;




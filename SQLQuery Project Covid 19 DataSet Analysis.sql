SELECT * FROM CovidDeaths
ORDER BY 3,4


--SELECT * FROM CovidVaccinations
--ORDER BY 3,4

SELECT LOCATION, DATE,
TOTAL_CASES, NEW_CASES, TOTAL_DEATHS, POPULATION
FROM CovidDeaths
ORDER BY 1,2

-- Looking at the Total Cases vs Total Deaths 
-- Sows the likelihood of dying if you contact COVID in the United states
SELECT LOCATION, DATE,
       TOTAL_CASES, TOTAL_DEATHS, 
       (CAST(Total_deaths AS float) / CAST(Total_cases AS float)) * 100 AS Death_Rate
FROM CovidDeaths
where location like '%states%'
ORDER BY 1, 2;


-- Looking at the total cases vs Population
--Shows what % of population got Covid

SELECT LOCATION, DATE,
       TOTAL_CASES, POPULATION, 
       (CAST(TOTAL_CASES AS float) / CAST(POPULATION AS float)) * 100 AS Infection_Rate
FROM CovidDeaths
order by 1,2 

-- Looking at countries with highest infection rates compared to population

SELECT LOCATION,
       max(TOTAL_CASES) TOTALCASES, POPULATION, 
       (CAST(max(TOTAL_CASES) AS float) / 
	   CAST(POPULATION AS float)) * 100 AS Infection_rate
FROM CovidDeaths
GROUP BY LOCATION, POPULATION
order by Infection_rate DESC

-- Countries with highest death count by population

SELECT LOCATION,
       max(CAST(total_deaths AS FLOAT)) TOTALDEATHS 
FROM CovidDeaths
where continent is not null--and location = 'Kenya'
GROUP BY LOCATION, POPULATION
order by TOTALDEATHS DESC

--Lets break things down by contintent

SELECT continent,
       max(CAST(total_deaths AS FLOAT)) TOTALDEATHS 
FROM CovidDeaths
where continent is not null--and location = 'Kenya'
GROUP BY continent
order by TOTALDEATHS DESC

--Showing continents with the highest death count per population

SELECT continent,
       max(CAST(total_deaths AS FLOAT)) TOTALDEATHS 
FROM CovidDeaths
where continent is not null--and location = 'Kenya'
GROUP BY continent
order by TOTALDEATHS DESC

-- Global numbers 
--Total  deathrate of new cases
SELECT DATE,
       SUM(NEW_CASES) AS TOTAL_NEW_CASES,
       SUM(CAST(NEW_deaths AS INT)) AS TOTAL_DEATHS,
       SUM(CAST(NEW_deaths AS FLOAT)) / NULLIF(SUM(CAST(New_cases AS FLOAT)), 0) * 100 AS DEATHRATE
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY DATE
ORDER BY 1;

--Total Cases 
SELECT --DATE,
       SUM(NEW_CASES) AS TOTAL_NEW_CASES,
       SUM(CAST(NEW_deaths AS INT)) AS TOTAL_DEATHS,
       SUM(CAST(NEW_deaths AS FLOAT)) / NULLIF(SUM(CAST(New_cases AS FLOAT)), 0) * 100 AS DEATHRATE
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY DATE
ORDER BY 1;

-- Total population vs vaccinations

select d.continent,d.location,d.date,
d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as float))over(partition by d.location 
order by d.location, d.date)rolling_people_vaccinated
from CovidVaccinations v
join CovidDeaths D
on v.location = D.location
and v.date = D.date
where d.continent is not null
order by 2,3

--USING CTE
WITH PopulationVsVaccination(continent, location, date,
population,new_vaccinations, rolling_people_vaccinated)
as
(
select d.continent,d.location,d.date,
d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as float))over(partition by d.location 
order by d.location,
d.date)rolling_people_vaccinated
from CovidVaccinations v
join CovidDeaths D
on v.location = D.location
and v.date = D.date
where d.continent is not null
--order by 2,3
)
SELECT *,(rolling_people_vaccinated/population)*100
FROM PopulationVsVaccination


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #PercentPopulationVaccinated
select d.continent,d.location,d.date,
d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as float))over(partition by d.location 
order by d.location,
d.date)rolling_people_vaccinated
from CovidVaccinations v
join CovidDeaths D
on v.location = D.location
and v.date = D.date
where d.continent is not null
--order by 2,3
select *, (rolling_people_vaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later Data Visualization

Create View PercentPopulationVaccinated as 
select d.continent,d.location,d.date,
d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as float))over(partition by d.location 
order by d.location,
d.date)rolling_people_vaccinated
from CovidVaccinations v
join CovidDeaths D
on v.location = D.location
and v.date = D.date
where d.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated
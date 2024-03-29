/* Covid 19 Data Exploration

used: Aggregate Functions, Converting Data Types, Joins, Windows Functions, CTEs, Temp Tables

*/

SELECT * FROM portfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


SELECT * FROM portfolioProjects..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4;



SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2;



--Total Deaths vs Total Cases (Likelihood of dying if you contract COVID)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deaths_In_Percentage
FROM  portfolioProjects..CovidDeaths
WHERE Location = 'Kenya'
order by 1,2;



--Total Cases vs Population (Percentage of population infected)
SELECT Location, date,population, total_cases, (total_cases/population)*100 AS percentageOfPopulationInfected
FROM  portfolioProjects..CovidDeaths
WHERE Location = 'Kenya'
order by 1,2;



--Countries with highest infection rates compared to the population
SELECT Location, population, MAX(total_cases) as highestInfection,   MAX((total_cases/population))*100 AS percentage_Of_Population_Infected
FROM	portfolioProjects..CovidDeaths
GROUP BY Location, population
order by percentage_Of_Population_Infected DESC


--Countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as Total_DeathCount 
FROM  portfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
order by Total_DeathCount DESC



--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int)) / SUM(new_cases)*100 AS Deaths_In_Percentage
FROM  portfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



--Continent with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as Total_Deaths
FROM  portfolioProjects..CovidDeaths
WHERE continent is not null
GROUP BY continent
order by Total_Deaths DESC


-- Total Population vs Vaccinations (Percentage of Population that has received at least one Covid Vaccine)

Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations
, SUM(CONVERT(bigint,vaccs.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as Total_Vaccinated
--, ((SUM(CONVERT(bigint,vaccs.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date))/population)*100
--as Percentage_Vaccinated
--, (Total_Vaccinated/population)*100
FROM portfolioProjects..CovidDeaths deaths
JOIN portfolioProjects..CovidVaccinations vaccs
	On deaths.location = vaccs.location
	and deaths.date = vaccs.date
where deaths.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVaccs(Continent, Location, Date, Population, new_vaccinations, Total_Vaccinated)
as 
(

--Total Population vs Vaccinations
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
SUM(CAST(vaccs.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location order by deaths.location, deaths.date) AS Total_Vaccinated --Sum new_vacss in each location and order by...
FROM portfolioProjects..CovidDeaths deaths JOIN
portfolioProjects..CovidVaccinations vaccs
	ON deaths.location = vaccs.location 
	AND deaths.date = vaccs.date
where deaths.continent IS NOT NULL
--and deaths.location = 'Kenya'
--order by 2, 3
)

SELECT *, (Total_Vaccinated/Population) * 100 as Percentage_Vaccinated FROM PopvsVaccs




--TEMP TABLE
DROP TABLE IF EXISTS #Percentage_Vaccinated

CREATE TABLE #Percentage_Vaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime
, Population numeric, new_vaccinations numeric, Total_Vaccinated numeric
)

INSERT INTO #Percentage_Vaccinated
--Total Population vs Vaccinations
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
SUM(CAST(vaccs.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location order by deaths.location, deaths.date) AS Total_Vaccinated --Sum new_vacss in each location and order by...
FROM portfolioProjects..CovidDeaths deaths JOIN
portfolioProjects..CovidVaccinations vaccs
	ON deaths.location = vaccs.location 
	AND deaths.date = vaccs.date
where deaths.continent IS NOT NULL 
--and deaths.location = 'Kenya'
--order by 2, 3

SELECT *, (Total_Vaccinated/Population) * 100 as Percentage_Vaccinated FROM #Percentage_Vaccinated




--Create Views: to store data for later visualizations
Create View PercentPopulation_Vaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations
, SUM(CONVERT(bigint,vaccs.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as Total_Vaccinated
---, (Total_Vaccinated/population)*100
FROM portfolioProjects..CovidDeaths deaths
JOIN portfolioProjects..CovidVaccinations vaccs
	On deaths.location = vaccs.location
	and deaths.date = vaccs.date
where deaths.continent is not null 
--order by 2,3

SELECT * FROM PercentPopulation_Vaccinated

CREATE View ContinentDeathCount as
SELECT continent, MAX(cast(total_deaths as int)) as Total_Deaths
FROM  portfolioProjects..CovidDeaths
WHERE continent is not null
GROUP BY continent
--order by Total_Deaths DESC


CREATE VIEW GlobalNumbers as 
--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int)) / SUM(new_cases)*100 AS Deaths_In_Percentage
FROM  portfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
--ORDER BY 1,2

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
order by 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population

FROM PortfolioProject.dbo.CovidDeaths
order by location, date

--Looking at Total Cases vs Total Deaths
--Shows the likehood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%South Africa%'
ORDER BY location, date

--Looking at Total cases vs Populations
--Shows what % got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%South Africa%'
ORDER BY location, date

--Looking at countries with the highest infection rate vs population

SELECT location, population, MAX(total_cases) AS Highest_cases, MAX((total_cases/population)) *100 AS PercentagePopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
----WHERE location <> 
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--Showing countries with highest Death Count per population

SELECT
location, MAX(CAST (total_deaths AS INT)) AS TotalDeathCount

FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing Countries with highest death percentage

SELECT
location, population, MAX(total_deaths) AS All_Deaths, MAX((total_deaths/population)) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP by location, population
ORDER BY DeathPercentage DESC

-- Showing breakdown by continent WITH HIGHEST DEATHCOUNT

SELECT
continent, MAX(CAST (total_deaths AS INT)) AS TotalDeathCount

FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS Death_Percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac	
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac	
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE

CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac	
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated


--CREATE VIEW

CREATE VIEW PPV as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac	
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


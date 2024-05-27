
SELECT *
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY date

--SELECT *
--FROM PortafolioProject..CovidVaccinations
--ORDER BY date

-- Select Data that we are going to be using.
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Looking at Total Cases vs Total Deaths
-- Shows likehood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortafolioProject..CovidDeaths
WHERE location = 'Venezuela' --LIKE '%venezuela%'
AND continent IS NOT NULL
ORDER BY location, date

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortafolioProject..CovidDeaths
WHERE location = 'Venezuela' --LIKE '%venezuela%'
AND continent IS NOT NULL
ORDER BY location, date

-- Looking at countries with highest infaction rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 
AS PercentPopulationInfected
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Looking at countries with highest infaction rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 
AS PercentPopulationInfected
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

--SELECT location, MAX(total_deaths) AS TotalDeathCount
--FROM PortafolioProject..CovidDeaths
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC

-- Showing the continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(total_cases) AS total_cases, SUM(total_deaths) AS total_deaths, SUM(total_deaths) / SUM(total_cases) * 100 AS DeathPercentage
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- COVID VACCINATIONS

-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM PortafolioProject..CovidDeaths AS dea
JOIN PortafolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2, 3



-- USE CTE
WITH PopVsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM PortafolioProject..CovidDeaths AS dea
JOIN PortafolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
--	ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM PopVsVac
--WHERE Location = 'Venezuela'

-- USE TEMP TABLES

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM PortafolioProject..CovidDeaths AS dea
JOIN PortafolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
--	ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated


-- Creating View to Store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
	FROM PortafolioProject..CovidDeaths AS dea
	JOIN PortafolioProject..CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated


SELECT *
FROM dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4;

/* SELECT Data that we are going to be using */
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths$
WHERE continent is not null 
ORDER BY 1,2;

/* Total Cases vs Total Deaths 
Shows liklihood of dying if you contract Covid in your country */
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage 
FROM dbo.CovidDeaths$
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2;

/* Total Cases vs Population 
Shows percentage of population that got Covid */
SELECT location, date, population, total_cases, (total_cases / Population) * 100 AS PercentPopulatonInfected
FROM dbo.CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2;

/*Countries with highest infection rate compared to Population */
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))* 100 AS PercentPopulatonInfected
FROM dbo.CovidDeaths$
GROUP BY population, location
ORDER BY PercentPopulatonInfected DESC;

/*Countries with the Highest death count per population */
SELECT location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY  location
ORDER BY TotalDeathCount DESC;



/* Break things down by Continent
Shows contintents with the highest death count per population*/
SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;



/* Global Numbers */
SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_NewDeaths, SUM(CAST(New_deaths AS INT))/SUM(new_cases)*100 AS  DeathPercentage
FROM dbo.CovidDeaths$
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;



/* Total Population vs Vaccinations
Shows Percentage of Population that has recieved at least one Covid Vaccination */

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(INT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths$ AS Dea
JOIN dbo.CovidVaccinations$ AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2,3;

--Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(INT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.location, Dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths$ AS Dea
JOIN dbo.CovidVaccinations$ AS Vac
	ON dea.location = vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;

/* Temp Tables */
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
DATE DATETIME, 
Population NUMERIC, 
New_vaccinations NUMERIC, 
RollingPeopleVaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated 
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(INT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.location, Dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths$ AS Dea
JOIN dbo.CovidVaccinations$ AS Vac
	ON dea.location = vac.location
	AND Dea.date = Vac.date
--WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

/* VIEW to store data for later visuals */

CREATE VIEW PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(INT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.location, Dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths$ AS Dea
JOIN dbo.CovidVaccinations$ AS Vac
	ON dea.location = vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3




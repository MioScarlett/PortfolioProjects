---- Let's select the data that we're going to be using ----

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid19..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


---- Looking at Total Cases vs Total Deaths -----
---- Shows likelihood of dying if you contract covid in your country ----

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Covid19..CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2


---- Looking at Total Cases vs Population -----
---- Shows percentage of population got Covid -----

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM Covid19..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

---- Looking at country with highest infection rate compared with population ----

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestInfectionRate
FROM Covid19..CovidDeaths
--WHERE location like '%vietnam%'
--WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC



---- Showing the country with highest death count per population -----


SELECT location, MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM Covid19..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC


---Let's break things down by continent
--- Shows the continent with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM Covid19..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--- GLOBAL	NUMBERS
-----per day

SELECT date, SUM(new_cases) as NewCases, SUM(CAST(new_deaths as int)) as NewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM Covid19..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-----total

SELECT SUM(new_cases) as NewCases, SUM(CAST(new_deaths as int)) as NewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM Covid19..CovidDeaths
WHERE continent is not null
ORDER BY 1,2



-----LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date	
WHERE dea.continent is not null
--and vac.new_vaccinations is not null
ORDER BY 2, 3

---- Using CTE

WITH PopVSVac AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date	
WHERE dea.continent is not null
--and vac.new_vaccinations is not null
)

SELECT *, RollingPeopleVaccinated/population*100
FROM PopVSVac


-----CREATE TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date	
--WHERE dea.continent is not null

SELECT *, RollingPeopleVaccinated/population*100
FROM #PercentPopulationVaccinated


----Creating View to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date	
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated
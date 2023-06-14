/**************QUERIES FOR TABLEAU PROJECTS*****************/

----1. Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
		SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Covid19..CovidDeaths


-----2. Total death count per continent. (not include world, European Union, International

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM Covid19..CovidDeaths
WHERE continent is null
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount 



-----3. Percent Population Infected each country

SELECT location, population, MAX(total_cases) as HighestInfectionCount, ROUND(MAX(total_cases)/population*100,2) as PercentPopulationInfected
FROM Covid19..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-----4. Percent Population Infected each country per date

SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, ROUND(MAX(total_cases)/population*100,2) as PercentPopulationInfected
FROM Covid19..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc

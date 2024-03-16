/* Data Exploration */

SELECT *
FROM PortfolioProyect..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProyect..CovidVaccinations
--ORDER BY 3, 4

-- Lookin at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your contry (ARREGLAR)

 SELECT Location, date, total_cases, total_deaths, (cast(total_deaths as int)/cast(total_cases as int))*100 as DeathsPercentage
FROM PortfolioProyect..CovidDeaths
WHERE location like '%arg%' AND continent is not null
ORDER BY 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location, date, Population, total_cases, total_deaths, (cast(total_cases as int)/population)*100 as CovidPercentage
FROM PortfolioProyect..CovidDeaths
WHERE location like '%arg%' AND continent is not null
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProyect..CovidDeaths
--WHERE location like '%arg%'
WHERE continent is not null
GROUP BY location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, Population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProyect..CovidDeaths
--WHERE location like '%arg%'
WHERE continent is not null
GROUP BY location, Population
ORDER BY TotalDeathCount DESC

-- Let´s break thing down by continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProyect..CovidDeaths
--WHERE location like '%arg%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS (ARREGLAR)

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 as DeathPercentage
FROM PortfolioProyect..CovidDeaths
--WHERE location like '%arg%' 
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

-- Looking at Total Population vs Vaccinations (BIGIN es cuando tenes un dato mayor)

SELECT dea.continent, dea.location, dea.date, dea.population, CONVERT(bigint, vac.new_vaccinations)
	, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
FROM PortfolioProyect..CovidDeaths dea
Join PortfolioProyect..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- Use CTE

With PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, CONVERT(bigint, vac.new_vaccinations)
	, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
FROM PortfolioProyect..CovidDeaths dea
Join PortfolioProyect..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

)
--ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE (Sin # como nombre de tabla)

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, CONVERT(bigint, vac.new_vaccinations)
	, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
FROM PortfolioProyect..CovidDeaths dea
Join PortfolioProyect..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, CONVERT(bigint, vac.new_vaccinations) as New_vaccinations
	, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
FROM PortfolioProyect..CovidDeaths dea
Join PortfolioProyect..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated

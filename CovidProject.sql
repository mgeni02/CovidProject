/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
From CovidProject..CovidDeaths
Order by 3


--Looking at total cases vs total deaths in one country i.e Cyprus
SELECT location, date ,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM CovidProject..CovidDeaths
WHERE location = 'Cyprus'
Order by 2 DESC

--Look at Total cases vs population
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM CovidProject..CovidDeaths



--Looking at countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestCovidCases, MAX((total_cases/population)*100) as InfectedPercentage
FROM CovidProject..CovidDeaths
Group By location, population
Order by InfectedPercentage DESC

--Showing countries with the highest deathcount 
SELECT location, MAX(cast(total_deaths as int)) as HighestCovidDeaths 
FROM CovidProject..CovidDeaths
WHERE continent is not Null
Group By location
Order By 2 DESC

--Break it down by continent
-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as HighestCovidDeaaths
FROM CovidProject..CovidDeaths
WHERE continent is not null
Group by continent
Order By 2 DESC

--Global numbers

SELECT SUM(new_cases) as Total_cases, SUM(cast (new_deaths as int)) as Total_deaths, (SUM(new_cases)/SUM(cast (new_deaths as int)))*100 as DeathPercentage
FROM CovidProject..CovidDeaths
Where continent is not null


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidProject..CovidDeaths dea 
Join CovidProject..CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
Order By 1,2,3 

--Use a CTE to perform previous calculations

With PopsVac(Continent, Location, Date, Population, Vaccinations, RollingPeopleVaccinated) as
(
SELECT dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order By dea.location, dea.date) 
as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea 
Join CovidProject..CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopsVac
Order By 6 DESC

--Use a temp table to perform previous calcucation

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order By dea.location, dea.date) 
as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea 
Join CovidProject..CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View for later Visualizations

USE CovidProject
GO
CREATE VIEW PercentPopulationVaccinted AS
SELECT dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order By dea.location, dea.date) 
as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea 
Join CovidProject..CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
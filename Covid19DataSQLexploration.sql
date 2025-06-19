
/* 
Covid 19 SQL Data exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions,
Aggregate Functions, Creating Views, Converting Data Types

*/

-- Three operations below previewing data that we are going to be working with

Select *
From coviddeaths
Where continent is not null and continent != ''
order by 3,4;

Select Location, date, total_cases, new_cases, total_deaths, population
From coviddeaths
Where continent is not null and continent != ''
order by 1,2;

Select *
From covidvaccinations
Where continent is not null and continent != '';


-- Total Cases vs Total Deaths
-- Shows likelihood of death if contracting covid in country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From coviddeaths
where location like '%states%'
and continent is not null 
and continent != ''
order by 1,2;


-- Total Cases vs Population
-- Shows percentage of Population that contracted covid

Select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From coviddeaths
-- where location like '%states%', update location to fit specific need
order by 1,2;


-- Looking at countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
-- where location like '%states%'
group by Location, population 
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Location

Select Location, MAX(cast(total_deaths as UNSIGNED)) as TotalDeathCount
From coviddeaths
Where continent is not null and continent != ''
group by Location
order by TotalDeathCount desc;


-- Continents with Highest Death Count per Population

Select continent, MAX(cast(total_deaths as UNSIGNED)) as TotalDeathCount
From coviddeaths
Where continent is not null and continent != ''
group by continent
order by TotalDeathCount desc;

-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as UNSIGNED)) as TotalDeathCount
From coviddeaths
Where continent is not null and continent != ''
group by location
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)) / sum(new_cases)*100 as DeathPercentage
From coviddeaths
Where continent is not null and continent != ''
-- group by date
order by 1,2;


-- Joining both tables of Deaths and Vaccinations

select *
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
;


-- Total Population vs Vaccinations
-- Shows percentage of Populatoin that has at least one Covid Vaccination

select dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingCountofPeopleVac
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null and dea.continent != ''
order by 2,3 ; 


-- USE CTE to perform Calculation on Parition By using previous query

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingCountofPeopleVac)
as
(
select dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingCountofPeopleVac 
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null and dea.continent != ''
-- order by 2,3 
)
Select * (RollingCountofPeopleVac/Population)*100
From PopvsVac


-- Using Temp Table to peform Calculation on Partition using previous query

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingCountofPeopleVac numeric,
)

Insert into
select dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingCountofPeopleVac 
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
-- Where dea.continent is not null and dea.continent != ''
-- order by 2,3 

Select * (RollingCountofPeopleVac/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data 

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingCountofPeopleVac 
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null and dea.continent != '';
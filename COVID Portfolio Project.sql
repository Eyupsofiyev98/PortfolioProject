--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking At Total Cases and Total Deaths

select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Looking At Total Cases and Population
--Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases / population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2

-- Looking At Countries with Highest Infection Rate compated to population

select location, population, MAX(total_cases) as HighestInfectionCounts, MAX((total_cases / population)) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

select location, MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount DESC

-- let's Break Thinks By Continent


-- Shownig Continents with the Highest Death Count per Population

select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount DESC

--Global Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int)) /  SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- Looking At Total Population and Vacciantions

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopandVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated / population) * 100
from PopandVac

--TEMP TABLE

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date

select *, (RollingPeopleVaccinated / population) * 100
from #PercentPopulationVaccinated


-- Creating View to Story Data for Later Visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null


select * 
from PercentPopulationVaccinated
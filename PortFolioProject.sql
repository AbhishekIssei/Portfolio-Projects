/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From CovidDeaths 
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From CovidDeaths
-- where location ='India'
Where location like '%india%'
and continent is not null 
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, population,total_cases, (cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%india%'
Where continent is not null 
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, population,MAX(total_cases) as HighestInfectionCount, MAx((cast(total_cases as float)/cast(population as float))*100) as PercentPopulationInfected
From CovidDeaths
--Where location like '%india%'
Where continent is not null 
group by location,population
order by 4 desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%india%'
Where continent is not null 
group by location
order by 2 desc

-- Let's break things down by continent

-- Showing continents with highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%india%'
Where continent is not null 
group by continent
order by 2 desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Looking at Total population vs Vaccination

select dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations,sum(convert(float,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and dea.date=vac.date
Where dea.continent is not null 
order by 2,3

-- using cte

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

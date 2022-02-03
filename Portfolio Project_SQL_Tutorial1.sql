select *
from [Portfolio Project]..['Covid Deaths$']
order by 3,4

select *
from [Portfolio Project]..['Covid Vaccinations$']
order by 3,4

select *
from [Portfolio Project]..[covidpop]
where continent is not null
order by 3,4

select location, date, total_cases,new_cases, total_deaths, population
from [Portfolio Project]..covidpop
where continent is not null
order by 1,2

--looking at total cases vs total deaths
-- Shows likelihood of dying if you get COVID in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..covidpop
where location like '%India%'
order by 1,2

--Looking at Total Cases vs Population

select location, date, total_cases, population, (total_cases/population)*100 as percentagePopulationgotcovid
from [Portfolio Project]..covidpop
where location like '%India%'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectioncount, max((total_cases/population))*100 as percentagepopulationgotinfected
from [Portfolio Project]..covidpop
--where location like '%India%'
group by location, population
order by percentagepopulationgotinfected desc

--Showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..covidpop
where continent is not null
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..covidpop
where continent is NOT null
group by location
order by TotalDeathCount desc

--Shwoing the continent with highest death counts

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidPop
where continent is null
group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS

select  sum(new_cases)as Total_cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidPop
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations

select pop.continent, dea.location, dea.date, pop.population, pop.new_vaccinations
, sum(cast(pop.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPoepleVaccinated
from [Portfolio Project]..CovidPop pop
join [Portfolio Project]..['Covid Deaths$'] dea
on pop.location = dea.location
and pop.date = dea.date
where pop.continent is not null
and pop.new_vaccinations is not null
order by 2,3

--USE CTE to use rolling 

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select pop.continent, dea.location, dea.date, pop.population, pop.new_vaccinations
, sum(cast(pop.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPoepleVaccinated
from [Portfolio Project]..CovidPop pop
join [Portfolio Project]..['Covid Deaths$'] dea
on pop.location = dea.location
and pop.date = dea.date
where pop.continent is not null
and pop.new_vaccinations is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100 as 
from popvsvac



--TEMP TABLE

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
Rollingpopelevaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
select pop.continent, dea.location, dea.date, pop.population, pop.new_vaccinations
, sum(cast(pop.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPoepleVaccinated
from [Portfolio Project]..CovidPop pop
join [Portfolio Project]..['Covid Deaths$'] dea
on pop.location = dea.location
and pop.date = dea.date
where pop.continent is not null
--and pop.new_vaccinations is not null
--order by 2,3

select *, (Rollingpopelevaccinated/population)*100
from #PercentPopulationVaccinated
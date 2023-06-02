select * from [Portfolio Project].dbo.CovidDeaths$ order by 3,4;

--select * from [Portfolio Project].dbo.CovidVaccinations$ order by 3,4;

--select data that we are going to use

select location, date, total_cases, total_deaths,new_cases,population 
from [Portfolio Project].dbo.CovidDeaths$ 
order by 1,2;

--- looking for total cases vs total deaths- shows the liklihood of dying if you are contract covid in your country

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage 
from [Portfolio Project].dbo.CovidDeaths$ 
where location like '%Indi%'
order by 1,2;

-- looking total cases vs population

select location, date, population, total_cases ,(total_cases/population)*100 as cases_population
from [Portfolio Project].dbo.CovidDeaths$ 
--where location like '%Indi%'
order by 1,2;

-- looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as highest_infection_count , Max((total_cases/population)*100) as Infected_cases_population
from [Portfolio Project].dbo.CovidDeaths$ 
--where location like '%Indi%' and continent is not Null
group by location,population
order by Infected_cases_population desc;

--Showing the countries with the higeshst death count per population

select location,  MAX(cast(total_deaths as int )) as Total_death_count 
from [Portfolio Project].dbo.CovidDeaths$ 
--where location like '%Indi%' and 
where continent is not Null
group by location
order by Total_death_count desc;

-- Lets breakup data continent wise
--Showing the continent with the highest death count

select continent,  MAX(cast(total_deaths as int )) as Total_death_count 
from [Portfolio Project].dbo.CovidDeaths$ 
--where location like '%Indi%' and 
where continent is not Null
group by continent
order by Total_death_count desc;

--- Global numbers

select   sum(new_cases) as total_cases, sum(cast( new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from [Portfolio Project].dbo.CovidDeaths$ 
where continent is not null
--group by date
order by 1,2;

-- Using covid vacination table

select * from  [Portfolio Project].dbo.CovidVaccinations$;

--Usiing join on location and date


select dea.location , dea.continent , dea.date , dea.population , vac.new_vaccinations , SUM(cast(vac.new_vaccinations as int)) 
over (Partition  by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
	from [Portfolio Project].dbo.CovidDeaths$ dea
	join [Portfolio Project].dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--USE cte

with PopvsVac (continent, location, date, population , new_vaccination, rolling_people_vaccinations)
as
(
select dea.location , dea.continent , dea.date , dea.population , vac.new_vaccinations , SUM(cast(vac.new_vaccinations as int)) 
over (Partition  by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
	from [Portfolio Project].dbo.CovidDeaths$ dea
	join [Portfolio Project].dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rolling_people_vaccinations/population)*100
from PopvsVac


-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric,
);

insert into #PercentPopulationVaccinated
select dea.location , dea.continent , dea.date , dea.population , vac.new_vaccinations , SUM(cast(vac.new_vaccinations as int)) 
over (Partition  by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
	from [Portfolio Project].dbo.CovidDeaths$ dea
	join [Portfolio Project].dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
;

select *, (RollingPeopleVaccinated / population)*100
from #PercentPopulationVaccinated



--creating view later for data visualization

create view PercentPopulationVaccinated as 
select dea.location , dea.continent , dea.date , dea.population , vac.new_vaccinations , SUM(cast(vac.new_vaccinations as int)) 
over (Partition  by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
	from [Portfolio Project].dbo.CovidDeaths$ dea
	join [Portfolio Project].dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3









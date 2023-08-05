select *
from portfolioproject..coviddeaths
order by 2,3,4


select *
from portfolioproject..CovidVaccinations


delete
from portfolioproject..coviddeaths
where date = '2020-01-01 00:00:00.000' or date = '2020-01-02 00:00:00.000'







---------------------------------------------------------------------------------------------------------------------------------
--show chances getting infected with covid in any country (Infection Rate) datewise
---------------------------------------------------------------------------------------------------------------------------------
select location, date,population, total_cases,cast(total_cases as decimal)/cast(population as decimal)*100 as '%PopulationInfected'
from portfolioproject..coviddeaths
where continent is not null 
--where location like '%india%'
order by 1,2





---------------------------------------------------------------------------------------------------------------------------------
--show chances getting infected with covid in any country (Infection Rate) overall
---------------------------------------------------------------------------------------------------------------------------------
select location,population, max(cast(total_cases as decimal)) as MaxTotalCases,max(cast(total_cases as decimal))/cast(population as decimal)*100 as '%PopulationInfected'
from portfolioproject..coviddeaths
where continent is not null 
--where location like '%india%'
group by location,population
order by 4 desc




---------------------------------------------------------------------------------------------------------------------------------
--show chances of dying if you get infected with covid in any country datewise
---------------------------------------------------------------------------------------------------------------------------------
select location, date,population, total_cases,total_deaths, cast(total_deaths as decimal)/cast(total_cases as decimal)*100 as '%DeathsWithCases'
from portfolioproject..coviddeaths
where continent is not null 
--where location like '%india%'
order by 1,2




---------------------------------------------------------------------------------------------------------------------------------
--show chances of dying with covid in any country wrt Population
---------------------------------------------------------------------------------------------------------------------------------
select location as Country,Max(Population) as Population, 
						max(cast(total_deaths as int)) as MaxTotalDeaths,
						max(cast(total_deaths as int))/Max(Population) *100 as '%PopulationDeaths'
from portfolioproject..coviddeaths
where continent is not null 
group by location
order by 4 desc




---------------------------------------------------------------------------------------------------------------------------------
--GLOBAL DATAS 
---------------------------------------------------------------------------------------------------------------------------------
select dea.location as continent, 
		cast(population as decimal) Population,
		max(cast(total_cases as decimal)) as TotalCases, 
		max(cast(total_cases as decimal))/cast(population as decimal)*100 as'%PopulationInfected',
		max(cast(total_deaths as decimal)) as TotalDeaths, 
		max(cast(total_deaths as decimal))/cast(population as decimal)*100 as'%PopulationDeaths',
		max(cast(people_vaccinated as decimal)) as PeopleVaccinated,
		max(cast(people_vaccinated as decimal))/cast(population as decimal)*100 as'%PopulationVaccinated'
from portfolioproject..coviddeaths dea
join PortfolioProject..CovidVaccinations vac
		on dea.location=vac.location and
			dea.date=vac.date
where dea.continent is null 
		and 
		dea.location not like '%income%'and 
		dea.location not like'%world%'and
		dea.location not like '%union%'
group by dea.location,dea.population
order by 8




---------------------------------------------------------------------------------------------------------------------------------
--show chances of dying with covid on Earth datewise by using given world data
---------------------------------------------------------------------------------------------------------------------------------
select date,max(population) as GlobalPopulation, 
		max(cast(total_cases as int)) GlobalTotalCases,
		max(cast(total_cases as decimal))/cast(max(population) as decimal)*100 as '%PopulationInfected',
		max(cast(total_deaths as int)) GlobalTotalDeaths,
		max(cast(total_deaths as decimal))/cast(max(population) as decimal)*100 as '%PopulationDeaths',
		max(cast(total_deaths as decimal))/max(cast(total_cases as decimal))*100 as '%CasesDeaths'
from portfolioproject..coviddeaths
where location like '%world%'
group by date
order by 1




---------------------------------------------------------------------------------------------------------------------------------
----show chances of dying with covid on Earth datewise without using given world data
---------------------------------------------------------------------------------------------------------------------------------
select date, sum(cast(population as bigint)) as GlobalPopulation,
			sum(cast(total_cases as int)) as GlobalTotalCases, 
			sum(cast(total_cases as int))/cast((sum(cast(population as bigint ))) as decimal)*100 as '%PopulationInfected',
			sum(cast(total_deaths as int)) GlobalTotalDeaths,
			sum(cast(total_deaths as int))/cast((sum(cast(population as bigint ))) as decimal)*100 as '%PopulationDeaths',
			sum(cast(total_deaths as int))/sum(cast(total_cases as decimal))*100 as '%CasesDeaths'
from portfolioproject..coviddeaths
where continent is not null 
group by date
order by 1




---------------------------------------------------------------------------------------------------------------------------------
--Showing  % of people vaccinated of any country datewise
---------------------------------------------------------------------------------------------------------------------------------
select dea.continent, dea.location, dea.date, 
		population,new_vaccinations_smoothed,
		Sum(convert(bigint,vac.new_vaccinations_smoothed)) over (partition by dea.location order by dea.location, dea.date) as CumVaccinations,
		people_vaccinated/population*100 '%PeopleVaccinated'
from PortfolioProject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	on dea.location =vac.location and
		dea.date = vac.date
where dea.continent is not null --and dea.location like '%india%'
order by 2,3




---------------------------------------------------------------------------------------------------------------------------------
--Showing  % of people vaccinated by country
---------------------------------------------------------------------------------------------------------------------------------
select dea.location,
		case when (max(cast(population as bigint))) < (max(cast(people_vaccinated as bigint))) 
			then max(cast(people_vaccinated as bigint))  
			else max(cast(population as bigint))
		end as population,
		sum(cast(new_vaccinations_smoothed as bigint)) TotalVaccination,
		max(cast(people_vaccinated as bigint)) PeopleVaccinated,
		cast((max(cast(people_vaccinated as bigint))) as decimal)/cast(case when (max(cast(population as bigint))) < (max(cast(people_vaccinated as bigint))) 
																			then max(cast(people_vaccinated as bigint))  
																			else max(cast(population as bigint))
																			end as decimal)*100 '%PeopleVaccinated'
from PortfolioProject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	on dea.location =vac.location and
		dea.date = vac.date
where dea.continent is not null --and dea.location like '%india%'
group by dea.location
order by 5 desc




---------------------------------------------------------------------------------------------------------------------------------
--Showing  % of people vaccinated by country with CTE
---------------------------------------------------------------------------------------------------------------------------------
with PopVsVacc as
(select dea.continent, dea.location, dea.date, 
		population,new_vaccinations_smoothed,
		people_vaccinated,
		Sum(convert(bigint,vac.new_vaccinations_smoothed)) over (partition by dea.location order by dea.location, dea.date) as CumVaccinations
from PortfolioProject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	on dea.location =vac.location and
		dea.date = vac.date
where dea.continent is not null --and dea.location like '%india%'
)
select*, people_vaccinated/population*100 '%PeopleVaccinated'
from Popvsvacc order by 2,3




---------------------------------------------------------------------------------------------------------------------------------
--Showing  % of people vaccinated by country with TEMP table
---------------------------------------------------------------------------------------------------------------------------------
drop table if exists #PercentPeopleVaccinated
create table #PercentPeopleVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations_smoothed numeric,
people_vaccinated numeric,
cumvaccinations numeric)
insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date,
		dea.population,new_vaccinations_smoothed,
		people_vaccinated,
		Sum(convert(bigint,vac.new_vaccinations_smoothed)) over (partition by dea.location order by dea.location, dea.date) as CumVaccinations
from PortfolioProject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	on dea.location =vac.location and
		dea.date = vac.date
where dea.continent is not null --and dea.location like '%india%'

select *, people_vaccinated/population*100 as'%PeopleVaccinated'
from #PercentPeopleVaccinated order by 2,3




---------------------------------------------------------------------------------------------------------------------------------
--Creating a view to store data for later visualizations
---------------------------------------------------------------------------------------------------------------------------------
create view PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, 
		population,new_vaccinations_smoothed,
		Sum(convert(bigint,vac.new_vaccinations_smoothed)) over (partition by dea.location order by dea.location, dea.date) as CumVaccinations,
		people_vaccinated,
		people_vaccinated/population*100 '%PeopleVaccinated'
from PortfolioProject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	on dea.location =vac.location and
		dea.date = vac.date
where dea.continent is not null --and dea.location like '%india%'

select *
from PercentPeopleVaccinated


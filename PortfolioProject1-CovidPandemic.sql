select *
from PortfolioProject..covidDeaths
order by 3,4

--select *
-- from portfolioProject..VaccinationsCovid
--order by 3,4

--select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covidDeaths
order by 1,2

--looking at total cases vs total deaths
-- shows likelihood of dying if you contratct in Pakistan
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
where location like '%pakistan%'
order by 1,2

-- looking at total cases vs population
--shows what percentage of population got Covid

select location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
where location like '%pakistan%'
order by 1,2

--Looking at countries with highest rate compared to population

Select location , population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as percentagePopulationInfected
from PortfolioProject..covidDeaths
group by location, population
order by percentagePopulationInfected desc

--Let's break things down by continent
Select continent, max(cast( total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--showing continents with highest death count per population

Select continent, max(cast( total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global number

Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(CONVERT(float, new_deaths) / NULLIF(CONVERT(float, new_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
where continent is not null
group by date
order by 1,2



--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum (convert(bigint,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..VaccinationsCovid vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3 

--USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum (convert(bigint,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..VaccinationsCovid vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)

Select * , (RollingPeopleVaccinated/population) * 100
from PopvsVac



--Temp Table
Drop table if exists #percentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPoeopleVaccinated numeric,
)


Insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum (convert(bigint,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..VaccinationsCovid vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingPoeopleVaccinated/population)*100
From #PercentPopulationVaccinated




--creating view to store data for later visualizations

create view PercentPopulationVaccinatedResult as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum (convert(bigint,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..VaccinationsCovid vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinatedResult

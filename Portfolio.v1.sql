

Select *
From PorfolioProject..[CovidDeaths.v1]
Order by 3,4


Select *
From PorfolioProject..[CovidVaccinations.v1]
Order by 3,4


--Select Data that we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
From PorfolioProject..[CovidDeaths.v1]
Where Location like '%states%'
Order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PorfolioProject..[CovidDeaths.v1]
Where Location like '%states%'
Order by 1,2


--Looking at Total Cases Vs Population
--Shows what percentage of population got covid

Select Location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentagePopulationInfected
From PorfolioProject..[CovidDeaths.v1]
Where Location like '%states%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases), (CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, population), 0))*100 as PercentagePopulationInfected
From PorfolioProject..[CovidDeaths.v1]
--Where Location like '%states%'
Group by Location, Population
Order by PercentagePopulationInfected DESC


--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..[CovidDeaths.v1]
--Where Location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount DESC


--LETS BREAK THINGS DOWN BY CONTINENT

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..[CovidDeaths.v1]
--Where Location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount DESC

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..[CovidDeaths.v1]
--Where Location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..[CovidDeaths.v1]
--Where Location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount DESC


--GLOBAL NUMBERS

Select date, SUM(new_cases),-- total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PorfolioProject..[CovidDeaths.v1]
--Where Location like '%states%'
Where continent is not null
Group by date
Order by 1,2


select date,(new_cases) as total_case1, (new_deaths) as total_death1, (cast(new_deaths as int) /  NULLIF(cast(new_cases as int),0)*100) as DeathPercentage
From PorfolioProject.dbo.[CovidDeaths.v1]
Where continent is not null
order by 1,2


Select  SUM(cast(new_cases as int)), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))*100 as DeathPercentage
From PorfolioProject.dbo.[CovidDeaths.v1]
where continent is not null 
--Group By date
order by 1,2


-- Looking at Total Population Vs Vaccinations

Select *
From PorfolioProject..[CovidDeaths.v1] as dea
join PorfolioProject..[CovidVaccinations.v1] vac
	ON dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PorfolioProject..[CovidDeaths.v1] as dea
join PorfolioProject..[CovidVaccinations.v1] vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3

--Rolling Count
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERt(int, vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PorfolioProject..[CovidDeaths.v1] as dea
join PorfolioProject..[CovidVaccinations.v1] vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- USING CTE

With PopvsVac (Continent, Location, Date, Popilation,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERt(int, vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PorfolioProject..[CovidDeaths.v1] as dea
join PorfolioProject..[CovidVaccinations.v1] as vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Popilation)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccianations numeric,
RollingPeopleVaccinated numeric,
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PorfolioProject..[CovidDeaths.v1] as dea
join PorfolioProject..[CovidVaccinations.v1] as vac
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View #PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERt(int, vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PorfolioProject..[CovidDeaths.v1] as dea
join PorfolioProject..[CovidVaccinations.v1] as vac
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3


Select *
From #PercentPopulationVaccinated



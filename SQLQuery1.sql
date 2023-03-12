
-- Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject2..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
-- Shows the odds of death if one was to contract Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as Chance_of_Death
From PortfolioProject2..CovidDeaths
Where location like '%united states%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of the population got Covid
Select location, date, total_cases, population, (total_cases / population)*100 as Percentofinfected
From PortfolioProject2..CovidDeaths
where continent is not null
order by 1,2

-- Countries with the highest infection rate in comparison to its popualtion
Select location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases / population))*100 as Percentofinfected
From PortfolioProject2..CovidDeaths
where continent is not null
Group by location, population
order by Percentofinfected desc

-- Contries death total in desc order
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject2..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Continent with the highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject2..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as Chance_of_Death
From PortfolioProject2..CovidDeaths
Where continent is not null
Group by date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as Chance_of_Death
From PortfolioProject2..CovidDeaths
Where continent is not null
--Group by date
order by 1,2


-- Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject2..CovidDeaths dea
join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Part 2
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as Rollingpeoplevaccinated 
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--USING A CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) 
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated / Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) 
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated / Population)*100
From #PercentPopulationVaccinated 

--Creating Views for later Visualizations!

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

use	PortfolioProject2
Select*
From #PercentPopulationVaccinated


/*
Covid 19 Data Exploration 
*/

Select *
From PortfolioProject..Deaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Deaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Deaths
Where location like '%India'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..Deaths
Where location like '%india'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Deaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..Deaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..Deaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..Deaths
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, Convert(date, cd.Date)) as RollingPeopleVaccinated
From PortfolioProject..Deaths cd
Join PortfolioProject..Vaccination cv
	On cd.location = cv.location
	and cd.date = cv.date
where cv.new_vaccinations is not null
AND cd.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, Convert(date, cd.Date)) as RollingPeopleVaccinated
From PortfolioProject..Deaths cd
Join PortfolioProject..Vaccination cv
	On cd.location = cv.location
	and cd.date = cv.date
where cv.new_vaccinations is not null
AND cd.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, Convert(date, cd.Date)) as RollingPeopleVaccinated
From PortfolioProject..Deaths cd
Join PortfolioProject..Vaccination cv
	On cd.location = cv.location
	and cd.date = cv.date
where cv.new_vaccinations is not null
AND cd.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
From #PercentPopulationVaccinated
where location like '%India'




-- Creating View to store data for later visualizations
DROP View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, Convert(date, cd.Date)) as RollingPeopleVaccinated
From PortfolioProject..Deaths cd
Join PortfolioProject..Vaccination cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
select *
from PercentPopulationVaccinated


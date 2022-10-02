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

-- What is the impact of COVID19 globally?
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..Deaths
where continent is not null 
order by 1,2

-- How many people in a nation contracted the disease?
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Deaths
Group by Location, Population
order by PercentPopulationInfected desc

--Which nations have the highest mortality rate per population?
Select Location,year(date) as year, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..Deaths
Where continent is not null 
Group by Location, year(date)
order by TotalDeathCount desc

--What are your odds of dying if you contract the disease by your country?
Select Location,date, Population, MAX(total_cases) as HighestInfectionCount,MAX(total_deaths) as HighestDeathCount,  (MAX(total_deaths)/MAX(total_cases))*100 as MortalityRate
From PortfolioProject..Deaths
Group by Location, Population, date
order by MortalityRate desc

-- What are your chances of contracting the disease if you live in India?
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..Deaths
Where location = 'India'
order by 1,2

--What are your odds of dying in India if you contract the disease?
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Deaths
Where location = 'India'
and continent is not null 
order by 1,2

-- Which continent have the highest mortality rate per population?
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..Deaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--Lets talk about vaccination

-- How many people have received at least one Covid vaccine?
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, Convert(date, cd.Date)) as RollingPeopleVaccinated
From PortfolioProject..Deaths cd
Join PortfolioProject..Vaccination cv
	On cd.location = cv.location
	and cd.date = cv.date
where cv.new_vaccinations is not null
AND cd.continent is not null 
order by 2,3

-- How many people have received at least one Covid vaccine as a percentage of the population?
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


-- How many people have received at least one Covid vaccine as a percentage of the population?
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
--where location = 'India'

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


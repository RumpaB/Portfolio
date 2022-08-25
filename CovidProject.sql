SELECT * 
FROM PortfolioProject..covidDeaths
Where continent IS NOT NULL
Order BY 3,4

SELECT * 
FROM PortfolioProject..covidVaccination
Order BY 3,4

-- Select the data that we are going to be using

Select location, date, population, total_cases, new_cases, total_deaths
From PortfolioProject..covidDeaths
Where continent IS NOT NULL
Order By 1,2

-- Looking at total cases vs total deaths
--Shows likelihood of dying if u contract covid in USA

Select location, date,  total_cases,  total_deaths, (total_deaths/total_cases)* 100 AS death_percentage
From PortfolioProject..covidDeaths
Where location like '%states' AND continent IS NOT NULL
Order By 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid

Select location, date,population,   total_cases, (total_cases/ population)* 100 AS covid_case_percentage
From PortfolioProject..covidDeaths
Where location like '%states' 
Order By 1,2

--looking at countries highest infection rate

Select location,  population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/ population))*100 AS percentage_of_population_infected
From PortfolioProject..covidDeaths
Group By  location, population
Order By percentage_of_population_infected DESC

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..covidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count 

Select continent, MAX(cast(total_deaths as int)) AS total_death_count
From PortfolioProject..covidDeaths
Where continent IS NOT NULL
Group By  continent
Order By  total_death_count DESC

--Showing countries of North America with the highest death count

Select continent,location, MAX(cast(total_deaths as int)) AS total_death_count
From PortfolioProject..covidDeaths
Where continent IS NOT NULL
Group By  continent, location
having continent like'north%'
Order By  total_death_count DESC

-- GLOBAL NUMBERS PER DAY

Select  date, SUM(new_cases) AS total_covid_cases,  SUM(cast(new_deaths AS int)) AS covid_deaths, (SUM(cast(new_deaths AS int)) / SUM(new_cases ))*100 AS DeathPercentage 
From PortfolioProject..covidDeaths
Where continent IS NOT NULL
Group By date
Order By 1,2

-- GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS bigint)) Over( Partition By dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent IS NOT NUll
Order by 2,3

--Vaccinated vs Fully Vaccinated
Select location, Max(cast(people_vaccinated as bigint)) As Vaccinated, Max(cast(people_fully_vaccinated as bigint)) As FullyVaccinated
From PortfolioProject..covidVaccination
Group by location
Order by location

--Precentage of population fully vaccinated
Select dea.location, dea.population,  Max(cast(vac.people_vaccinated as bigint)) As Vaccinated, Max(cast(vac.people_fully_vaccinated as bigint)) As FullyVaccinated,
Max(cast(vac.people_fully_vaccinated as bigint)) /population *100 AS PercentageOfPopulationFullyVaccinated
From PortfolioProject..covidVaccination vac
Join PortfolioProject..covidDeaths dea
On vac.location = dea.location
Group by dea.location , dea.population
Order by dea.location

---- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Using CTE to perform Calculation on Partition By in previous query

With PopVsVac(continent, location,date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS bigint)) Over( Partition By dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent IS NOT NUll)

Select *, (RollingPeopleVaccinated/ population)* 100 AS PercentagePopulationVaccinated
From PopVsVac

-- Creating View to store data for later visualizations

Create View Percent_Population_Vaccinated AS
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS bigint)) Over( Partition By dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent IS NOT NUll
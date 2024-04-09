select *
from CovidDeaths

select *
from CovidVaccinations

select *
from CovidDeaths
order by 3,4

select *
from CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--Total Cases v. Total Deaths
--Likelihood of death if Covid is contracted
select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from CovidDeaths
Where location like '%states%'
order by 1,2

--View of likelihood of death if Covid is contracted
Create view LikelihoodOfDeathDueToCovid as
select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from CovidDeaths
Where location like '%states%'
--order by 1,2

--Total Cases v. Population
--The percentage of the population that contracted Covid
select location, date, total_cases, population, (total_cases/population) *100 as PercentageofPopulationContractedCovid
from CovidDeaths
Where location like '%states%'
order by 1,2

--View of the percentage of the population that contracted Covid
Create view PercentageOfPopulationContractedCovid as
select location, date, total_cases, population, (total_cases/population) *100 as PercentageofPopulationContractedCovid
from CovidDeaths
Where location like '%states%'
--order by 1,2


--Countries with Highest Infection Rates Compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as PercentageofPopulationInfected
from CovidDeaths
group by location, population
order by PercentageofPopulationInfected desc

--View of Countries with Highest Infection Rates Compared to Population
Create view HighestInfectedRates as
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as PercentageofPopulationInfected
from CovidDeaths
group by location, population
--order by PercentageofPopulationInfected desc

--Countries with Highest Covid Fatalities per Population
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--View of Countries with Higest Covid Fatality per Population
Create view CountriesWithHighestRatesofCovidFatalities as
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
--order by TotalDeathCount desc

--Continents with Highest Covid Fatalities per Population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCountbyContinent
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCountbyContinent desc

--View of Continents with Higest Covid Fatality per Population
Create view ContinentswithHighestRatesofCovidFatalities as
select continent, MAX(cast(total_deaths as int)) as TotalDeathCountbyContinent
from CovidDeaths
where continent is not null
group by continent
--order by TotalDeathCountbyContinent desc

--Locations with Highest Covid Fatalities per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCountbyLocation
from CovidDeaths
where continent is null
group by location
order by TotalDeathCountbyLocation desc

--View Locations with Highest Covid Fatalities per Population
Create View LocationsWithHighestCovidFatalities as
select location, MAX(cast(total_deaths as int)) as TotalDeathCountbyLocation
from CovidDeaths
where continent is null
group by location
--order by TotalDeathCountbyLocation desc

--Global Death Percentage
select SUM(new_cases)as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From CovidDeaths
Where continent is not null
--Group by date
order by 1,2

--View of Global Death Percentage
Create View GlobalDeathPercentage as
select SUM(new_cases)as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From CovidDeaths
Where continent is not null
--Group by date
--order by 1,2

--Vaccination by Population
Select death.continent, death.location, death.date, death.population, Vaccination.new_vaccinations
From CovidVaccinations Vaccination
join CovidDeaths Death
on Death.location = Vaccination.location
and Death.date = Vaccination.date
where vaccination.continent is not null
order by 2,3

--View  of Vaccination by Population
Create View VaccinationbyPopulation as
Select death.continent, death.location, death.date, death.population, Vaccination.new_vaccinations
From CovidVaccinations Vaccination
join CovidDeaths Death
on Death.location = Vaccination.location
and Death.date = Vaccination.date
where vaccination.continent is not null
--order by 2,3

--Count of New Vaccinations by Location
Select death.continent, death.location, death.date, death.population, Vaccination.new_vaccinations, SUM(cast(Vaccination.new_vaccinations as int)) OVER (Partition by death.location) as TotalVaccinations
From CovidVaccinations Vaccination
join CovidDeaths Death
on Death.location = Vaccination.location
and Death.date = Vaccination.date
where vaccination.continent is not null
order by 2,3

--View of Count of New Vaccinations by Location
Create View CountofNewVaccinationsbyLocation as
Select death.continent, death.location, death.date, death.population, Vaccination.new_vaccinations, SUM(cast(Vaccination.new_vaccinations as int)) OVER (Partition by death.location) as TotalVaccinations
From CovidVaccinations Vaccination
join CovidDeaths Death
on Death.location = Vaccination.location
and Death.date = Vaccination.date
where vaccination.continent is not null
--order by 2,3

--Count of New Vaccinations per Day (Rolling Count)
Select death.continent, death.location, death.date, death.population, Vaccination.new_vaccinations, SUM(cast(Vaccination.new_vaccinations as int))
OVER (Partition by death.location Order by death.location, death.date) as VaccinationsPerDay
From CovidVaccinations Vaccination
join CovidDeaths Death
on Death.location = Vaccination.location
and Death.date = Vaccination.date
where vaccination.continent is not null
order by 2,3

--View of Count of New Vaccinations per Day (Rolling Count)
Create View NewVaccinationsPerDay as
Select death.continent, death.location, death.date, death.population, Vaccination.new_vaccinations, SUM(cast(Vaccination.new_vaccinations as int))
OVER (Partition by death.location Order by death.location, death.date) as VaccinationsPerDay
From CovidVaccinations Vaccination
join CovidDeaths Death
on Death.location = Vaccination.location
and Death.date = Vaccination.date
where vaccination.continent is not null
--order by 2,3

--People Vaccinated: Population v. Vaccinations
Select death.continent, death.location, death.date, death.population, Vaccination.new_vaccinations, SUM(cast(Vaccination.new_vaccinations as int))
OVER (Partition by death.location Order by death.location, death.date) as VaccinationsPerDay
--We want to find the ppl vaccinated so either a TempTable or a CTE are in order to figure, (VaccinationsPerDay/death.population)*100
From CovidVaccinations Vaccination
join CovidDeaths Death
on Death.location = Vaccination.location
and Death.date = Vaccination.date
where vaccination.continent is not null
order by 2,3

--View of People Vaccinated: Population v. Vaccinations
Create View PeopleVaccinated as
Select death.continent, death.location, death.date, death.population, Vaccination.new_vaccinations, SUM(cast(Vaccination.new_vaccinations as int))
OVER (Partition by death.location Order by death.location, death.date) as VaccinationsPerDay
--We want to find the ppl vaccinated so either a TempTable or a CTE are in order to figure, (VaccinationsPerDay/death.population)*100
From CovidVaccinations Vaccination
join CovidDeaths Death
on Death.location = Vaccination.location
and Death.date = Vaccination.date
where vaccination.continent is not null
--order by 2,3


--Use CTE (number of columns in CTE must equal the amount of columns in the Select Statement)
With PopvVac (Continent, Location, Date, Population, New_Vaccinations, VaccinationsPerDay)
as
(
Select death.continent, death.location, death.date, death.population, Vaccination.new_vaccinations, SUM(CONVERT(int,Vaccination.new_vaccinations))
OVER (Partition by death.location Order by death.location, death.date) as VaccinationsPerDay
--We want to find the ppl vaccinated so either a TempTable or a CTE are in order to figure, (VaccinationsPerDay/death.population)*100
From CovidVaccinations Vaccination
join CovidDeaths Death
on Death.location = Vaccination.location
and Death.date = Vaccination.date
where vaccination.continent is not null
--order by 2,3
)
Select *,(VaccinationsPerDay/Population)*100 as PplVaccinated
From PopvVac

--Maximum Vaccinations by Location CTE (Come back to complete)


--Temp Table
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationsPerDay numeric,
)

Insert into #PercentagePopulationVaccinated
Select death.continent, death.location, death.date, death.population, Vaccination.new_vaccinations, SUM(CONVERT(int,Vaccination.new_vaccinations))
OVER (Partition by death.location Order by death.location, death.date) as VaccinationsPerDay
--We want to find the ppl vaccinated so either a TempTable or a CTE are in order to figure, (VaccinationsPerDay/death.population)*100
From CovidVaccinations Vaccination
join CovidDeaths Death
on Death.location = Vaccination.location
and Death.date = Vaccination.date
where vaccination.continent is not null
--order by 2,3

Select *,(VaccinationsPerDay/Population)*100 as PplVaccinated
From #PercentagePopulationVaccinated

--Percentage of Population Vaccinated
Create View PercentagePopulationVaccinated as
Select death.continent, death.location, death.date, death.population, Vaccination.new_vaccinations, SUM(CONVERT(int,Vaccination.new_vaccinations))
OVER (Partition by death.location Order by death.location, death.date) as VaccinationsPerDay
--We want to find the ppl vaccinated so either a TempTable or a CTE are in order to figure, (VaccinationsPerDay/death.population)*100
From CovidVaccinations Vaccination
join CovidDeaths Death
on Death.location = Vaccination.location
and Death.date = Vaccination.date
where vaccination.continent is not null
--order by 2,3

--Views will be stored for Visualization use

--Truncate table 
Select *
from PortfolioProject..CovidDeaths
Where Continent is not null
Order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--Order by 3,4

Use PortfolioProject
Select top 5 * from CovidDeaths
where total_deaths is not null

--Select Data that we are going to be using
Select 
Location, 
date,
total_cases,
new_cases,
total_deaths,
population
from PortfolioProject..CovidDeaths
Order by 1,2


--Looking at Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select 
Location, 
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as 'Percentage of Deaths Over Total Cases'
from PortfolioProject..CovidDeaths
Where Location like '%States%'
Order by 1,2

--Looking at Total Cases vs Population
--Shows the percentage of population that has contracted Covid from day to day.
Select 
Location, 
date,
Population,
total_cases,
(total_cases/population)*100 as 'Percentage of Total Cases Over Entire Population'
from PortfolioProject..CovidDeaths
Where Location like '%States%'
Order by 2


--Location with highest to lowest infection rates
--Showing Percent of Infected Population from highest to lowest.
Select Location,
Population,
Max(total_Cases) AS Infection_Rates_In_Descending_Order,
Max(Total_cases/population)*100 as Percent_Of_Infected_Population
From CovidDeaths
Where Location <>'World'
group by Location,population
Order by Percent_Of_Infected_Population DESC, Max(total_Cases) DESC



--Select 
--Location,
--Population,
--Convert(int,Max(total_deaths)) AS Death_Rates_In_Descending_Order,
--(Convert(int,Max(total_deaths))/population)*100 as Percentage_Of_Deaths_Over_Population
--From CovidDeaths
--Where Location <>'World'
--group by Location,population
--Order by Death_Rates_In_Descending_Order DESC


--Showing Countries with Highest Death Count per Population
Select 
Location,
Max(cast(total_deaths as int)) as Death_Rates_In_Descending_Order
--Max(convert(int,total_deaths)) as Death_Rates_In_Descending_Order_Convert
From CovidDeaths
Where Continent is not null
group by Location
Order by Death_Rates_In_Descending_Order DESC


--Let's break things down by Location
--Specifically we want to see 
Select 
Location,
Max(cast(total_deaths as int)) as Death_Rates_In_Descending_Order
--Max(convert(int,total_deaths)) as Death_Rates_In_Descending_Order_Convert
From CovidDeaths
Where Continent is null
group by Location
Order by Death_Rates_In_Descending_Order DESC



Select 
Continent,
Max(cast(total_deaths as int)) as Death_Rates_In_Descending_Order
--Max(convert(int,total_deaths)) as Death_Rates_In_Descending_Order_Convert
From CovidDeaths
Where Continent is not null
group by Continent
Order by Death_Rates_In_Descending_Order DESC

--Use PortfolioProject
--Global Numbers
--Showing % of New Deaths Over New Cases
Select 
--date, --We can include or exclude the date column to analyze.
Sum(New_Cases) As Total_of_New_Cases_Per_Date,
Sum(cast (New_deaths as int)) as Total_Of_New_Deaths_Per_Date,
(Sum(cast (New_deaths as int))/Sum(New_Cases))*100 As '% of New Deaths Over New Cases'
from PortfolioProject..CovidDeaths
--Where Location like '%States%'
Where continent is not null
--Group by date
Order by 1,2


--Looking at Total Population Vs Vaccinations

Select
dea.Location,
population,
Count(people_fully_vaccinated) as Num_folks_fully_vaccinated,
Count(people_vaccinated) as Folks_Received_vaccine
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.Location like '%States%'
Group by dea.Location,
population


--Some additions here.
--Subquery
Select Top 10
continent,
Location,
date,
population,
Num_folks_newly_vaccinated,
(RollingPeopleVaccinated/population)*100
from(
Select
dea.continent,
dea.Location,
dea.date,
population,
new_vaccinations as Num_folks_newly_vaccinated,
Sum(cast(New_Vaccinations as int)) Over 
(Partition by dea.Location Order by dea.Location,dea.Date) As RollingPeopleVaccinated
--Count(people_vaccinated) as Folks_Received_vaccine
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	--Where dea.Location like '%States%'
	Where dea.continent is not null
	--And dea.location='Canada'
	And dea.continent='Europe'
) as Table1
Where Num_folks_newly_vaccinated <>''
Order by 2,3


--USE CTE
With CTE as
(Select
dea.continent,
dea.Location,
dea.date,
population,
new_vaccinations as Num_folks_newly_vaccinated,
Sum(cast(New_Vaccinations as int)) Over 
(Partition by dea.Location Order by dea.Location,dea.Date) As RollingPeopleVaccinated
--Count(people_vaccinated) as Folks_Received_vaccine
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	--Where dea.Location like '%States%'
	Where dea.continent is not null
	--And dea.location='Canada'
	And dea.continent='Europe'
	and dea.Location='Albania')
Select
continent,
Location,
date,
population,
Num_folks_newly_vaccinated,
RollingPeopleVaccinated,
(RollingPeopleVaccinated/Population)*100  As '% of Rolling People Vaccinated'
from cte
Where Num_folks_newly_vaccinated <>''
Order by 2,3

Use PortfolioProject
Drop table if exists #VacineOverPopulation
--Temp Table
Select
dea.continent,
dea.Location,
dea.date,
population,
new_vaccinations as Num_folks_newly_vaccinated,
Sum(cast(New_Vaccinations as int)) Over 
(Partition by dea.Location Order by dea.Location,dea.Date) As RollingPeopleVaccinated
--Count(people_vaccinated) as Folks_Received_vaccine
into #VacineOverPopulation
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	--Where dea.Location like '%States%'
	Where dea.continent is not null
	--And dea.location='Canada'
	And dea.continent='Europe'
	and dea.Location='Albania'

	Select *,
	(RollingPeopleVaccinated/population)*100 
	from #VacineOverPopulation


	--Create View to store data for later visualizations
Drop table if exists #VacineOverPopulation
--Select * from #VacineOverPopulation
Drop View if exists PercentRollingPopul_Vaccinated
Create View PercentRollingPopul_Vaccinated as
Select
dea.continent,
dea.Location,
dea.date,
population,
new_vaccinations as Num_folks_newly_vaccinated,
Sum(cast(New_Vaccinations as int)) Over 
(Partition by dea.Location Order by dea.Location,dea.Date) As RollingPeopleVaccinated
--Count(people_vaccinated) as Folks_Received_vaccine
--into #VacineOverPopulation
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	--Where dea.Location like '%States%'
	Where dea.continent is not null
	--And dea.location='Canada'
	--And dea.continent='Europe'
	--and dea.Location='Albania'

Select *, 
(RollingPeopleVaccinated/population)*100 As RollingPercentVaccinated
From [dbo].[PercentRollingPopul_Vaccinated]
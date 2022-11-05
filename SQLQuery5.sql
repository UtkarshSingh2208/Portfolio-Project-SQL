--Select* from CovidDeaths
--Select* from PortfolioProject.dbo.CovidDeaths

Select* from PortfolioProject..CovidDeaths
Order by 3,4 --3rd and 4th column se order karega

--Q1. Total Cases vs Total Deaths
--Shows likelihood of dying
Select location, total_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
from CovidDeaths
order by 1,2

Select location, total_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
from CovidDeaths
--where location='India' --Using = operator for strings
--where location like '__di_' --using Wild Card
where location like 'i%dia'  --Using Wild Card
order by 1,2

--Q2. Total Cases vs Population
Select location, date, Population, total_cases, (total_cases/population)*100 as percentageInfected
from CovidDeaths
Order by 1,2

Select location, date, Population, total_cases, (total_cases/population)*100 as percentageInfected
from CovidDeaths
where location='India'
Order by 1,2 desc

--Q3. Total Cases vs Population. Find countries with highest infection rate.
Select location, date, Population, total_cases, (total_cases/population)*100 as percentageInfected
from CovidDeaths
Order by 5 desc

Select location, Population, Max(total_cases)as TotalCase, Max((total_cases/population)*100) as percentageInfected
from CovidDeaths
Group by location, population
Order by 4 desc

--Q3. Showing highest death count per population.
Select location, Population, Max(Cast (Total_Deaths as int)) as totalDeathCount, Max((Total_Deaths/population)*100) as percentageDied
from CovidDeaths
Group by location, Population
Order by 3 desc

/*Note: We had a problem after applying aggregate function "MAX" on totaldeaths it is showing a hell lot of 9's in the data. 
This kind of thing is common which occurs due to invalid data type of the field (Total_Deaths).
Hence, we had to cast the datatype of Total_deaths to int*/
/*In the location column mostly countries are there but at some places it is showing  continents which is making our answer wrong.
To avoid this we have checked the data once there were few errors in that. The error was places whose continent column is null
their location column is filled by the name of country. Hence, we are adding where clause to get rid of this.*/

Select location, Population, Max(Cast (Total_Deaths as int)) as totalDeathCount, Max((Total_Deaths/population)*100) as percentageDied
from CovidDeaths
Where continent is not null
Group by location, Population
Order by 4 desc

--Q4. Showing highest death count continent wise.
/*Select location, Max(Cast (Total_Deaths as int)) as totalDeathCount, Max((Total_Deaths/population)*100) as percentageDied
from CovidDeaths
Where continent is null
Group by location, Population
Order by 3 desc  */

--By coincidence sahi jaisa dikh rha hai. data galat hai. Try to think on this.

Select Continent, SUM(cast(new_cases as int))as totalCases, Sum(Cast(new_deaths as int)) as TotalDeaths--, Sum(Cast(new_deaths as int))/SUM(cast(new_cases as int)) as percentageDied
from CovidDeaths
Where continent is not Null
Group by Continent
Order by totaldeaths desc

--Q5. Showing death globally. Show date wise deaths, cases globally.
--It is showing datewise cases and deaths
Select date, sum(New_cases) as totalCases, Sum(Convert (int,new_deaths)) as totalDeathCount, Sum(Convert (int,new_deaths))/sum(New_cases)*100 as percentageDied
from CovidDeaths
Group by date
Having sum(New_cases)>0
Order by 1,2

--It is showing total deaths & cases till date
Select sum(New_cases) as totalCases, Sum(Convert (int,new_deaths)) as totalDeathCount, Sum(Convert (int,new_deaths))/sum(New_cases)*100 as percentageDied
from CovidDeaths
Having sum(New_cases)>0
Order by 1

--Q6. Joining both the tables .
Select * from CovidDeaths as dea
Join CovidVaccinations as vac
on dea.Date=vac.date
and dea.location=vac.location

--Q7. Total Vaccinations vs Total Population
Select dea.date, dea.location,dea.continent, dea.population,vac.new_vaccinations
from coviddeaths dea
join Covidvaccinations vac
on dea.date=vac.date
and dea.location=vac.location
Where dea.continent is not null
Order by location

--Adding a column to get an idea of total vaccinated people date wise

Select dea.date, dea.location,dea.continent, dea.population, vac.new_vaccinations, 
Sum (Cast (vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.date, dea.location ) as rollingPeopleVaccinated
from coviddeaths dea
join Covidvaccinations vac
on dea.date=vac.date
and dea.location=vac.location
Where dea.continent is not null
Order by location,date

--Q7. Add a column which says percentage of people vaccinated.
/*Problem with this is that, we can't use a newly created field to again create a new field (need to find why)
So, we can creat either a temp table or a CTE. add the newly constructed field as a column there and that can be further used once.*/

-- A) Use CTE
With Popvsvac
as 
(
Select dea.date, dea.location,dea.continent, dea.population, vac.new_vaccinations, 
Sum (Cast (vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.date, dea.location ) as rollingPeopleVaccinated
from coviddeaths dea
join Covidvaccinations vac
on dea.date=vac.date
and dea.location=vac.location
Where dea.continent is not null
--Order by location,date
)
--select * from popvsvac

select * , rollingPeopleVaccinated/population*100 as percentageVaccinated
from popvsvac


-- B) Use TEMP TABLE

Drop table if Exists #percentagePeopleVaccinated --Done to not show any error if we re run it.
Create Table #percentagePeopleVaccinated
(
date Datetime,
location nvarchar(255),
continent nvarchar(255),
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)
Insert into #percentagePeopleVaccinated
Select dea.date, dea.location,dea.continent, dea.population, vac.new_vaccinations, 
Sum (Cast (vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.date, dea.location ) as rollingPeopleVaccinated
from coviddeaths dea
join Covidvaccinations vac
on dea.date=vac.date
and dea.location=vac.location
Where dea.continent is not null

Select *,rollingPeopleVaccinated/population*100 as percentageVaccinated
from #percentagePeopleVaccinated

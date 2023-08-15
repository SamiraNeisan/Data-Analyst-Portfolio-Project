SELECT * FROM [PortfolioProject]..[CovidDeaths]
where continent <>''
ORDER BY 3,4

--SELECT * FROM [PortfolioProject]..[CovidVaccinations]
--ORDER BY 3,4

--select data that we are going to be using

SELECT location,DATE,total_cases,new_cases,total_deaths,population
FROM [PortfolioProject]..[CovidDeaths]
where continent <>''
ORDER BY 1,2

--looking at total cases vs total deaths

SELECT location,DATE,total_cases,total_deaths,(cast(total_deaths as int)/total_cases)*100 AS DeathPercentage
FROM [PortfolioProject]..[CovidDeaths]
WHERE location LIKE '%afgh%'
AND continent <>''
ORDER BY 1,2


--looking at total cases vs population
--show get percentage of population got covid 
SELECT location,DATE,total_cases,total_deaths,(total_cases/population)*100 AS CasePercentage
FROM [PortfolioProject]..[CovidDeaths]
WHERE location LIKE '%afgh%'
AND continent <>''
ORDER BY 1,2

--looking at the countries with highest infection rate compare to population
SELECT location,population,max(total_cases) As HighestInfectionCountry,max((total_cases/population)*100) AS PercentPopulationInfection
FROM [PortfolioProject]..[CovidDeaths]
group by location,population 
order by PercentPopulationInfection desc

--showing countries with highest death count per comunication
SELECT location,max(cast(total_deaths as int)) As TotalDeathCount
FROM [PortfolioProject]..[CovidDeaths]
where continent <>''
group by location
order by TotalDeathCount desc

--let's break things down by continent
SELECT continent,max(cast(total_deaths as int)) As TotalDeathCount
FROM [PortfolioProject]..[CovidDeaths]
where continent <>''
group by continent 
order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT 
	--DATE,
	SUM(new_cases) AS TOTAL_cases,
	SUM(new_deaths) AS TOTAL_death,
		CASE sum(new_deaths) WHEN 0 THEN 0
		ELSE
		(sum(new_deaths)/sum(new_cases))*100
		END
	AS DeathPercentage
FROM [PortfolioProject]..[CovidDeaths]
WHERE continent <>''
--GROUP BY DATE
ORDER BY 1,2

--lookinG at total population vs vaccination
SELECT DEA.continent,DEA.location,DEA.DATE,DEA.population,VAC.new_vaccinations
,SUM(CONVERT(FLOAT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY
DEA.location,DEA.DATE) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location=VAC.location
	AND DEA.DATE=VAC.DATE
WHERE DEA.continent <>''
ORDER BY 2,3

--use cte
with PopvsVac(continenet,location,Date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT DEA.continent,DEA.location,DEA.DATE,DEA.population,VAC.new_vaccinations
,SUM(CONVERT(FLOAT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY
DEA.location,DEA.DATE) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location=VAC.location
	AND DEA.DATE=VAC.DATE
WHERE DEA.continent <>''
--ORDER BY 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac
ORDER BY 2,3

--temp table
drop table if exists #PercentPopulationVaccinated
SELECT 
	DEA.continent,
	DEA.location,
	DEA.DATE,
	DEA.population,
	VAC.new_vaccinations,
	SUM(CONVERT(FLOAT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.DATE) AS RollingPeopleVaccinated
into #PercentPopulationVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location=VAC.location
	AND DEA.DATE=VAC.DATE
WHERE DEA.continent <>''
--ORDER BY 2,3
select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
ORDER BY 2,3

--Creating View to store data for later visualization
Create View PercentPopulationVaccinated as
SELECT DEA.continent,DEA.location,DEA.DATE,DEA.population,VAC.new_vaccinations
,SUM(CONVERT(FLOAT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY
DEA.location,DEA.DATE) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location=VAC.location
	AND DEA.DATE=VAC.DATE
WHERE DEA.continent <>''
--ORDER BY 2,3

select * from PercentPopulationVaccinated
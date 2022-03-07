/* show all data in table */
SELECT * 
FROM sc_covid_19.coviddeath
where continent is not null
order by 1 ,2 ;

-- select data that we are going to be starting with it 
select location , date , population , total_cases , new_cases , total_deaths , new_deaths
From sc_covid_19.coviddeath
where continent is not null 
order by 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location , date, population , total_cases , total_deaths ,
         (total_cases  / total_deaths) *100 as death_percentage
from sc_covid_19.coviddeath
-- where location like "%states%" 
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
 select location , date ,  population , total_cases ,(total_cases/population)*100 as people_affected_percent 
 FROM sc_covid_19.coviddeath
 order by 1,2;
 
 -- Countries with Highest Infection Rate compared to Population
 select location , population,  MAX(total_cases) AS highestInfectionCount,
		max((total_cases / population)*100 ) as afected_peo_percent
 FROM sc_covid_19.coviddeath
 GROUP BY location , population
 ORDER BY afected_peo_percent desc;
        
-- Countries with Highest Death Count per Population
 SELECT location , max(cast( total_deaths as unsigned)) as highest_death 
 FROM sc_covid_19.coviddeath
 -- where continent is not null
 Group by location
 order by highest_death desc; 
 
 
-- BREAKING THINGS DOWN BY CONTINENT
select distinct continent , COUNT(*) as count
from sc_covid_19.coviddeath
where continent != ''
GROUP BY continent;
-- Showing contintents with the highest death count per population
select continent , max(cast(total_deaths as unsigned)) as highest_death
FROM sc_covid_19.coviddeath
where continent != '' 
Group by continent
order by highest_death desc ;

-- Global Numbers
SELECT  sum(total_cases) as all_cases ,sum(total_deaths) as all_deaths,
        sum(new_cases) all_new_cases, sum(new_deaths) as all_new_death
FROM sc_covid_19.coviddeath
-- where continent is not null
order by  1,3 desc;

-- define all columns and its datatypes for covidvaccine table
SELECT COLUMN_NAME ,DATA_TYPE 
from INFORMATION_SCHEMA.COLUMNS 
where
	table_schema = 'sc_covid_19' and table_name = 'covidvaccine';
    
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
      -- SUM(cast(vac.new_vaccinations as unsigned)) over(partition by dea.location ORDER BY dea.date) as rolling_people_vaccination
FROM sc_covid_19.coviddeath as dea
JOIN sc_covid_19.covidvaccine as vac
ON dea.population = vac.population  AND
   dea.date       = vac.date
WHERE dea.continent is not null ;
-- ORDER BY 1,2

-- Using CTE to perform Calculation on Partition By in previous query
WITH pop_vs_vac 
AS(
select dea.continent , dea.location, dea.date ,dea.population,vac.new_vaccinations,
       sum(cast(vac.new_vaccinations as unsigned)) over(partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM sc_covid_19.coviddeath as dea
JOIN sc_covid_19.covidvaccine as vac
ON dea.location = vac.location 
and dea.date  = vac.date 
Where dea.continent != ''
) 
SELECT *  ,  ((RollingPeopleVaccinated / population)*100 ) as percentage_peo_vac  
from pop_vs_vac;


-- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists sc_covid_19.percentPopulationVaccinated;
Create table sc_covid_19.percentPopulationVaccinated 
(
continent varchar(255), 
location  varchar(255),
date      datetime ,
population int,
new_vaccination varchar(255) , 
RollingPeopleVaccinated int
);

insert into sc_covid_19.percentpopulationvaccinated
select dea.continent , dea.location, dea.date ,dea.population,-- CAST(vac.new_vaccinations AS unsigned),
       sum(cast(vac.new_vaccinations as unsigned)) over(partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM sc_covid_19.coviddeath as dea
JOIN sc_covid_19.covidvaccine as vac
	ON dea.location = vac.location 
	and dea.date  = vac.date  ;
    
    
select * , (RollingPeopleVaccinated / population)*100 
FROM sc_covid_19.percentpopulationvaccinated;


-- Creating View to store data for later visualizations
drop view sc_covid_19.v_PercentPopulationVaccinated ;
create VIEW sc_covid_19.v_PercentPopulationVaccinated AS 
select dea.continent , dea.location, dea.date ,dea.population,-- CAST(vac.new_vaccinations AS unsigned),
       sum(cast(vac.new_vaccinations as unsigned)) over(partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM sc_covid_19.coviddeath as dea
JOIN sc_covid_19.covidvaccine as vac
	ON dea.location = vac.location 
	and dea.date  = vac.date  ;


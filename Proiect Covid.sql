select * 
FROM Proiect_Covid..CovidDeaths
where continent is not null
order by 3,4

--select * 
--FROM Proiect_Covid..CovidVactinations
--order by 3,4

-- Selectam datele pe care urmeaza sa le folosim

Select Location, date, total_cases, new_cases, total_deaths, population
FROM Proiect_Covid..CovidDeaths
where continent is not null
order by 1,2

-- ne uitam la nr total de cazuri vs nr total de morti in Romania
--Vedem probabilitatea de a muri daca contactam virusul Covid in Romania 
-- in data de 07.07.2022 aceasta este de aproximativ 2.25% 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
FROM Proiect_Covid..CovidDeaths
where location like '%romania%'
order by 1,2

-- Analizam numarul total de cazuri raportat la populatia tarii
-- vedem ce procent din populatie a avut Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPrecentage
FROM Proiect_Covid..CovidDeaths
where location like '%romania%'
order by 1,2

-- ne uitam la tarile care au cea mai mare rata de infectie  in comparatie cu populatia
-- trebuie luat in calcul ca pot exista cazuri in care persoanele sa se reinfecteze
-- In Insulele Faeroae nr de cazuri maxim a fost de 34658, astfel procentul de populatie infectata ajungajnd la 70.65%
Select Location, population, max(cast(total_cases as int)) as HighestInfectionCount, max((total_cases/population))*100 as InfectionPrecentage
FROM Proiect_Covid..CovidDeaths
where continent is not null
Group by Location, Population
order by InfectionPrecentage desc



-- Vizualizam ce tari au cel mai mare numar de morti per populatie
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
FROM Proiect_Covid..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Vizualizam numarul de morti per continent
-- Vedem ce continent  a avut cel mai mare nr de morti
Select location, max(cast(total_deaths as int)) as TotalDeathCount
FROM Proiect_Covid..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

-- Numarul Global pe zi
Select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
FROM Proiect_Covid..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- Numarul Total
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
FROM Proiect_Covid..CovidDeaths
where continent is not null
order by 1,2


-- Ne  uitam la numarul total de populatie vs nr total de vaccinati

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalofVaccines
--, (TotalofVaccines/population)*100
From Proiect_Covid..CovidDeaths  dea 
Join Proiect_Covid..CovidVactinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Folosim CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, TotalofVaccines)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalofVaccines
--, (TotalofVaccines/population)*100
From Proiect_Covid..CovidDeaths  dea 
Join Proiect_Covid..CovidVactinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)
Select * , (TotalofVaccines/Population)*100
From PopvsVac



-- Folosim TEMP TABLE
DROP  Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalofVaccines numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalofVaccines
--, (TotalofVaccines/population)*100
From Proiect_Covid..CovidDeaths  dea 
Join Proiect_Covid..CovidVactinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (TotalofVaccines/Population)*100
From #PercentPopulationVaccinated



-- Cream o vizualizare pentru datele corespunzatoare numarului de vaccinari

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalofVaccines
From Proiect_Covid..CovidDeaths  dea 
Join Proiect_Covid..CovidVactinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

 Select * 
 From PercentPopulationVaccinated





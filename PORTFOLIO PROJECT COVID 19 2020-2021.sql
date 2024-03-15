SELECT *
FROM PortfolioProjectCOVID..CovidDeaths
order by 3,4

--SELECT *
--FROM PortfolioProjectCOVID..CovidVaccinations
--order by 3,4

-- Se seleccionan los datos a utilizar
SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	PortfolioProjectCOVID..CovidDeaths
ORDER BY 1,2


-- C�lculo de muertes totales respecto a los casos totales en M�xico
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	ROUND((total_deaths/total_cases)*100, 2) AS Death_Percentage
FROM
	PortfolioProjectCOVID..CovidDeaths
WHERE
	location = 'Mexico'
ORDER BY 1,2 
-- Para el 30 de Abril de 2021 hab�a un 9.25% de probabilidades de morir si te contagiabas de COVID 19 en M�xico 


--C�lculo para mostrar el porcentaje de infectados de la poblaci�n de M�xico
SELECT 
	location,
	date,
	total_cases,
	population ,
	ROUND((total_cases/population)*100, 2) AS Infection_Percentage
FROM
	PortfolioProjectCOVID..CovidDeaths
WHERE
	location = 'Mexico'
ORDER BY 1,2
--Para el 30 de Abril de 2021 el 1.82% de la poblaci�n estaba infectada de COVID 19 en M�xico 

--C�lculo de los pa�ses con mayor tasa de infecci�n
SELECT
	location AS country,
	MAX(population) AS population,
	MAX (total_cases) AS HighestInfectionCount,
    ROUND((MAX(total_cases) / MAX(population)) * 100, 2) AS Infection_Percentage
FROM PortfolioProjectCOVID..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY location
ORDER BY Infection_Percentage DESC;
--Poblaciones peque�as como Andorra, Montenegro y Czechia fueron las que tuvieron m�s altos los �ndices de infecci�n

--C�lculo de los pa�ses con mayor tasa mortalidad
SELECT
	location AS country,
	population,
	MAX (CAST(total_deaths AS int)) AS HighestDeathCount,
    ROUND(MAX(total_deaths/population)*100,2) AS Death_Percentage
FROM PortfolioProjectCOVID..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY location, population
ORDER BY Death_Percentage DESC;
--De nueva cuenta, las poblaciones peque�as tienen los m�s altos �ndices de mortalidad

--C�lculo para observar los �ontinentes con mayores muertes totales
SELECT
	location AS continent,
	MAX(CAST(total_deaths AS INT)) AS TotalDeaths
FROM PortfolioProjectCOVID..CovidDeaths
WHERE
	continent IS NULL
GROUP BY location
ORDER BY TotalDeaths DESC;
-- Europa y Norte Am�rica destacan como los continentes con mayores muertes

--C�lculos globales por fecha
SELECT
	date,
	SUM(new_cases) AS EachDayInfected,
	SUM(CAST(new_deaths AS INT)) AS EachDayDeaths,
	ROUND((SUM(CAST(new_deaths AS INT)))/(SUM(new_cases))*100,2) AS DailyDeathPercentage
FROM
	PortfolioProjectCOVID..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 
-- Para el 30 de Abril de 2021 hab�a un 1.66% de probabilidades de morir si te contagiabas de COVID 19 en el mundo



--C�lculo de las personas vacunadas cada d�a por pa�s hasta el 30 de abril de 2021
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations AS DailyVaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY vac.location ORDER BY dea.date) AS AccumulatedVaccinations
FROM PortfolioProjectCOVID..CovidDeaths dea 
JOIN PortfolioProjectCOVID..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--C�lculo del porcentaje de la poblaci�n vacunada utilizando una CTE
WITH VaccinatedPopulation (Continent, Location, Date, Population, New_Vaccinations, AccumulatedVaccinations)
AS
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations AS DailyVaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY vac.location ORDER BY dea.date) AS AccumulatedVaccinations
FROM PortfolioProjectCOVID..CovidDeaths dea 
JOIN PortfolioProjectCOVID..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,
	(AccumulatedVaccinations/Population)*100 AS VaccinatedPopulation
FROM VaccinatedPopulation

--Creaci�n de una view con las vacunas acumuladas de la poblaci�n
Create View PercentPopulationVaccinated as
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as AccumulatedVaccinations
From PortfolioProjectCOVID..CovidDeaths dea
Join PortfolioProjectCOVID..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT*
FROM PercentPopulationVaccinated
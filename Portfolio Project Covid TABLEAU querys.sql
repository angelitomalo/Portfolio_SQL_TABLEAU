--QUERYS PARA LAS VISUALIZACIONES EN TABLEAU
-- 1. C�lculo de casos totales de covid, muertes totales y la tasa de mortalidad por covid en el mundo.

SELECT 
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM 
	PortfolioProjectCOVID..CovidDeaths
WHERE 
	continent IS NOT NULL
ORDER BY  1,2;


-- 2. C�lculo de las muertes totales por continente

SELECT 
	location, 
	SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM
	PortfolioProjectCOVID..CovidDeaths
WHERE 
	continent IS NULL 
	AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- 3. C�lculo de los pa�ses con mayores �ndices con mayores �ndices de poblaci�n infectada.

SELECT 
	location, 
	population, 
	MAX(total_cases) AS HighestInfectionCount,  
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM 
	PortfolioProjectCOVID..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- 4. C�lculo de los mayores �ndices de infecci�n registrados por pa�s y d�a.

SELECT 
	location, 
	population,
	date, 
	MAX(total_cases) AS HighestInfectionCount,  
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM 
	PortfolioProjectCOVID..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;

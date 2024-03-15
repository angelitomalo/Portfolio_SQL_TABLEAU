--QUERYS PARA LAS VISUALIZACIONES EN TABLEAU
-- 1. Cálculo de casos totales de covid, muertes totales y la tasa de mortalidad por covid en el mundo.

SELECT 
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM 
	PortfolioProjectCOVID..CovidDeaths
WHERE 
	continent IS NOT NULL
ORDER BY  1,2;


-- 2. Cálculo de las muertes totales por continente

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


-- 3. Cálculo de los países con mayores índices con mayores índices de población infectada.

SELECT 
	location, 
	population, 
	MAX(total_cases) AS HighestInfectionCount,  
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM 
	PortfolioProjectCOVID..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- 4. Cálculo de los mayores índices de infección registrados por país y día.

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

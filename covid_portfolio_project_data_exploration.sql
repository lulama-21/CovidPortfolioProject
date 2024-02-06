-- Preview of data in South Africa
SELECT * FROM covid_deaths
WHERE location LIKE 'South Africa'
ORDER BY date DESC
LIMIT 10;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS Case_vs_Deaths
FROM covid_deaths
WHERE location LIKE 'South Africa'
ORDER BY location, date;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT location, date, population, total_cases, (CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 AS case_to_population
FROM covid_deaths
WHERE location LIKE 'South Africa'
ORDER BY date;

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, SUM((CAST(new_cases AS FLOAT)/CAST(population AS FLOAT)))*100 AS Infection_Rate
FROM covid_deaths
--WHERE location LIKE 'South Africa'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY location;

-- Countries with Highest Death Count per Population
SELECT location, population, MAX((CAST(total_deaths AS FLOAT)/CAST(population AS FLOAT)))*100 AS death_rate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY death_rate DESC;

/*Shit focus to continents 
Showing contintents with the highest death count per population*/
SELECT continent, MAX(total_deaths) AS death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY death_count DESC;

--world stats
SELECT SUM(new_cases) AS new_cases, SUM(new_deaths) AS new_deaths, SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS death_rate
FROM covid_deaths
WHERE continent IS NOT NULL;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine (vacs per day)
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(b.new_vaccinations) OVER (Partition by a.Location ORDER BY a.location, a.Date) AS rolling_vaccinations
From covid_deaths AS a
Join covid_vaccinations AS b
	ON a.location = b.location
WHERE a.continent is not null AND new_vaccinations is not null
order by location, date
LIMIT 500;

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVacs (continent, location, date, population, new_vaccinations, rolling_vaccinations)
AS
(
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
	,SUM(b.new_vaccinations) OVER (Partition by a.Location ORDER BY a.location, a.Date) AS rolling_vaccinations
From covid_deaths AS a
Join covid_vaccinations AS b
ON a.location = b.location
WHERE a.continent is not null AND new_vaccinations is not null
)
Select *, (rolling_vaccinations/population)*100 AS rolling_rate
From PopvsVacs
LIMIT 500;

-- create view
CREATE VIEW PercentPopulationVaccinated AS
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(new_vaccinations) OVER (Partition by a.Location ORDER BY a.location, a.Date) AS rolling_vaccinations
From covid_deaths AS a
Join covid_vaccinations AS b
	ON a.location = b.location
	AND a.date = b.date
WHERE a.continent is not null;

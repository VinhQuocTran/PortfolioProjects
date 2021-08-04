# Tableau Profile: https://public.tableau.com/app/profile/vinhtran
# Create table and import data from csv file
CREATE TABLE covid 
(
	iso_code VARCHAR(255),
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    total_cases INT,
    new_cases INT,
    total_deaths INT,
    new_deaths INT,
    population INT
);



# Global numbers of COVID19
SELECT 
    SUM(new_Cases) Total_cases,
    SUM(new_deaths) Total_deaths,
    ROUND(SUM(new_deaths) * 100 / SUM(new_Cases),1) Death_rate
FROM
    covid;


# Total cases, Total deaths, Death percentage in each continent
SELECT 
    continent,
    SUM(new_Cases) Total_cases,
    SUM(new_deaths) Total_deaths,
    ROUND(SUM(new_deaths) * 100 / SUM(new_Cases),1) Death_rate
FROM
    covid
WHERE
    continent NOT LIKE ''
GROUP BY continent;


# Percent population infected per country
SELECT 
    Location Country,
    SUM(new_cases) Total_cases,
    MAX(population) Population,
    (SUM(new_cases) * 100) / MAX(population) AS Percent
FROM
    covid
GROUP BY location;


# Deaths count per continent each month
select
Continent,
date,
sum(new_Deaths) Total_deaths,
sum(new_cases) Total_cases
from covid
where continent not like ''
group by extract(month from date), continent

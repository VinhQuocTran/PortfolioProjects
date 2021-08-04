# Tableau Profile: https://public.tableau.com/app/profile/vinhtran
# Create table and import data from csv file
create table covid
(
	iso_code varchar(255),
    continent varchar(255),
    location varchar(255),
    date date,
    total_cases int,
    new_cases int,
    total_deaths int,
    new_deaths int,
    population int
);



# Global numbers of COVID19
select
sum(new_Cases) Total_cases,
sum(new_deaths) Total_deaths,
round(sum(new_deaths)*100/sum(new_Cases),1) Death_rate
from covid;


# Total cases, Total deaths, Death percentage in each continent
select 
continent,
sum(new_Cases) Total_cases,
sum(new_deaths) Total_deaths,
round(sum(new_deaths)*100/sum(new_Cases),1) Death_rate
from covid
where continent not like ''
group by continent;


# Percent population infected per country
select
Location Country,
sum(new_cases) Total_cases,
max(population) Population,
(sum(new_cases)*100)/max(population) as Percent
from covid
group by location;


# Deaths count per continent each month
select
Continent,
date,
sum(new_Deaths) Total_deaths,
sum(new_cases) Total_cases
from covid
where continent not like ''
group by extract(month from date), continent

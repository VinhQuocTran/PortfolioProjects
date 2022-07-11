/*
World Happiness Report - Data Exploration 
Skills used: CTE's, Temp Tables, Windows Functions, Aggregate Functions, Create View
*/

# The topic of today is: Is money the ONLY factor that contributes to a country's happiness ?
# We will use World Happiness Report 2021 data (modified version) and MySQL to answer this question

# Features that we use to determine a country's happiness:
# 	Economy: GDP per capita
# 	Support: If you were in trouble, do you have relatives or friends you can count on to help you whenever you need them, or not ( binary responses, either 0 or 1 )
# 	Age: Healthy life expectancies at birth are based on the data extracted from WHO.
#	Freedom: Freedom to make life choices ( binary responses, either 0 or 1 )
#	Generosity: is defined as the residual of regressing the national average of responses to the question, “Have you donated money to a charity in past months?” on GDP capita.
#	Corruption: Corruption Perception. The measure is the national average of the survey responses to two questions in the GWP: “Is corruption widespread throughoutthe government or not”	( binary responses, either 0 or 1 )

# We split 6 criteria columns of happiness into 3 parts:
# Main factor: Economy
# Positive factor: Social support, Freedom, Generostity, Life Expectance
# Negative factor: Corruption


# Create new table and import data from csv file
CREATE TABLE IF NOT EXISTS World_Happiness 
(
    Country VARCHAR(255),
    Region VARCHAR(255),
    Happiness FLOAT,
    Economy FLOAT,
    Supoort FLOAT,
    Age FLOAT,
    Freedom FLOAT,
    Generosity FLOAT,
    Corruption FLOAT
);


# check if any column contains null
SELECT 	COUNT(*) AS total_row,
	SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS nulls_Country,
        SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END) AS nulls_Region,
        SUM(CASE WHEN Happiness IS NULL THEN 1 ELSE 0 END) AS nulls_Happiness,
        SUM(CASE WHEN Economy IS NULL THEN 1 ELSE 0 END) AS nulls_Economy,
        SUM(CASE WHEN support IS NULL THEN 1 ELSE 0 END) AS nulls_Supoort,
        SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS nulls_Age,
        SUM(CASE WHEN Freedom IS NULL THEN 1 ELSE 0 END) AS nulls_Freedom,
        SUM(CASE WHEN Generosity IS NULL THEN 1 ELSE 0 END) AS nulls_Generosity,
        SUM(CASE WHEN Corruption IS NULL THEN 1 ELSE 0 END) AS nulls_Corruption
FROM world_happiness;

# Let start with some light explorations:

# Average happiness of the world
SELECT 
    ROUND(AVG(Happiness), 2) AS World_happiness
FROM
    world_happiness;


# Average happiness and wealth of every region
SELECT 
    region,
    ROUND(AVG(economy), 2) AS avg_economy,
    ROUND(AVG(Happiness), 2) AS avg_happiness
FROM
    world_happiness
GROUP BY region
ORDER BY avg_happiness DESC;
# There is 1 noticeable difference between 2 regions that we might see
# Even though East Asia is wealthier than Latin American and Caribbean, Their happiness is still lower 

# Count how many country that has happiness over 5
SELECT
SUM(CASE WHEN Happiness>5 THEN 1 ELSE 0 END) AS over_5,
SUM(CASE WHEN Happiness<5 THEN 1 ELSE 0 END) AS below_5
from world_happiness;


# Dive in a little deeper 

# Does wealth equal happiness in one country ?
SELECT 
    country, 
    Happiness, 
    round((economy - min(economy) over())/(max(economy) over() -min(economy) over()),2) eco_normalization
FROM
    world_happiness
ORDER BY Happiness DESC
LIMIT 10;
# The answer is yes but it's only the HALF-TRUTH
# As we can see, the 10 happiest countries in the world all have economy higher than 0.8 when using min-max normalization
# Beyond that point it also depends on another factors, Finland is not the richest country but still consistenly ranks top in happiness for fourth year in a row


# Looking at how all factors affect a country's happiness
# Find correlation between happiness and all factors
SELECT 
    ROUND((AVG(economy * happiness) - (AVG(economy) * AVG(happiness))) / (STD(economy) * STD(happiness)),2) AS Economy,
    ROUND((AVG(support * happiness) - (AVG(support) * AVG(happiness))) / (STD(support) * STD(happiness)),2) AS Support,
    ROUND((AVG(Age * happiness) - (AVG(Age) * AVG(happiness))) / (STD(Age) * STD(happiness)),2) AS Age,
    ROUND((AVG(Freedom * happiness) - (AVG(Freedom) * AVG(happiness))) / (STD(Freedom) * STD(happiness)),2) AS Freedom,
    ROUND((AVG(Generosity * happiness) - (AVG(Generosity) * AVG(happiness))) / (STD(Generosity) * STD(happiness)),2) AS Generosity,
    ROUND((AVG(Corruption * happiness) - (AVG(Corruption) * AVG(happiness))) / (STD(Corruption) * STD(happiness)),2) AS Corruption
FROM
    world_happiness;
# From observing data, we can clearly see not only economy but another positive factors like Support, Age, Freedom also have huge correlation and affect a lot to a country's happiness
# Last but not least, We should not forget about negative factor like Corruption. They play a big role in determining happiness of a citizen as well


# How Corruption can limit economic growth and be detrimental to happiness
SELECT 
    country,
    Happiness,
    eco_normalization,
    corruption_normalization
FROM
		(SELECT
			country,
			round(happiness,2) Happiness,
			round((economy - MIN(economy) OVER())/(max(economy) OVER() -MIN(economy) OVER()),2) eco_normalization,
			round((corruption - MIN(corruption) OVER())/(max(corruption) OVER() -MIN(corruption) OVER()),2) corruption_normalization
		from world_happiness) tempTable
WHERE corruption_normalization>0.9
ORDER BY corruption_normalization DESC;
# Country has high corruption (>0.9) also tends to have low happiness and wealth.


# Remember what I said about one noticeable difference between to region earlier ? We will use that example to prove that money is not the only factor contributing to happiness
# We also create view to store data for later visualizations
CREATE VIEW Region_overall AS
    SELECT 
        region,
        ROUND(AVG(happiness), 2) happiness,
        ROUND(AVG(Economy), 2) Economy,
        ROUND(AVG(support), 2) support,
        ROUND(AVG(age), 2) age,
        ROUND(AVG(freedom), 2) freedom,
        ROUND(AVG(Generosity), 2) Generosity,
        ROUND(AVG(Corruption), 2) Corruption
    FROM
        world_happiness
    WHERE
        region = 'Latin America and Caribbean'
            OR region = 'East Asia'
    GROUP BY region;


# Use View
SELECT 
    *
FROM
    region_overall;






    


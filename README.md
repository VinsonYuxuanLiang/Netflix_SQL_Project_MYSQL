# Netflix Data Analysis Using SQL(MYSQL)

![Netflix Logo](https://github.com/VinsonYuxuanLiang/Netflix_SQL_Project_MYSQL/blob/main/Logo.jpg)

## Overview
This project performs a comprehensive, business-driven Exploratory Data Analysis (EDA) on Netflix's movies and TV shows dataset using **MySQL 8.0**. 

The main goal is to solve key business challenges regarding content acquisition, audience targeting, global content distribution, and catalog optimization. By executing complex SQL queries—utilizing **window functions, recursive CTEs, string manipulation, and data type casting**—this project translates raw catalog data into actionable business insights to support decision-making for streaming platforms.

## Objectives

- **Content Distribution Analysis:** Evaluate the overall ratio between Movies and TV Shows to understand platform catalog structure.
- **Audience & Rating Profiling:** Identify the dominant content ratings across different media types to determine primary target demographics.
- **Geographical & Market Insights:** Track top content-producing countries and measure regional investment (e.g., Indian production trends).
- **Temporal & Growth Trends:** Analyze platform content release volume by year and pinpoint historical growth peaks.
- **Catalog Optimization & Deep-Dives:** Perform targeted queries on duration, directors, genres, and multi-season TV shows to optimize content curation.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
Select 
	type, 
  count(type) as total_number 
from netflix
Group BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
Select
	type,
  rating
From
(
	Select 
		type, 
		rating, 
    count(*),
    rank() over(PARTITION by type order by Count(rating) DESC) as ranking
	from netflix
	Group by type, rating
) as t1
Where 
	ranking = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
Select * From netflix
Where 
	type = 'Movie'
  AND
  release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
Select
	country,
  Count(show_id) as total_content
From netflix
Group by 1
Order by 2 DESC
Limit 5;
```
**Weakness:** I should spared every country, not a group of countries be one object.

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. What are the titles of all movies directed by 'Kirsten Johnson'?

```sql
Select 
	title
From 
	netflix
Where
	type = 'Movie'
  AND
  director = 'Kirsten Johnson';
```

**Objective:** Identify all movies from one director.

### 6. Find the list of all 'TV Shows' that have 5 or more seasons.

```sql
Select 
	title,
  duration
From 
	netflix
Where 
	type = 'TV Show'
  AND
  -- duration >= '5 Seasons'
  CAST(substring_index(duration, ' ', 1) as unsigned) >= 5;
```
**Weakness:** For this case, I think using the whole string to compare is not enought.

**Objective:** Find out 'TV Shows' having longer than 5 seasons.

### 7. List all the movies produced in 'India' that belong to the 'Comedies' category.

```sql
Select
	title,
  country,
  listed_in
From 
	netflix
Where
	type = 'Movie'
  AND
  country LIKE '%India%'
  AND
  listed_in LIKE '%Comedies%';
```

**Objective:** List all content is 'Comedies' and also from 'India'.

### 8. How many new shows/movies were released each year? Sort the results in descending order of the release year.

```sql
Select 
	release_year,
  count(*) as total_num,
  type
From 
	netflix
Group by 1, 3
Order by 1 DESC;
```

**Objective:** Analyze the volume of content releases per year for both Movies and TV Shows over time.

### 9. Who are the top 5 directors with the highest number of directed movies(excluding 'Not Given')?

```sql
Select
	director,
  count(*) as total_num
From netflix
Where 
	type = 'Movie' 
  AND
  director != ''
Group by 1
Order by 2 DESC
Limit 5;
```

**Objective:** Identify the top 5 most prolific movie directors on Netflix, excluding missing director records.

### 10. In which year did Netflix add the highest amount of content to its platform?

```sql
Select
	Right(date_added, 4) as year_added,
  count(*) as total_num
From 
	netflix
Group by 1
Order by 2 DESC
Limit 1;
```

**Objective:** Find the peak year when Netflix added the largest quantity of content to its catalog.

### 11. Which are the 5 oldest movies released in India on Netflix?

```sql
Select 
	release_year,
  title,
	country
From
	netflix
Where
	country Like '%India%'
Order by 1
Limit 5;
```

**Objective:** Retrieve the 5 earliest-released Indian movies available on Netflix.

### 12. Find the titles of all movies listed as 'Documentaries' that were released after the year 2015.

```sql
Select 
	title,
  release_year,
  listed_in,
  type
From
	netflix
Where 
	type = 'Movie'
  AND
	listed_in Like '%Documentaries%'
	AND
  release_year >= 2015
Order by 2;
```

**Objective:** Filter modern documentary movies released from 2015 onwards.

### 13. Which movie has the longest duration in minutes on Netflix?

```sql
Select
	title,
  CAST(SUBSTRING_index(duration, ' ', 1)as UNSIGNED) as duration_mins
From
	netflix
Where 
	type = 'Movie'
Order by duration_mins DESC
Limit 1;
```

**Objective:** Determine the single movie with the longest running time on the platform.

### 14. What is the most recently released movie for each country?

```sql
Select 
	title,
  release_year,
  country
From
	(Select 
		title,
		release_year,
		country,
		Row_number() over(partition by country order by release_year DESC) as rnk
	From
		netflix
	Where type = 'Movie'
	) as ranked_movie
Where 
	rnk = 1
	AND
  country != ''
Order by country;
```
**Weakness:** I think need to separate each country to get each individual country.

**Objective:** Use window functions to extract the single latest movie released for every distinct country.

### 15. Identify the release years in which more than 50 movies from India were released.

```sql
Select 
	release_year,
	count(*) as total_num
From
	netflix
Where 
	country Like '%India%'
Group by 
	release_year
Having 
	total_num > 50
Order by 
	release_year DESC;
```

**Objective:** Use group filtering (HAVING) to find key high-output release years for Indian movies (over 50 titles per year).

## Findings and Conclusion

### Key Insights:
1. **Catalog Portfolio Strategy:** Movies comprise the majority of the Netflix catalog compared to TV Shows, though TV Shows demonstrate higher user engagement potential through multi-season retention.
2. **Target Audience Alignment:** The predominant ratings across both Movies and TV Shows skew towards mature and teen audiences (e.g., TV-MA, TV-14), reflecting Netflix's core subscriber demographic focus.
3. **Regional Market Concentration:** The United States, India, and the United Kingdom represent the largest source markets for content production. India, in particular, exhibits significant growth in movie releases, establishing itself as a crucial regional market.
4. **Content Production Lifecycle:** Long-form movies and multi-season TV shows require unique handling in database querying; extracting numerical duration metrics revealed critical outliers in platform catalog runtime.

### Strategic Recommendations:
- **Balance Regional Curation:** Continue expanding content localized for high-volume markets like India while refining multi-country co-production tracking.
- **Optimize Content Mix:** Leverage insights on peak release years and popular genres (such as Documentaries and Comedies) to guide future license acquisitions and original content investments.
- **Data Engineering Enhancements:** Future database schemas should normalize multi-value fields (e.g., comma-separated `country` and `casts` columns) into relational junction tables to further improve query performance and analysis accuracy.

---
*This analysis demonstrates end-to-end data processing capability in MySQL—from data cleaning and type conversion to advanced aggregation and analytics.*

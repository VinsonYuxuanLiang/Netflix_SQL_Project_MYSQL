-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

Select 
	type, 
    count(type) as total_number 
from netflix
Group BY type;

-- 2. Find the most common rating for movies and TV shows

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
where 
	ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

Select * From netflix
Where 
	type = 'Movie'
    AND
    release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

Select
	country,
    Count(show_id) as total_content
From netflix
Group by 1
Order by 2 DESC
Limit 5;

-- 5. What are the titles of all movies directed by 'Kirsten Johnson'?

Select 
	title
From 
	netflix
Where
	type = 'Movie'
    AND
    director = 'Kirsten Johnson';
    
-- 6. Find the list of all 'TV Shows' that have 5 or more seasons.

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
    
-- 7. List all the movies produced in 'India' that belong to the 'Comedies' category.

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
    
-- 8. How many new shows/movies were released each year? Sort the results in 
-- descending order of the release year.

Select 
	release_year,
    count(*) as total_num,
    type
From 
	netflix
Group by 1, 3
Order by 1 DESC;

-- 9. Who are the top 5 directors with the highest number of directed movies
-- (excluding 'Not Given')?

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

-- 10. In which year did Netflix add the highest amount of content to its platform?

Select
	Right(date_added, 4) as year_added,
    count(*) as total_num
From 
	netflix
Group by 1
Order by 2 DESC
Limit 1;

-- 11. Which are the 5 oldest movies released in India on Netflix?
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

-- 12. Find the titles of all movies listed as 'Documentaries' that were released
-- after the year 2015.

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

-- 13. Which movie has the longest duration in minutes on Netflix?

Select
	title,
    CAST(SUBSTRING_index(duration, ' ', 1)as UNSIGNED) as duration_mins
From
	netflix
Where 
	type = 'Movie'
Order by duration_mins DESC
Limit 1;

-- 14. What is the most recently released movie for each country?
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

-- 15. Identify the release years in which more than 50 movies from India were released.
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
	release_year DESC
 


	

    
    
    
    
    

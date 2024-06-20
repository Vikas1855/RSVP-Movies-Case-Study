create database imdb;
USE imdb;

-- Q1. Find the total number of rows in each table of the schema?

SELECT COUNT(*) FROM DIRECTOR_MAPPING;
-- Number of rows = 3867

SELECT COUNT(*) FROM GENRE ;
-- Number of rows = 14662

SELECT COUNT(*) FROM  MOVIE;
-- Number of rows = 7997

SELECT COUNT(*) FROM  NAMES;
-- Number of rows = 25735

SELECT COUNT(*) FROM  RATINGS;
-- Number of rows = 7997

SELECT COUNT(*) FROM  ROLE_MAPPING;
-- Number of rows = 15615

-- Q2. Which columns in the movie table have null values?

SELECT Sum(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS ID_NULL_COUNT,
       Sum(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_NULL_COUNT,
       Sum(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_NULL_COUNT,
       Sum(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_published_NULL_COUNT,
       Sum(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_NULL_COUNT,
       Sum(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_NULL_COUNT,
       Sum(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worlwide_gross_income_NULL_COUNT,
       Sum(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS languages_NULL_COUNT,
       Sum(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_NULL_COUNT
FROM   movie;

-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
-- Number of movies released each year
SELECT year,
Count(title) AS NUMBER_OF_MOVIES
FROM   movie
GROUP  BY year;

-- Number of movies released each month 
SELECT Month(date_published) AS MONTH_NUM,
Count(*) AS NUMBER_OF_MOVIES
FROM   movie
GROUP  BY month_num
ORDER  BY month_num;

-- Q4. How many movies were produced in the USA or India in the year 2019??

SELECT Count(DISTINCT id) AS number_of_movies, year
FROM   movie
WHERE (country LIKE '%INDIA%'OR country LIKE '%USA%') AND year = 2019; 

-- Q5. Find the unique list of the genres present in the data set?
-- Finding unique genres using DISTINCT keyword
SELECT DISTINCT genre
FROM genre;

-- Q6.Which genre had the highest number of movies produced overall?

SELECT genre,
Count(m.id) AS number_of_movies
FROM movie AS m
INNER JOIN genre AS g
where g.movie_id = m.id
GROUP BY genre
ORDER BY number_of_movies DESC limit 1 ;

-- Q7. How many movies belong to only one genre?

WITH movies_with_one_genre
AS (SELECT movie_id
FROM  genre
GROUP  BY movie_id
HAVING Count(DISTINCT genre) = 1)
SELECT Count(*) AS movies_with_one_genre
FROM   movies_with_one_genre;

-- Q8.What is the average duration of movies in each genre? 

SELECT genre,
Round(Avg(duration),2) AS avg_duration
FROM movie AS m
INNER JOIN genre AS g
ON g.movie_id = m.id
GROUP BY genre
ORDER BY avg_duration DESC;

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 


WITH genre_summary AS
(SELECT genre,
Count(movie_id) AS movie_count,Rank() OVER(ORDER BY Count(movie_id) DESC) AS genre_rank
FROM genre                                 
GROUP BY genre)
SELECT *
FROM genre_summary
WHERE genre = "THRILLER" ;

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?

SELECT Min(avg_rating)    AS MIN_AVG_RATING,
       Max(avg_rating)    AS MAX_AVG_RATING,
       Min(total_votes)   AS MIN_TOTAL_VOTES,
       Max(total_votes)   AS MAX_TOTAL_VOTES,
       Min(median_rating) AS MIN_MEDIAN_RATING,
       Max(median_rating) AS MAX_MEDIAN_RATING
FROM   ratings; 


-- Q11. Which are the top 10 movies based on average rating?

SELECT title,
avg_rating,
Rank() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM ratings  AS r
INNER JOIN movie AS m
ON  m.id = r.movie_id limit 10;

-- top 10 movies can also be displayed using WHERE caluse with CTE
WITH MOVIE_RANK AS
(SELECT title, avg_rating,ROW_NUMBER() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM ratings AS r
INNER JOIN movie AS m
ON m.id = r.movie_id)
SELECT * FROM MOVIE_RANK
WHERE movie_rank<=10;

-- Q12. Summarise the ratings table based on the movie counts by median ratings.

SELECT median_rating,
Count(movie_id) AS movie_count
FROM   ratings
GROUP  BY median_rating
ORDER  BY movie_count DESC; 

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??

WITH production_company_hit_movie_summary
AS (SELECT production_company,
Count(movie_id) AS MOVIE_COUNT, Rank()OVER(ORDER BY Count(movie_id) DESC ) AS PROD_COMPANY_RANK
FROM ratings AS R
INNER JOIN movie AS M
ON M.id = R.movie_id
WHERE  avg_rating > 8
AND production_company IS NOT NULL
GROUP  BY production_company)
SELECT *
FROM production_company_hit_movie_summary
WHERE prod_company_rank = 1; 

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

SELECT genre,
Count(M.id) AS MOVIE_COUNT
FROM movie AS M
INNER JOIN genre AS G
ON G.movie_id = M.id
INNER JOIN ratings AS R
ON R.movie_id = M.id
WHERE  year = 2017
AND Month(date_published) = 3
AND country LIKE '%USA%'
AND total_votes > 1000
GROUP  BY genre
ORDER  BY movie_count DESC; 

-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?




-- 1. Number of movies of each genre that start with the word ‘The’ (LIKE operator is used for pattern matching)
-- 2. Which have an average rating > 8?
-- Grouping by title to fetch distinct movie titles as movie belog to more than one genre

SELECT  title,
avg_rating,
genre
FROM   movie AS M
INNER JOIN genre AS G
ON G.movie_id = M.id
INNER JOIN ratings AS R
ON R.movie_id = M.id
WHERE  avg_rating > 8
AND title LIKE 'THE%'
GROUP BY 1,2,3
ORDER BY avg_rating DESC;

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

SELECT median_rating, Count(*) AS movie_count
FROM  movie AS M
INNER JOIN ratings AS R
ON R.movie_id = M.id
WHERE  median_rating = 8
AND date_published BETWEEN '2018-04-01' AND '2019-04-01'
GROUP BY median_rating;

-- Q17. Do German movies get more votes than Italian movies? 

SELECT country, sum(total_votes) as total_votes
FROM movie AS m
INNER JOIN ratings as r ON m.id=r.movie_id
WHERE country = 'Germany' or country = 'Italy'
GROUP BY country;


-- Q18. Which columns in the names table have null values??

SELECT Count(*) AS name_nulls
FROM names
WHERE NAME IS NULL;

SELECT Count(*) AS height_nulls
FROM   names
WHERE  height IS NULL;

SELECT Count(*) AS date_of_birth_nulls
FROM names
WHERE date_of_birth IS NULL;

SELECT Count(*) AS known_for_movies_nulls
FROM   names
WHERE  known_for_movies IS NULL;

SELECT 
SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls, 
SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls		
FROM names;

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?

WITH top_3_genres AS
(SELECT genre,Count(m.id) AS movie_count ,
Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
FROM movie AS m
INNER JOIN genre AS g
ON g.movie_id = m.id
INNER JOIN ratings AS r
ON r.movie_id = m.id
WHERE avg_rating > 8
GROUP BY genre limit 3 )
SELECT n.NAME AS director_name ,
Count(d.movie_id) AS movie_count
FROM director_mapping  AS d
INNER JOIN genre G
using (movie_id)
INNER JOIN names AS n
ON n.id = d.name_id
INNER JOIN top_3_genres
using (genre)
INNER JOIN ratings
using (movie_id)
WHERE avg_rating > 8
GROUP BY NAME
ORDER BY movie_count DESC limit 3 ;

-- Q20. Who are the top two actors whose movies have a median rating >= 8?

SELECT N.name AS actor_name,
Count(movie_id) AS movie_count
FROM   role_mapping AS RM
INNER JOIN movie AS M
ON M.id = RM.movie_id
INNER JOIN ratings AS R USING(movie_id)
INNER JOIN names AS N
ON N.id = RM.name_id
WHERE  R.median_rating >= 8
AND category = 'ACTOR'
GROUP  BY actor_name
ORDER  BY movie_count DESC
LIMIT  2; 
        
-- Q21. Which are the top three production houses based on the number of votes received by their movies?

-- Approach 1: Using select statement 
SELECT production_company,
Sum(total_votes) AS vote_count,
Rank() OVER(ORDER BY Sum(total_votes) DESC) AS prod_comp_rank
FROM movie AS m
INNER JOIN ratings AS r
ON r.movie_id = m.id
GROUP BY production_company limit 3;

-- Approach 2: using CTEs
WITH ranking AS(
SELECT production_company, sum(total_votes) AS vote_count,
RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM movie AS m
INNER JOIN ratings AS r ON r.movie_id=m.id
GROUP BY production_company)
SELECT production_company, vote_count, prod_comp_rank
FROM ranking
WHERE prod_comp_rank<4;



-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
WITH actor_summary AS (SELECT N.NAME AS
actor_name, total_votes,
Count(R.movie_id) AS movie_count,
Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) AS actor_avg_rating
FROM   movie AS M
INNER JOIN ratings AS R
ON M.id = R.movie_id
INNER JOIN role_mapping AS RM
ON M.id = RM.movie_id
INNER JOIN names AS N
ON RM.name_id = N.id
WHERE  category = 'ACTOR'
AND country = "india"
GROUP  BY NAME
HAVING movie_count >= 5)
SELECT *,Rank()OVER(ORDER BY actor_avg_rating DESC) AS actor_rank 
FROM actor_summary; 

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 

-- Type your code below:

WITH actress_summary AS
(SELECT n.NAME AS actress_name, total_votes,
Count(r.movie_id)AS movie_count,
Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
FROM movie AS m
INNER JOIN ratings  AS r
ON m.id=r.movie_id
INNER JOIN role_mapping AS rm
ON m.id = rm.movie_id
INNER JOIN names AS n
ON rm.name_id = n.id
WHERE category = 'ACTRESS'
AND country = "INDIA"
AND languages LIKE '%HINDI%'
GROUP BY   NAME,total_votes
HAVING movie_count>=3 )
SELECT *,Rank() OVER(ORDER BY actress_avg_rating DESC) AS actress_rank
FROM actress_summary LIMIT 5;

-- Q24. Select thriller movies as per avg rating and classify them in the following category: 

WITH thriller_movies AS (SELECT DISTINCT title,avg_rating
FROM movie AS M
INNER JOIN ratings AS R
ON R.movie_id = M.id
INNER JOIN genre AS G using(movie_id)
WHERE  genre LIKE 'THRILLER')
SELECT *,
CASE WHEN avg_rating > 8 THEN 'Superhit movies'
	WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
    WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies' ELSE 'Flop movies'
	END AS avg_rating_category
FROM   thriller_movies; 

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 

SELECT genre,
ROUND(AVG(duration),2) AS avg_duration,
SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;


-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 

WITH top_genres AS(SELECT genre,
Count(m.id)AS movie_count ,
Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
FROM movie AS m
INNER JOIN genre AS g
ON g.movie_id = m.id
INNER JOIN ratings AS r
ON r.movie_id = m.id
WHERE      avg_rating > 8
GROUP BY genre limit 3 ), movie_summary AS
(SELECT genre,year,title AS movie_name,
CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10)) AS worlwide_gross_income ,
DENSE_RANK() OVER(partition BY year ORDER BY CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10))  DESC ) AS movie_rank
FROM movie AS m
INNER JOIN genre AS g
ON  m.id = g.movie_id
WHERE genre IN(SELECT genre FROM   top_genres)
GROUP BY 1,2,3,4)
SELECT *
FROM   movie_summary
WHERE  movie_rank<=5
ORDER BY YEAR;

-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?

WITH production_company_summary
AS (SELECT production_company,
Count(*) AS movie_count
FROM   movie AS m
inner join ratings AS r
ON r.movie_id = m.id
WHERE  median_rating >= 8
AND production_company IS NOT NULL
AND Position(',' IN languages) > 0
GROUP  BY production_company
ORDER  BY movie_count DESC)
SELECT *,Rank()over(ORDER BY movie_count DESC) AS prod_comp_rank 
FROM production_company_summary
LIMIT 2;

-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?

WITH actress_summary AS(select n.NAME AS actress_name,
SUM(total_votes) AS total_votes,
Count(r.movie_id) AS movie_count,
Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
FROM movie AS m
INNER JOIN ratings AS r
ON m.id=r.movie_id
INNER JOIN role_mapping AS rm
ON m.id = rm.movie_id
INNER JOIN names AS n
ON rm.name_id = n.id
INNER JOIN GENRE AS g
ON g.movie_id = m.id
WHERE category = 'ACTRESS'
AND avg_rating>8
AND genre = "Drama"
GROUP BY   NAME )
SELECT   *,Rank() OVER(ORDER BY movie_count DESC) AS actress_rank
FROM actress_summary 
LIMIT 3;

--	Q29. Get the following details for top 9 directors (based on number of movies)
WITH next_date_published_summary AS
(SELECT d.name_id,NAME,d.movie_id,duration,r.avg_rating,total_votes,m.date_published,
Lead(date_published,1) OVER(partition BY d.name_id ORDER BY date_published,movie_id ) AS next_date_published
FROM director_mapping AS d
INNER JOIN names                                                                                 AS n
ON n.id = d.name_id
INNER JOIN movie AS m
ON m.id = d.movie_id
INNER JOIN ratings AS r
ON r.movie_id = m.id ), top_director_summary AS
(SELECT *,Datediff(next_date_published, date_published) AS date_difference
FROM next_date_published_summary )
SELECT   name_id AS director_id,
NAME AS director_name,
Count(movie_id) AS number_of_movies,
Round(Avg(date_difference),2) AS avg_inter_movie_days,
Round(Avg(avg_rating),2) AS avg_rating,
Sum(total_votes) AS total_votes,
Min(avg_rating) AS min_rating,
Max(avg_rating) AS max_rating,
Sum(duration)  AS total_duration
FROM top_director_summary
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;

create database Project;
USE project;
CREATE TABLE netflix (
    show_id VARCHAR(20),
    type VARCHAR(20),
    title VARCHAR(255),
    director VARCHAR(255),
    cast TEXT,
    country VARCHAR(255),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(20),
    duration VARCHAR(50),
    listed_in VARCHAR(255),
    description TEXT
);
show tables;
select * from netflix_titles;
select * from netflix;
SELECT * 
FROM netflix_titles
LIMIT 10;
desc netflix_titles;
rename table netflix_titles to Netflixs;
show tables;
rename table netflixs to Netflix_project;
show tables;
select * from netflix_project;
#Q1-Basic
SELECT 
    *
FROM
    netflix_project
WHERE
    type = 'Movie';
    #Q2
SELECT 
    type,
    COUNT(*) AS total_count
FROM 
    netflix_project
WHERE 
    type IN ('Movie', 'TV Show')
GROUP BY 
    type;
 #Q3
 SELECT DISTINCT
    title,
    country
FROM
    netflix_project
WHERE
    country IS NOT NULL
ORDER BY
    title;
#Q4
SELECT 
    title, release_year
FROM
    netflix_project
WHERE
    type = 'Movie'
ORDER BY release_year ASC
LIMIT 1;
#Q5
SELECT 
    title, release_year
FROM
    netflix_project
WHERE
    release_year > 2018
ORDER BY release_year;
#Q6
SELECT 
    *
FROM
    netflix_project
WHERE
    director IS NULL OR director = '';
#Q7
SELECT 
    RIGHT(date_added, 4) AS year_added,
    COUNT(*) AS total_titles_added
FROM 
    netflix_project
WHERE 
    date_added IS NOT NULL
GROUP BY 
    RIGHT(date_added, 4)
ORDER BY 
    year_added ASC;
#Q8
SELECT 
    title, rating
FROM
    netflix_project
WHERE
    rating = 'TV-MA';
 #Q1- Intermediate
 SELECT 
    country,
    COUNT(*) AS total_titles
FROM 
    netflix_project
WHERE 
    country IS NOT NULL
GROUP BY 
    country
ORDER BY 
    total_titles DESC
LIMIT 5;
#Q2
SELECT 
    rating, COUNT(*) AS total_count
FROM
    netflix_project
WHERE
    type = 'Movie' AND rating IS NOT NULL
GROUP BY rating
ORDER BY total_count DESC
LIMIT 1;
SELECT 
    rating, COUNT(*) AS total_count
FROM
    netflix_project
WHERE
    type = 'TV Show' AND rating IS NOT NULL
GROUP BY rating
ORDER BY total_count DESC
LIMIT 1;
 #Q3
SELECT 
    ROUND(AVG(SUBSTRING_INDEX(duration, ' ', 1)), 2) AS average_movie_duration
FROM 
    netflix_project
WHERE 
    type = 'Movie';
#Q4
SELECT 
    listed_in,
    COUNT(*) AS total_titles
FROM 
    netflix_project
WHERE 
    listed_in IS NOT NULL
GROUP BY 
    listed_in
ORDER BY 
    total_titles DESC
LIMIT 1;
#Q13
SELECT 
    release_year, COUNT(*) AS total_release
FROM
    netflix_project
GROUP BY release_year
ORDER BY release_year DESC
LIMIT 1;
#Q14
SELECT 
    director, COUNT(*) AS total_titles
FROM
    netflix_project
WHERE
    director IS NOT NULL
GROUP BY director
HAVING COUNT(*) > 5
ORDER BY total_titles DESC;
#Q15
SELECT 
    title,
    listed_in
FROM 
    netflix_project
WHERE 
    listed_in LIKE '%,%';
#Q16
SELECT 
    RIGHT(date_added, 4) AS year_added,
    type,
    COUNT(*) AS total_added
FROM 
    netflix_project
WHERE 
    date_added IS NOT NULL
GROUP BY 
    RIGHT(date_added, 4),
    type
ORDER BY 
    year_added ASC,
    type;
#Q17
SELECT 
    country
FROM 
    netflix_project
WHERE 
    country IS NOT NULL
GROUP BY 
    country
HAVING 
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) > 0
    AND
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) = 0;
#Q18
SELECT 
    country,
    COUNT(*) AS total_titles,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS country_rank
FROM 
    netflix_project
WHERE 
    country IS NOT NULL
GROUP BY 
    country
ORDER BY 
    country_rank;
#Q19
WITH yearly_data AS (
    SELECT 
        RIGHT(date_added, 4) AS year_added,
        COUNT(*) AS total_added
    FROM 
        netflix_project
    WHERE 
        date_added IS NOT NULL
    GROUP BY 
        RIGHT(date_added, 4)
)

SELECT 
    year_added,
    total_added,
    total_added - LAG(total_added) OVER (ORDER BY year_added) AS yoy_growth
FROM 
    yearly_data
ORDER BY 
    year_added;
#Q20
WITH genre_split AS (
    SELECT 
        country,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) AS genre
    FROM 
        netflix_project
    JOIN 
        (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) numbers
        ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= numbers.n - 1
    WHERE 
        country IS NOT NULL
),

genre_count AS (
    SELECT 
        country,
        genre,
        COUNT(*) AS total_titles
    FROM 
        genre_split
    GROUP BY 
        country, genre
)

SELECT 
    country,
    genre,
    total_titles
FROM (
    SELECT 
        country,
        genre,
        total_titles,
        RANK() OVER (PARTITION BY country ORDER BY total_titles DESC) AS rank_num
    FROM 
        genre_count
) ranked
WHERE 
    rank_num <= 3
ORDER BY 
    country, rank_num;
#Q21
SELECT 
    type,
    COUNT(*) AS total_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_project),
        2
    ) AS percentage_contribution
FROM 
    netflix_project
GROUP BY 
    type;
#Q22
SELECT 
    release_year,
    COUNT(*) AS total_releases,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS year_rank
FROM 
    netflix_project
GROUP BY 
    release_year
ORDER BY 
    year_rank;
#Q23
SELECT 
    director,
    COUNT(*) AS total_titles
FROM 
    netflix_project
WHERE 
    director IS NOT NULL
GROUP BY 
    director
HAVING 
    SUM(CASE 
            WHEN rating IN ('TV-MA', 'R', 'NC-17') 
            THEN 1 
            ELSE 0 
        END) = COUNT(*);
#Q24
WITH yearly_counts AS (
    SELECT 
        release_year,
        COUNT(*) AS total_releases
    FROM 
        netflix_project
    GROUP BY 
        release_year
)

SELECT 
    release_year,
    total_releases
FROM 
    yearly_counts
WHERE 
    total_releases < (
        SELECT AVG(total_releases) 
        FROM yearly_counts
    )
ORDER BY 
    total_releases ASC;
#Q25
SELECT 
    release_year,
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS total_movies,
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS total_tv_shows
FROM 
    netflix_project
WHERE 
    release_year >= YEAR(CURDATE()) - 10
GROUP BY 
    release_year
ORDER BY 
    release_year ASC;
#Q26
WITH genre_split AS (
    SELECT 
        release_year,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) AS genre
    FROM 
        netflix_project
    JOIN 
        (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) numbers
        ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= numbers.n - 1
),

genre_count AS (
    SELECT 
        release_year,
        genre,
        COUNT(*) AS total_titles
    FROM 
        genre_split
    GROUP BY 
        release_year, genre
)

SELECT 
    release_year,
    genre,
    total_titles
FROM (
    SELECT 
        release_year,
        genre,
        total_titles,
        RANK() OVER (PARTITION BY release_year ORDER BY total_titles DESC) AS rank_num
    FROM 
        genre_count
) ranked
WHERE 
    rank_num = 1
ORDER BY 
    release_year;
#Q27
WITH yearly_country_data AS (
    SELECT 
        country,
        RIGHT(date_added, 4) AS year_added,
        COUNT(*) AS total_added
    FROM 
        netflix_project
    WHERE 
        country IS NOT NULL
        AND date_added IS NOT NULL
    GROUP BY 
        country, RIGHT(date_added, 4)
),

growth_data AS (
    SELECT 
        country,
        year_added,
        total_added,
        total_added - LAG(total_added) 
            OVER (PARTITION BY country ORDER BY year_added) AS yoy_growth
    FROM 
        yearly_country_data
)

SELECT 
    country,
    year_added,
    total_added,
    yoy_growth
FROM 
    growth_data
WHERE 
    yoy_growth < 0
ORDER BY 
    country, year_added;




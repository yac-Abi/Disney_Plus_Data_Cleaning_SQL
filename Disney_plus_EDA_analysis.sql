-- Analysis of the annual distribution between movies and TV shows to identify Disney’s business model shift.

SELECT
	release_year,
    SUM(
		CASE
			WHEN type='TV Show' THEN 1 
            ELSE 0
		END) AS Total_TV_Shows,
    SUM(
		CASE
			WHEN type='Movie' THEN 1 
            ELSE 0
		END) AS Total_Movies
FROM
	disney_titles_final
GROUP BY
	release_year
ORDER BY
	release_year;
    

    

-- Total TV_shows and Movies from 1928 to 2021

WITH Pct AS(
	SELECT
		type,
		COUNT(*) AS Total_titles
	FROM
		disney_titles_final
	GROUP BY
		type
)
SELECT
	type,
    total_titles,
    ROUND((total_titles/(SELECT SUM(total_titles) FROM Pct))*100,0)
    AS Pct_of_titles
FROM pct;



-- RATING of every movie:
SELECT
	title,
    type,
    rating
FROM
	disney_titles_final
    ORDER BY
		rating DESC;
        
        
-- Distribution of content by maturity rating
SELECT
	rating,
    COUNT(title) AS Numbre_of_titles
FROM
	disney_titles_final
GROUP BY
	rating
ORDER BY
	Numbre_of_titles DESC;
    
/* Here we can see that the top content ratings is TV-G with 327 titles, followed by TV-PG with 275 titles and  G rating
with 235 titles. These rating are Family friendly type of content, so we can say that Family content plays the biggest important role 
in disney. */
    
-- Categorisation of each rating

SELECT
	CASE
		WHEN rating IN('TV-Y','TV-Y7','TV-Y7-FV') THEN 'Kids-Toddlers'
        WHEN rating IN('G','TV-G','PG','TV-PG') THEN 'Family'
        WHEN rating IN('PG-13','TV-14') THEN 'Teens'
        ELSE 'Unrated'
	END AS Audience,
    rating,
    COUNT(title) AS Number_of_titles
FROM
	disney_titles_final
GROUP BY
	Audience,
    rating
ORDER BY
	Audience;
    
    
  -- Numbers of movies by Audiences  
    SELECT
	CASE
		WHEN rating IN('TV-Y','TV-Y7','TV-Y7-FV') THEN 'Kids-Toddlers'
        WHEN rating IN('G','TV-G','PG','TV-PG') THEN 'Family'
        WHEN rating IN('PG-13','TV-14') THEN 'Teens'
        ELSE 'Unrated'
	END AS Audience,
	GROUP_CONCAT(DISTINCT rating SEPARATOR ', ') AS Ratings,
    COUNT(title) AS Number_of_titles
FROM
	disney_titles_final
GROUP BY
	Audience
ORDER BY
	Audience;
  /* We can say that Family Audience takes a big part in disney_content. In fact, Since 1928, 
  1044 titles has been made for Family Audiences, followed bt the Kids_Toddlers audience with 190 titles.
  The Teens Audience is in 3rd place with 132 titles.*/
    
    
    
    
    
    
-- Countries which  produces the most content for each Audience
    
    SELECT
    CASE
        WHEN rating IN('TV-Y','TV-Y7','TV-Y7-FV') THEN 'Kids-Toddlers'
        WHEN rating IN('G','TV-G','PG','TV-PG') THEN 'Family'
        WHEN rating IN('PG-13','TV-14') THEN 'Teens'
        ELSE 'Unrated'
    END AS Audience,
    country,
    COUNT(*) AS Number_of_titles
FROM
    disney_titles_final
WHERE 
    country IS NOT NULL 
GROUP BY
    Audience,
    country
ORDER BY
    Audience, 
    Number_of_titles DESC;
    
    
    
-- We separate each country to see more clearly
    
    
    SELECT
    CASE
        WHEN rating IN('TV-Y','TV-Y7','TV-Y7-FV') THEN 'Kids-Toddlers'
        WHEN rating IN('G','TV-G','PG','TV-PG') THEN 'Family'
        WHEN rating IN('PG-13','TV-14') THEN 'Teens'
        ELSE 'Unrated'
    END AS Audience,
    TRIM(SUBSTRING_INDEX(country, ',', 1)) AS Primary_Country,
    COUNT(*) AS Number_of_titles
FROM
    disney_titles_final
WHERE 
    country IS NOT NULL
GROUP BY
    Audience,
    Primary_Country
ORDER BY
	Audience,
    Number_of_titles DESC;
    
    /* We can see that for the Family Audience, the United States are leading by a total number of 857 titles,
    followed by the United Kingdom with 43 titles and Canada with 20 titles.
    For the Kids_Toddler Audience, the United States are leading by far with 131 titles, followed by France (4 titles) and
    Canada  with 3 titles.
    And finally, regarding the Teens Audience, United States are again at the top with 98 titles, followed by the
    United Kingdom with 4 titles.*/
    
   -- Nb: For the movies and TV_Shows produced by many countries, i decided to only keep the first country on the left in the list thats why
   --  i used '1' in the substring_index . 
   
    
    
    
    
    -- The Actors  who appears the most in disney contents
    
    SELECT
		TRIM(SUBSTRING_INDEX(cast, ',', 1)) AS Primary_actor,
        COUNT(title) AS Number_of_titles
	FROM
		disney_titles_final
	WHERE
		cast IS NOT NULL
	GROUP BY
        Primary_actor
	ORDER BY
		Number_of_titles DESC;
    
    
    -- The director who appears the most in disney content:
    
      SELECT
		TRIM(SUBSTRING_INDEX(director, ',', 1)) AS Primary_director,
        COUNT(title) AS Number_of_titles
	FROM
		disney_titles_final
	WHERE 
		director IS NOT NULL
	GROUP BY
		Primary_director
	ORDER BY
		Number_of_titles DESC;
    
    
    -- What actor appears the most in each Audience category ?

    
    
    SELECT
    CASE
        WHEN rating IN('TV-Y','TV-Y7','TV-Y7-FV') THEN 'Kids-Toddlers'
        WHEN rating IN('G','TV-G','PG','TV-PG') THEN 'Family'
        WHEN rating IN('PG-13','TV-14') THEN 'Teens'
        ELSE 'Unrated'
    END AS Audience,
    TRIM(SUBSTRING_INDEX(cast, ',', 1)) AS Primary_actor,
    COUNT(*) AS Number_of_titles
FROM
    disney_titles_final
WHERE 
    cast IS NOT NULL 
    AND rating IS NOT NULL
GROUP BY
    Audience, 
    Primary_actor
ORDER BY
    Audience, 
    Number_of_titles DESC;
    
    
-- What director appears the most in each Audience category ?

    SELECT
    CASE
        WHEN rating IN('TV-Y','TV-Y7','TV-Y7-FV') THEN 'Kids-Toddlers'
        WHEN rating IN('G','TV-G','PG','TV-PG') THEN 'Family'
        WHEN rating IN('PG-13','TV-14') THEN 'Teens'
        ELSE 'Unrated'
    END AS Audience,
    TRIM(SUBSTRING_INDEX(director, ',', 1)) AS Primary_director,
    COUNT(*) AS Number_of_titles
FROM
    disney_titles_final
WHERE 
    director IS NOT NULL 
    AND rating IS NOT NULL
GROUP BY
    Audience, 
    Primary_director
ORDER BY
    Audience, 
    Number_of_titles DESC;    
    
    

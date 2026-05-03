-- NB: I did a manual import via LOAD DATA LOCAL INFILE  over the Import Wizard 
-- to handle encoding issues encountered in the raw source file.


CREATE DATABASE Disney;
USE Disney;

CREATE TABLE IF NOT EXISTS disney_titles_final (
    show_id TEXT,
    type TEXT,
    title TEXT,
    director TEXT,
    cast TEXT,
    country TEXT,
    date_added TEXT,
    release_year TEXT,
    rating TEXT,
    duration TEXT,
    listed_in TEXT,
    description TEXT
    );

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'Replace the path with your local path to the CSV/disney_plus_titles.csv'
INTO TABLE disney_titles_final 
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;



-- We verify to see if the columns are mixed or not
SELECT *
FROM
	disney_titles_final
LIMIT 20;
-- the columns arent mixed.


/* Etape 1: Data cleaning (we remove excessive spaces and replace ghost values by NULL espaces for all columns.
We also replace commas by dots for the future numeric columns.*/

SET 
	SQL_SAFE_UPDATES = 0;

UPDATE 
	 disney_titles_final
SET 
	
    
    -- We clean the text columns by removing the excessive spaces and replaced the ghost values by NULL.
    -- I also put capital letters for show_id column and for the rating column.
    show_id = UPPER(TRIM(show_id)),
    type = TRIM(type),
    title = TRIM(title),
    director = NULLIF(TRIM(director), ''),
    cast = NULLIF(TRIM(cast), ''),
    country = NULLIF(TRIM(country), ''),
    date_added= NULLIF(TRIM(date_added), ''),
    rating= NULLIF(UPPER(TRIM(rating)), ''),
    listed_in = NULLIF(TRIM(listed_in), ''),
    description = NULLIF(TRIM(description), ''),
    
    
	-- Now i clean the future numeric column by removing the excessive spaces,
    -- also by replacing the commas by a dot and replacing ghost values by NULL to prevent casting errors later.
    
    release_year = NULLIF(TRIM(REPLACE(release_year, ',', '.')), '');
   

-- For the Data Integrity: i ensure no non-numeric characters remain in futur numerical columns
UPDATE 
	disney_titles_final 
SET 
	release_year = NULL 
WHERE 
	release_year REGEXP '[^0-9.]';


SET 
	SQL_SAFE_UPDATES = 1;

-- Verify cleaning results
SELECT  *
FROM
	disney_titles_final
LIMIT 5;

-- Etape 2: i verify if in our column show_id, the ids begins only with S and ends with a number.
SELECT * 
FROM 
	disney_titles_final 
WHERE 
	show_id NOT REGEXP '^S[0-9]+$';

-- Les id sont propres.

-- Etape 3: I verify if the columns contain special characters (émojis, weird symbols or encoding errors)
SELECT 
	*
FROM 
	disney_titles_final 
WHERE 
	title REGEXP '[^[:alnum:][:space:][:punct:]]';

-- I notice 7 rows where special characters are seen
-- â€™('), Ã©(é),â€(-) et â€“ ou â€œ(")



-- I remove the special characters :
SET 
	SQL_SAFE_UPDATES = 0;

UPDATE disney_titles_final
SET 
    -- Correction of ' (â€™)
    title = REPLACE(title, 'â€™', "'"),
    cast = REPLACE(cast, 'â€™', "'"),
    
    -- Correction of accents (Ã©)
    title = REPLACE(title, 'Ã©', 'é'),
    cast = REPLACE(cast, 'Ã©', 'é'),
    
    -- Correction of quotes(") and dash(-) (â€“, â€œ, â€ )
	title = REPLACE(REPLACE(REPLACE(title, 'â€œ', '"'), 'â€ ', '"'), 'â€“', '-'),
	cast = REPLACE(REPLACE(REPLACE(cast, 'â€œ', '"'), 'â€ ', '"'), 'â€“', '-');


SET 
	SQL_SAFE_UPDATES = 1;

-- Vérification:
SELECT 
	*
FROM 
	disney_titles_final 
WHERE 
	title REGEXP '[^[:alnum:][:space:][:punct:]]';

-- The special characters have been removed.

-- Etape 4: the column release_year needs to contain  4 numbers, so we replace by NULL if its not the case:

SET 
	SQL_SAFE_UPDATES = 0;

UPDATE 
	disney_titles_final 
SET 
	release_year = NULL 
WHERE 
	release_year NOT REGEXP '^[0-9]{4}$';

SET 
	SQL_SAFE_UPDATES = 1;


-- Etape 5 : We standardize the Date Format (YYYY-MM-DD)


ALTER TABLE 
	disney_titles_final
ADD 
	date_added_Standard DATE;


SET SQL_SAFE_UPDATES = 0;


UPDATE 
	disney_titles_final
SET 
	date_added_Standard = STR_TO_DATE(date_added, '%M %e, %Y');

-- Vérification
SELECT 
	date_added, 
    date_added_Standard 
FROM 
	 disney_titles_final
LIMIT 5;
 
-- Etape 6 : Lets standardise the duration table
-- We noticed that we have a mix between numbers and letters 
 

 -- We start by creating 2 numerical columns, one for duration in seasons and one for duration in minutes
ALTER TABLE 
	disney_titles_final 
ADD COLUMN 
	duration_minutes INT, 
ADD COLUMN 
	duration_seasons INT;

-- We remove the securite so we can use UPDATE
SET SQL_SAFE_UPDATES = 0;

-- We fill the minutes column for the Movies
UPDATE 
	disney_titles_final
SET 
	duration_minutes = CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)
WHERE 
	duration LIKE '%min%';

--  We fill the season column for the TV_Shows
UPDATE 
	disney_titles_final
SET 
	duration_seasons = CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)
WHERE 
	duration LIKE '%Season%';
    
-- We put the security back
SET SQL_SAFE_UPDATES = 1;
 
 
 
 
 -- Etape 7: Delete the duplicates (Row_Number() PARTITION BY ORDER BY)
 -- Here we only verify by the title, the type and the release year, if we add the other columns, they can mess our results
 
SET SQL_SAFE_UPDATES = 0;
 
DELETE
FROM
	disney_titles_final
WHERE
	show_id IN(
    SELECT
		id
        FROM(
        SELECT
			show_id AS id,
			ROW_NUMBER() OVER(
			PARTITION BY title,type,release_year
			ORDER BY show_id
        ) AS row_num
	FROM
		disney_titles_final
	) AS t
    WHERE
		row_num >1

);

SET SQL_SAFE_UPDATES = 1;

-- Lets verify if that there is no more duplicates:
SELECT 
    title, 
    type, 
    release_year, 
    COUNT(*) AS total_appearance
FROM 
    disney_titles_final
GROUP BY 
    title, 
    type, 
    release_year
HAVING 
  total_appearance > 1;
  
  -- We succeded, no more duplicates.
  
  
  
 -- Etape 8: Lets give each column its original format
 -- Now that we finished cleaning our data, lets restablish the original column formats:
 -- For cast, director and description, we keep the  TEXT format because its better( we can have hundreds of actors).
ALTER TABLE 
	disney_titles_final
MODIFY COLUMN show_id VARCHAR(20),
MODIFY COLUMN type VARCHAR(20),
MODIFY COLUMN country VARCHAR(255),
MODIFY COLUMN release_year INT,
MODIFY COLUMN rating VARCHAR(10),
-- We also delete columns we dont use anymore
DROP COLUMN date_added,
DROP COLUMN duration;
    
-- Final verification of data types and values
SELECT *
FROM  
	disney_titles_final
LIMIT 10;










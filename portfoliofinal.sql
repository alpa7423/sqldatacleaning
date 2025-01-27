SELECT *
FROM
	layoffs;

-- creating copy of table to edit

CREATE TABLE layoffs_edit
LIKE layoffs;

SELECT *
FROM layoffs_edit;

INSERT layoffs_edit
SELECT *
FROM layoffs;

-- creating row number column to find duplicates

SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS rn
FROM
	layoffs_edit;

WITH cte AS (
	SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS rn
	FROM
		layoffs_edit)
SELECT *
FROM cte
WHERE
	rn > 1;
    
-- creating new table to remove duplicates

CREATE TABLE `layoffs_edit2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `rn` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_edit2
SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS rn
FROM
	layoffs_edit;
    
SELECT *
FROM 
	layoffs_edit2
WHERE
	rn > 1;

DELETE
FROM 
	layoffs_edit2
WHERE
	rn > 1;
    
SELECT *
FROM
	layoffs_edit2;

-- data cleaning

SELECT
	TRIM(company)
FROM
	layoffs_edit2;

UPDATE
	layoffs_edit2
SET
	company = TRIM(company);
    
SELECT
	DISTINCT(industry)
FROM
	layoffs_edit2;

-- standardizing name

UPDATE
	layoffs_edit2
SET
	industry = 'Crypto'
WHERE
	industry LIKE 'Crypto%';

SELECT
	DISTINCT(location)
FROM
	layoffs_edit2
ORDER BY
	location;

SELECT
	DISTINCT(country)
FROM
	layoffs_edit2
ORDER BY
	country;
    
-- standardizing name

UPDATE
	layoffs_edit2
SET country = REPLACE(country, '.', '')
WHERE
	country LIKE '%.%';
    
-- changing data type

UPDATE
	layoffs_edit2
SET
	`date` = str_to_date(`date`, '%m/%d/%Y');
    
ALTER TABLE
	layoffs_edit2
MODIFY COLUMN
	`date` DATE;
    
-- checking nulls

SELECT *
FROM
	layoffs_edit2
WHERE
	total_laid_off IS NULL OR
    percentage_laid_off IS NULL OR
    industry IS NULL OR
    funds_raised_millions IS NULL;
    
SELECT *
FROM
	layoffs_edit2
WHERE
	industry IS NULL OR industry = '';

SELECT *
FROM
	layoffs_edit2
WHERE
	company = 'Airbnb' OR
    company = "Bally's Interactive" OR
    company = 'Carvana' OR
    company = 'Juul';
    
-- updating nulls and blanks

UPDATE layoffs_edit2
SET industry = 'Travel'
WHERE
	industry = '' AND company = 'Airbnb';
    
UPDATE layoffs_edit2
SET industry = 'Transportation'
WHERE
	industry = '' AND company = 'Carvana';
    
UPDATE layoffs_edit2
SET industry = 'Consumer'
WHERE
	industry = '' AND company = 'Juul';

SELECT *
FROM layoffs_edit2
WHERE
	industry IS NULL OR industry = ''; -- left blank because no unknown
    
-- Checking for other nulls
SELECT *
FROM layoffs_edit2;

SELECT *
FROM layoffs_edit2
WHERE
	total_laid_off IS NULL AND percentage_laid_off IS NULL;
    
-- deleted unnecessary rows that could skew visualization
DELETE
FROM layoffs_edit2
WHERE
	total_laid_off IS NULL AND percentage_laid_off IS NULL;
    
-- deleted column no longer needed for visualization
ALTER TABLE layoffs_edit2
DROP COLUMN rn;
    
SELECT *
FROM layoffs_edit2

SELECT * FROM layoffs;
CREATE TABLE layoffs_staging
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;

-- Find and remove duplicates

WITH duplicates_CTE AS
(
SELECT *, 
row_number() OVER(PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_id
FROM layoffs_staging
)
SELECT * 
FROM duplicates_CTE
WHERE row_id > 1;

-- try to delete here instaed of select
WITH duplicates_CTE AS
(
SELECT *, 
row_number() OVER(PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_id
FROM layoffs_staging
)
DELETE 
FROM duplicates_CTE
WHERE row_id > 1;

-- Error : The target table duplicates_CTE of the DELETE is not updatable ( So now create a new staging table)

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_id` INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT  layoffs_staging2
SELECT *, 
row_number() OVER(PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_id
FROM layoffs_staging;

SELECT * FROM layoffs_staging2
WHERE row_id>1;

SELECT * FROM layoffs_staging2
WHERE company ="Casper" ;
-- now i want to delete the duplicates i.e.., with row_id =2 
DELETE 
FROM layoffs_staging2
WHERE row_id >1 ;

SELECT * 
FROM layoffs_staging2
WHERE row_id >1 ;  # done with duplicates removal

-- 2)STANDARDIZING THE DATA
SELECT *
FROM layoffs_staging2
WHERE company LIKE ' %'; -- so we need to trim those 2

SELECT company, TRIM(company)
FROM layoffs_staging2;  -- Trim(company) looks better and without spaces, SO now we can upadate the table 

UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT distinct industry
FROM layoffs_staging2
Order BY industry; -- Crypto is a problem here , so update it 

SELECT industry 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';-- majority has the name Crypto , so update the related to Crypto

UPDATE layoffs_staging2
SET industry='Crypto' 
WHERE industry LIKE 'Crypto%';


SELECT distinct COUNTRY
FROM layoffs_staging2
ORDER BY COUNTRY;-- THERE IS A MISTAKE WITH UNITED STATES 

SELECT country 
FROM layoffs_staging2
WHERE country LIKE 'United States%'; -- only one name is as united states . - here . is extra , so we can use trimming

UPDATE layoffs_staging2
SET Country = TRIM(TRAILING '.' FROM country) 
WHERE country LIKE 'United States%';

SELECT `date` from layoffs_staging2;

SELECT  `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2
WHERE `date` LIKE '%/%';

SELECT  `date`, STR_TO_DATE(`date`, '%m-%d-%Y')
FROM layoffs_staging2
WHERE `date` LIKE '%-%';


-- UNKNOWN ERROR

UPDATE layoffs_staging2
SET `date`=STR_TO_DATE(`date`, '%m/%d/%Y' )
WHERE `date` LIKE '%/%';

UPDATE layoffs_staging2
SET `date` =  STR_TO_DATE(`date`, '%m-%d-%Y')
WHERE `date` LIKE '%-%' AND `date` NOT LIKE '____-__-__';

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; -- datatype of `date` is updated to DATE.



Select *
FROM  layoffs_staging2
WHERE industry IS null;

UPDATE layoffs_staging2
SET industry= null
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL and percentage_laid_off  IS NULL; -- i guess we can delete these as there will be no use without total laid off and per laid off


DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL and percentage_laid_off  IS NULL;

SELECT * from layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_id;

SELECT * from layoffs_staging2; -- cleaned and ready for analysis.
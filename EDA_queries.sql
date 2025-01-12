SELECT * FROM layoffs_staging2;
-- get the data for top 5 companies with high layoff's every year.

WITH CTE1 AS
(
SELECT company, YEAR(`date`) years,sum(total_laid_off) AS Total_off
FROM layoffs_staging2
where YEAR(`date`) IS NOT NULL
Group BY company,years

), CTE2 AS
(
SELECT *,dense_rank()OVER(partition by years order by Total_off desc) as `rank`
FROM CTE1)
SELECT *
FROM CTE2
WHERE `rank`<=5;



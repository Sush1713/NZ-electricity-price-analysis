-- Q3 step 1: NZ lines share of the price, every quarter
SELECT
    Date,
    ROUND(SUM(CASE WHEN Component = 'Lines'  THEN Price_c_kWh END), 2) AS lines_c_kwh,
    ROUND(SUM(CASE WHEN Component = 'Retail' THEN Price_c_kWh END), 2) AS retail_c_kwh,
    ROUND(SUM(CASE WHEN Component = 'Lines'  THEN Price_c_kWh END)
        / SUM(CASE WHEN Component = 'Retail' THEN Price_c_kWh END) * 100, 1) AS lines_share_pct
FROM qsdep_long
WHERE Town = 'New Zealand'
GROUP BY Date
ORDER BY Date;

-- Q3 step 2: Lines share by town, Feb 2019 vs Aug 2026 (percentage points)
WITH parts AS (
    SELECT
        Town,
        MAX(CASE WHEN Date = '2019-02-15' AND Component = 'Lines'  THEN Price_c_kWh END) AS lines_2019,
        MAX(CASE WHEN Date = '2019-02-15' AND Component = 'Retail' THEN Price_c_kWh END) AS retail_2019,
        MAX(CASE WHEN Date = '2026-08-15' AND Component = 'Lines'  THEN Price_c_kWh END) AS lines_2026,
        MAX(CASE WHEN Date = '2026-08-15' AND Component = 'Retail' THEN Price_c_kWh END) AS retail_2026
    FROM qsdep_long
    WHERE Town <> 'New Zealand'
    GROUP BY Town
)
SELECT
    Town,
    ROUND(lines_2019 / retail_2019 * 100, 1) AS lines_share_2019_pct,
    ROUND(lines_2026 / retail_2026 * 100, 1) AS lines_share_2026_pct,
    ROUND((lines_2026 / retail_2026 - lines_2019 / retail_2019) * 100, 1) AS share_change_pp,
    RANK() OVER (ORDER BY (lines_2026 / retail_2026 - lines_2019 / retail_2019) DESC) AS change_rank
FROM parts
ORDER BY change_rank;
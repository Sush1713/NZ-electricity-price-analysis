-- Q4: Hamilton vs New Zealand average, every quarter (c/kWh)
-- Gap = Hamilton minus NZ (negative = Hamilton is cheaper)
SELECT
    Date,
    ROUND(SUM(CASE WHEN Town = 'Hamilton'    AND Component = 'Retail' THEN Price_c_kWh END), 2) AS ham_retail,
    ROUND(SUM(CASE WHEN Town = 'New Zealand' AND Component = 'Retail' THEN Price_c_kWh END), 2) AS nz_retail,
    ROUND(SUM(CASE WHEN Town = 'Hamilton'    AND Component = 'Retail' THEN Price_c_kWh END)
        - SUM(CASE WHEN Town = 'New Zealand' AND Component = 'Retail' THEN Price_c_kWh END), 2) AS retail_gap,
    ROUND(SUM(CASE WHEN Town = 'Hamilton'    AND Component = 'Lines'  THEN Price_c_kWh END)
        - SUM(CASE WHEN Town = 'New Zealand' AND Component = 'Lines'  THEN Price_c_kWh END), 2) AS lines_gap,
    ROUND(SUM(CASE WHEN Town = 'Hamilton'    AND Component = 'Energy & Other' THEN Price_c_kWh END)
        - SUM(CASE WHEN Town = 'New Zealand' AND Component = 'Energy & Other' THEN Price_c_kWh END), 2) AS energy_gap
FROM qsdep_long
WHERE Town IN ('Hamilton', 'New Zealand')
GROUP BY Date
ORDER BY Date;
-- Q2: Town price level (Aug 2026) and % rise since Feb 2019
WITH town_prices AS (
    SELECT
        Town,
        MAX(CASE WHEN Date = '2019-02-15' THEN Price_c_kWh END) AS price_2019,
        MAX(CASE WHEN Date = '2026-08-15' THEN Price_c_kWh END) AS price_2026
    FROM qsdep_long
    WHERE Component = 'Retail'
      AND Town <> 'New Zealand'
    GROUP BY Town
)
SELECT
    Town,
    ROUND(price_2019, 2) AS price_2019_c_kwh,
    ROUND(price_2026, 2) AS price_2026_c_kwh,
    ROUND((price_2026 / price_2019 - 1) * 100, 1) AS rise_pct,
    RANK() OVER (ORDER BY price_2026 DESC) AS price_rank_2026,
    RANK() OVER (ORDER BY price_2026 / price_2019 DESC) AS rise_rank
FROM town_prices
WHERE price_2019 IS NOT NULL
  AND price_2026 IS NOT NULL
ORDER BY price_rank_2026;
-- Q1 step 1: NZ retail price and CPI, start and end dates
SELECT
    q.Date,
    q.Price_c_kWh AS nz_retail_c_kwh,
    c.CPI_Index
FROM qsdep_long AS q
JOIN cpi AS c
    ON q.Date = c.QSDEP_Date
WHERE q.Town = 'New Zealand'
  AND q.Component = 'Retail'
  AND q.Date IN ('2019-02-15', '2026-08-15');
  
  -- Q1 step 2: % rise of NZ electricity price vs CPI (Feb 2019 to Aug 2026)
WITH start_end AS (
    SELECT
        MAX(CASE WHEN q.Date = '2019-02-15' THEN q.Price_c_kWh END) AS price_2019,
        MAX(CASE WHEN q.Date = '2026-08-15' THEN q.Price_c_kWh END) AS price_2026,
        MAX(CASE WHEN q.Date = '2019-02-15' THEN c.CPI_Index END) AS cpi_2019,
        MAX(CASE WHEN q.Date = '2026-08-15' THEN c.CPI_Index END) AS cpi_2026
    FROM qsdep_long AS q
    JOIN cpi AS c
        ON q.Date = c.QSDEP_Date
    WHERE q.Town = 'New Zealand'
      AND q.Component = 'Retail'
)
SELECT
    ROUND(price_2019, 2) AS price_2019_c_kwh,
    ROUND(price_2026, 2) AS price_2026_c_kwh,
    ROUND((price_2026 / price_2019 - 1) * 100, 1) AS electricity_rise_pct,
    ROUND((cpi_2026 * 1.0 / cpi_2019 - 1) * 100, 1) AS cpi_rise_pct,
    ROUND(((price_2026 / price_2019) / (cpi_2026 * 1.0 / cpi_2019) - 1) * 100, 1) AS real_rise_pct
FROM start_end;
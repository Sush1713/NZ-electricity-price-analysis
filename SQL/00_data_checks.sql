-- Check 1: rows per component (expect 1333 each)
SELECT Component, COUNT(*) AS row_count
FROM qsdep_long
GROUP BY Component;

-- Check 2: number of towns (expect 43, including New Zealand)
SELECT COUNT(DISTINCT Town) AS town_count
FROM qsdep_long;

-- Check 3: CPI rows and date range (expect 31, 2019-02-15 to 2026-08-15)
SELECT COUNT(*) AS cpi_rows, MIN(QSDEP_Date) AS first_date, MAX(QSDEP_Date) AS last_date
FROM cpi;

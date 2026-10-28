# NZ Household Electricity Price Analysis (2019–2026)

**What is really driving NZ household power bills?**

An end-to-end analysis of official MBIE and Stats NZ data, following a business analysis process: from business problem and stakeholders, through requirements and data preparation, to findings, recommendations and a Power BI dashboard.

**Tools:** Excel · Power Query · SQL (SQLite) · Power BI

![Dashboard overview](Power%20BI/overview.png)

---

## Contents
1. [Business problem](#1-business-problem)
2. [Stakeholders](#2-stakeholders)
3. [Business questions (requirements)](#3-business-questions-requirements)
4. [Data sourcing and assessment](#4-data-sourcing-and-assessment)
5. [Data preparation](#5-data-preparation)
6. [Analysis approach](#6-analysis-approach)
7. [Findings](#7-findings)
8. [Recommendations](#8-recommendations)
9. [Assumptions and limitations](#9-assumptions-and-limitations)
10. [Dashboard](#10-dashboard)
11. [Repository structure](#11-repository-structure)
12. [Sources](#12-sources)

---

## 1. Business problem

Power bills are a major cost-of-living concern in New Zealand.

- Household and small business bills rose **6.8%** in the first half of 2026, after an **8.0%** rise in 2025 (Electricity Authority).
- Wholesale electricity prices have fallen, but bills keep rising, mainly because of **lines charges** (the cost of delivering electricity through poles and wires).
- From **1 April 2027**, the low fixed charge cap for low-use households is fully removed (MBIE).

**Problem statement:** Households, retailers and regulators need a clear, evidence-based view of how much prices have risen, where, why, and what may happen next.

**Project goal:** Use official public data to measure the price rise, identify the main cost drivers, compare regions, and model possible 2027 bills.

---

## 2. Stakeholders

| Stakeholder | Interest | What this analysis gives them |
|---|---|---|
| Households | Rising bills, budgeting | How much more they pay, and what 2027 may cost |
| Electricity retailers | Pricing, customer communication | Which part of the price is rising (lines vs energy) |
| Lines companies | Network charges | How their charges compare by region |
| Regulators (Electricity Authority, Commerce Commission, MBIE) | Fair prices, policy impact | Regional differences and the effect of lines charge rises |
| Consumer groups (e.g. Powerswitch) | Affordability | Which areas and households are most affected |

---

## 3. Business questions (requirements)

Five SMART questions were defined, covering descriptive, diagnostic and predictive analysis. Recommendations cover the prescriptive level.

| # | Question | Type |
|---|---|---|
| Q1 | How much did the average household electricity price (c/kWh) rise from Feb 2019 to Aug 2026, and was the rise faster or slower than CPI? | Descriptive |
| Q2 | In the Aug 2026 survey, which towns had the highest price, and which had the largest % increase since Feb 2019 (only towns in both surveys)? | Descriptive |
| Q3 | What % of the household price was lines charges in 2019 compared with 2026, and in which towns did that share grow most (in percentage points)? | Diagnostic |
| Q4 | How do Hamilton's prices compare with the national average from Feb 2019 to Aug 2026, and is the lines charge the reason for any difference? | Descriptive and diagnostic |
| Q5 | For the year from 1 April 2027, what would the yearly bill be for a typical 8,000 kWh household if lines charges rise by a low, medium or high amount, and how much more is that than in 2026? | Predictive (scenario) |

**Scope decisions**
- A question comparing retail and wholesale prices was **removed**: it needed complex wholesale data, and public data cannot show retailer hedging or margins, so any conclusion could be misleading.
- Q5 was **simplified to one household type** (8,000 kWh), because the data does not separate daily fixed charges.

---

## 4. Data sourcing and assessment

| Dataset | Source | Content |
|---|---|---|
| Quarterly Survey of Domestic Electricity Prices (QSDEP), to 15 Aug 2026 | MBIE | Price per kWh (incl. GST) for 42 towns and the NZ average: Retail total, Lines component, Energy & Other |
| CPI All Groups for New Zealand, quarterly (2019Q1–2026Q3) | Stats NZ Infoshare | Inflation index (base: June 2017 quarter = 1000) |

**Feasibility check:** before analysis, each question was checked against the data:
- Regional and lines-charge columns exist ✅
- Full quarterly history from 2004 to 2026 in one sheet ✅
- No missing values for any town in Feb 2019 or Aug 2026 ✅
- QSDEP does **not** include daily fixed charges, so Q5 was adjusted ⚠️

**What QSDEP measures:** a modelled household using 8,000 kWh a year on the cheapest low-user plan. Prices include GST and prompt-payment discounts, but exclude lines company discounts, energy trust payments, multi-fuel and online discounts, and fixed-term deals.

---

## 5. Data preparation

All cleaning was done in **Power Query**, so every step is recorded and repeatable with *Refresh*. Raw files were never edited.

**QSDEP → `qsdep_long` (3,999 rows)**
1. Created three Excel tables from the Retail, Lines and Energy & Other blocks.
2. Unpivoted 91 date columns into rows (wide → long format).
3. Renamed columns: `Town`, `Date`, `Price_c_kWh`, `Component`.
4. Set data types and filtered to 15 Feb 2019 – 15 Aug 2026 (31 quarters).
5. Fixed a spelling error in the source: "Blenhiem" → "Blenheim".
6. Added a `Component` label and appended the three queries into one table.

**CPI → `cpi` (31 rows)**
1. Converted the Infoshare download (a web table with an .xls name) into a real .xlsx file. No data was changed.
2. Removed title and note rows, and renamed columns to `Quarter` and `CPI_Index`.
3. Added a `QSDEP_Date` join key (Q1 → 15 Feb, Q2 → 15 May, Q3 → 15 Aug, Q4 → 15 Nov).

**Validation**
- Row counts: 3,999 (43 places × 31 quarters × 3 components) and 31 CPI quarters ✅
- No blanks or duplicate rows ✅
- Five values spot-checked against MBIE's published figures ✅
- Reconciliation (Lines + Energy & Other = Retail): 8 rows (Otorohanga and Taumaranui, May 2024 – Feb 2025) differ by 0.02c in MBIE's own data, so they were left as published.
- The Transmission and Distribution blocks were excluded: they are MBIE estimates that sum to the Lines component, so including them would double-count.

---

## 6. Analysis approach

| Step | Tool | Work |
|---|---|---|
| Data checks | SQL | Row counts, town count, CPI date range (`00_data_checks.sql`) |
| Q1 | SQL | JOIN prices to CPI on the date key; nominal and real % change (`01_Q1_price_vs_cpi.sql`) |
| Q2 | SQL | Town price level and % rise, ranked with `RANK()` window functions (`02_Q2_town_prices.sql`) |
| Q3 | SQL | Lines share by quarter and by town, change in percentage points (`03_Q3_lines_share.sql`) |
| Q4 | SQL | Hamilton vs NZ gap for each price component, every quarter (`04_Q4_hamilton_vs_nz.sql`) |
| Q5 | Excel | Scenario model linked to the clean data with `SUMIFS`; rates from the lines charge history (MINIFS, CAGR) |
| Dashboard | Power BI | Relationship on the date key, DAX measures, two report pages |

---

## 7. Findings

### Q1: Prices rose faster than inflation
| Measure | Feb 2019 | Aug 2026 | Change |
|---|---|---|---|
| NZ average price | 30.07c/kWh | 42.15c/kWh | **+40.2%** |
| CPI | 1026 | 1368 | **+33.3%** |
| Real change (after inflation) | | | **+5.1%** |

A typical 8,000 kWh household's yearly bill rose from about **$2,406 to $3,372**, about **$966 more per year**.

### Q2: Prices differ widely by town, but the gaps are narrowing
- **Most expensive (Aug 2026):** Balclutha 51.00c, Kerikeri 50.62c, Cromwell 48.88c
- **Cheapest:** Wellington City 37.20c, Ashburton 38.16c, Nelson 38.43c
- **Fastest rise since 2019:** Dunedin +65.8%, Kaiapoi +60.3%, Oamaru +60.1%
- **Slowest rise:** Balclutha +21.7%, Kerikeri +23.0%, Westport +23.6%
- Towns that were already expensive rose slowly, while cheaper towns rose fastest. Cromwell is the exception: both expensive and fast-rising.
- **Hamilton:** 39.78c, a rise of +31.5% (36th of 42 on both measures).

### Q3: The main cost driver changed in 2024
| Period | Lines charge (NZ) | Main driver of the price rise |
|---|---|---|
| Feb 2019 → Feb 2024 | Fell slightly (12.26c → 11.89c) | Energy and other costs |
| Feb 2024 → Aug 2026 | Rose **41%** (11.89c → 16.81c) | Lines charges (about 58% of the rise) |

- The largest jump was **+19.5% in the year to May 2025**, followed by **+10.7%** to May 2026.
- Over the full period, the yearly bill rose **$966**: **$602** from energy and other costs, and **$364** from lines charges.
- **Lines share grew most:** Kaiapoi +8.3 pp, Cromwell +8.1 pp, Paraparaumu +8.1 pp.
- **Lines share fell most:** Kerikeri −8.4 pp, Wellington City −7.0 pp, Napier −7.0 pp.
- The share rose in 19 towns and fell in 23, because each local lines company sets its own charges.

### Q4: Hamilton is now cheaper than the NZ average, mainly due to lines charges
| | Feb 2019 | Aug 2026 |
|---|---|---|
| Hamilton | 30.26c | 39.78c |
| NZ average | 30.07c | 42.15c |
| Gap | +0.19c | **−2.36c** |
| of which Lines | +0.48c | **−1.80c** |

- Hamilton's lines charge rose **18%**, compared with **37%** for the NZ average.
- Lower lines charges explain about **three-quarters** of Hamilton's price advantage, which is worth about **$189 a year** for a typical household.

### Q5: A typical bill could rise by $31 to $143 in 2027 (lines charges only)
| Scenario | Lines rise | 2027 yearly bill | Extra vs today ($3,372) |
|---|---|---|---|
| Low | 2.27% (smallest rise since 2019) | $3,402 | +$31 |
| Medium | 4.83% (average yearly growth, CAGR) | $3,437 | +$65 |
| High | 10.67% (latest yearly rise) | $3,515 | +$143 |

---

## 8. Recommendations

**Households**
- Budget for higher bills from April 2027, and compare plans regularly (for example, on Powerswitch).
- Low-use households, especially people living alone, should check their plan when the low fixed charge cap ends.

**Retailers**
- Explain bill changes clearly by showing how much comes from lines charges and how much from energy costs.
- Design plans and support for low-use and vulnerable customers before April 2027.

**Regulators and policymakers**
- Monitor the impact of lines charge increases by region, since the effect differs widely between towns.
- Target support, such as the Power Credits Scheme, at the households most affected.

---

## 9. Assumptions and limitations

**Assumptions**
- The household is QSDEP's model: 8,000 kWh a year, cheapest low-user plan, prices including GST.
- In Q5, only lines charges change; energy and other costs stay at the Aug 2026 level.
- Q5 shows **scenarios, not forecasts**.

**Limitations**
- QSDEP prices exclude some discounts, so some households pay less than shown.
- "Energy & Other" is one combined figure (energy, retail costs and margin, metering) and cannot be split further.
- MBIE marks some towns' lines splits as approximate.
- Electricity is part of CPI, so the real-rise comparison slightly understates the gap.
- The Q5 model uses an average price per kWh and does not include the April 2027 removal of the low fixed charge cap.
- Public data cannot show retailer costs, hedging or margins, so no conclusions are drawn about retailer pricing.

---

## 10. Dashboard

The Power BI report has two pages:

**Page 1: Overview**
- **Q1:** KPI row (price now, rise since 2019, CPI, real rise)
- **Q3:** Line chart of the yearly bill by component, 2019–2026
- **Q4:** Stacked bar of Hamilton vs NZ (Lines + Energy & Other)
- **Q5:** 2027 bill scenarios with a "Today" reference line
- Key insights and data source

**Page 2: Towns**
- **Q2:** Price for all 42 towns and the NZ average, with NZ and Hamilton highlighted

![Towns page](Power%20BI/towns.png)

---

## 11. Repository structure

```
NZ_Electricity_Project/
├── Raw/        Original MBIE and Stats NZ files (unchanged)
├── Clean/      QSDEP_Clean.xlsx (Power Query, Q5 model), qsdep_long.csv, cpi.csv
├── SQL/        nz_electricity.db and query files 00–04
├── Power BI/   NZ_Electricity_Dashboard.pbix, PDF export, screenshots
└── Docs/       Business questions, cleaning log
```

---

## 12. Sources

- MBIE – [Electricity cost and price monitoring (QSDEP)](https://www.mbie.govt.nz/building-and-energy/energy-and-natural-resources/energy-statistics-and-modelling/energy-statistics/energy-prices/electricity-cost-and-price-monitoring)
- MBIE – [Mid-point review of the phase-out of the Low Fixed Charge regulations](https://www.mbie.govt.nz/building-and-energy/energy-and-natural-resources/energy-consultations-and-reviews/electricity-price/mid-point-review-of-the-phase-out-of-the-low-fixed-charge-lfc-regulations)
- Electricity Authority – [Data shows 6.8% increase to power bills (12 Aug 2026)](https://www.ea.govt.nz/news/general-news/data-shows-68-increase-to-power-bills-across-households-and-small-businesses/)
- Stats NZ – [Infoshare: CPI All Groups for New Zealand](https://infoshare.stats.govt.nz)
- 1News – [Power prices up for some pre-Christmas, despite wholesale prices falling (19 Oct 2026)](https://www.1news.co.nz/2026/10/19/power-prices-up-for-some-pre-christmas-despite-wholesale-prices-falling/)

---

**Author:** Susmita Kumari Giri, Master of Digital Business (AI and Business Analytics), University of Waikato
[GitHub](https://github.com/Sush1713) · LinkedIn: *add your profile link*

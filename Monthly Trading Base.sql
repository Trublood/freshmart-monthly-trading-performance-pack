USE freshmart_kpi;

-- =====================
-- Monthly Trading Base
-- =====================

CREATE OR REPLACE VIEW vw_monthly_sales_base AS
SELECT 
	DATE_FORMAT(transaction_date, "%Y-%m") AS month_year,
    store_id,
    ROUND(SUM(net_sales), 2) AS net_sales,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT transaction_id) AS transactions 
FROM vw_sales_base
GROUP BY 
	month_year,
    store_id
ORDER BY 
	month_year,
    store_id;

-- validate table
SELECT * 
FROM vw_monthly_sales_base;
-- 290 entries, which is less tahn expected

-- Further insight on the table

SELECT COUNT(*) FROM vw_monthly_sales_base;
SELECT COUNT(distinct store_id), count(distinct month) from vw_monthly_sales_base;

--  ******
SELECT
    store_id,
    MIN(month_year) AS first_trading_month,
    MAX(month_year) AS last_trading_month,
    COUNT(*) AS months_with_sales
FROM vw_monthly_sales_base
GROUP BY store_id
ORDER BY first_trading_month, store_id;


SELECT 
	month_year,
    store_id,
    net_sales,
    units_sold,
    transactions,
    
    ROUND(
        net_sales / NULLIF(transactions, 0),
        2
    ) AS avg_transaction_value,

    ROUND(
        units_sold / NULLIF(transactions, 0),
        2
    ) AS units_per_transaction,

    ROUND(
        net_sales / NULLIF(units_sold, 0),
        2
    ) AS avg_selling_price

FROM vw_monthly_sales_base;


SELECT
    month_year,
    COUNT(*) AS store_rows,
    ROUND(SUM(net_sales), 2) AS company_sales,
    SUM(units_sold) AS company_units,
    SUM(transactions) AS company_transactions
FROM vw_monthly_sales_base
GROUP BY month_year
ORDER BY month_year;


-- Join Sales to Target
-- =====================

SELECT DISTINCT month_year
FROM vw_monthly_sales_base
ORDER BY month_year;

-- AND 

SELECT DISTINCT reporting_month
FROM fact_store_targets
ORDER BY reporting_month;

SELECT
    s.month_year,
    s.store_id,
    s.net_sales,
    s.units_sold,
    s.transactions,
    t.sales_target

FROM vw_monthly_sales_base s

LEFT JOIN fact_store_targets t
    ON s.store_id = t.store_id
    AND s.month_year = t.reporting_month

ORDER BY
    s.month_year,
    s.store_id;


-- Calculate Target Achievement
SELECT
    s.month_year,
    s.store_id,
    s.net_sales,
    t.sales_target,

    ROUND(
        s.net_sales - t.sales_target,
        2
    ) AS sales_vs_target,

    ROUND(
        (s.net_sales / NULLIF(t.sales_target, 0)) * 100,
        2
    ) AS target_achievement_pct

FROM vw_monthly_sales_base s

LEFT JOIN fact_store_targets t
    ON s.store_id = t.store_id
    AND s.month_year = t.reporting_month

ORDER BY
    s.month_year,
    s.store_id;

-- Add Store Information
SELECT
    s.month_year,
    s.store_id,
    d.store_name,
    d.store_format,

    s.net_sales,
    s.units_sold,
    s.transactions,

    ROUND(
        s.net_sales / NULLIF(s.transactions, 0),
        2
    ) AS avg_transaction_value,

    ROUND(
        s.units_sold / NULLIF(s.transactions, 0),
        2
    ) AS units_per_transaction,

    ROUND(
        s.net_sales / NULLIF(s.units_sold, 0),
        2
    ) AS avg_selling_price,

    t.sales_target,

    ROUND(
        s.net_sales - t.sales_target,
        2
    ) AS sales_vs_target,

    ROUND(
        (s.net_sales / NULLIF(t.sales_target, 0)) * 100,
        2
    ) AS target_achievement_pct

FROM vw_monthly_sales_base s

LEFT JOIN dim_store d
    ON s.store_id = d.store_id

LEFT JOIN fact_store_targets t
    ON s.store_id = t.store_id
    AND s.month_year = t.reporting_month

ORDER BY
    s.month_year,
    s.store_id;

WITH monthly_comparison AS (

    SELECT
        month_year,
        store_id,
        net_sales,

        LAG(net_sales) OVER (
            PARTITION BY store_id
            ORDER BY month_year
        ) AS previous_month_sales

    FROM vw_monthly_sales_base
)

SELECT
    month_year,
    store_id,
    net_sales,
    previous_month_sales,

    ROUND(
        net_sales - previous_month_sales,
        2
    ) AS mom_sales_variance,

    ROUND(
        (
            (net_sales - previous_month_sales)
            / NULLIF(previous_month_sales, 0)
        ) * 100,
        2
    ) AS mom_sales_growth_pct

FROM monthly_comparison

ORDER BY
    month_year,
    store_id;

-- ==================================
-- Combined Monthly Store Performance
-- ==================================
CREATE OR REPLACE VIEW vw_monthly_store_performance AS

WITH monthly_comparison AS (

    SELECT
        m.month_year,
        m.store_id,
        m.net_sales,
        s.store_name,
        s.store_format,
        s.region,

        LAG(m.net_sales) OVER (
            PARTITION BY m.store_id
            ORDER BY m.month_year
        ) AS previous_month_sales

    FROM vw_monthly_sales_base m

    LEFT JOIN dim_store s
        ON m.store_id = s.store_id
)

SELECT
    m.month_year,
    m.store_id,
    m.store_name,
    m.store_format,
    m.region,
    m.net_sales,
    m.previous_month_sales,

    ROUND(
        m.net_sales - m.previous_month_sales,
        2
    ) AS mom_sales_variance,

    ROUND(
        ((m.net_sales - m.previous_month_sales)
        / NULLIF(m.previous_month_sales, 0)) * 100,
        2
    ) AS mom_sales_growth_pct,

    f.sales_target,

    ROUND(
        m.net_sales - f.sales_target,
        2
    ) AS sales_vs_target,

    ROUND(
        (m.net_sales / NULLIF(f.sales_target, 0)) * 100,
        2
    ) AS target_achievement_pct

FROM monthly_comparison m

LEFT JOIN fact_store_targets f
    ON m.month_year = f.reporting_month
    AND m.store_id = f.store_id;



select * from vw_monthly_store_performance;
SELECT * FROM vw_monthly_sales_base;
SELECT * FROM vw_sales_base;
SELECT * FROM dim_date;
SELECT * FROM dim_store;
SELECT * FROM fact_store_targets;


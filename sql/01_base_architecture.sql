/*
=============================================================
CUSTOMER CHURN & RETENTION ENGINE - BASE ARCHITECTURE
=============================================================
Project: SaaS Customer Churn Analytics
Purpose: Isolate the most recent subscription per account to prevent
         Cartesian explosion (duplicate rows) when joining telemetry data.
Author: Chirag Suri
Created: April 2026
Dialect: Google BigQuery Standard SQL
=============================================================
*/

-- =============================================================
-- STEP 1: ISOLATE LATEST SUBSCRIPTION
-- =============================================================
-- We use a Common Table Expression (CTE) and a Window Function
-- to rank subscriptions for each account based on their start date.

WITH cte_latest_subs AS (
    SELECT 
        account_id,
        subscription_id,
        ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY start_date DESC) as latest_subscription_id
    FROM 
        `customer-chrun-project.ravenstack_analytics.subscriptions`
)

-- =============================================================
-- STEP 2: SELECT FINAL FOUNDATION
-- =============================================================
-- We filter the CTE to only return the row ranked #1 (the newest).

SELECT 
    account_id,
    subscription_id
FROM 
    cte_latest_subs
WHERE 
    latest_subscription_id = 1;
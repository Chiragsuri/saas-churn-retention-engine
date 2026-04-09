/*
=============================================================
CUSTOMER CHURN & RETENTION ENGINE - FEATURE ENGINEERING
=============================================================
Project: SaaS Customer Churn Analytics
Purpose: Transform normalized relational tables into a flattened 
         analytical wide table for machine learning ingestion.
Author: Chirag Suri
Created: April 2026
Dialect: Google BigQuery Standard SQL

Prerequisites:
- Source data loaded into customer-chrun-project.ravenstack_analytics
- Temporal boundaries established to prevent data leakage
=============================================================
*/

-- =============================================================
-- SECTION 1: FOUNDATIONAL SUBSCRIPTION STATE
-- =============================================================
-- Isolate the most recent subscription per account to establish the base grain

WITH cte_latest_subs AS (
    SELECT 
        account_id,
        subscription_id,
        ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY start_date DESC) as latest_subscription_id
    FROM 
        `customer-chrun-project.ravenstack_analytics.subscriptions`
),

-- =============================================================
-- SECTION 2: FEATURE USAGE AGGREGATION
-- =============================================================
-- Aggregate high-frequency telemetry data to the subscription level

cte_features AS (
    SELECT 
        subscription_id,
        count(usage_id) as total_usage_events,
        max(usage_date) as last_usage_date
    FROM
        `customer-chrun-project.ravenstack_analytics.feature_usage`
    GROUP BY
        subscription_id
),

-- =============================================================
-- SECTION 3: SUPPORT TICKET METRICS
-- =============================================================
-- Quantify operational friction and handle null satisfaction scores

cte_support AS (
    SELECT 
        account_id,
        count(ticket_id) as total_tickets,
        COALESCE(avg(satisfaction_score), 0) as avg_satisfaction_score
    FROM
        `customer-chrun-project.ravenstack_analytics.support_tickets`
    GROUP BY
        account_id
),

-- =============================================================
-- SECTION 4: CHURN EVENT DEDUPLICATION
-- =============================================================
-- Handle reactivation edge cases by ensuring only one churn flag per account

cte_churn AS (
    SELECT DISTINCT
        account_id
    FROM
        `customer-chrun-project.ravenstack_analytics.churn_events`
)

-- =============================================================
-- SECTION 5: FINAL ANALYTICAL TABLE ASSEMBLY
-- =============================================================
-- Join all engineered features onto the primary account dimension and generate the target variable

SELECT
    a.account_id,
    s.subscription_id,
    f.total_usage_events,
    f.last_usage_date,
    t.total_tickets,
    t.avg_satisfaction_score,
    CASE 
        WHEN c.account_id IS NOT NULL THEN 1 
        ELSE 0 
    END AS churn_target
FROM
    `customer-chrun-project.ravenstack_analytics.accounts` a
LEFT JOIN
    cte_latest_subs s ON a.account_id = s.account_id AND s.latest_subscription_id = 1
LEFT JOIN
    cte_features f ON s.subscription_id = f.subscription_id
LEFT JOIN
    cte_support t ON a.account_id = t.account_id
LEFT JOIN
    cte_churn c ON a.account_id = c.account_id;
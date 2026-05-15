/*
=============================================================
CUSTOMER CHURN & RETENTION ENGINE - FEATURE ENGINEERING
=============================================================
Project: SaaS Customer Churn Analytics
Purpose: Transform normalized relational tables into a flattened 
         analytical wide table for machine learning ingestion.
         Calculates recency against a dynamic global maximum date
         to handle static dataset timelines.
Author: Chirag Suri
Created: April 2026
Dialect: Google BigQuery Standard SQL

Prerequisites:
- Source data loaded into customer-chrun-project.ravenstack_analytics
- Temporal boundaries established to prevent data leakage
=============================================================
*/

-- SECTION 0: TEMPORAL ANCHOR (GLOBAL MAX DATE)
-- =============================================================
-- Find the absolute latest date in the entire dataset to act as "today"

CREATE OR REPLACE VIEW `customer-chrun-project.ravenstack_analytics.churn_feature_matrix` AS
WITH global_max_date AS (
    SELECT MAX(usage_date) AS max_date 
    FROM `customer-chrun-project.ravenstack_analytics.feature_usage`
),

-- =============================================================
-- SECTION 1: FOUNDATIONAL SUBSCRIPTION STATE
-- =============================================================
-- Isolate the most recent subscription per account to establish the base grain

cte_latest_subs AS (
    SELECT 
        account_id,
        subscription_id,
        ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY start_date DESC) AS latest_subscription_id,
        mrr_amount,
        billing_frequency,
        start_date AS sub_start_date
    FROM `customer-chrun-project.ravenstack_analytics.subscriptions`
),

-- =============================================================
-- SECTION 2: FEATURE USAGE AGGREGATION
-- =============================================================
-- Aggregate high-frequency telemetry data to the subscription level

cte_features AS (
    SELECT 
        subscription_id,
        COUNT(usage_id) AS total_usage_events,
        MAX(usage_date) AS last_usage_date
    FROM `customer-chrun-project.ravenstack_analytics.feature_usage`
    GROUP BY subscription_id
),

-- =============================================================
-- SECTION 3: SUPPORT TICKET METRICS
-- =============================================================
-- Quantify operational friction and handle null satisfaction scores

cte_support AS (
    SELECT 
        account_id,
        COUNT(ticket_id) AS total_tickets,
        ROUND(COALESCE(AVG(satisfaction_score), 0), 2) AS avg_satisfaction_score
    FROM `customer-chrun-project.ravenstack_analytics.support_tickets`
    GROUP BY account_id
),

cte_churn AS (
    SELECT DISTINCT account_id
    FROM `customer-chrun-project.ravenstack_analytics.churn_events`
),

-- =============================================================
-- SECTION 4B: RENEWAL CYCLE CALCULATION
-- =============================================================
-- Computes next renewal date per account based on billing frequency.
-- Uses global_max_date as "today" to keep calculations stable
-- against this static pilot dataset.

cte_renewal AS (
    SELECT
        s.account_id,
        CASE
            WHEN s.billing_frequency = 'monthly' THEN
                DATE_ADD(
                    s.sub_start_date,
                    INTERVAL (DATE_DIFF((SELECT max_date FROM global_max_date), s.sub_start_date, MONTH) + 1) MONTH
                )
            ELSE
                DATE_ADD(
                    s.sub_start_date,
                    INTERVAL (DATE_DIFF((SELECT max_date FROM global_max_date), s.sub_start_date, YEAR) + 1) YEAR
                )
        END AS next_renewal_date
    FROM cte_latest_subs s
    WHERE s.latest_subscription_id = 1
)

-- =============================================================
-- SECTION 5: FINAL ANALYTICAL TABLE ASSEMBLY
-- =============================================================
-- Join all engineered features onto the primary account dimension and generate the target variable

SELECT
    a.account_id,
    a.industry,
    a.plan_tier,
    a.referral_source,
    s.subscription_id,
    f.total_usage_events,
    f.last_usage_date,
    COALESCE(DATE_DIFF((SELECT max_date FROM global_max_date), f.last_usage_date, DAY), 999) AS days_since_last_usage,
    t.total_tickets,
    t.avg_satisfaction_score,
    s.mrr_amount AS mrr,
    DATE_DIFF(r.next_renewal_date, (SELECT max_date FROM global_max_date), DAY) AS days_to_renewal,
    CASE
        WHEN DATE_DIFF(r.next_renewal_date, (SELECT max_date FROM global_max_date), DAY) <= 30
            THEN 'Renewing in 30 Days'
        ELSE 'Not Urgent'
    END AS renewal_urgency,
    CASE WHEN c.account_id IS NOT NULL THEN 1 ELSE 0 END AS churn_target,
    CASE WHEN c.account_id IS NOT NULL THEN 'At-Risk' ELSE 'Retained' END AS churn_label
FROM `customer-chrun-project.ravenstack_analytics.accounts` a
LEFT JOIN cte_latest_subs s ON a.account_id = s.account_id AND s.latest_subscription_id = 1
LEFT JOIN cte_features f ON s.subscription_id = f.subscription_id
LEFT JOIN cte_support t ON a.account_id = t.account_id
LEFT JOIN cte_churn c ON a.account_id = c.account_id
LEFT JOIN cte_renewal r ON a.account_id = r.account_id;
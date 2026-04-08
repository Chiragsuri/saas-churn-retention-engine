# Business Requirements Document (BRD)

**Project Name:** Customer Churn & Retention Decision Engine  
**Client/Company:** RavenStack (Stealth-Mode B2B SaaS)  
**Document Version:** 2.0  
**Date:** April 2026  
**Target Audience:** Chief Revenue Officer (CRO), VP of Customer Success, Director of Data Engineering

---

## 1. Document Control & Portfolio Context

**Implementation Note:**  
This document serves as the strategic blueprint for an independent data consulting engagement. It is designed to demonstrate enterprise-grade data architecture, predictive machine learning, and business intelligence capabilities using a multi-table synthetic dataset, executed within a cloud-based (Google BigQuery) environment.

---

## 2. Executive Summary

RavenStack, a stealth-mode B2B SaaS platform delivering AI-driven team collaboration tools, has recently concluded its pilot phase with coding bootcamp graduates. During this phase, the company observed unacceptably high user attrition.

In the current B2B SaaS market, the average annual churn rate is approximately 4.9%, with a "good" benchmark considered to be below 1% monthly (or under 5% annually). RavenStack is currently exceeding this threshold, resulting in an estimated $50,000 in lost Monthly Recurring Revenue (MRR). Furthermore, Customer Acquisition Costs (CAC) in the SaaS industry have risen by an average of 55% over recent years, placing immense pressure on the business to retain accounts to achieve a positive Return on Investment (ROI).

To protect the company's valuation, this initiative will deliver an end-to-end predictive machine learning pipeline. The system will identify "At-Risk" accounts 30 days prior to their contract renewal, enabling the Customer Success (CS) team to deploy targeted, proactive retention interventions.

---

## 3. Strategic Objectives & Financial Impact

The core objectives of this data analytics initiative are deeply tied to financial outcomes:

- **Predictive Identification:**  
  Architect a machine learning classification model to forecast churn probability for 500 enterprise accounts.

- **Targeted Churn Reduction:**  
  Reduce gross logo churn by a minimum of 15% through data-driven Customer Success outreach.

- **Revenue Protection (ROI):**  
  Protect the estimated $50,000 in MRR currently leaking from the active subscriber base.  
  For example, retaining 319 customers with an average Customer Lifetime Value (CLV) of $2,400 yields a gross annual value saved of over $765,000, heavily offsetting any retention campaign costs.

- **Driver Analysis:**  
  Quantify the exact product usage patterns, feature adoption depth, and support escalations that correlate with account cancellation.

---

## 4. Project Scope and Boundaries

### 4.1 In-Scope Data

The analysis will exclusively utilize RavenStack's internal relational telemetry. The data architecture encompasses the following synthetic entity volumes:

- **accounts:** 500 customer metadata records
- **subscriptions:** 5,000 temporal records of subscription lifecycles
- **feature_usage:** 25,000 high-frequency product interaction logs
- **support_tickets:** 2,000 customer service interactions and satisfaction scores
- **churn_events:** 600 explicit termination logs

### 4.2 Out-of-Scope Elements

To prevent scope creep, the following are explicitly excluded from this phase:

- External macroeconomic analysis
- Competitor benchmarking and pricing intelligence
- Third-party data enrichment (e.g., Clearbit, ZoomInfo)
- Social media sentiment analysis

---

## 5. Stakeholder Alignment & Deliverables

| Stakeholder                      | Role               | Primary Requirement                                             | Expected Deliverable                                                                                         |
| -------------------------------- | ------------------ | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| Customer Success Managers (CSMs) | Primary End-Users  | Account-level risk scores to prioritize daily outreach          | Interactive Power BI dashboard with Explainable AI (SHAP) tooltips detailing exact churn drivers per account |
| VP of Customer Success & CRO     | Executive Sponsors | High-level tracking of MRR at risk and overall retention health | Executive summary dashboard visualizing Net Revenue Churn and Gross Logo Churn                               |
| Product Management               | Secondary Users    | Aggregated insights into feature usage versus retention         | EDA reports highlighting which specific features act as "sticky" retention drivers                           |

---

## 6. Data Architecture & Feature Engineering

The raw normalized tables will be extracted via Google BigQuery and flattened into a single analytical wide table for machine learning ingestion.

### 6.1 Key Engineered Telemetry Features

- **Support Ticket Frequency to Tenure Ratio:**  
  Total support tickets divided by account tenure. High ratios indicate operational friction.

- **Feature Adoption Depth Index:**  
  Evaluates the level of engagement by assessing the frequency of use and the breadth of premium features utilized.

- **Recency of Engagement:**  
  Days since the last active session. Extended inactivity prior to renewal is the strongest behavioral churn signal.

- **MRR Contraction Velocity:**  
  Tracking subscription downgrades over the trailing 90 days.

- **Aggregated CSAT Sentiment Scores:**  
  Moving averages of customer satisfaction scores derived from support tickets.

---

## 7. Business Constraints & Model Success Criteria

### 7.1 Optimization Metric: Prioritizing Recall

In B2B SaaS, the financial cost of a False Negative (failing to predict a churner and losing their MRR) is astronomically higher than a False Positive (a CSM spending 15 minutes checking in on a healthy account). Therefore, the machine learning algorithm (e.g., XGBoost) will be aggressively optimized for Recall to capture the maximum number of true churners.

### 7.2 Temporal Data Leakage Prevention

To ensure the model is financially viable for production deployment, strict architectural guardrails will be implemented. The SQL data pipeline will forcefully separate the "observation window" (historical data used for feature generation) from the 30-day "prediction window". No future data will be permitted to leak into the training set, preventing artificial inflation of model accuracy.

### 7.3 Handling Class Imbalance

Given that the dataset contains only 600 churn events against 5,000 subscriptions, the data suffers from severe class imbalance. The modeling phase will mandate the use of techniques such as:

- SMOTE (Synthetic Minority Over-sampling Technique)
- Algorithmic class weight adjustments

These ensure the model does not default to a "No Churn" prediction.

---

## 8. Technology Stack

- **Data Warehouse:** Google BigQuery (Cloud SQL execution)
- **Programming Language:** Python (Pandas, Scikit-Learn, XGBoost, SHAP)
- **Business Intelligence:** Microsoft Power BI (DAX, Dimensional Modeling)
- **Version Control & Documentation:** Git, GitHub

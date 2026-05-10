# Customer Churn & Retention Decision Engine

---

## 📌 Executive Summary

This project is an end-to-end predictive analytics pipeline designed to identify at-risk customers for **RavenStack**, a B2B SaaS platform. By leveraging cloud data architecture and machine learning, this decision engine transitions the Customer Success team from a reactive support model to a proactive retention strategy, protecting Monthly Recurring Revenue (MRR).

---

## 🏢 The Business Problem

During its pilot phase, RavenStack experienced unacceptably high user attrition, resulting in significant MRR leakage. Because the cost of acquiring a new customer (CAC) in the SaaS industry is significantly higher than retaining an existing one, the business required a data-driven system to flag churning accounts **30 days prior to their contract renewal**.

---

## 🛠️ Methodology & Technical Stack

This project mimics a true enterprise production environment, executing the following pipeline:

**Cloud Data Architecture (Google BigQuery & SQL):**

- Extracted and flattened five highly normalized relational tables: accounts, subscriptions, telemetry, support tickets, and churn events.
- Engineered advanced SQL pipelines utilizing Common Table Expressions (CTEs) and Window Functions to handle complex one-to-many subscription relationships and resolve Cartesian explosions caused by customer reactivations.

**Data Ingestion & Preprocessing (Python & Pandas):**

- Connected local analytical environments to Google BigQuery via the Google Cloud Python SDK.
- Handled missing data, executed one-hot encoding, and utilized stratification during train/test splitting to preserve minority class distributions.

**Machine Learning (Scikit-Learn & XGBoost):**

- Trained an XGBoost classification model.
- Due to the imbalanced nature of churn data, the algorithm was explicitly penalized for missing the minority class using the `scale_pos_weight` hyperparameter.

**Model Optimization (The Recall Tradeoff):**

- The model was aggressively optimized for **Recall** rather than overall Accuracy.
- In a B2B SaaS context, the financial penalty of a False Negative (failing to identify a churning customer and losing thousands in MRR) is astronomically higher than a False Positive (a Customer Success Manager conducting a proactive check-in).

**Explainable AI (SHAP):**

- Deployed SHapley Additive exPlanations (SHAP) to crack the machine learning "black box."
- Generated **global summary plots** to identify macroeconomic churn drivers.
- Generated **local waterfall plots** to provide Customer Success Managers with the exact behavioral reasons (e.g., specific inactivity periods or unresolved support tickets) driving an individual account's risk score.

---

## 📈 Key Results & Business Impact

- Successfully architected a predictive model capable of capturing **64% of actual churners** on baseline, un-tuned data, providing a robust foundation for targeted retention campaigns.
- Empirically proved through SHAP analysis that **Recency of Engagement** (days since last active session) is the primary leading indicator of churn across the business.
- Delivered actionable intelligence to the Customer Success team, enabling them to prioritize daily outreach based on **quantitative risk scores** and specific **feature-level drivers**.

---

## 📂 Repository Structure

The repository is structured to reflect a production-ready analytics workflow:

- `/docs` contains all business and technical documentation.
- `/sql` stores feature engineering queries and data extraction pipelines.
- `/notebooks` holds interactive Jupyter Notebooks for EDA, preprocessing, model training, and explainability.

This organization ensures reproducibility, maintainability, and ease of handoff—even as a solo data scientist.

---

## 🗂️ Data & ML Pipeline Diagram

Google BigQuery Tables
├─ accounts
├─ subscriptions
├─ telemetry
├─ support tickets
└─ churn events
│
▼
Data Extraction & Feature Engineering (SQL & CTEs)
│
▼
Preprocessing in Python (Pandas)
├─ Handle missing values
├─ One-hot encoding of categorical features
└─ Train/test split (stratified)
│
▼
XGBoost Model Training
├─ scale_pos_weight for class imbalance
├─ Optimized for Recall
└─ Predict churn probability
│
▼
Model Explainability (SHAP)
├─ Global: summary plots for top churn drivers
└─ Local: waterfall plots for individual accounts
│
▼
Actionable Insights for Customer Success
├─ Prioritize high-risk accounts
└─ Personalized outreach based on feature-level risk

---

## 📝 Summary

This README fully documents a **production-ready churn prediction engine**:

- End-to-end pipeline: data → model → explainability → business actions.
- Focused on **Recall optimization** to minimize MRR loss.
- Clear structure and reproducibility for single-person execution.

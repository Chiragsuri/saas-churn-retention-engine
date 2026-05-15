# Key Analytical Findings

This document summarizes the main insights from the RavenStack churn analysis — patterns that emerged from the data, model, and SHAP explainability layer.

---

## 1. Days Since Last Usage Is the Top Predictor

SHAP analysis across all 500 accounts shows `days_since_last_usage` consistently has the highest absolute SHAP values. Accounts with 400+ days of inactivity show dramatically elevated churn risk regardless of their satisfaction scores or MRR.

This is the clearest behavioral signal in the dataset. An account that hasn't logged in for 13+ months is going to churn, period. CSAT surveys and support ticket resolution won't save them at that point.

**Implication:** Engagement is the leading indicator. Re-engagement campaigns should trigger at 90 days of inactivity, not at renewal time.

---

## 2. High CSAT Doesn't Prevent Churn

The "At-Risk MRR by Satisfaction Score" chart on Page 1 shows that accounts with CSAT scores of 4–5 contribute **$503K in at-risk MRR** — more than any other satisfaction tier.

This is counterintuitive. You'd expect dissatisfied customers (CSAT 1–2) to dominate the at-risk bucket. But the data shows satisfaction scores are a lagging indicator. By the time someone rates their support interaction as a 4 or 5, they may have already stopped using the product entirely.

**Implication:** CSAT is not a reliable churn signal on its own. A high score means the support interaction went well, not that the account is healthy.

---

## 3. Churn Is Behavioral, Not Plan-Driven

The "Churn Rate by Plan Tier" stacked bar shows roughly even churn distribution across Basic, Pro, and Enterprise plans — all hovering around 68–72% predicted churn.

There's no "safe" tier. Enterprise customers churn at nearly the same rate as Basic customers. Plan upgrades don't appear to meaningfully reduce churn risk in this dataset.

**Implication:** Retention interventions should target behavioral signals (usage, engagement, support friction) rather than trying to upsell accounts into higher tiers as a retention strategy.

---

## 4. The 30-Day vs. Annual Renewal Split

The data has a natural bimodal distribution for `days_to_renewal`:
- **Monthly subscribers:** 1–30 days (210 accounts)
- **Annual subscribers:** 184–365 days (280 accounts)
- **Gap:** 31–180 days (10 accounts)

The 61–180 day range is completely empty. This isn't a bug — it's because the pilot ended December 31, 2024. Monthly subs started in December and renew in January. Annual subs started throughout 2024 and renew in 2025.

**Implication:** A 60-day urgency tier adds no value. The 30-day filter isolates the monthly subscriber cohort that needs immediate attention. Annual subscribers can be contacted proactively but aren't urgent.

---

## 5. Days to Renewal Appears in SHAP (Correctly)

In the SHAP waterfall charts, `days_to_renewal` shows up with both positive and negative SHAP values depending on the account:
- Negative SHAP (green bars) = lower days to renewal → **higher** churn risk (correct)
- Positive SHAP (red bars) = higher days to renewal → **lower** churn risk (correct)

The model learned that imminent renewals correlate with churn. An account renewing in 5 days with 200 days of inactivity is more likely to churn than the same account with 300 days until renewal — the urgency compounds the risk.

**Implication:** The model is using `days_to_renewal` as intended. It's not just predicting who will churn eventually, but who will churn *soon*.

---

## 6. Support Tickets Are a Weak Signal

`total_tickets` appears in SHAP charts but with relatively low absolute values compared to `days_since_last_usage` or `avg_satisfaction_score`. High ticket volume doesn't strongly predict churn in this dataset.

This could mean:
- Accounts that churn quickly don't bother opening tickets
- Or RavenStack's support team resolves tickets well enough that volume alone doesn't drive cancellations

Either way, tickets are more of a "nice to have" feature than a core churn driver.

---

## 7. The Model Captures 64% of Churners at Baseline

The confusion matrix shows 64% recall on the minority class. That's acceptable for a first-pass model with no hyperparameter tuning. It means 64 out of every 100 accounts that will actually churn get flagged in advance.

The precision is lower (around 30%), meaning many flagged accounts won't actually churn. But in B2B SaaS, that tradeoff is correct — the cost of a false positive (unnecessary CSM check-in) is far lower than a false negative (losing $2K+ MRR with no warning).

**Implication:** The model is production-viable as-is. Tuning the decision threshold could push recall to 75%+ but would flood CSMs with false positives.

---

## Summary: What Actually Drives Churn at RavenStack

1. **Inactivity** (days since last usage) — the strongest signal by far
2. **Imminent renewal** (days to renewal ≤30) — compounds risk when combined with inactivity
3. **Low engagement** (total usage events, feature breadth) — secondary but important
4. **Support friction** (ticket count) — weak signal on its own

Satisfaction scores, plan tier, and industry are not predictive.

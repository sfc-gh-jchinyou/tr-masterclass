# Cortex Code Demo Prompts

Three prompts in increasing complexity to showcase the breadth of Cortex Code capabilities.

---

## 1 — Simple (SQL + AI, ~30 sec)

> Find the top 5 customers by total order value in our sales data, then use AI_CLASSIFY to label each one as "At Risk", "Loyal", or "High Growth" based on their order history.

*Shows: catalog search, SQL authoring, and inline AI functions in one shot.*

---

## 2 — Medium (App generation, ~90 sec)

> Build a Streamlit app that lets a user paste in a block of customer feedback, then shows AI_SENTIMENT score, AI_EXTRACT key entities, and a suggested reply from AI_COMPLETE — all side by side.

*Shows: multi-file app scaffolding, Snowflake session wiring, and chaining multiple Cortex AI functions through a UI.*

---

## 3 — Complex (End-to-end ML pipeline, ~3 min)

> Train a customer churn prediction model on our CRM data, register it in the Snowflake Model Registry, deploy it as a batch inference task that scores new customers nightly, and build a monitoring notebook that plots prediction drift over time.

*Shows: ML skill, feature engineering, Model Registry, DAG/task scheduling, and notebook orchestration — the full platform surface in one workflow.*

---

The jump in scope is deliberate: prompt 1 is one `SELECT`, prompt 2 is a deployable app, prompt 3 is a production pipeline. Together they cover SQL → UI → MLOps.

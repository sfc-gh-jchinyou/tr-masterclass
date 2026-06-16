# Thomson Reuters Digital Product Engagement Masterclass
## Snowflake Intelligence — In-Lab Guide

---

## Workshop Objective

> **"By the end of this session, you will be able to identify which of your customer accounts are losing digital engagement momentum — and know exactly who to call before a renewal becomes a risk."**

Every exercise in today's session connects back to this one idea: your customers are telling you they're disengaging through their usage data. Snowflake Intelligence lets you hear that signal before it's too late.

This session requires no SQL and no technical skills. The hardest thing you'll do today is type a question.

---

## Workshop Assets at a Glance

| Asset | Type | What it is |
|---|---|---|
| `ACCOUNT_USAGE_BY_PRODUCT` | Source table | Pendo daily engagement data — all analysis originates here |
| `ACCOUNT_HEALTH_SEMANTIC_VIEW` | Semantic view | Translates column names into the business language you use |
| `ACCOUNT_HEALTH_AGENT` | Cortex Agent | The AI agent wired to the data |
| `SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT` | Snowflake Intelligence | The chat interface you'll use throughout the session |
| `SNFL_INTL_MASTERCLASS_LEARNER_ROLE` | Role | Your access role for today |

---

## Understanding What the Agent Knows

When you ask the Account Health Intelligence Assistant a question, it queries real TR data — not the internet, not a general-purpose model. Here is what is available and what it means.

### The Core Scores

**PES (Product Engagement Score)** measures;

- **Breadth** — how many features the account uses
- **Depth** — how intensively users engage within sessions
- **Frequency** — how often users come back

**>0.6** indicates a healthy, engaged account. **< 0.3** is stagnant. 

When the agent describes an account as "at risk," it means:

```
PES_SCORE < 0.3   OR   GROWTH < 0
```

### Daily vs. 30-Day Columns

The underlying data has two types of activity columns:

- **`LAST_30_DAYS` columns** — rolling 30-day windows, more stable and representative for most business questions
- **`BY_DAY` columns** — activity on a single specific date, useful for trend analysis

For most of your questions today, the agent will automatically use the `LAST_30_DAYS` columns. This is intentional — they smooth out single-day spikes and give a truer picture of account health.

### How the Agent Understands Your Language

The semantic view maps your everyday business language to the data. When you say "engagement score," the agent knows you mean `PES_SCORE`. When you say "at-risk accounts," it knows the threshold. When you say "customers" or "clients," it knows you mean accounts. You do not need to know any of the column names.

If you ask *"What is a product engagement score?"* the agent will explain it in plain English — that explanation was written by the data team and stored in the system. You can trust it.

---

## Hands-On Exercises

| Block | Time Limit | What you'll do |
|---|---|---|
| Exercise 1: Understanding the data | 5 min | Orient yourself to what the agent knows |
| Exercise 2: Find your at-risk accounts | 5 min | Core objective — build your risk list |
| Exercise 3: Diagnose an account | 5 min | Deep-dive into a specific account |
| Exercise 4: Turn insight into action | 10 min | From data to a decision |

---

### Getting Started

1. In a web browser, navigate to ai.snowflake.com
2. Your Account Identifier is `thomsonreuters-trpoc`
3. Switch your role to `SNFL_INTL_MASTERCLASS_LEARNER_ROLE`
4. Confirm you can see the **Account Health Intelligence Assistant**

---

### Exercise 1: Understanding the Data (5 min)

Before answering hard business questions, spend a few minutes learning what the agent has access to. Try these starter questions:

```
What data do you have access to?
How many customer accounts are in the dataset?
What products or applications are tracked?
What market segments are covered?
What is a product engagement score?
```

**What to notice:** When you ask about the product engagement score, the agent responds with a plain English explanation. That definition was written by the data team as part of the symantic layer. The agent is not making it up — this is how enterprise AI is governed.

---

### Exercise 2: Find Your At-Risk Accounts (5 min)
#### Note! These are example questions and have not been tested against TR data. You may need to figure out some new questions to get the information you are looking for.

This is the core exercise. Work through the three scenarios in order — each one narrows your focus from the full portfolio down to specific accounts that need attention.

**Scenario A — Portfolio-level view**
```
How many accounts have a product engagement score below 0.3?
Which accounts have negative growth in the last 30 days?
find all at-risk accounts sorted by engagement score, lowest first.
What is the average engagement score across all accounts?
```

**Scenario B — Segment and app breakdown**
```
Which market segment has the lowest average engagement score?
Find all at-risk accounts in the Legal segment <<or other key segment>>.
Which applications have the lowest adoption rates?
Compare average stickiness across different applications.
```

**Scenario C — Combining signals**
```
Show me accounts that have both low engagement AND a negative NPS score.
Which accounts have declining growth AND fewer than 5 active users last month?
Find accounts where users are dismissing guides but not completing them.
Which accounts have been customers the longest but still have low engagement?
```

> You just identified your at-risk book in under 5 minutes. The next question is: what do you do with it?

---

### Exercise 3: Diagnose a Single Account (5 min)

Knowing an account is at risk is only half the work. The harder question is: *why?*

Is it low adoption — have users never been properly onboarded? Is it negative growth — people who used to use the product have stopped? Is there a satisfaction issue flagged by NPS? The answer changes your next best action.

**Work through this five-step chain. Start with your most concerning account from Exercise 2.**

```
Step 1: "Show me the 5 accounts with the lowest product engagement scores"
Step 2: "Tell me more about the top account on that list"
Step 3: "What is the trend in their engagement score over the last 60 days?"
```
> Pause here -- will your next questions change based on the previous answer?
```
Step 4: "How does their NPS score compare to the segment average?"
Step 5: "Based on this data, what should my talking points be for a call with this account?"
```

**Step 5 is the key moment.** The agent uses the data it retrieved in steps 1–4 to generate account-specific call preparation notes. Ask yourself: do the talking points match what you would have said? Where would you edit them? Should you modify Steps 4 and 5?

---

### Exercise 4: Turn Insight into Action (10 min)

> | **"Data without action is just an interesting report."** - Mike Wies

Pick the single most important account you found today and be ready to share:

1. **Which account** — and which application is the concern
2. **What signal flagged it** — low PES? Negative growth? Low NPS? A combination?
3. **What you would do differently** on the next call or renewal touchpoint as a result

> Notice what you just did — you identified the account, diagnosed the signal, and decided on an action. That workflow used to take days. It just took 10 minutes.

---

## Question Bank by Role

Use these during any exercise if you want additional prompts.

### All Roles (warm-up)
```
How many customer accounts are in the dataset?
What applications are tracked?
What is the overall average product engagement score?
How many accounts have a score below 0.3?
How many accounts have negative growth?
```

### Account Managers / Customer Success
```
Which accounts in the dataset have the lowest engagement scores?
Show me accounts with declining engagement over the past 60 days.
Which accounts have low adoption — fewer than 10% of their users active?
Show me accounts with both low engagement and negative NPS.
Which accounts have been active for more than 2 years but still have low engagement?
Which accounts dismissed guides most frequently?
Find accounts where engagement improved month-over-month.
```

### Regional Sales Directors
```
What is the average engagement score by market segment?
Which segment has the highest proportion of at-risk accounts?
Compare adoption rates across segments.
Show me account health distribution for the Legal segment.
Which segment improved the most in engagement this quarter?
```

### Product Managers
```
Which application has the lowest average PES score?
Which app has the highest guide dismissal rate?
Compare stickiness across all applications.
Which app shows the most growth?
Which accounts use the most applications and how does that correlate with engagement?
```

### Renewals / Finance
```
How many accounts with negative growth have more than 50 active users?
Which accounts combine low engagement with negative NPS?
Show me the accounts with the lowest stickiness scores sorted by number of visitors.
Which accounts have not had any activity in the past 30 days?
What is the distribution of engagement scores across the portfolio?
```

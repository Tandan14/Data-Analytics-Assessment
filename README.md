**Question 1**

**THE OBJECTIVES**

Find customers with at least one funded savings plan and one funded investment plan, sorted by total deposits (savings + investments).

The Effect Of The Query 

* Filters Only Funded plans (amount > 0 )
* Groups by owner_id to get total savings and investments per 
user
* Joins only owners who have both savings and investment plans
* Then have it sorted by total deposits in descending order.

**CHALLENGE**

 While constructing the query to identify customers with both savings and investment plans, I initially wrote the subqueries using: SELECT user_id. this resulted in an error indicating that the column user_id was unknown.

**RESOLUTION**

To resolve the issue, I had to re-run SELECT * FROM plans_plan;
This allowed me to carefully inspect the actual column names in the table. I discovered that the correct foreign key referencing the user is owner_id, not user_id. After updating the subqueries to use owner_id, the query executed successfully.

**Question 2**

**THE OBJECTIVES**

Calculate the average number of transactions per customer per month
Categorize each customer as:
High Frequency (≥ 10 txns/month)
Medium Frequency (3–9 txns/month)
Low Frequency (≤ 2 txns/month)

**The Explanation**

**Step 1:** I had to breakdown transactions by user nd month SELECT 
  owner_id, 
  DATE_FORMAT(transaction_date, '%Y-%m') AS month,
  COUNT(*) AS monthly_tx_count
FROM savings_transactions
GROUP BY owner_id, txn_month
),
**Step 2: **Average the monthly counts for each user
Following the customer’s monthly counts, i calculated the average per month per user.

Took the output of Step 1 as a subquery and run:SELECT 
  owner_id,
  AVG(monthly_tx_count) AS avg_tx_per_month
FROM (
  -- (Step 1's query here)
) AS monthly_tx
GROUP BY owner_id
)
Step 3:Join with users_customuser and categorize
Attached customer details from the users_customuser table
Categorized based on the averageSELECT 
  u.id,
  u.first_name,
  u.last_name,
  freq.avg_tx_per_month,
  CASE 
    WHEN freq.avg_tx_per_month >= 10 THEN 'High Frequency'
    WHEN freq.avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
    ELSE 'Low Frequency'
  END AS frequency_category
FROM users_customuser u
JOIN (
) freq ON u.id = freq.owner_id
Why This Approach?
Grouping by year-month captures usage patterns over time
Averaging by month avoids favoring users active for fewer months
Joining back to user table gives access to names and lets us return full info
CASE statements are the cleanest way to assign categories based on ranges.

**CHALLENGE**

I was having inconsistent and missing trqnsaction dates while writing the query
Joins Returning More Rows Than Expected

**RESOLUTION**

In resolving this,i had to explore the data first: Run SELECT * with LIMIT 10 to carefullty inspect the structure and spot issues early.
Use CTEs (Common Table Expressions) for readability and step-by-step debugging.
Added comments in your SQL to explain why certain filters or logic are used.

**QUESTION 3**

**THE OBJECTIVES**

Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) 

**Approach Breakdown**

**Step 1**: Identified inflow transactions
* Confirmed_amount > 0
* transaction_date is within the last 365 days
This helped me find account with recents deposits
Step2:Flag active accounts
Step3:Used UNION to find accounts with no inflow in the last 365 days
-- Get active savings and investment accounts with no inflow in the past year

SELECT a.id AS account_id, a.owner_id, 'Savings' AS account_type
FROM savings_savingsaccount a
WHERE NOT EXISTS (
    SELECT 1
    FROM savings_transactions t
    WHERE t.account_id = a.id
      AND t.confirmed_amount > 0
      AND t.transaction_date >= DATE_SUB(CURDATE(), INTERVAL 365 DAY)
)

UNION

SELECT p.id AS account_id, p.owner_id, 'Investment' AS account_type
FROM plans_plan p
WHERE NOT EXISTS (
    SELECT 1
    FROM investment_transactions t
    WHERE t.plan_id = p.id
      AND t.confirmed_amount > 0
      AND t.transaction_date >= DATE_SUB(CURDATE(), INTERVAL 365 DAY)
);

**CHALLENGES**
No inflow definition
Merging results from two different tables with similar structure.

**RESOLUTION**

Used Confirmed_ amount > 0 as a proxy for deposits/inflows.
Applied UNION and tagged account type ('Savings' or 'Investment') in the result.

**QUESTION 4**

**THE OBJECTIVES**

 For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
Account tenure (months since signup)
Total transactions
Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
Order by estimated CLV from highest to lowest

**MY Approach **

users_customuser contains customer data (including signup date)
savings_transactions contains inflow/outflow data
Handled confirmed_amount as the transaction value
**Step 1**: Calculate tenure in months
Using MySQL’s TIMESTAMPDIFF(MONTH, signup_date, CURDATE()).
**Step 2**: Calculate total number of transactions and total value
Group by owner_id, using COUNT and SUM on confirmed_amount.
**Step 3**: Calculate average profit per transaction
profit_per_transaction = 0.001 * confirmed_amount, so:avg_profit_per_transaction = (SUM(confirmed_amount) * 0.001) / COUNT(*)
Step 4: Plug into CLV formula
CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction

**CHALLENGES**

Had issue with Confirmed amount in Kobo
Division by zero (e.g., tenure = 0 or no transactions)
Performance on large tables

**RESOLUTION**

Multiply/divide as needed to convert to Naira
Used NULLIF(..., 0) to avoid division errors
Use indexes on owner_id, confirmed_amount, and date_joined

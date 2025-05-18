-- Count how many transactions each customer made per month
WITH transactions_per_customer_month AS (
    SELECT 
        owner_id,
        DATE_FORMAT(created_on, '%Y-%m') AS txn_month,
        COUNT(*) AS monthly_txn_count
    FROM savings_savingsaccount
    GROUP BY owner_id, txn_month
),

-- Calculate average monthly transactions per customer
average_txn_per_customer AS (
    SELECT 
        owner_id,
        AVG(monthly_txn_count) AS avg_txn_per_month
    FROM transactions_per_customer_month
    GROUP BY owner_id
)

-- Join with user table and categorize frequency
SELECT 
    u.id AS user_id,
    u.first_name,
    u.last_name,
    a.avg_txn_per_month,
    
    -- Categorize frequency
    CASE
        WHEN a.avg_txn_per_month >= 10 THEN 'High Frequency'
        WHEN a.avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category

FROM 
    average_txn_per_customer a
JOIN 
    users_customuser u ON u.id = a.owner_id
ORDER BY 
    a.avg_txn_per_month DESC;

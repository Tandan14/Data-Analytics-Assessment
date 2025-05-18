-- Savings accounts: no inflow transactions in the last 365 days
SELECT 
    'savings' AS account_type,
    id AS account_id,
    owner_id,
    last_returns_date AS last_transaction
FROM savings_savingsaccount
WHERE last_returns_date < CURDATE() - INTERVAL 365 DAY
AND amount > 0

UNION

-- Investment plans: no inflow transactions in the last 365 days
SELECT 
    'investment' AS account_type,
    id AS account_id,
    owner_id,
    last_charge_date AS last_transaction
FROM plans_plan
WHERE 
    last_charge_date < CURDATE() - INTERVAL 365 DAY
    AND amount > 0;

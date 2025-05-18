-- SELECT customer info,total savings,investments,and combined deposits
SELECT 
    u.id AS user_id,
    u.first_name,
    u.last_name,
    s.total_savings,
    p.total_investments,
    (s.total_savings + p.total_investments) AS total_deposits
FROM 
    users_customuser u
    
    -- Subquery: Get total funding savings per customer
JOIN (
    SELECT owner_id, SUM(amount) AS total_savings
    FROM savings_savingsaccount
    WHERE amount > 0
    GROUP BY owner_id
) s ON u.id = s.owner_id

-- Subquery: Get total funded investment per customer
JOIN (
    SELECT owner_id, SUM(amount) AS total_investments
    FROM plans_plan
    WHERE amount > 0
    GROUP BY owner_id
) p ON u.id = p.owner_id
-- Sort results by total deposits (highest first)
ORDER BY total_deposits DESC;

-- Calculation of CLV for each customer 
SELECT 
    u.id AS user_id,
    u.first_name,
    u.last_name,

    -- Calculate account tenure in months
    TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()) AS tenure_months,

    -- Total number of inflow transactions
    COUNT(t.id) AS total_transactions,

    -- Average inflow amount (converted to Naira)
    ROUND(AVG(t.confirmed_amount) / 100, 2) AS avg_inflow_naira,

    -- Estimated CLV using provided formula
    ROUND((
        (COUNT(t.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()), 0))
        * 12
        * (0.001 * AVG(t.confirmed_amount))
    ) / 100, 2) AS estimated_clv_naira  -- Convert Kobo to Naira

FROM 
    users_customuser u

JOIN 
    savings_savingsaccount t ON u.id = t.owner_id

WHERE 
    t.confirmed_amount > 0  -- Only count inflow transactions

GROUP BY 
    u.id, u.first_name, u.last_name, u.created_on

ORDER BY 
    estimated_clv_naira DESC;

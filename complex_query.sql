WITH risky_vehicles AS ( 
    SELECT 
        Vehicles.vehicleID,
        Vehicles.make, 
        Vehicles.model,
        COUNT(*) AS old_vehicle_ticket_count
    FROM dev_insurance.Vehicles 
    JOIN prod_insurance.Tickets ON Vehicles.vehicleID = Tickets.vehicleID
    WHERE Vehicles.modelYear < YEAR(CURRENT_DATE) - 10 
      AND Tickets.issueDate > CURRENT_DATE - INTERVAL '2 years'
    GROUP BY Vehicles.vehicleID, Vehicles.make, Vehicles.model 
),

state_premiums AS (
    SELECT state, AVG(premium) as avg_state_premium
    FROM prod_insurance.Policies 
    JOIN prod_insurance.Customers ON Policies.customerID = Customers.customerID
    GROUP BY state
)

SELECT 
    Customers.name,
    risky_vehicles.make,
    risky_vehicles.model,
    Policies.endDate AS expiry,
    old_vehicle_ticket_count AS speeding_tickets,
    Policies.premium
FROM prod_insurance.Customers
INNER JOIN prod_insurance.Policies ON Customers.customerID = Policies.customerID
INNER JOIN risky_vehicles ON Policies.vehicleID = risky_vehicles.vehicleID
INNER JOIN state_premiums ON Customers.state = state_premiums.state
WHERE Policies.endDate BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days' 
 AND Policies.premium > state_premiums.avg_state_premium 
 AND old_vehicle_ticket_count > 2 
 AND ( 
    SELECT COUNT(*) 
    FROM prod_insurance.Tickets recent_tickets 
    WHERE recent_tickets.issueDate > CURRENT_DATE - INTERVAL '2 years' 
      AND recent_tickets.policyID = Policies.policyID 
) > 0; 

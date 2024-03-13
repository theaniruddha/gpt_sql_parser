SELECT 
        E.DepartmentID,
        D.Name AS DepartmentName,
        AVG(E.BaseSalary) AS AverageSalary,
        COUNT(*) AS NumberOfEmployees
    FROM Employee E
    JOIN Department D ON E.DepartmentID = D.DepartmentID
    WHERE E.BaseSalary > 50000
    GROUP BY E.DepartmentID, D.Name
    HAVING COUNT(*) > 10;
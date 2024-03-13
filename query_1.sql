SELECT 
        P.ProductID, 
        P.Name AS ProductName,
        SUM(SOD.OrderQty * SOD.UnitPrice) AS TotalSales,
        MAX(C.FirstName + ' ' + C.LastName) AS TopCustomerName,
        COUNT(DISTINCT SOH.CustomerID) AS NumberOfCustomers
    FROM SalesOrderDetail SOD
    JOIN SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
    JOIN Product P ON SOD.ProductID = P.ProductID
    JOIN Customer C ON SOH.CustomerID = C.CustomerID
    GROUP BY P.ProductID, P.Name
    ORDER BY TotalSales DESC;
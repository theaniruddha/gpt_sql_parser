SELECT 
        YEAR(SOH.OrderDate) AS OrderYear,
        MONTH(SOH.OrderDate) AS OrderMonth,
        PC.Name AS ProductCategory,
        SUM(SOD.OrderQty) AS TotalQuantitySold,
        SUM(SOD.LineTotal) AS TotalSalesValue,
        (SELECT AVG(SOD2.UnitPrice) 
         FROM SalesOrderDetail SOD2 
         WHERE YEAR(SOD2.ModifiedDate) = YEAR(SOH.OrderDate)
           AND MONTH(SOD2.ModifiedDate) = MONTH(SOH.OrderDate)) AS AverageSellingPrice
    FROM SalesOrderDetail SOD
    JOIN SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
    JOIN Product P ON SOD.ProductID = P.ProductID
    JOIN ProductCategory PC ON P.ProductCategoryID = PC.ProductCategoryID
    GROUP BY YEAR(SOH.OrderDate), MONTH(SOH.OrderDate), PC.Name
    ORDER BY OrderYear, OrderMonth, TotalSalesValue DESC;
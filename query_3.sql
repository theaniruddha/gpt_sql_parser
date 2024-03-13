WITH RankedSales AS (
        SELECT 
            PC.Name AS CategoryName,
            P.Name AS ProductName,
            SUM(SOD.UnitPrice * SOD.OrderQty) OVER (PARTITION BY PC.Name ORDER BY SUM(SOD.UnitPrice * SOD.OrderQty) DESC) AS TotalSales,
            RANK() OVER (PARTITION BY PC.Name ORDER BY SUM(SOD.UnitPrice * SOD.OrderQty) DESC) AS SalesRank
        FROM SalesOrderDetail SOD
        JOIN Product P ON SOD.ProductID = P.ProductID
        JOIN ProductCategory PC ON P.ProductCategoryID = PC.ProductCategoryID
        GROUP BY PC.Name, P.Name
    )
    SELECT CategoryName, ProductName, TotalSales, SalesRank
    FROM RankedSales
    WHERE SalesRank <= 3
    ORDER BY CategoryName, SalesRank;
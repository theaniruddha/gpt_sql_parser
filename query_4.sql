WITH ProductSales AS (
        SELECT 
            PC.ProductCategoryID,
            PC.Name AS CategoryName,
            P.ProductID,
            P.Name AS ProductName,
            SUM(SOD.OrderQty) AS TotalQuantity,
            COUNT(DISTINCT SOH.SalesOrderID) AS NumberOfOrders,
            SUM(SOD.LineTotal) AS TotalSales
        FROM SalesOrderDetail SOD
        JOIN SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
        JOIN Product P ON SOD.ProductID = P.ProductID
        JOIN ProductCategory PC ON P.ProductCategoryID = PC.ProductCategoryID
        WHERE SOH.OrderDate >= DATEADD(YEAR, -1, GETDATE())
        GROUP BY PC.ProductCategoryID, PC.Name, P.ProductID, P.Name
    ),
    RankedProducts AS (
        SELECT 
            ProductCategoryID,
            CategoryName,
            ProductID,
            ProductName,
            TotalQuantity,
            NumberOfOrders,
            TotalSales,
            RANK() OVER (PARTITION BY ProductCategoryID ORDER BY TotalSales DESC) AS SalesRank
        FROM ProductSales
    )
    SELECT 
        RP.CategoryName,
        RP.ProductName,
        RP.TotalQuantity,
        RP.NumberOfOrders,
        RP.TotalSales,
        (SELECT AVG(TotalQuantity) 
         FROM RankedProducts 
         WHERE SalesRank <= 3 AND ProductCategoryID = RP.ProductCategoryID) AS AverageQuantityForTopSellingProducts
    FROM RankedProducts RP
    WHERE RP.SalesRank <= 3
    ORDER BY RP.CategoryName, RP.SalesRank;
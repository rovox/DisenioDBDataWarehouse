USE Northwind_DW;
GO

INSERT INTO Northwind_DW.dbo.Fact_Sales (ProductKey, CustomerKey, EmployeeKey, DateKey, Quantity, UnitPrice)
SELECT 
    dp.ProductKey,
    dc.CustomerKey,
    de.EmployeeKey,
    CONVERT(VARCHAR(8), o.OrderDate, 112), 
    od.Quantity,
    od.UnitPrice
FROM Northwind.dbo.[OrderDetails] AS od
INNER JOIN Northwind.dbo.Orders AS o ON od.OrderID = o.OrderID
INNER JOIN Northwind_DW.dbo.Dim_Product AS dp ON od.ProductID = dp.ProductID
INNER JOIN Northwind_DW.dbo.Dim_Customer AS dc 
    ON o.CustomerID COLLATE DATABASE_DEFAULT = dc.CustomerID COLLATE DATABASE_DEFAULT
INNER JOIN Northwind_DW.dbo.Dim_Employee AS de ON o.EmployeeID = de.EmployeeID;
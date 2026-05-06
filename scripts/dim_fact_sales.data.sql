USE Northwind_DW;
GO

PRINT 'Cargando Hechos y calculando métricas de negocio...';

INSERT INTO dw.FactSalesLine (
    OrderID, 
    OrderLineNo, 
    OrderDateKey, 
    CustomerKey, 
    ProductKey, 
    Quantity, 
    UnitPrice, 
    Discount, 
    GrossSales, 
    DiscountAmount, 
    NetSales
)
SELECT 
    od.OrderID,
    ROW_NUMBER() OVER(PARTITION BY od.OrderID ORDER BY od.ProductID),
    CONVERT(INT, CONVERT(VARCHAR(8), o.OrderDate, 112)),
    cu.CustomerKey,
    pr.ProductKey,
    od.Quantity,
    od.UnitPrice,
    od.Discount,
    (CAST(od.Quantity AS DECIMAL(19,4)) * od.UnitPrice) AS GrossSales,
    (CAST(od.Quantity AS DECIMAL(19,4)) * od.UnitPrice * CAST(od.Discount AS DECIMAL(19,4))) AS DiscountAmount, -- Calculamos el descuento
    (CAST(od.Quantity AS DECIMAL(19,4)) * od.UnitPrice * (1 - CAST(od.Discount AS DECIMAL(19,4)))) AS NetSales
FROM NorthWind.dbo.OrderDetails od 
JOIN NorthWind.dbo.Orders o ON od.OrderID = o.OrderID
JOIN dw.DimCustomer cu ON cu.CustomerID COLLATE DATABASE_DEFAULT = o.CustomerID COLLATE DATABASE_DEFAULT
JOIN dw.DimProduct pr ON pr.ProductID = od.ProductID;
GO


/*
DW Northwind - esquema analítico orientado a ventas
Base OLTP: Northwind

Estrategia:
- Esquema dw
- Dimensiones conformadas: Date, Customer, Employee, Shipper, Category, Supplier, Product
- Hechos: FactOrderHeader y FactSalesLine
*/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dw')
    EXEC('CREATE SCHEMA dw');
GO

-- Limpieza opcional
-- revisar orden las fk
-- 1. Eliminar Vistas (si existen)
IF OBJECT_ID('dw.vw_SalesMonthly', 'V') IS NOT NULL DROP VIEW dw.vw_SalesMonthly;

-- 2. Eliminar las Tablas de Hechos (Hijos)
IF OBJECT_ID('dw.FactSalesLine', 'U') IS NOT NULL DROP TABLE dw.FactSalesLine;
IF OBJECT_ID('dw.FactOrderHeader', 'U') IS NOT NULL DROP TABLE dw.FactOrderHeader; -- ¡Esta era la que faltaba!

-- 3. Eliminar Dimensiones con dependencias (DimProduct depende de Supplier y Category)
IF OBJECT_ID('dw.DimProduct', 'U') IS NOT NULL DROP TABLE dw.DimProduct;

-- 4. Eliminar Dimensiones Base (Padres)
IF OBJECT_ID('dw.DimSupplier', 'U') IS NOT NULL DROP TABLE dw.DimSupplier;
IF OBJECT_ID('dw.DimCategory', 'U') IS NOT NULL DROP TABLE dw.DimCategory;
IF OBJECT_ID('dw.DimShipper', 'U') IS NOT NULL DROP TABLE dw.DimShipper;
IF OBJECT_ID('dw.DimEmployee', 'U') IS NOT NULL DROP TABLE dw.DimEmployee;
IF OBJECT_ID('dw.DimCustomer', 'U') IS NOT NULL DROP TABLE dw.DimCustomer;
IF OBJECT_ID('dw.DimDate', 'U') IS NOT NULL DROP TABLE dw.DimDate;
GO

CREATE TABLE dw.DimDate (
    DateKey         int         NOT NULL PRIMARY KEY,  -- yyyymmdd
    FullDate        date        NOT NULL UNIQUE,
    [Year]          smallint    NOT NULL,
    QuarterOfYear   tinyint     NOT NULL,
    MonthOfYear     tinyint     NOT NULL,
    MonthName       nvarchar(15) NOT NULL,
    DayOfMonth      tinyint     NOT NULL,
    DayOfWeek       tinyint     NOT NULL,
    DayName         nvarchar(15) NOT NULL,
    WeekOfYear      tinyint     NOT NULL,
    IsWeekend       bit         NOT NULL,
    IsHoliday       bit         NOT NULL DEFAULT(0)
);

CREATE TABLE dw.DimCustomer (
    CustomerKey     int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerID      nchar(5) NOT NULL,
    CompanyName     nvarchar(40) NOT NULL,
    ContactName     nvarchar(30) NULL,
    ContactTitle    nvarchar(30) NULL,
    City            nvarchar(15) NULL,
    Region          nvarchar(15) NULL,
    PostalCode      nvarchar(10) NULL,
    Country         nvarchar(15) NULL,
    Phone           nvarchar(24) NULL,
    IsCurrent       bit NOT NULL DEFAULT(1),
    CONSTRAINT UQ_DimCustomer_BK UNIQUE (CustomerID)
);

CREATE TABLE dw.DimEmployee (
    EmployeeKey     int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EmployeeID      int NOT NULL,
    FullName        nvarchar(61) NOT NULL,
    Title           nvarchar(30) NULL,
    TitleOfCourtesy nvarchar(25) NULL,
    BirthDate       date NULL,
    HireDate        date NULL,
    City            nvarchar(15) NULL,
    Region          nvarchar(15) NULL,
    Country         nvarchar(15) NULL,
    ReportsTo       int NULL,
    IsCurrent       bit NOT NULL DEFAULT(1),
    CONSTRAINT UQ_DimEmployee_BK UNIQUE (EmployeeID)
);

CREATE TABLE dw.DimShipper (
    ShipperKey      int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ShipperID       int NOT NULL,
    CompanyName     nvarchar(40) NOT NULL,
    Phone           nvarchar(24) NULL,
    CONSTRAINT UQ_DimShipper_BK UNIQUE (ShipperID)
);

CREATE TABLE dw.DimCategory (
    CategoryKey     int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CategoryID      int NOT NULL,
    CategoryName    nvarchar(15) NOT NULL,
    Description     nvarchar(max) NULL,
    CONSTRAINT UQ_DimCategory_BK UNIQUE (CategoryID)
);

CREATE TABLE dw.DimSupplier (
    SupplierKey     int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SupplierID      int NOT NULL,
    CompanyName     nvarchar(40) NOT NULL,
    ContactName     nvarchar(30) NULL,
    ContactTitle    nvarchar(30) NULL,
    City            nvarchar(15) NULL,
    Region          nvarchar(15) NULL,
    PostalCode      nvarchar(10) NULL,
    Country         nvarchar(15) NULL,
    Phone           nvarchar(24) NULL,
    HomePage        nvarchar(max) NULL,
    CONSTRAINT UQ_DimSupplier_BK UNIQUE (SupplierID)
);

CREATE TABLE dw.DimProduct (
    ProductKey      int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProductID       int NOT NULL,
    ProductName     nvarchar(40) NOT NULL,
    CategoryKey     int NOT NULL,
    SupplierKey     int NOT NULL,
    QuantityPerUnit nvarchar(20) NULL,
    UnitPrice       decimal(19,4) NULL,
    UnitsInStock    smallint NULL,
    UnitsOnOrder    smallint NULL,
    ReorderLevel    smallint NULL,
    Discontinued    bit NOT NULL,
    CONSTRAINT UQ_DimProduct_BK UNIQUE (ProductID),
    CONSTRAINT FK_DimProduct_Category FOREIGN KEY (CategoryKey) REFERENCES dw.DimCategory(CategoryKey),
    CONSTRAINT FK_DimProduct_Supplier FOREIGN KEY (SupplierKey) REFERENCES dw.DimSupplier(SupplierKey)
);

CREATE TABLE dw.FactOrderHeader (
    OrderFactKey        bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    OrderID             int NOT NULL,   -- dimensión degenerada
    OrderDateKey        int NOT NULL,
    RequiredDateKey     int NULL,
    ShippedDateKey      int NULL,
    CustomerKey         int NOT NULL,
    EmployeeKey         int NULL,
    ShipperKey          int NULL,
    OrderLineCount      int NOT NULL,
    TotalQuantity       int NOT NULL,
    GrossSales          decimal(19,4) NOT NULL,
    DiscountAmount      decimal(19,4) NOT NULL,
    NetSales            decimal(19,4) NOT NULL,
    FreightAmount       decimal(19,4) NULL,
    OrderLeadDays       int NULL,
    ShipDelayDays       int NULL,
    CONSTRAINT UQ_FactOrderHeader UNIQUE (OrderID),
    CONSTRAINT FK_FactOrderHeader_OrderDate FOREIGN KEY (OrderDateKey) REFERENCES dw.DimDate(DateKey),
    CONSTRAINT FK_FactOrderHeader_RequiredDate FOREIGN KEY (RequiredDateKey) REFERENCES dw.DimDate(DateKey),
    CONSTRAINT FK_FactOrderHeader_ShippedDate FOREIGN KEY (ShippedDateKey) REFERENCES dw.DimDate(DateKey),
    CONSTRAINT FK_FactOrderHeader_Customer FOREIGN KEY (CustomerKey) REFERENCES dw.DimCustomer(CustomerKey),
    CONSTRAINT FK_FactOrderHeader_Employee FOREIGN KEY (EmployeeKey) REFERENCES dw.DimEmployee(EmployeeKey),
    CONSTRAINT FK_FactOrderHeader_Shipper FOREIGN KEY (ShipperKey) REFERENCES dw.DimShipper(ShipperKey)
);
GO

CREATE TABLE dw.FactSalesLine (
    SalesLineKey        bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    OrderID             int NOT NULL,             -- dimensión degenerada
    OrderLineNo         int NOT NULL,
    OrderDateKey        int NOT NULL,
    RequiredDateKey     int NULL,
    ShippedDateKey      int NULL,
    CustomerKey         int NOT NULL,
    EmployeeKey         int NULL,
    ShipperKey          int NULL,
    ProductKey          int NOT NULL,
    Quantity            int NOT NULL,
    UnitPrice           decimal(19,4) NOT NULL,
    Discount            decimal(9,4) NOT NULL,
    GrossSales          decimal(19,4) NOT NULL,
    DiscountAmount      decimal(19,4) NOT NULL,
    NetSales            decimal(19,4) NOT NULL,
    CONSTRAINT UQ_FactSalesLine UNIQUE (OrderID, OrderLineNo),
    CONSTRAINT FK_FactSalesLine_OrderDate FOREIGN KEY (OrderDateKey) REFERENCES dw.DimDate(DateKey),
    CONSTRAINT FK_FactSalesLine_RequiredDate FOREIGN KEY (RequiredDateKey) REFERENCES dw.DimDate(DateKey),
    CONSTRAINT FK_FactSalesLine_ShippedDate FOREIGN KEY (ShippedDateKey) REFERENCES dw.DimDate(DateKey),
    CONSTRAINT FK_FactSalesLine_Customer FOREIGN KEY (CustomerKey) REFERENCES dw.DimCustomer(CustomerKey),
    CONSTRAINT FK_FactSalesLine_Employee FOREIGN KEY (EmployeeKey) REFERENCES dw.DimEmployee(EmployeeKey),
    CONSTRAINT FK_FactSalesLine_Shipper FOREIGN KEY (ShipperKey) REFERENCES dw.DimShipper(ShipperKey),
    CONSTRAINT FK_FactSalesLine_Product FOREIGN KEY (ProductKey) REFERENCES dw.DimProduct(ProductKey)
);
GO

/* Carga de dimensiones desde Northwind OLTP.
   Ajusta el nombre de la BD OLTP si no es NorthWind.
*/

-- DimDate: rango basado en la fecha mínima y máxima de CUALQUIER evento del pedido
DECLARE @MinDate date, @MaxDate date;

SELECT 
    @MinDate = MIN(dt), 
    @MaxDate = MAX(dt)
FROM (
    SELECT CONVERT(date, OrderDate) AS dt FROM Northwind.dbo.Orders
    UNION
    SELECT CONVERT(date, RequiredDate) FROM Northwind.dbo.Orders
    UNION
    SELECT CONVERT(date, ShippedDate) FROM Northwind.dbo.Orders
) AS TodasLasFechas
WHERE dt IS NOT NULL;

-- Asignar valores por defecto en caso de que la tabla de origen esté vacía
SET @MinDate = ISNULL(@MinDate, '1996-01-01');
SET @MaxDate = ISNULL(@MaxDate, '1998-12-31');

;WITH d AS (
    SELECT @MinDate AS dt
    UNION ALL
    SELECT DATEADD(day, 1, dt) FROM d WHERE dt < @MaxDate
)
INSERT INTO dw.DimDate(DateKey, FullDate, [Year], QuarterOfYear, MonthOfYear, MonthName, DayOfMonth, DayOfWeek, DayName, WeekOfYear, IsWeekend, IsHoliday)
SELECT
    CONVERT(int, CONVERT(char(8), dt, 112)),
    dt,
    YEAR(dt),
    DATEPART(quarter, dt),
    MONTH(dt),
    DATENAME(month, dt),
    DAY(dt),
    DATEPART(weekday, dt),
    DATENAME(weekday, dt),
    DATEPART(week, dt),
    CASE WHEN DATEPART(weekday, dt) IN (1,7) THEN 1 ELSE 0 END,
    0
FROM d
OPTION (MAXRECURSION 0);

INSERT INTO dw.DimCustomer (CustomerID, CompanyName, ContactName, ContactTitle, City, Region, PostalCode, Country, Phone)
SELECT CustomerID, CompanyName, ContactName, ContactTitle, City, Region, PostalCode, Country, Phone
FROM Northwind.dbo.Customers;

INSERT INTO dw.DimEmployee (EmployeeID, FullName, Title, TitleOfCourtesy, BirthDate, HireDate, City, Region, Country, ReportsTo)
SELECT
    EmployeeID,
    CONCAT(FirstName, ' ', LastName),
    Title, TitleOfCourtesy,
    CONVERT(date, BirthDate),
    CONVERT(date, HireDate),
    City, Region, Country, ReportsTo
FROM Northwind.dbo.Employees;

INSERT INTO dw.DimShipper (ShipperID, CompanyName, Phone)
SELECT ShipperID, CompanyName, Phone
FROM Northwind.dbo.Shippers;

INSERT INTO dw.DimCategory (CategoryID, CategoryName, Description)
SELECT CategoryID, CategoryName, Description
FROM Northwind.dbo.Categories;

INSERT INTO dw.DimSupplier (SupplierID, CompanyName, ContactName, ContactTitle, City, Region, PostalCode, Country, Phone, HomePage)
SELECT SupplierID, CompanyName, ContactName, ContactTitle, City, Region, PostalCode, Country, Phone, HomePage
FROM Northwind.dbo.Suppliers;

INSERT INTO dw.DimProduct
(
    ProductID, ProductName, CategoryKey, SupplierKey, QuantityPerUnit,
    UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued
)
SELECT
    p.ProductID,
    p.ProductName,
    c.CategoryKey,
    s.SupplierKey,
    p.QuantityPerUnit,
    CONVERT(decimal(19,4), p.UnitPrice),
    p.UnitsInStock,
    p.UnitsOnOrder,
    p.ReorderLevel,
    p.Discontinued
FROM Northwind.dbo.Products p
JOIN dw.DimCategory c ON c.CategoryID = p.CategoryID
JOIN dw.DimSupplier s ON s.SupplierID = p.SupplierID;

-- Hecho de cabecera: una fila por pedido
INSERT INTO dw.FactOrderHeader
(
    OrderID, OrderDateKey, RequiredDateKey, ShippedDateKey,
    CustomerKey, EmployeeKey, ShipperKey,
    OrderLineCount, TotalQuantity, GrossSales, DiscountAmount, NetSales,
    FreightAmount, OrderLeadDays, ShipDelayDays
)
SELECT
    o.OrderID,
    CONVERT(int, CONVERT(char(8), CONVERT(date, o.OrderDate), 112)),
    CONVERT(int, CONVERT(char(8), CONVERT(date, o.RequiredDate), 112)),
    CONVERT(int, CONVERT(char(8), CONVERT(date, o.ShippedDate), 112)),
    c.CustomerKey,
    e.EmployeeKey,
    s.ShipperKey,
    COUNT(od.ProductID) AS OrderLineCount,
    SUM(CAST(od.Quantity AS int)) AS TotalQuantity,
    SUM(CONVERT(decimal(19,4), od.Quantity * od.UnitPrice)) AS GrossSales,
    SUM(CONVERT(decimal(19,4), od.Quantity * od.UnitPrice * od.Discount)) AS DiscountAmount,
    SUM(CONVERT(decimal(19,4), od.Quantity * od.UnitPrice * (1 - od.Discount))) AS NetSales,
    CONVERT(decimal(19,4), o.Freight),
    CASE WHEN o.OrderDate IS NOT NULL AND o.RequiredDate IS NOT NULL
         THEN DATEDIFF(day, CONVERT(date, o.OrderDate), CONVERT(date, o.RequiredDate))
         END,
    CASE WHEN o.ShippedDate IS NOT NULL AND o.OrderDate IS NOT NULL
         THEN DATEDIFF(day, CONVERT(date, o.OrderDate), CONVERT(date, o.ShippedDate))
         END
FROM Northwind.dbo.Orders o
JOIN Northwind.dbo.OrderDetails od ON od.OrderID = o.OrderID
JOIN dw.DimCustomer c            ON c.CustomerID = o.CustomerID
LEFT JOIN dw.DimEmployee e       ON e.EmployeeID = o.EmployeeID
LEFT JOIN dw.DimShipper s        ON s.ShipperID = o.ShipVia
GROUP BY
    o.OrderID, o.OrderDate, o.RequiredDate, o.ShippedDate,
    c.CustomerKey, e.EmployeeKey, s.ShipperKey, o.Freight;
GO

-- Hecho de detalle: una fila por línea de pedido
INSERT INTO dw.FactSalesLine
(
    OrderID, OrderLineNo, OrderDateKey, RequiredDateKey, ShippedDateKey,
    CustomerKey, EmployeeKey, ShipperKey, ProductKey,
    Quantity, UnitPrice, Discount,
    GrossSales, DiscountAmount, NetSales
)
SELECT
    od.OrderID,
    ROW_NUMBER() OVER (PARTITION BY od.OrderID ORDER BY od.ProductID) AS OrderLineNo,
    CONVERT(int, CONVERT(char(8), CONVERT(date, o.OrderDate), 112)),
    CONVERT(int, CONVERT(char(8), CONVERT(date, o.RequiredDate), 112)),
    CONVERT(int, CONVERT(char(8), CONVERT(date, o.ShippedDate), 112)),
    c.CustomerKey,
    e.EmployeeKey,
    s.ShipperKey,
    p.ProductKey,
    CAST(od.Quantity AS int),
    CONVERT(decimal(19,4), od.UnitPrice),
    CONVERT(decimal(9,4), od.Discount),
    CONVERT(decimal(19,4), od.Quantity * od.UnitPrice),
    CONVERT(decimal(19,4), od.Quantity * od.UnitPrice * od.Discount),
    CONVERT(decimal(19,4), od.Quantity * od.UnitPrice * (1 - od.Discount))
FROM Northwind.dbo.OrderDetails od
JOIN Northwind.dbo.Orders o      ON o.OrderID = od.OrderID
JOIN dw.DimCustomer c            ON c.CustomerID = o.CustomerID
LEFT JOIN dw.DimEmployee e       ON e.EmployeeID = o.EmployeeID
LEFT JOIN dw.DimShipper s        ON s.ShipperID = o.ShipVia
JOIN dw.DimProduct p             ON p.ProductID = od.ProductID;
GO

-- Índices recomendados
CREATE INDEX IX_FactOrderHeader_OrderDateKey ON dw.FactOrderHeader(OrderDateKey);
CREATE INDEX IX_FactOrderHeader_CustomerKey  ON dw.FactOrderHeader(CustomerKey);
CREATE INDEX IX_FactSalesLine_OrderDateKey   ON dw.FactSalesLine(OrderDateKey);
CREATE INDEX IX_FactSalesLine_CustomerKey    ON dw.FactSalesLine(CustomerKey);
CREATE INDEX IX_FactSalesLine_ProductKey     ON dw.FactSalesLine(ProductKey);
GO

-- Vista agregada útil para análisis
CREATE OR ALTER VIEW dw.vw_SalesMonthly AS
SELECT
    d.[Year],
    d.MonthOfYear,
    d.MonthName,
    c.Country AS CustomerCountry,
    cat.CategoryName,
    SUM(f.Quantity) AS TotalQuantity,
    SUM(f.NetSales) AS TotalNetSales,
    SUM(f.DiscountAmount) AS TotalDiscountAmount,
    COUNT(*) AS Lines
FROM dw.FactSalesLine f
JOIN dw.DimDate d       ON d.DateKey = f.OrderDateKey
JOIN dw.DimCustomer c   ON c.CustomerKey = f.CustomerKey
JOIN dw.DimProduct p    ON p.ProductKey = f.ProductKey
JOIN dw.DimCategory cat ON cat.CategoryKey = p.CategoryKey
GROUP BY d.[Year], d.MonthOfYear, d.MonthName, c.Country, cat.CategoryName;
GO

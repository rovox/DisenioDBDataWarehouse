USE master;
GO
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'Northwind_DW')
    CREATE DATABASE Northwind_DW;
GO
USE Northwind_DW;
GO

-- DIMENSIÓN: PRODUCTOS
CREATE TABLE Dim_Product (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY, -- Llave para el DW
    ProductID INT NOT NULL,                   -- Llave origen (Northwind)
    ProductName NVARCHAR(40) NOT NULL,
    CategoryName NVARCHAR(15),                -- Desnormalizado
    SupplierName NVARCHAR(40),
    UnitPrice MONEY
);

-- DIMENSIÓN: CLIENTES
CREATE TABLE Dim_Customer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NCHAR(5) NOT NULL,             -- Llave origen
    CompanyName NVARCHAR(40) NOT NULL,
    City NVARCHAR(15),
    Region NVARCHAR(15),
    Country NVARCHAR(15)
);

-- DIMENSIÓN: EMPLEADOS
CREATE TABLE Dim_Employee (
    EmployeeKey INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,                  -- Llave origen
    EmployeeName NVARCHAR(40) NOT NULL,       -- Nombre Completo
    Title NVARCHAR(30),
    ReportsToName NVARCHAR(40)                -- Jerarquía simple
);

-- DIMENSIÓN: TIEMPO (Estructura base)
CREATE TABLE Dim_Date (
    DateKey INT PRIMARY KEY,                  -- Formato AAAAMMDD
    FullDate DATE NOT NULL,
    Day INT NOT NULL,
    Month INT NOT NULL,
    MonthName NVARCHAR(15) NOT NULL,
    Quarter INT NOT NULL,
    Year INT NOT NULL,
    DayOfWeekName NVARCHAR(15) NOT NULL
);

CREATE TABLE Fact_Sales (
    SalesKey INT IDENTITY(1,1) PRIMARY KEY,
    -- Llaves foráneas (FK)
    ProductKey INT NOT NULL CONSTRAINT FK_FactSales_Product REFERENCES Dim_Product(ProductKey),
    CustomerKey INT NOT NULL CONSTRAINT FK_FactSales_Customer REFERENCES Dim_Customer(CustomerKey),
    EmployeeKey INT NOT NULL CONSTRAINT FK_FactSales_Employee REFERENCES Dim_Employee(EmployeeKey),
    OrderDateKey INT NOT NULL CONSTRAINT FK_FactSales_Date REFERENCES Dim_Date(DateKey),
    
    -- Métricas de negocio
    OrderID INT NOT NULL,       -- ID original para auditoría
    Quantity INT NOT NULL,
    UnitPrice MONEY NOT NULL,
    Discount REAL NOT NULL,
    TotalRevenue AS (Quantity * UnitPrice * (1 - Discount)) PERSISTED, -- Calculado
    
    -- Metadatos de carga
    ETL_LoadDate DATETIME DEFAULT GETDATE()
);
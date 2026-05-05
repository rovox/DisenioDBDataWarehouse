USE Northwind_DW;
GO

-- 1. Calendario (Evita el conflicto FK_Fact_Date)
DECLARE @StartDate DATE = '1996-01-01';
WHILE @StartDate <= '1999-12-31'
BEGIN
    INSERT INTO Dim_Date (DateKey, FullDate, Day, Month, MonthName, Quarter, Year)
    VALUES (CONVERT(INT, CONVERT(VARCHAR(8), @StartDate, 112)), @StartDate, DAY(@StartDate), MONTH(@StartDate), DATENAME(MONTH, @StartDate), DATEPART(QUARTER, @StartDate), YEAR(@StartDate));
    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END

-- 2. Productos
INSERT INTO Dim_Product (ProductID, ProductName, CategoryName, UnitPrice)
SELECT p.ProductID, p.ProductName, c.CategoryName, p.UnitPrice FROM Northwind.dbo.Products p JOIN Northwind.dbo.Categories c ON p.CategoryID = c.CategoryID;

-- 3. Clientes
INSERT INTO Dim_Customer (CustomerID, CompanyName, City, Country)
SELECT CustomerID, CompanyName, City, Country FROM Northwind.dbo.Customers;

-- 4. Empleados
INSERT INTO Dim_Employee (EmployeeID, EmployeeName, Title)
SELECT EmployeeID, FirstName + ' ' + LastName, Title FROM Northwind.dbo.Employees;
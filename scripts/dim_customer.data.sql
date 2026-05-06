USE Northwind_DW;
GO

INSERT INTO dw.DimCustomer (CustomerID, CompanyName, ContactName, City, Country)
SELECT 
    CustomerID COLLATE DATABASE_DEFAULT, 
    CompanyName COLLATE DATABASE_DEFAULT, 
    ContactName COLLATE DATABASE_DEFAULT, 
    City COLLATE DATABASE_DEFAULT, 
    Country COLLATE DATABASE_DEFAULT
FROM NorthWind.dbo.Customers;
GO

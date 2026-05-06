USE Northwind_DW;
GO
PRINT 'Cargando Categorías y Proveedores...';
INSERT INTO dw.DimCategory (CategoryID, CategoryName)
SELECT CategoryID, CategoryName COLLATE DATABASE_DEFAULT FROM NorthWind.dbo.Categories;

INSERT INTO dw.DimSupplier (SupplierID, CompanyName)
SELECT SupplierID, CompanyName COLLATE DATABASE_DEFAULT FROM NorthWind.dbo.Suppliers;

PRINT 'Cargando Productos...';
INSERT INTO dw.DimProduct (ProductID, ProductName, CategoryKey, SupplierKey, UnitPrice, Discontinued)
SELECT 
    p.ProductID, 
    p.ProductName COLLATE DATABASE_DEFAULT, 
    c.CategoryKey, 
    s.SupplierKey, 
    p.UnitPrice, 
    p.Discontinued
FROM NorthWind.dbo.Products p
JOIN dw.DimCategory c ON p.CategoryID = c.CategoryID
JOIN dw.DimSupplier s ON p.SupplierID = s.SupplierID;
GO

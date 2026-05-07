# ✅ Validación de Integridad y Consistencia

## Introducción

Este documento detalla todos los procedimientos y consultas SQL necesarios para validar que el OLTP y el Data Warehouse funcionan correctamente y que los datos son consistentes.

---

## 1. Validación OLTP

### 1.1 Verificar Integridad Referencial

```sql
USE Northwind;

-- 1. Registros huérfanos en OrderDetails (sin Order asociada)
SELECT od.OrderID, od.ProductID
FROM OrderDetails od
LEFT JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.OrderID IS NULL;
-- Resultado esperado: 0 filas

-- 2. Registros huérfanos en Orders (sin Customer)
SELECT o.OrderID, o.CustomerID
FROM Orders o
LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;
-- Resultado esperado: 0 filas

-- 3. Registros huérfanos en Orders (sin Employee)
SELECT o.OrderID, o.EmployeeID
FROM Orders o
LEFT JOIN Employees e ON o.EmployeeID = e.EmployeeID
WHERE e.EmployeeID IS NULL;
-- Resultado esperado: 0 filas

-- 4. Registros huérfanos en Orders (sin Shipper)
SELECT o.OrderID, o.ShipperID
FROM Orders o
LEFT JOIN Shippers s ON o.ShipperID = s.ShipperID
WHERE s.ShipperID IS NULL;
-- Resultado esperado: 0 filas

-- 5. Registros huérfanos en Products (sin Category)
SELECT p.ProductID, p.CategoryID
FROM Products p
LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE c.CategoryID IS NULL;
-- Resultado esperado: 0 filas

-- 6. Registros huérfanos en Products (sin Supplier)
SELECT p.ProductID, p.SupplierID
FROM Products p
LEFT JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE s.SupplierID IS NULL;
-- Resultado esperado: 0 filas
```

### 1.2 Validar Constraints CHECK

```sql
USE Northwind;

-- 1. Validar que todos los descuentos están entre 0 y 1
SELECT OrderID, ProductID, Discount
FROM OrderDetails
WHERE Discount < 0 OR Discount > 1;
-- Resultado esperado: 0 filas

-- 2. Validar que todas las cantidades son > 0
SELECT OrderID, ProductID, Quantity
FROM OrderDetails
WHERE Quantity <= 0;
-- Resultado esperado: 0 filas

-- 3. Validar que todos los precios unitarios son >= 0
SELECT OrderID, ProductID, UnitPrice
FROM OrderDetails
WHERE UnitPrice < 0;
-- Resultado esperado: 0 filas

-- 4. Validar que todos los precios de productos son >= 0
SELECT ProductID, UnitPrice
FROM Products
WHERE UnitPrice < 0;
-- Resultado esperado: 0 filas

-- 5. Validar fechas de nacimiento de empleados
SELECT EmployeeID, FirstName, LastName, BirthDate
FROM Employees
WHERE BirthDate >= CAST(GETDATE() AS DATE);
-- Resultado esperado: 0 filas

-- 6. Validar que fechas de envío no sean anteriores a fecha de orden
SELECT OrderID, OrderDate, ShippedDate
FROM Orders
WHERE ShippedDate IS NOT NULL AND ShippedDate < OrderDate;
-- Resultado esperado: 0 filas
```

### 1.3 Validar Unicidad

```sql
USE Northwind;

-- 1. Validar CustomerID único
SELECT CustomerID, COUNT(*) AS Duplicados
FROM Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;
-- Resultado esperado: 0 filas

-- 2. Validar ProductID único (con ProductName único)
SELECT ProductID, ProductName
FROM Products
GROUP BY ProductID, ProductName
HAVING COUNT(*) > 1;
-- Resultado esperado: 0 filas

-- 3. Validar que CategoryName sea único
SELECT CategoryName, COUNT(*) AS Duplicados
FROM Categories
GROUP BY CategoryName
HAVING COUNT(*) > 1;
-- Resultado esperado: 0 filas
```

### 1.4 Resumen de Datos OLTP

```sql
USE Northwind;

-- Contar registros por tabla
SELECT 
    'Customers' AS Tabla, COUNT(*) AS Registros FROM Customers
UNION ALL SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL SELECT 'OrderDetails', COUNT(*) FROM OrderDetails
UNION ALL SELECT 'Products', COUNT(*) FROM Products
UNION ALL SELECT 'Categories', COUNT(*) FROM Categories
UNION ALL SELECT 'Suppliers', COUNT(*) FROM Suppliers
UNION ALL SELECT 'Employees', COUNT(*) FROM Employees
UNION ALL SELECT 'Shippers', COUNT(*) FROM Shippers
UNION ALL SELECT 'Region', COUNT(*) FROM Region
UNION ALL SELECT 'Territories', COUNT(*) FROM Territories
UNION ALL SELECT 'EmployeeTerritories', COUNT(*) FROM EmployeeTerritories
ORDER BY Tabla;
```

---

## 2. Validación Data Warehouse

### 2.1 Verificar Integridad Referencial en FactSales

```sql
USE NorthWindDW;

-- 1. Verificar que todas las CustomerSK sean válidas
SELECT COUNT(*) AS InvalidCustomers
FROM FactSales fs
LEFT JOIN DimCustomer dc ON fs.CustomerSK = dc.CustomerSK
WHERE dc.CustomerSK IS NULL;
-- Resultado esperado: 0

-- 2. Verificar que todas las ProductSK sean válidas
SELECT COUNT(*) AS InvalidProducts
FROM FactSales fs
LEFT JOIN DimProduct dp ON fs.ProductSK = dp.ProductSK
WHERE dp.ProductSK IS NULL;
-- Resultado esperado: 0

-- 3. Verificar que todas las EmployeeSK sean válidas
SELECT COUNT(*) AS InvalidEmployees
FROM FactSales fs
LEFT JOIN DimEmployee de ON fs.EmployeeSK = de.EmployeeSK
WHERE de.EmployeeSK IS NULL;
-- Resultado esperado: 0

-- 4. Verificar que todas las ShipperSK sean válidas
SELECT COUNT(*) AS InvalidShippers
FROM FactSales fs
LEFT JOIN DimShipper ds ON fs.ShipperSK = ds.ShipperSK
WHERE ds.ShipperSK IS NULL;
-- Resultado esperado: 0

-- 5. Verificar que todas las OrderDateKey sean válidas
SELECT COUNT(*) AS InvalidOrderDates
FROM FactSales fs
LEFT JOIN DimDate dd ON fs.OrderDateKey = dd.DateKey
WHERE dd.DateKey IS NULL;
-- Resultado esperado: 0

-- 6. Verificar que todas las ShipLocationSK sean válidas
SELECT COUNT(*) AS InvalidLocations
FROM FactSales fs
LEFT JOIN DimShipLocation dsl ON fs.ShipLocationSK = dsl.ShipLocationSK
WHERE dsl.ShipLocationSK IS NULL;
-- Resultado esperado: 0
```

### 2.2 Validar Datos en Dimensiones

```sql
USE NorthWindDW;

-- 1. Verificar que no hayan nombres de clientes vacíos
SELECT COUNT(*) AS EmptyNames
FROM DimCustomer
WHERE CompanyName IS NULL OR CompanyName = '';
-- Resultado esperado: 0

-- 2. Verificar que no hayan productos con nombre vacío
SELECT COUNT(*) AS EmptyNames
FROM DimProduct
WHERE ProductName IS NULL OR ProductName = '';
-- Resultado esperado: 0

-- 3. Verificar que no hayan empleados sin nombre
SELECT COUNT(*) AS EmptyNames
FROM DimEmployee
WHERE FirstName IS NULL OR LastName IS NULL;
-- Resultado esperado: 0

-- 4. Verificar que las fechas en DimDate sean válidas
SELECT COUNT(*) AS InvalidDates
FROM DimDate
WHERE 
    DayNumber < 1 OR DayNumber > 31 OR
    MonthNumber < 1 OR MonthNumber > 12 OR
    YearNumber < 1990 OR YearNumber > 2100;
-- Resultado esperado: 0

-- 5. Verificar cobertura de DimDate
SELECT MIN(YearNumber) AS MinYear, MAX(YearNumber) AS MaxYear,
       MIN(FullDate) AS MinDate, MAX(FullDate) AS MaxDate
FROM DimDate;
-- Resultado esperado: Años 1996-1998, fechas coherentes
```

### 2.3 Validar Métricas de FactSales

```sql
USE NorthWindDW;

-- 1. Verificar que no hayan cantidades negativas
SELECT COUNT(*) AS NegativeQty
FROM FactSales
WHERE Quantity < 0;
-- Resultado esperado: 0

-- 2. Verificar que no hayan precios negativos
SELECT COUNT(*) AS NegativePrices
FROM FactSales
WHERE UnitPrice < 0 OR ExtendedPrice < 0;
-- Resultado esperado: 0

-- 3. Verificar que descuentos estén entre 0 y 1
SELECT COUNT(*) AS InvalidDiscounts
FROM FactSales
WHERE Discount < 0 OR Discount > 1;
-- Resultado esperado: 0

-- 4. Validar cálculo de ExtendedPrice
SELECT COUNT(*) AS CalculationErrors
FROM FactSales
WHERE ExtendedPrice <> Quantity * UnitPrice * (1 - Discount);
-- Resultado esperado: 0
```

### 2.4 Resumen de Datos DW

```sql
USE NorthWindDW;

-- Contar registros por tabla
SELECT 
    'DimCustomer' AS Tabla, COUNT(*) AS Registros FROM DimCustomer
UNION ALL SELECT 'DimProduct', COUNT(*) FROM DimProduct
UNION ALL SELECT 'DimEmployee', COUNT(*) FROM DimEmployee
UNION ALL SELECT 'DimShipper', COUNT(*) FROM DimShipper
UNION ALL SELECT 'DimDate', COUNT(*) FROM DimDate
UNION ALL SELECT 'DimShipLocation', COUNT(*) FROM DimShipLocation
UNION ALL SELECT 'FactSales', COUNT(*) FROM FactSales
ORDER BY Tabla;
```

---

## 3. Reconciliación OLTP vs. DW

### 3.1 Totales de Ventas

```sql
-- Consulta que compara ambas bases de datos

SELECT 
    'OLTP' AS Fuente,
    SUM(Quantity * UnitPrice * (1 - Discount)) AS TotalVentas,
    COUNT(*) AS NumeroLineas
FROM Northwind.dbo.OrderDetails

UNION ALL

SELECT 
    'DW' AS Fuente,
    SUM(ExtendedPrice) AS TotalVentas,
    COUNT(*) AS NumeroLineas
FROM NorthWindDW.dbo.FactSales;

-- Resultado esperado: 
-- OLTP y DW deben tener el mismo total y número de líneas
```

### 3.2 Conteo de Registros por Dimensión

```sql
-- Verificar que el número de clientes coincida
SELECT 
    'OLTP Customers' AS Fuente, COUNT(*) AS Cantidad
FROM Northwind.dbo.Customers

UNION ALL

SELECT 
    'DW DimCustomer', COUNT(*)
FROM NorthWindDW.dbo.DimCustomer;

-- Verificar que el número de productos coincida
SELECT 
    'OLTP Products' AS Fuente, COUNT(*) AS Cantidad
FROM Northwind.dbo.Products

UNION ALL

SELECT 
    'DW DimProduct', COUNT(*)
FROM NorthWindDW.dbo.DimProduct;

-- Verificar que el número de empleados coincida
SELECT 
    'OLTP Employees' AS Fuente, COUNT(*) AS Cantidad
FROM Northwind.dbo.Employees

UNION ALL

SELECT 
    'DW DimEmployee', COUNT(*)
FROM NorthWindDW.dbo.DimEmployee;
```

### 3.3 Detalle de Ventas por Cliente

```sql
-- Comparar ventas totales por cliente en ambas bases

-- OLTP
SELECT TOP 5
    c.CompanyName,
    SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalOLTP
FROM Northwind.dbo.Customers c
INNER JOIN Northwind.dbo.Orders o ON c.CustomerID = o.CustomerID
INNER JOIN Northwind.dbo.OrderDetails od ON o.OrderID = od.OrderID
GROUP BY c.CompanyName
ORDER BY TotalOLTP DESC;

-- DW
SELECT TOP 5
    dc.CompanyName,
    SUM(fs.ExtendedPrice) AS TotalDW
FROM NorthWindDW.dbo.DimCustomer dc
INNER JOIN NorthWindDW.dbo.FactSales fs ON dc.CustomerSK = fs.CustomerSK
GROUP BY dc.CompanyName
ORDER BY TotalDW DESC;

-- Resultado esperado: 
-- Los mismos clientes con los mismos totales, en el mismo orden
```

---

## 4. Procedimiento Almacenado de Validación Integral

Crear un procedimiento que valide todo de una sola vez:

```sql
USE NorthWindDW;
GO

CREATE PROCEDURE usp_ValidateDataIntegrity
AS
BEGIN
    DECLARE @ErrorCount INT = 0;
    
    -- Test 1: Verificar integridad referencial en FactSales
    SELECT @ErrorCount = @ErrorCount + COUNT(*)
    FROM FactSales fs
    LEFT JOIN DimCustomer dc ON fs.CustomerSK = dc.CustomerSK
    WHERE dc.CustomerSK IS NULL;
    
    -- Test 2: Verificar cálculos de ExtendedPrice
    SELECT @ErrorCount = @ErrorCount + COUNT(*)
    FROM FactSales
    WHERE ExtendedPrice <> ROUND(Quantity * UnitPrice * (1 - Discount), 2);
    
    -- Test 3: Verificar descuentos válidos
    SELECT @ErrorCount = @ErrorCount + COUNT(*)
    FROM FactSales
    WHERE Discount < 0 OR Discount > 1;
    
    -- Test 4: Validar totales OLTP vs DW
    DECLARE @OLTPTotal MONEY, @DWTotal MONEY;
    
    SELECT @OLTPTotal = SUM(Quantity * UnitPrice * (1 - Discount))
    FROM Northwind.dbo.OrderDetails;
    
    SELECT @DWTotal = SUM(ExtendedPrice)
    FROM NorthWindDW.dbo.FactSales;
    
    IF ABS(@OLTPTotal - @DWTotal) > 0.01
        SET @ErrorCount = @ErrorCount + 1;
    
    -- Resultado
    IF @ErrorCount = 0
        PRINT 'Validación exitosa: No se encontraron errores.';
    ELSE
        PRINT 'Validación FALLIDA: Se encontraron ' + CAST(@ErrorCount AS VARCHAR(10)) + ' errores.';
    
    RETURN @ErrorCount;
END;
GO

-- Ejecutar el procedimiento
EXEC usp_ValidateDataIntegrity;
```

---

## 5. Monitoreo Continuo

### 5.1 Ver estado de las bases de datos

```sql
-- Estado de las bases de datos
SELECT 
    name AS DatabaseName,
    state_desc AS Status,
    recovery_model_desc AS RecoveryModel,
    DATABASEPROPERTYEX(name, 'Status') AS Property
FROM sys.databases
WHERE name IN ('Northwind', 'NorthWindDW');
```

### 5.2 Verificar espacio utilizado

```sql
-- Espacio utilizado en cada base de datos
SELECT 
    DB_NAME() AS Database_Name,
    CAST(SUM(size) * 8 / 1024.0 AS NUMERIC(10,2)) AS Size_MB
FROM sys.master_files
WHERE database_id IN (DB_ID('Northwind'), DB_ID('NorthWindDW'))
GROUP BY database_id;
```

### 5.3 Ver índices fragmentados

```sql
USE NorthWindDW;

-- Verificar fragmentación de índices
SELECT 
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.avg_fragmentation_in_percent AS Fragmentation
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id 
    AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10
  AND ips.page_count > 1000
ORDER BY Fragmentation DESC;
```

---

## 6. Checklist de Validación Post-Despliegue

Usar esta lista para validar que todo funciona:

- [ ] Base de datos OLTP `Northwind` existe
- [ ] Base de datos DW `NorthWindDW` existe
- [ ] Todas las tablas OLTP existen (11 tablas)
- [ ] Todas las tablas DW existen (7 tablas)
- [ ] No hay registros huérfanos en OrderDetails
- [ ] Todos los descuentos están entre 0 y 1
- [ ] Todas las cantidades son > 0
- [ ] Total de ventas OLTP = Total de ventas DW
- [ ] Todas las claves foráneas en FactSales son válidas
- [ ] ExtendedPrice se calcula correctamente en FactSales
- [ ] Dimensiones tienen el número correcto de registros
- [ ] DimDate cubre el rango de fechas esperado (1996-1998)


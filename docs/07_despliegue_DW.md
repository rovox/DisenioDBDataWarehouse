# 🚀 Instrucciones de Despliegue

## Requisitos Previos

- **SQL Server 2019 o superior** (o SQL Server Express)
- **SQL Server Management Studio (SSMS)** o **Azure Data Studio**
- (Opcional) **Visual Studio con SQL Server Data Tools (SSDT)** para trabajar con DACPAC
- **Acceso administrativo** a la instancia de SQL Server
- **Espacio en disco**: Mínimo 500 MB

---

## Opción A: Despliegue mediante Scripts SQL (Recomendado)

### Paso 1: Preparar el entorno

1. Conectarse a la instancia de SQL Server usando **SSMS** o **Azure Data Studio**
2. Verificar que el usuario tenga permisos para crear bases de datos
3. Verificar el espacio disponible en la ubicación predeterminada de archivos SQL Server:
   ```
   C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA
   ```

### Paso 2: Crear la base de datos OLTP

1. Abrir la carpeta `scripts/` del repositorio
2. Ejecutar el script **en el siguiente orden**:
   ```
   01_OLTP_Northwind_Full.sql
   ```

**Esto hará:**
- Crear la base de datos `Northwind`
- Crear todas las tablas (Customers, Orders, OrderDetails, Products, etc.)
- Poblar las tablas con datos de prueba (~2,155 líneas de OrderDetails)
- Crear índices y constraints

**Tiempo estimado**: 5-10 segundos

**Validación**:
```sql
-- Verificar que las tablas fueron creadas
SELECT COUNT(*) AS TotalTables 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo' 
  AND TABLE_CATALOG = 'Northwind';
-- Resultado esperado: 11 tablas

-- Verificar datos cargados
SELECT 'Customers' AS Tabla, COUNT(*) AS Registros FROM Northwind.dbo.Customers
UNION ALL
SELECT 'Orders', COUNT(*) FROM Northwind.dbo.Orders
UNION ALL
SELECT 'OrderDetails', COUNT(*) FROM Northwind.dbo.OrderDetails;
```

### Paso 3: Crear el Data Warehouse

Ejecutar los scripts **en este orden exacto**:

#### 3a. Crear el esquema DW
```
02_DW_Schema_final.sql
```

**Esto hará:**
- Crear la base de datos `NorthWindDW`
- Crear tablas de dimensiones (DimCustomer, DimProduct, DimEmployee, etc.)
- Crear tabla de hechos (FactSales)
- Crear índices para optimizar consultas analíticas
- Crear esquema staging opcional

**Tiempo estimado**: 5-10 segundos

**Validación**:
```sql
USE NorthWindDW;
SELECT COUNT(*) AS TotalTables 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo';
-- Resultado esperado: 7 tablas (5 dimensiones + 1 hecho + 1 config)
```

#### 3b. Poblar las dimensiones
```
04_Poblar_Dimensiones.sql
```

**Esto hará:**
- Insertar datos en `DimCustomer` desde `Customers`
- Insertar datos en `DimProduct` desde `Products`
- Insertar datos en `DimEmployee` desde `Employees`
- Insertar datos en `DimShipper` desde `Shippers`
- Crear tabla `DimDate` con calendario completo
- Insertar datos en `DimShipLocation` desde direcciones de envío

**Tiempo estimado**: 5-15 segundos

**Validación**:
```sql
USE NorthWindDW;
SELECT 
    'DimCustomer' AS Tabla, COUNT(*) AS Registros FROM DimCustomer
UNION ALL SELECT 'DimProduct', COUNT(*) FROM DimProduct
UNION ALL SELECT 'DimEmployee', COUNT(*) FROM DimEmployee
UNION ALL SELECT 'DimShipper', COUNT(*) FROM DimShipper
UNION ALL SELECT 'DimDate', COUNT(*) FROM DimDate
UNION ALL SELECT 'DimShipLocation', COUNT(*) FROM DimShipLocation;
```

#### 3c. Cargar la tabla de hechos
```
03_Carga_fact_Sales.sql
```

**Esto hará:**
- Calcular y transformar datos desde `OrderDetails` del OLTP
- Insertar registros en `FactSales` con claves foráneas a las dimensiones
- Calcular `ExtendedPrice` = `Quantity × UnitPrice × (1 - Discount)`

**Tiempo estimado**: 5-10 segundos

**Validación**:
```sql
USE NorthWindDW;
SELECT COUNT(*) AS TotalSales FROM FactSales;
-- Resultado esperado: ~2,155 registros (uno por OrderDetail)

-- Verificar que todas las claves foráneas sean válidas
SELECT 'Clientes sin FK' AS Validación, COUNT(*) AS Problemas
FROM FactSales fs
LEFT JOIN DimCustomer dc ON fs.CustomerSK = dc.CustomerSK
WHERE dc.CustomerSK IS NULL
UNION ALL
SELECT 'Productos sin FK', COUNT(*)
FROM FactSales fs
LEFT JOIN DimProduct dp ON fs.ProductSK = dp.ProductSK
WHERE dp.ProductSK IS NULL;
-- Resultado esperado: 0 problemas
```

---

## Opción B: Despliegue mediante DACPAC

### Requisitos previos
- **SQL Server Management Studio (SSMS)** versión 18.0 o superior
- **Acceso administrativo** a la instancia SQL Server

### Paso 1: Desplegar OLTP

1. Abrir **SQL Server Management Studio (SSMS)**
2. Conectarse a la instancia de SQL Server deseada
3. En el **Object Explorer**, click derecho sobre **Databases**
4. Seleccionar **Deploy Data-tier Application...**
5. Navegar a `dacpac/Northwind.dacpac`
6. En el asistente, ingresar:
   - **Nombre de aplicación**: `Northwind` (o personalizado)
   - **Ubicación**: SQL Server local
7. Revisar el resumen y hacer click en **Siguiente**
8. Hacer click en **Finish** para completar el despliegue

**Resultado**: Base de datos `Northwind` creada con todas las tablas y datos

### Paso 2: Desplegar Data Warehouse

Repetir el proceso anterior pero con `dacpac/Northwind_DW.dacpac`:

1. Click derecho sobre **Databases** → **Deploy Data-tier Application...**
2. Navegar a `dacpac/Northwind_DW.dacpac`
3. Ingresar nombre: `NorthWindDW`
4. Seguir el asistente y finalizar

**Resultado**: Base de datos `NorthWindDW` creada con dimensiones, hechos e índices

---

## Paso 4: Validación de Integridad Referencial (Ambas Opciones)

Ejecutar las siguientes consultas para verificar que todo se desplegó correctamente:

### Validación OLTP

```sql
-- Usar base de datos OLTP
USE Northwind;

-- 1. Verificar que no hayan huérfanos en OrderDetails
SELECT 'Huérfanos en OrderDetails' AS Validación, COUNT(*) AS Problemas
FROM OrderDetails od
LEFT JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.OrderID IS NULL;
-- Esperado: 0

-- 2. Verificar que no hayan huérfanos en Orders
SELECT 'Huérfanos en Orders (Customer)', COUNT(*)
FROM Orders o
LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL
UNION ALL
SELECT 'Huérfanos en Orders (Employee)', COUNT(*)
FROM Orders o
LEFT JOIN Employees e ON o.EmployeeID = e.EmployeeID
WHERE e.EmployeeID IS NULL;
-- Esperado: 0

-- 3. Resumen de datos
SELECT 
    'Clientes' AS Entidad, COUNT(*) AS Cantidad FROM Customers
UNION ALL SELECT 'Órdenes', COUNT(*) FROM Orders
UNION ALL SELECT 'Líneas de Orden', COUNT(*) FROM OrderDetails
UNION ALL SELECT 'Productos', COUNT(*) FROM Products
UNION ALL SELECT 'Empleados', COUNT(*) FROM Employees;
```

### Validación DW

```sql
-- Usar base de datos Data Warehouse
USE NorthWindDW;

-- 1. Verificar que todas las claves foráneas en FactSales sean válidas
SELECT 'Clientes sin FK' AS Validación, COUNT(*) AS Problemas
FROM FactSales fs
LEFT JOIN DimCustomer dc ON fs.CustomerSK = dc.CustomerSK
WHERE dc.CustomerSK IS NULL
UNION ALL
SELECT 'Productos sin FK', COUNT(*)
FROM FactSales fs
LEFT JOIN DimProduct dp ON fs.ProductSK = dp.ProductSK
WHERE dp.ProductSK IS NULL
UNION ALL
SELECT 'Empleados sin FK', COUNT(*)
FROM FactSales fs
LEFT JOIN DimEmployee de ON fs.EmployeeSK = de.EmployeeSK
WHERE de.EmployeeSK IS NULL
UNION ALL
SELECT 'Fechas sin FK', COUNT(*)
FROM FactSales fs
LEFT JOIN DimDate dd ON fs.OrderDateKey = dd.DateKey
WHERE dd.DateKey IS NULL;
-- Esperado: 0 en todas las categorías

-- 2. Reconciliación de totales OLTP vs DW
SELECT 
    'OLTP' AS Fuente,
    SUM(Quantity * UnitPrice * (1 - Discount)) AS TotalVentas
FROM Northwind.dbo.OrderDetails
UNION ALL
SELECT 
    'DW' AS Fuente,
    SUM(ExtendedPrice) AS TotalVentas
FROM NorthWindDW.dbo.FactSales;
-- Esperado: Ambos totales deben coincidir

-- 3. Resumen de datos en DW
SELECT 
    'DimCustomer' AS Tabla, COUNT(*) AS Registros FROM DimCustomer
UNION ALL SELECT 'DimProduct', COUNT(*) FROM DimProduct
UNION ALL SELECT 'DimEmployee', COUNT(*) FROM DimEmployee
UNION ALL SELECT 'DimShipper', COUNT(*) FROM DimShipper
UNION ALL SELECT 'DimDate', COUNT(*) FROM DimDate
UNION ALL SELECT 'FactSales', COUNT(*) FROM FactSales;
```

---

## Resolución de Problemas

### Error: "La base de datos ya existe"

**Problema**: `CREATE DATABASE Northwind failed because ... already exists`

**Solución**:
```sql
-- Opción 1: Ejecutar script con IF NOT EXISTS
USE master;
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Northwind')
    DROP DATABASE Northwind;
-- Luego ejecutar el script normalmente

-- Opción 2: Usar un nombre diferente
-- Editar el script y cambiar CREATE DATABASE [Northwind] 
-- por CREATE DATABASE [Northwind_v2]
```

### Error: "Insufficient disk space"

**Problema**: `The operating system returned error 112(There is not enough space ...)`

**Solución**:
1. Liberar espacio en la unidad `C:\` (mínimo 500 MB recomendado)
2. O cambiar la ubicación de archivos SQL Server:
   ```sql
   -- Cambiar ubicación de datos
   ALTER DATABASE Northwind 
   MODIFY FILE (NAME = Northwind, FILENAME = 'D:\SQLData\Northwind.mdf');
   ```

### Error: "LOGIN failed for user"

**Problema**: Permisos insuficientes

**Solución**:
1. Conectarse con una cuenta con permisos administrativos
2. O ejecutar SSMS como administrador

### Los datos no coinciden entre OLTP y DW

**Problema**: Totales de ventas diferentes

**Solución**:
1. Verificar que se ejecutaron los scripts en el orden correcto
2. Verificar que `04_Poblar_Dimensiones.sql` se ejecutó antes de `03_Carga_fact_Sales.sql`
3. Ejecutar validación de integridad referencial (ver arriba)
4. Si alguna dimensión tiene registros faltantes, repoblar manualmente

---

## Limpieza (Desinstalar)

Si necesitas eliminar las bases de datos:

```sql
-- Desconectar usuarios antes de eliminar
USE master;
ALTER DATABASE Northwind SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE Northwind;

ALTER DATABASE NorthWindDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE NorthWindDW;
```

---

## Scripts de Backup

Realizar backup regularmente:

```sql
-- Backup OLTP
BACKUP DATABASE Northwind 
TO DISK = 'C:\Backups\Northwind.bak' 
WITH INIT, COMPRESSION;

-- Backup DW
BACKUP DATABASE NorthWindDW 
TO DISK = 'C:\Backups\NorthWindDW.bak' 
WITH INIT, COMPRESSION;
```


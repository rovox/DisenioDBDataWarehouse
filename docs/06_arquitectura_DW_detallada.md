# 📊 Arquitectura Detallada del Data Warehouse - NorthWind DW

## Descripción General

El **Data Warehouse (DW) NorthWindDW** es una base de datos analítica implementada en **SQL Server 2017+** usando un esquema de **estrella (Star Schema)** dimensional para análisis histórico de ventas.

### Características principales

- **Base de datos**: `NorthWindDW`
- **Esquema**: Estrella dimensional
- **Grano de la tabla de hechos**: Una fila por línea de pedido (OrderDetail)
- **Cobertura temporal**: Desde 1996 a 1998
- **Fuente de datos**: Base de datos transaccional `Northwind` (OLTP)

---

## Diagrama del Modelo

> ![Diagrama DW NorthWind Estrella](../imgs/Diagrama%20DW.png)

---

## 1. Tabla de Hechos: FactSales

### Propósito
Registra cada línea de venta con sus métricas numéricas y referencias a todas las dimensiones.

### Estructura

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `SalesKey` | `BIGINT` | Clave única (identidad) - Clave primaria |
| `OrderID` | `INT` | Identificador del pedido (referencia al OLTP) |
| `OrderLineNumber` | `SMALLINT` | Número de línea dentro del pedido |
| `OrderDateKey` | `INT` | Clave foránea a `DimDate` (fecha del pedido) |
| `ShipDateKey` | `INT` | Clave foránea a `DimDate` (fecha de envío) |
| `CustomerSK` | `INT` | Clave foránea a `DimCustomer` |
| `ProductSK` | `INT` | Clave foránea a `DimProduct` |
| `EmployeeSK` | `INT` | Clave foránea a `DimEmployee` |
| `ShipperSK` | `INT` | Clave foránea a `DimShipper` |
| `ShipLocationSK` | `INT` | Clave foránea a `DimShipLocation` |
| `Quantity` | `SMALLINT` | Cantidad de unidades vendidas |
| `UnitPrice` | `MONEY` | Precio unitario al momento de la venta |
| `Discount` | `REAL` | Descuento aplicado (0.0 a 1.0) |
| `ExtendedPrice` | `MONEY` | Cálculo: `Quantity × UnitPrice × (1 - Discount)` |
| `Freight` | `MONEY` | Costo de envío de la orden |

### Índices de rendimiento

Se crean índices no agrupados sobre las claves foráneas para optimizar consultas de análisis:

```sql
CREATE NONCLUSTERED INDEX [IX_FactSales_OrderDateKey]   ON [dbo].[FactSales]([OrderDateKey])
CREATE NONCLUSTERED INDEX [IX_FactSales_CustomerSK]     ON [dbo].[FactSales]([CustomerSK])
CREATE NONCLUSTERED INDEX [IX_FactSales_ProductSK]      ON [dbo].[FactSales]([ProductSK])
CREATE NONCLUSTERED INDEX [IX_FactSales_EmployeeSK]     ON [dbo].[FactSales]([EmployeeSK])
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipperSK]      ON [dbo].[FactSales]([ShipperSK])
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipLocationSK] ON [dbo].[FactSales]([ShipLocationSK])
```

### Volumen de datos

- **Registros**: ~2,155 líneas de pedidos (uno por cada `OrderDetail` del OLTP)
- **Tamaño aproximado**: 200 KB (sin índices)
- **Cobertura**: 01/01/1996 a 28/03/1998

---

## 2. Dimensiones

### 2.1 DimCustomer — Dimensión de Clientes

Denormaliza la información de clientes desde la tabla `Customers` del OLTP.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `CustomerSK` | `INT` (PK) | Clave sucedánea (surrogate key), autonumerada |
| `CustomerID` | `NCHAR(5)` | Clave natural del cliente en el OLTP |
| `CompanyName` | `NVARCHAR(40)` | Nombre de la empresa cliente |
| `ContactName` | `NVARCHAR(30)` | Nombre del contacto |
| `ContactTitle` | `NVARCHAR(30)` | Cargo del contacto |
| `Address` | `NVARCHAR(60)` | Dirección |
| `City` | `NVARCHAR(15)` | Ciudad |
| `Region` | `NVARCHAR(15)` | Región o provincia |
| `PostalCode` | `NVARCHAR(10)` | Código postal |
| `Country` | `NVARCHAR(15)` | País |
| `Phone` | `NVARCHAR(24)` | Teléfono |
| `Fax` | `NVARCHAR(24)` | Fax |

**Casos de uso analíticos:**
- Análisis de ventas por país/región/ciudad
- Segmentación de clientes por ubicación geográfica
- Identificación de clientes principales por región

---

### 2.2 DimProduct — Dimensión de Productos

Combina información de `Products`, `Categories` y `Suppliers` del OLTP.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `ProductSK` | `INT` (PK) | Clave sucedánea, autonumerada |
| `ProductID` | `INT` | Clave natural del producto |
| `ProductName` | `NVARCHAR(40)` | Nombre del producto |
| `CategoryID` | `INT` | Identificador de categoría |
| `CategoryName` | `NVARCHAR(15)` | Nombre de la categoría (denormalizado) |
| `SupplierID` | `INT` | Identificador del proveedor |
| `SupplierName` | `NVARCHAR(40)` | Nombre del proveedor (denormalizado) |
| `QuantityPerUnit` | `NVARCHAR(20)` | Cantidad por unidad de compra |
| `StandardCost` | `MONEY` | Costo estándar |
| `ListPrice` | `MONEY` | Precio de lista |
| `Discontinued` | `BIT` | Indicador: producto descontinuado (0 o 1) |

**Casos de uso analíticos:**
- Análisis de ventas por categoría
- Análisis de ventas por proveedor
- Identificación de productos top sellers
- Análisis de productos descontinuados vs. activos

---

### 2.3 DimEmployee — Dimensión de Empleados

Estructura organizacional de vendedores y personal.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `EmployeeSK` | `INT` (PK) | Clave sucedánea, autonumerada |
| `EmployeeID` | `INT` | Clave natural del empleado |
| `LastName` | `NVARCHAR(20)` | Apellido |
| `FirstName` | `NVARCHAR(10)` | Nombre |
| `FullName` | Columna calculada | Concatenación: `FirstName + ' ' + LastName` |
| `Title` | `NVARCHAR(30)` | Título del puesto |
| `TitleOfCourtesy` | `NVARCHAR(25)` | Tratamiento (Mr., Ms., Dr., etc.) |
| `BirthDate` | `DATETIME` | Fecha de nacimiento |
| `HireDate` | `DATETIME` | Fecha de contratación |
| `ReportsTo` | `INT` | ID del empleado superior (jerarquía) |
| `Country` | `NVARCHAR(15)` | País de residencia |

**Casos de uso analíticos:**
- Análisis de desempeño de vendedores
- Comparativa de ventas entre empleados
- Análisis de antigüedad en la empresa
- Estructura organizacional y reportes

---

### 2.4 DimShipper — Dimensión de Transportistas

Información de empresas de envío.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `ShipperSK` | `INT` (PK) | Clave sucedánea, autonumerada |
| `ShipperID` | `INT` | Clave natural del transportista |
| `CompanyName` | `NVARCHAR(40)` | Nombre de la empresa de transporte |
| `Phone` | `NVARCHAR(24)` | Teléfono de contacto |

**Casos de uso analíticos:**
- Análisis de envíos por transportista
- Comparativa de costos de envío
- Evaluación de desempeño de transportistas

---

### 2.5 DimShipLocation — Dimensión de Ubicación de Envío

Denormaliza datos de dirección de envío.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `ShipLocationSK` | `INT` (PK) | Clave sucedánea, autonumerada |
| `OrderID` | `INT` | Referencia al pedido |
| `ShipName` | `NVARCHAR(40)` | Nombre del destinatario |
| `ShipAddress` | `NVARCHAR(60)` | Dirección de envío |
| `ShipCity` | `NVARCHAR(15)` | Ciudad de destino |
| `ShipRegion` | `NVARCHAR(15)` | Región de destino |
| `ShipPostalCode` | `NVARCHAR(10)` | Código postal de destino |
| `ShipCountry` | `NVARCHAR(15)` | País de destino |

**Casos de uso analíticos:**
- Análisis de ventas por ubicación de entrega
- Análisis de costos de flete por destino
- Patrones geográficos de entrega

---

### 2.6 DimDate — Dimensión Temporal

Tabla calendárica que facilita análisis históricos y comparativas temporales.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `DateKey` | `INT` (PK) | Formato: YYYYMMDD (ej: 19960101 para 01-01-1996) |
| `FullDate` | `DATE` | Fecha completa |
| `DayNumber` | `INT` | Día del mes (1-31) |
| `MonthNumber` | `INT` | Número del mes (1-12) |
| `MonthName` | `NVARCHAR(20)` | Nombre del mes en español |
| `QuarterNumber` | `INT` | Trimestre (1-4) |
| `YearNumber` | `INT` | Año |
| `DayName` | `NVARCHAR(20)` | Nombre del día en español |

**Casos de uso analíticos:**
- Análisis de tendencias mensuales, trimestrales y anuales
- Comparativas año a año
- Identificación de patrones estacionales
- Análisis por día de la semana

---

## 3. Esquema de Staging

Para facilitar el ETL y depuración, se utiliza un esquema intermedio `staging` con tablas espejo:

- `staging.Customer`
- `staging.Employee`
- `staging.Product`
- `staging.Sales`
- `staging.ShipLocation`
- `staging.Shipper`

Estas tablas son **opcionales** y se usan para validar datos antes de insertar en las dimensiones y hechos.

---

## 4. Configuración de la Base de Datos

### Opciones de seguridad y rendimiento

```sql
-- Modo de recuperación FULL para auditoría y backup
ALTER DATABASE [NorthWindDW] SET RECOVERY FULL

-- Query Store habilitado para análisis de rendimiento
ALTER DATABASE [NorthWindDW] SET QUERY_STORE = ON

-- Configuración de integridad y verificación
ALTER DATABASE [NorthWindDW] SET PAGE_VERIFY CHECKSUM
```

### Nivel de compatibilidad

- **Nivel**: 170 (SQL Server 2022)
- Permite usar features modernas de SQL Server en entornos más antiguos si es necesario

---

## 5. Flujo de Carga (ETL)

### Proceso típico

1. **Extracción (E)**: Lectura desde `Northwind` (OLTP)
2. **Transformación (T)**:
   - Aplicar SCD (Slowly Changing Dimensions) si aplica
   - Denormalizar datos relacionales
   - Aplicar cálculos (ExtendedPrice, etc.)
   - Validar integridad referencial
3. **Carga (L)**: Inserciones en DW
   - Cargar dimensiones primero
   - Luego cargar hechos

### Scripts disponibles

| Script | Descripción |
|--------|-------------|
| `02_DW_Schema_final.sql` | Creación del esquema DW (definitivo) |
| `04_Poblar_Dimensiones.sql` | Carga inicial de dimensiones |
| `03_Carga_fact_Sales.sql` | Carga de la tabla de hechos |

---

## 6. Comparación: OLTP vs. DW

| Aspecto | OLTP | DW |
|--------|------|-----|
| **Propósito** | Operaciones transaccionales | Análisis histórico |
| **Normalización** | 3FN (máxima) | Desnormalizado (estrella) |
| **Tablas** | Muchas pequeñas | Pocas grandes |
| **Actualizaciones** | Frecuentes (CRUD) | Carga batch (inserts) |
| **Consultas** | Simples, rápidas | Complejas, agregadas |
| **Dimensiones** | Entidades independientes | Denormalizadas en tablas planas |
| **Claves** | Claves naturales | Claves sucedáneas (surrogate keys) |

---

## 7. Ejemplos de Consultas Analíticas

### Ventas por país y mes

```sql
SELECT 
    dc.Country,
    dd.MonthName,
    dd.YearNumber,
    SUM(fs.Quantity) AS TotalQuantity,
    SUM(fs.ExtendedPrice) AS TotalSales
FROM FactSales fs
INNER JOIN DimCustomer dc ON fs.CustomerSK = dc.CustomerSK
INNER JOIN DimDate dd ON fs.OrderDateKey = dd.DateKey
GROUP BY dc.Country, dd.MonthName, dd.YearNumber
ORDER BY dd.YearNumber, dd.MonthNumber, dc.Country;
```

### Top 10 productos más vendidos

```sql
SELECT TOP 10
    dp.ProductName,
    dp.CategoryName,
    SUM(fs.Quantity) AS TotalQuantity,
    SUM(fs.ExtendedPrice) AS TotalRevenue
FROM FactSales fs
INNER JOIN DimProduct dp ON fs.ProductSK = dp.ProductSK
GROUP BY dp.ProductName, dp.CategoryName
ORDER BY TotalRevenue DESC;
```

### Desempeño de vendedores

```sql
SELECT 
    de.FullName,
    de.Title,
    COUNT(DISTINCT fs.OrderID) AS TotalOrders,
    SUM(fs.Quantity) AS TotalQuantity,
    SUM(fs.ExtendedPrice) AS TotalRevenue
FROM FactSales fs
INNER JOIN DimEmployee de ON fs.EmployeeSK = de.EmployeeSK
GROUP BY de.FullName, de.Title
ORDER BY TotalRevenue DESC;
```

---

## 8. Validación de Datos

### Verificar integridad referencial

```sql
-- Verificar que todas las claves foráneas en FactSales sean válidas
SELECT COUNT(*) AS InvalidReferences
FROM FactSales fs
LEFT JOIN DimCustomer dc ON fs.CustomerSK = dc.CustomerSK
LEFT JOIN DimProduct dp ON fs.ProductSK = dp.ProductSK
LEFT JOIN DimEmployee de ON fs.EmployeeSK = de.EmployeeSK
LEFT JOIN DimShipper ds ON fs.ShipperSK = ds.ShipperSK
LEFT JOIN DimDate dd ON fs.OrderDateKey = dd.DateKey
WHERE dc.CustomerSK IS NULL
   OR dp.ProductSK IS NULL
   OR de.EmployeeSK IS NULL
   OR ds.ShipperSK IS NULL
   OR dd.DateKey IS NULL;
```

### Reconciliación OLTP vs. DW

```sql
-- Total ventas (debe coincidir entre OLTP y DW)
SELECT 
    'OLTP' AS fuente,
    SUM(Quantity * UnitPrice * (1 - Discount)) AS total_ventas
FROM Northwind.dbo.OrderDetails
UNION ALL
SELECT 
    'DW' AS fuente,
    SUM(ExtendedPrice) AS total_ventas
FROM NorthWindDW.dbo.FactSales;
```

---

## 9. Notas de Implementación

- **Surrogate Keys**: Se usan claves sucedáneas (SK) en lugar de claves naturales para mejor rendimiento y flexibilidad
- **Lentitud de cambio (SCD)**: El DW actual no implementa SCD; es una instantánea de los datos del OLTP
- **Particionamiento**: Para producción con millones de registros, considerar particionar `FactSales` por fecha
- **Compresión**: Se puede aplicar compresión de página a las dimensiones grandes para optimizar almacenamiento


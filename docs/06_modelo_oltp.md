# 🏗️ Modelo OLTP - NorthWind

## Descripción General

El **modelo OLTP (Online Transaction Processing)** de NorthWind es un sistema transaccional completamente normalizado en **Tercera Forma Normal (3FN)** implementado en SQL Server 2019+.

### Características

- **Base de datos**: `Northwind`
- **Normalización**: 3FN (máxima normalización)
- **Propósito**: Capturar operaciones transaccionales diarias de ventas y logística
- **Dominio**: Ventas y distribución internacional de alimentos y bebidas

---

## Diagrama Entidad-Relación

> ![Diagrama ER NorthWind OLTP](../imgs/ModeloOLTP.png)

---

## Entidades Principales

| Entidad | Descripción | Registros |
|---------|-------------|-----------|
| `Customers` | Empresas o personas que realizan pedidos | 91 |
| `Orders` | Pedidos registrados en el sistema | 830 |
| `OrderDetails` | Líneas de detalle de cada pedido | 2,155 |
| `Products` | Catálogo de productos disponibles para venta | 77 |
| `Categories` | Agrupación de productos por tipo | 8 |
| `Suppliers` | Empresas proveedoras de productos | 29 |
| `Employees` | Vendedores y personal de la empresa | 9 |
| `Shippers` | Empresas de transporte y envío | 3 |
| `Region / Territories` | Organización territorial de las ventas | 10 territorios, 4 regiones |

---

## Claves Primarias y Foráneas

### Relaciones Principales

| Tabla | Clave Primaria | Claves Foráneas |
|-------|---------------|-----------------|
| `Orders` | `OrderID` | `CustomerID` → Customers<br/>`EmployeeID` → Employees<br/>`ShipperID` → Shippers |
| `OrderDetails` | `OrderID + ProductID` | `OrderID` → Orders<br/>`ProductID` → Products |
| `Products` | `ProductID` | `CategoryID` → Categories<br/>`SupplierID` → Suppliers |
| `Employees` | `EmployeeID` | `ReportsTo` → Employees (auto-referencia) |
| `Territories` | `TerritoryID` | `RegionID` → Region |
| `EmployeeTerritories` | `EmployeeID + TerritoryID` | `EmployeeID` → Employees<br/>`TerritoryID` → Territories |

---

## Estructura Detallada de Tablas

### Customers

```sql
CREATE TABLE Customers (
    CustomerID NCHAR(5) PRIMARY KEY,
    CompanyName NVARCHAR(40) NOT NULL,
    ContactName NVARCHAR(30),
    ContactTitle NVARCHAR(30),
    Address NVARCHAR(60),
    City NVARCHAR(15),
    Region NVARCHAR(15),
    PostalCode NVARCHAR(10),
    Country NVARCHAR(15),
    Phone NVARCHAR(24),
    Fax NVARCHAR(24)
);
```

**Propósito**: Almacenar información de clientes (empresas u organizaciones).

---

### Orders

```sql
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID NCHAR(5) NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    EmployeeID INT NOT NULL FOREIGN KEY REFERENCES Employees(EmployeeID),
    OrderDate DATETIME NOT NULL,
    RequiredDate DATETIME NOT NULL,
    ShippedDate DATETIME,
    ShipperID INT NOT NULL FOREIGN KEY REFERENCES Shippers(ShipperID),
    Freight MONEY,
    ShipName NVARCHAR(40),
    ShipAddress NVARCHAR(60),
    ShipCity NVARCHAR(15),
    ShipRegion NVARCHAR(15),
    ShipPostalCode NVARCHAR(10),
    ShipCountry NVARCHAR(15),
    CHECK (ShippedDate >= OrderDate)
);
```

**Propósito**: Registro de todos los pedidos realizados.
**Regla de negocio**: Cada pedido tiene exactamente un cliente, un empleado responsable y un transportista.

---

### OrderDetails

```sql
CREATE TABLE OrderDetails (
    OrderID INT NOT NULL FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT NOT NULL FOREIGN KEY REFERENCES Products(ProductID),
    UnitPrice MONEY NOT NULL,
    Quantity SMALLINT NOT NULL,
    Discount REAL NOT NULL DEFAULT 0,
    PRIMARY KEY (OrderID, ProductID),
    CHECK (Quantity > 0),
    CHECK (UnitPrice >= 0),
    CHECK (Discount >= 0 AND Discount <= 1)
);
```

**Propósito**: Desglose línea por línea de cada pedido.
**Reglas de negocio**:
- El precio extendido = `Quantity × UnitPrice × (1 - Discount)`
- Cantidad debe ser > 0
- Descuento entre 0% y 100%

---

### Products

```sql
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(40) NOT NULL UNIQUE,
    SupplierID INT NOT NULL FOREIGN KEY REFERENCES Suppliers(SupplierID),
    CategoryID INT NOT NULL FOREIGN KEY REFERENCES Categories(CategoryID),
    QuantityPerUnit NVARCHAR(20),
    UnitPrice MONEY,
    UnitsInStock SMALLINT DEFAULT 0,
    UnitsOnOrder SMALLINT DEFAULT 0,
    ReorderLevel SMALLINT DEFAULT 0,
    Discontinued BIT NOT NULL DEFAULT 0,
    CHECK (UnitPrice >= 0)
);
```

**Propósito**: Catálogo de productos disponibles para venta.

---

### Categories

```sql
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(15) NOT NULL UNIQUE,
    Description NTEXT
);
```

**Propósito**: Clasificar productos en categorías (ej: Bebidas, Productos Lácteos, etc.).

---

### Suppliers

```sql
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    CompanyName NVARCHAR(40) NOT NULL,
    ContactName NVARCHAR(30),
    ContactTitle NVARCHAR(30),
    Address NVARCHAR(60),
    City NVARCHAR(15),
    Region NVARCHAR(15),
    PostalCode NVARCHAR(10),
    Country NVARCHAR(15),
    Phone NVARCHAR(24),
    Fax NVARCHAR(24),
    HomePage NTEXT
);
```

**Propósito**: Información de proveedores de productos.

---

### Employees

```sql
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    LastName NVARCHAR(20) NOT NULL,
    FirstName NVARCHAR(10) NOT NULL,
    Title NVARCHAR(30),
    TitleOfCourtesy NVARCHAR(25),
    BirthDate DATETIME,
    HireDate DATETIME,
    Address NVARCHAR(60),
    City NVARCHAR(15),
    Region NVARCHAR(15),
    PostalCode NVARCHAR(10),
    Country NVARCHAR(15),
    Phone NVARCHAR(24),
    Extension NVARCHAR(4),
    Photo IMAGE,
    Notes NTEXT,
    ReportsTo INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    PhotoPath NVARCHAR(255),
    CHECK (BirthDate < GETDATE())
);
```

**Propósito**: Registro de empleados y estructura organizacional.
**Regla de negocio**: La fecha de nacimiento debe ser anterior a hoy.

---

### Shippers

```sql
CREATE TABLE Shippers (
    ShipperID INT PRIMARY KEY IDENTITY(1,1),
    CompanyName NVARCHAR(40) NOT NULL,
    Phone NVARCHAR(24)
);
```

**Propósito**: Empresas de transporte y envío.

---

### Region / Territories

```sql
CREATE TABLE Region (
    RegionID INT PRIMARY KEY,
    RegionDescription NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Territories (
    TerritoryID NVARCHAR(20) PRIMARY KEY,
    TerritoryDescription NVARCHAR(50) NOT NULL,
    RegionID INT NOT NULL FOREIGN KEY REFERENCES Region(RegionID)
);

CREATE TABLE EmployeeTerritories (
    EmployeeID INT NOT NULL FOREIGN KEY REFERENCES Employees(EmployeeID),
    TerritoryID NVARCHAR(20) NOT NULL FOREIGN KEY REFERENCES Territories(TerritoryID),
    PRIMARY KEY (EmployeeID, TerritoryID)
);
```

**Propósito**: Organizar vendedores por territorio y región.

---

## Normalización (3FN)

### Primera Forma Normal (1FN)

✅ **Cumplida**
- Todos los atributos almacenan valores atómicos e indivisibles
- No existen grupos repetidos ni columnas multivalor
- Cada tabla tiene clave primaria claramente definida

### Segunda Forma Normal (2FN)

✅ **Cumplida**
- Todos los atributos no clave dependen funcionalmente de la totalidad de la clave primaria
- En `OrderDetails` (clave compuesta `OrderID + ProductID`), los campos `UnitPrice`, `Quantity` y `Discount` dependen de ambas columnas en conjunto

### Tercera Forma Normal (3FN)

✅ **Cumplida**
- No existen dependencias transitivas entre atributos no clave
- `CategoryName` no se almacena en `Products` sino en `Categories`, referenciada mediante `CategoryID`
- Los datos del proveedor residen en `Suppliers` y no se repiten en `Products`
- Cambios en nombres de categorías o proveedores se actualizan en un único lugar

---

## Tipos de Datos Utilizados

| Tipo | Uso | Ejemplo |
|------|-----|---------|
| `INT` / `SMALLINT` | Identificadores (PKs y FKs) | `OrderID`, `ProductID` |
| `NVARCHAR(n)` | Nombres, descripciones, direcciones | `CompanyName`, `Address` |
| `MONEY` / `DECIMAL` | Precios, importes monetarios | `UnitPrice`, `Freight` |
| `REAL` | Descuentos (valor entre 0 y 1) | `Discount` |
| `SMALLINT` | Cantidades | `Quantity`, `UnitsInStock` |
| `DATETIME` | Fechas y horas | `OrderDate`, `ShippedDate` |
| `BIT` | Banderas booleanas | `Discontinued` |
| `NTEXT` | Textos largos | `Notes`, `Description` |
| `IMAGE` | Datos binarios | `Photo` |

---

## Reglas de Negocio Implementadas

Las siguientes restricciones están implementadas como constraints SQL:

### CHECK Constraints

```sql
-- En OrderDetails: Descuento debe estar entre 0% y 100%
CHECK (Discount >= 0 AND Discount <= 1)

-- En OrderDetails: Cantidad pedida debe ser mayor a cero
CHECK (Quantity > 0)

-- En OrderDetails: Precios no pueden ser negativos
CHECK (UnitPrice >= 0)

-- En Employees: Fecha de nacimiento anterior a hoy
CHECK (BirthDate < GETDATE())

-- En Orders: La fecha de envío debe ser posterior a la de orden
CHECK (ShippedDate >= OrderDate)

-- En Products: Precios no negativos
CHECK (UnitPrice >= 0)
```

### FOREIGN KEY Constraints

```sql
-- Integridad referencial en cascada
Orders.CustomerID → Customers.CustomerID
Orders.EmployeeID → Employees.EmployeeID
Orders.ShipperID → Shippers.ShipperID
OrderDetails.OrderID → Orders.OrderID
OrderDetails.ProductID → Products.ProductID
Products.CategoryID → Categories.CategoryID
Products.SupplierID → Suppliers.SupplierID
Territories.RegionID → Region.RegionID
EmployeeTerritories.EmployeeID → Employees.EmployeeID
EmployeeTerritories.TerritoryID → Territories.TerritoryID
```

### UNIQUE Constraints

```sql
Products.ProductName (debe ser único)
Categories.CategoryName (debe ser único)
Customers.CustomerID (clave primaria, implícitamente única)
```

---

## Volumen de Datos

Tabla de distribución de registros en el OLTP:

| Tabla | Registros | Tamaño aprox. |
|-------|-----------|--------------|
| Customers | 91 | 20 KB |
| Orders | 830 | 150 KB |
| OrderDetails | 2,155 | 100 KB |
| Products | 77 | 15 KB |
| Categories | 8 | 2 KB |
| Suppliers | 29 | 8 KB |
| Employees | 9 | 5 KB |
| Shippers | 3 | 1 KB |
| Region | 4 | <1 KB |
| Territories | 10 | 2 KB |
| EmployeeTerritories | 49 | 2 KB |
| **TOTAL** | **3,257** | **~305 KB** |

---

## Ejemplos de Consultas Transaccionales

### Registrar un nuevo pedido

```sql
BEGIN TRANSACTION;

INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, RequiredDate, ShipperID)
VALUES ('ALFKI', 1, GETDATE(), DATEADD(DAY, 5, GETDATE()), 1);

DECLARE @OrderID INT = SCOPE_IDENTITY();

INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
VALUES 
    (@OrderID, 72, 34.80, 5, 0),
    (@OrderID, 10, 31.00, 10, 0.05);

COMMIT;
```

### Actualizar cantidad en stock

```sql
UPDATE Products
SET UnitsInStock = UnitsInStock - @QuantityOrdered
WHERE ProductID = @ProductID
  AND UnitsInStock >= @QuantityOrdered;
```

### Consultar historial de pedidos de un cliente

```sql
SELECT 
    o.OrderID,
    o.OrderDate,
    o.RequiredDate,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    (od.Quantity * od.UnitPrice * (1 - od.Discount)) AS ExtendedPrice
FROM Orders o
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
WHERE o.CustomerID = 'ALFKI'
ORDER BY o.OrderDate DESC, od.ProductID;
```

---

## Relación OLTP ↔ DW

El modelo OLTP es la **fuente de datos** para el Data Warehouse:

- **OLTP**: Mantiene los datos actuales y operativos (insert, update, delete)
- **DW**: Almacena datos históricos y desnormalizados para análisis

Ver: [Arquitectura Detallada del DW](06_arquitectura_DW_detallada.md)


# 🗄️ NorthWind — Diseño OLTP, Data Warehouse y ETL

> Proyecto académico desarrollado en SQL Server que implementa un modelo de base de datos transaccional (OLTP) completamente normalizado en 3FN, su correspondiente modelo analítico (Data Warehouse) en esquema estrella, y un proceso ETL desarrollado con SSIS (SQL Server Integration Services), basado en la base de datos NorthWind.

---

## 👥 Integrantes del grupo

| Nombre | Usuario GitHub |
|--------|---------------|
| Jorge Félix Zientarski Balderrama | cocozien |
| José Roberto Vargas Orellana | rovox |
| Ismael Peralta Fernandez | Isma9000 |
| Lizbeth Hualca Yavi | LizbethHY |
| Maria Yesica Sanchez Calle | YesicaSc2 |

---

## 📋 Descripción del proyecto

**Dominio de negocio:** Ventas y distribución internacional de alimentos y bebidas.

NorthWind es un sistema de gestión comercial para una empresa distribuidora internacional de alimentos y bebidas que cubre el ciclo completo de operaciones: administración de catálogo, gestión de clientes, procesamiento de pedidos, coordinación con proveedores y seguimiento de envíos.

**Componentes principales:**
- ✅ **OLTP** (`NorthWindOLTP`): Modelo relacional normalizado en 3FN para operaciones transaccionales
- ✅ **DW** (`NorthWindDW`): Esquema estrella dimensional orientado a análisis histórico de ventas
- ✅ **ETL** (`NorthWindETL`): Paquetes SSIS para la carga automatizada desde OLTP hacia el DW
- ✅ **DACPAC**: Proyectos compilados para despliegue reproducible

---

## 📁 Estructura del repositorio

```
DisenioDBDataWarehouse/
├── README.md
├── NorthWindBI/                             ← Solución Visual Studio (NorthWindBI.slnx)
│   ├── NorthWindBI.slnx                     (Solución principal con los tres proyectos)
│   ├── NorthWindOLTP/                       (Proyecto SSDT — Base de datos transaccional)
│   │   ├── dbo/
│   │   └── NorthWindOLTP.sql...
│   ├── NorthWindDW/                         (Proyecto SSDT — Data Warehouse)
│   │   ├── dbo/
│   │   │   └── Tables/
│   │   │       ├── DimCustomer.sql
│   │   │       ├── DimDate.sql
│   │   │       ├── DimEmployee.sql
│   │   │       ├── DimProduct.sql
│   │   │       ├── DimShipLocation.sql
│   │   │       ├── DimShipper.sql
│   │   │       ├── FactSales.sql
│   │   │       └── PackageConfig.sql
│   │   ├── Security/
│   │   ├── staging/Tables/
│   │   └── NorthWindDW.sql...
│   └── NorthWindETL/                        (Proyecto SSIS — Paquetes ETL)
│       ├── Customer.dtsx
│       ├── Employee.dtsx
│       ├── Products.dtsx
│       ├── Sales.dtsx
│       ├── ShipLocation.dtsx
│       ├── Shipper.dtsx
│       ├── NorthWindETL.dtproj
│       └── Project.params
├── dacpac/
│   ├── Northwind.dacpac                     (OLTP compilado)
│   └── Northwind_DW.dacpac                  (DW compilado)
├── docs/
│   ├── 01_dominio_negocio.md
│   ├── 02_estado_inicial.md
│   ├── 03_normalizacion_OLTP.md
│   ├── 04_metricas_DW.md
│   ├── 05_instrucciones_despliegue.md
│   ├── 06_modelo_oltp.md
│   ├── 06_arquitectura_DW_detallada.md
│   ├── 07_despliegue_DW.md
│   ├── 08_validacion_integridad.md
│   └── dw_design_summary.md
├── imgs/
│   ├── Diagrama DW.png
│   └── ModeloOLTP.png
└── scripts/                                 (Scripts SQL standalone — alternativa a SSIS)
    ├── 01_OLTP_Schema.sql
    ├── 01_OLTP_Northwind_Full.sql
    ├── 02_DW_Schema_fase_Inicial.sql
    ├── 02_DW_Schema_final.sql               (✅ Versión FINAL del DW)
    ├── 02_Fase_Intermedia_northwind_dw.sql
    ├── 03_Carga_fact_Sales.sql
    ├── 04_Poblar_Dimensiones.sql
    ├── dim_customer.data.sql
    ├── dim_date.data.sql
    ├── dim_fact_sales.data.sql
    ├── dim_product.data.sql
    └── NorthWindDW.bak
```

---

## 🏗️ Modelo OLTP — `NorthWindOLTP`

El modelo OLTP implementa un sistema transaccional completamente normalizado en **Tercera Forma Normal (3FN)**.

### Características principales

| Aspecto | Detalle |
|---------|---------|
| **Normalización** | 3FN |
| **Tablas** | 11 (Customers, Orders, OrderDetails, Products, Categories, Suppliers, Employees, Shippers, Region, Territories, EmployeeTerritories) |
| **Registros aprox.** | ~3,257 (830 pedidos, 2,155 líneas de detalle) |
| **Propósito** | Capturar operaciones transaccionales diarias |

### Entidades principales

| Entidad | Descripción |
|---------|-------------|
| **Customers** | Empresas o personas que realizan pedidos |
| **Orders** | Pedidos registrados en el sistema |
| **OrderDetails** | Líneas de detalle de cada pedido (PK compuesta: `OrderID + ProductID`) |
| **Products** | Catálogo de productos para venta |
| **Employees** | Vendedores y personal de la empresa |
| **Suppliers** | Empresas proveedoras de productos |
| **Categories** | Agrupación de productos por tipo |
| **Shippers** | Empresas de transporte y envío |

### Normalización aplicada

- **1FN**: Valores atómicos, sin grupos repetidos, clave primaria definida en cada tabla.
- **2FN**: Todos los atributos dependen de la totalidad de la clave primaria. En `OrderDetails`, `Quantity`, `UnitPrice` y `Discount` dependen del par `OrderID + ProductID`.
- **3FN**: Sin dependencias transitivas. `CategoryName` vive en `Categories` (no en `Products`); datos del proveedor en `Suppliers` (no en `Products`).

### Reglas de negocio implementadas como constraints

```sql
CHECK (Discount >= 0 AND Discount <= 1)  -- descuento entre 0% y 100%
CHECK (Quantity > 0)                      -- cantidad debe ser positiva
CHECK (UnitPrice >= 0)                    -- precio no puede ser negativo
CHECK (BirthDate < GETDATE())             -- fecha de nacimiento válida
```

### Diagrama Entidad-Relación

> ![Diagrama ER NorthWind OLTP](imgs/ModeloOLTP.png)

**Ver documentación completa:** [📄 Modelo OLTP Detallado](docs/06_modelo_oltp.md)

---

## 📊 Data Warehouse — `NorthWindDW`

El **Data Warehouse** es un modelo dimensional en **esquema estrella**, desnormalizado y optimizado para consultas analíticas.

### Características principales

| Aspecto | Detalle |
|---------|---------|
| **Modelo** | Esquema estrella (Star Schema) |
| **Grano** | Una fila por línea de pedido (`OrderDetail`) |
| **Tablas** | 8 (1 fact + 6 dimensiones + 1 config) |
| **Registros FactSales** | ~2,155 |
| **Base de datos destino** | `NorthWindDW` |
| **Script de creación** | `scripts/02_DW_Schema_final.sql` |

### Tablas del DW — `NorthWindDW/dbo/Tables/`

| Archivo | Tabla | Tipo | Descripción |
|---------|-------|------|-------------|
| `FactSales.sql` | **FactSales** | Hecho | Métricas de ventas: Quantity, UnitPrice, Discount, ExtendedPrice, Freight |
| `DimCustomer.sql` | **DimCustomer** | Dimensión | Clientes: CompanyName, City, Country, Region |
| `DimDate.sql` | **DimDate** | Dimensión | Calendario: Day, Month, Quarter, Year (1996–1998) |
| `DimEmployee.sql` | **DimEmployee** | Dimensión | Empleados: FullName, Title, estructura organizacional |
| `DimProduct.sql` | **DimProduct** | Dimensión | Productos con categoría y proveedor desnormalizados |
| `DimShipper.sql` | **DimShipper** | Dimensión | Transportistas: CompanyName |
| `DimShipLocation.sql` | **DimShipLocation** | Dimensión | Ubicación de envío desnormalizada |
| `PackageConfig.sql` | **PackageConfig** | Config | Configuración de parámetros para paquetes SSIS |

### Métricas de `FactSales`

| Métrica | Descripción |
|---------|-------------|
| `Quantity` | Unidades vendidas por línea |
| `UnitPrice` | Precio unitario al momento de la venta |
| `Discount` | Descuento aplicado (0.0 – 1.0) |
| `ExtendedPrice` | `Quantity × UnitPrice × (1 - Discount)` |
| `Freight` | Costo de envío de la orden |

### Diagrama del Modelo Estrella

> ![Diagrama DW NorthWind Estrella](imgs/Diagrama%20DW.png)

**Ver documentación completa:** [📄 Arquitectura Detallada del DW](docs/06_arquitectura_DW_detallada.md)

---

## 🔄 ETL — `NorthWindETL` (SSIS)

El proyecto ETL fue desarrollado con **SQL Server Integration Services (SSIS)** y automatiza la extracción, transformación y carga de datos desde `NorthWindOLTP` hacia `NorthWindDW`.

### Paquetes SSIS

| Archivo | Tabla destino | Descripción |
|---------|--------------|-------------|
| `Customer.dtsx` | `DimCustomer` | Carga clientes desde `Customers` |
| `Employee.dtsx` | `DimEmployee` | Carga empleados desde `Employees` |
| `Products.dtsx` | `DimProduct` | Carga productos con categoría y proveedor |
| `Shipper.dtsx` | `DimShipper` | Carga transportistas desde `Shippers` |
| `ShipLocation.dtsx` | `DimShipLocation` | Carga ubicaciones de envío |
| `Sales.dtsx` | `FactSales` | Carga hechos de ventas desde `OrderDetails` + `Orders` |

> ⚠️ **Orden de ejecución obligatorio**: Las dimensiones deben cargarse **antes** que la tabla de hechos. `Sales.dtsx` debe ejecutarse siempre al final.

### Flujo ETL

```
NorthWindOLTP (fuente)
        │
        ├──► Customer.dtsx    ──► DimCustomer
        ├──► Employee.dtsx    ──► DimEmployee
        ├──► Products.dtsx    ──► DimProduct
        ├──► Shipper.dtsx     ──► DimShipper
        ├──► ShipLocation.dtsx──► DimShipLocation
        │                         (DimDate se genera desde el script)
        └──► Sales.dtsx       ──► FactSales
                                        │
                                NorthWindDW (destino)
```

### Archivos del proyecto ETL

| Archivo | Descripción |
|---------|-------------|
| `NorthWindETL.dtproj` | Proyecto SSIS (abrir en Visual Studio) |
| `Project.params` | Parámetros del proyecto: cadenas de conexión a OLTP y DW |
| `PackageConfig.sql` | Configuración de tablas auxiliares para los paquetes |

---

## 🗂️ Scripts SQL (alternativa sin SSIS)

| Archivo | Versión | Descripción |
|---------|---------|-------------|
| `01_OLTP_Northwind_Full.sql` | ✅ Final | Creación y población completa del OLTP |
| `02_DW_Schema_final.sql` | ✅ **FINAL** | Creación del esquema DW (versión definitiva) |
| `03_Carga_fact_Sales.sql` | ✅ Final | Carga de `FactSales` |
| `04_Poblar_Dimensiones.sql` | ✅ Final | Población de todas las dimensiones |
| `dim_customer.data.sql` | Auxiliar | Datos de `DimCustomer` |
| `dim_date.data.sql` | Auxiliar | Datos de `DimDate` |
| `dim_product.data.sql` | Auxiliar | Datos de `DimProduct` |
| `dim_fact_sales.data.sql` | Auxiliar | Datos de `FactSales` |

---

## 🚀 Instrucciones de despliegue

### Opción A: Con SSIS — Recomendado

**Requisitos**: SQL Server + Integration Services + Visual Studio con SSDT

```
1. Abrir NorthWindBI.slnx en Visual Studio
2. Configurar Project.params con las cadenas de conexión a tu instancia SQL Server
3. Build NorthWindOLTP → Deploy (crea la base Northwind)
4. Build NorthWindDW → Deploy (crea la base NorthWindDW)
5. Ejecutar paquetes SSIS en orden:
   a. Customer.dtsx
   b. Employee.dtsx
   c. Products.dtsx
   d. Shipper.dtsx
   e. ShipLocation.dtsx
   f. Sales.dtsx   ← siempre último
```

### Opción B: Con scripts SQL (sin SSIS)

```sql
-- Ejecutar en este orden exacto:
scripts/01_OLTP_Northwind_Full.sql    -- 1. Crear y poblar OLTP
scripts/02_DW_Schema_final.sql        -- 2. Crear esquema DW
scripts/04_Poblar_Dimensiones.sql     -- 3. Poblar dimensiones
scripts/03_Carga_fact_Sales.sql       -- 4. Cargar hechos (siempre último)
```

### Opción C: Despliegue mediante DACPAC

1. Abrir **SQL Server Management Studio (SSMS)**
2. Click derecho en **Databases** → **Deploy Data-tier Application...**
3. Seleccionar `dacpac/Northwind.dacpac` → despliega el OLTP
4. Repetir con `dacpac/Northwind_DW.dacpac` → despliega el DW

**Ver detalles completos:** [📄 Instrucciones de Despliegue](docs/07_despliegue_DW.md)

---

## ✅ Validación de datos

```sql
-- Validar OLTP
SELECT COUNT(*) AS Clientes FROM Northwind.dbo.Customers;        -- esperado: 91
SELECT COUNT(*) AS Pedidos  FROM Northwind.dbo.Orders;           -- esperado: 830
SELECT COUNT(*) AS Detalles FROM Northwind.dbo.OrderDetails;     -- esperado: 2,155

-- Validar DW
SELECT COUNT(*) AS FactSales  FROM NorthWindDW.dbo.FactSales;    -- esperado: 2,155
SELECT COUNT(*) AS Clientes   FROM NorthWindDW.dbo.DimCustomer;
SELECT COUNT(*) AS Productos  FROM NorthWindDW.dbo.DimProduct;
SELECT COUNT(*) AS Empleados  FROM NorthWindDW.dbo.DimEmployee;

-- Reconciliación OLTP ↔ DW (totales deben coincidir)
SELECT 'OLTP' AS Fuente, SUM(Quantity * UnitPrice * (1 - Discount)) AS TotalVentas
FROM Northwind.dbo.OrderDetails
UNION ALL
SELECT 'DW', SUM(ExtendedPrice)
FROM NorthWindDW.dbo.FactSales;
```

**Ver guía completa:** [📄 Validación de Integridad](docs/08_validacion_integridad.md)

---

## 📦 Archivos DACPAC

| Archivo | Base de datos | Descripción |
|---------|--------------|-------------|
| `dacpac/Northwind.dacpac` | `Northwind` | OLTP compilado desde Visual Studio SSDT |
| `dacpac/Northwind_DW.dacpac` | `NorthWindDW` | Data Warehouse compilado desde Visual Studio SSDT |

Generados mediante Build del proyecto `NorthWindBI.slnx` en Visual Studio. Permiten despliegue sin ejecutar scripts individuales.

---

## 📋 Resumen ejecutivo

| Aspecto | OLTP | DW |
|---------|------|----|
| **Proyecto** | `NorthWindOLTP` | `NorthWindDW` |
| **Modelo** | Relacional 3FN | Dimensional Estrella |
| **Propósito** | Operaciones transaccionales | Análisis histórico |
| **Tablas** | 11 | 8 (1 fact + 6 dim + 1 config) |
| **Registros** | ~3,257 | ~2,155 (FactSales) |
| **Optimización** | Escritura (CRUD) | Lectura (Analytics) |
| **Carga de datos** | Scripts SQL / DACPAC | SSIS (`NorthWindETL`) |

---

## 📚 Documentación

| Documento | Descripción |
|-----------|-------------|
| [01_dominio_negocio.md](docs/01_dominio_negocio.md) | Análisis del dominio de negocio |
| [02_estado_inicial.md](docs/02_estado_inicial.md) | Estado inicial de la base de datos |
| [03_normalizacion_OLTP.md](docs/03_normalizacion_OLTP.md) | Proceso de normalización del OLTP |
| [04_metricas_DW.md](docs/04_metricas_DW.md) | Métricas y KPIs del DW |
| [06_modelo_oltp.md](docs/06_modelo_oltp.md) | Modelo OLTP detallado |
| [06_arquitectura_DW_detallada.md](docs/06_arquitectura_DW_detallada.md) | Arquitectura completa del DW |
| [07_despliegue_DW.md](docs/07_despliegue_DW.md) | Instrucciones de despliegue paso a paso |
| [08_validacion_integridad.md](docs/08_validacion_integridad.md) | Validación de datos e integridad referencial |

---

## 🔗 Diagramas

- **[Diagrama OLTP ER](imgs/ModeloOLTP.png)** — Entidad-Relación del modelo transaccional
- **[Diagrama DW Estrella](imgs/Diagrama%20DW.png)** — Esquema dimensional del Data Warehouse

---

**Última actualización**: Mayo 2026 | **Estado**: Completo ✅

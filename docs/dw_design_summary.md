# Diseño Data Warehouse - Northwind

## Dominio
Ventas y distribución de productos. El OLTP Northwind se modela como sistema transaccional y el DW se orienta al análisis de pedidos, ventas, clientes, productos y desempeño logístico.

## Alcance
El análisis responde preguntas como:
- ¿Cuáles son las ventas netas por mes, país y categoría?
- ¿Qué clientes compran más?
- ¿Qué productos generan mayor ingreso?
- ¿Cómo varía el tiempo entre pedido, requerimiento y envío?
- ¿Qué transportista y empleado participan más en las ventas?

## Modelo dimensional propuesto
### Hechos
**FactOrderHeader**
- Grano: una fila por pedido.
- Métricas:
  - OrderLineCount
  - TotalQuantity
  - GrossSales
  - DiscountAmount
  - NetSales
  - FreightAmount
  - OrderLeadDays
  - ShipDelayDays

**FactSalesLine**
- Grano: una fila por cada línea de pedido.
- Métricas:
  - Quantity
  - UnitPrice
  - Discount
  - GrossSales
  - DiscountAmount
  - NetSales


### Dimensiones
- **DimDate**: año, trimestre, mes, día, semana, feriado, fin de semana.
- **DimCustomer**: cliente, ciudad, región, país, contacto.
- **DimEmployee**: empleado, cargo, fecha de contratación, ubicación.
- **DimShipper**: transportista.
- **DimCategory**: categoría de producto.
- **DimSupplier**: proveedor.
- **DimProduct**: producto con referencia a categoría y proveedor.

## Normalización OLTP
El OLTP Northwind mantiene separación clara entre:
- Customers
- Employees
- Orders
- OrderDetails
- Products
- Suppliers
- Categories
- Shippers
- Region / Territories

Esto evita redundancia y permite llegar a 3FN de forma adecuada para el sistema transaccional.

## Relaciones clave
- Orders → Customers
- Orders → Employees
- Orders → Shippers
- OrderDetails → Orders
- OrderDetails → Products
- Products → Suppliers
- Products → Categories

## Recomendación para el informe
Incluye dos diagramas:
1. ER del OLTP
2. Estrella del DW

## Estructura sugerida del repositorio
```text
/OLTP
  northwind_oltp.sql
/DW
  northwind_dw.sql
/ETL
  load_dw.sql
/DACPAC
  (proyecto SSDT)
/docs
  modelo_oltp.png
  modelo_dw.png
README.md
```

## Observación
El archivo `northwind_dw.sql` crea:
- esquema `dw`
- dimensiones
- hecho principal
- carga desde Northwind
- vista agregada mensual para análisis

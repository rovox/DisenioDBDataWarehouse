# NorthWind — Diseño OLTP y Data Warehouse

Proyecto académico desarrollado en SQL Server que implementa un modelo de base de datos transaccional (OLTP) y su correspondiente modelo analítico (Data Warehouse) basado en la base de datos NorthWind.

## Integrantes del grupo
- Jorge Felix Zientarki Balderrama
- Jose Roberto Vargas Orellana
- Ismael Peralta Fernandez
- Lizbeth Hualca Yavi
- Maria Yesica Sanchez Calle

## Descripción del proyecto

**Dominio de negocio:** Ventas y distribución internacional de alimentos y bebidas.

NorthWind es un sistema de gestión comercial para una empresa distribuidora internacional de alimentos y bebidas. El sistema cubre el ciclo completo de ventas, desde la administración del catálogo de productos y la gestión de clientes, hasta el procesamiento de pedidos, la coordinación con proveedores y el seguimiento de envíos a través de transportistas externos. Como parte de este proyecto se diseñó un modelo OLTP completamente normalizado en Tercera Forma Normal (3FN) y un Data Warehouse en esquema estrella orientado al análisis histórico de ventas.

---

## Estructura del repositorio

La solución está organizada en tres carpetas principales que separan claramente el modelo transaccional, el modelo analítico y el paquete de despliegue:
DisenioDBDataWarehouse/
├── README.md
├── OLTP/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_insert_data.sql
│   └── diagrama_ER.png
├── DW/
│   ├── 01_create_dw.sql
│   ├── 02_dimensiones.sql
│   ├── 03_fact_table.sql
│   ├── 04_etl_procedures.sql
│   └── diagrama_estrella.png
└── DACPAC/
└── NorthWindDW.dacpac

---

## Modelo OLTP

### Diagrama Entidad-Relación

El siguiente diagrama representa el modelo físico de la base de datos NorthWind, generado a partir del esquema implementado en SQL Server. Muestra las 14 tablas del sistema, sus atributos, claves primarias, claves foráneas y las relaciones de integridad referencial entre ellas.

![Diagrama ER NorthWind](OLTP/diagrama_ER.png)

### Entidades principales

El modelo está compuesto por las siguientes entidades, cada una con una responsabilidad clara dentro del dominio de negocio:

| Entidad | Descripción |
|---|---|
| Customers | Empresas o personas que realizan pedidos |
| Orders | Pedidos registrados en el sistema |
| OrderDetails | Líneas de detalle de cada pedido |
| Products | Catálogo de productos disponibles para venta |
| Categories | Agrupación de productos por tipo |
| Suppliers | Empresas proveedoras de productos |
| Employees | Vendedores y personal de la empresa |
| Shippers | Empresas de transporte y envío |
| Region / Territories | Organización territorial de las ventas |

### Normalización

El modelo cumple con los requisitos de la Tercera Forma Normal (3FN), lo que garantiza la eliminación de redundancias y la consistencia de los datos ante operaciones de inserción, actualización y eliminación.

- **Primera Forma Normal (1FN):** Todos los atributos almacenan valores atómicos e indivisibles. No existen grupos repetidos ni columnas multivalor. Cada tabla cuenta con una clave primaria claramente definida.
- **Segunda Forma Normal (2FN):** Todos los atributos no clave dependen funcionalmente de la totalidad de la clave primaria. En la tabla `OrderDetails`, cuya clave es compuesta (`OrderID + ProductID`), los campos `UnitPrice`, `Quantity` y `Discount` dependen de ambas columnas en conjunto, no de una sola parte de la clave.
- **Tercera Forma Normal (3FN):** No existen dependencias transitivas entre atributos no clave. Por ejemplo, `CategoryName` no se almacena en `Products` sino en su propia tabla `Categories`, referenciada mediante `CategoryID`. De igual forma, los datos del proveedor residen en `Suppliers` y no se repiten en `Products`. Esto garantiza que un cambio en el nombre de una categoría o proveedor se actualice en un único lugar.

### Reglas de negocio implementadas

Las siguientes restricciones de negocio están implementadas directamente en el esquema de la base de datos mediante cláusulas `CHECK` y `FOREIGN KEY`, asegurando la integridad de los datos independientemente de la aplicación cliente:

- El descuento debe estar entre 0% y 100%: `CHECK (Discount >= 0 AND Discount <= 1)`
- La cantidad pedida debe ser mayor a cero: `CHECK (Quantity > 0)`
- Los precios no pueden ser negativos: `CHECK (UnitPrice >= 0)`
- La fecha de nacimiento del empleado debe ser anterior a la fecha actual: `CHECK (BirthDate < GETDATE())`
- Integridad referencial completa entre todas las tablas mediante `FOREIGN KEY`

---

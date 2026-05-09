CREATE TABLE [staging].[product] (
    [ProductSK]            INT            NULL,
    [ProductID]            INT            NOT NULL,
    [ProductName]          NVARCHAR (40)  NOT NULL,
    [QuantityPerUnit]      NVARCHAR (20)  NULL,
    [UnitPrice]            MONEY          NULL,
    [UnitsInStock]         SMALLINT       NULL,
    [UnitsOnOrder]         SMALLINT       NULL,
    [ReorderLevel]         SMALLINT       NULL,
    [Discontinued]         BIT            NOT NULL,
    [CategoryName]         NVARCHAR (15)  NULL,
    [CategoryDescription]  NVARCHAR (MAX) NULL,
    [SupplierName]         NVARCHAR (40)  NULL,
    [SupplierContactName]  NVARCHAR (30)  NULL,
    [SupplierContactTitle] NVARCHAR (30)  NULL,
    [SupplierCity]         NVARCHAR (15)  NULL,
    [SupplierRegion]       NVARCHAR (15)  NULL,
    [SupplierCountry]      NVARCHAR (15)  NULL
);


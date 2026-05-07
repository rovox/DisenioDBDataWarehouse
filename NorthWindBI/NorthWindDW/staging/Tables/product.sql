CREATE TABLE [staging].[product] (
    [ProductSK]       INT           NULL,
    [ProductID]       INT           NOT NULL,
    [ProductName]     NVARCHAR (40) NOT NULL,
    [CompanyName]     NVARCHAR (40) NOT NULL,
    [CategoryName]    NVARCHAR (15) NOT NULL,
    [QuantityPerUnit] NVARCHAR (20) NULL,
    [UnitPrice]       MONEY         NULL,
    [UnitsInStock]    SMALLINT      NULL,
    [UnitsOnOrder]    SMALLINT      NULL,
    [ReorderLevel]    SMALLINT      NULL,
    [Discontinued]    BIT           NOT NULL
);


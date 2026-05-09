CREATE TABLE [dbo].[FactSales] (
    [OrderID]         INT      NOT NULL,
    [ProductID]       INT      NOT NULL,
    [OrderDateKey]    INT      NULL,
    [RequiredDateKey] INT      NOT NULL,
    [ShippedDateKey]  INT      NOT NULL,
    [CustomerSK]      INT      NOT NULL,
    [ProductSK]       INT      NOT NULL,
    [EmployeeSK]      INT      NULL,
    [ShipperSK]       INT      NULL,
    [ShipLocationSK]  INT      NULL,
    [UnitPrice]       MONEY    NOT NULL,
    [Quantity]        SMALLINT NOT NULL,
    [Discount]        REAL     NOT NULL,
    [GrossAmount]     MONEY    NOT NULL,
    [DiscountAmount]  MONEY    NOT NULL,
    [NetAmount]       MONEY    NOT NULL,
    [FreightAmount]   MONEY    NULL,
    CONSTRAINT [PK_FactSales] PRIMARY KEY CLUSTERED ([OrderID] ASC, [ProductID] ASC),
    CONSTRAINT [FK_FactSales_DimCustomer] FOREIGN KEY ([CustomerSK]) REFERENCES [dbo].[DimCustomer] ([CustomerSK]),
    CONSTRAINT [FK_FactSales_DimDate_OrderDate] FOREIGN KEY ([OrderDateKey]) REFERENCES [dbo].[DimDate] ([DateKey]),
    CONSTRAINT [FK_FactSales_DimDate_RequiredDate] FOREIGN KEY ([RequiredDateKey]) REFERENCES [dbo].[DimDate] ([DateKey]),
    CONSTRAINT [FK_FactSales_DimDate_ShippedDate] FOREIGN KEY ([ShippedDateKey]) REFERENCES [dbo].[DimDate] ([DateKey]),
    CONSTRAINT [FK_FactSales_DimEmployee] FOREIGN KEY ([EmployeeSK]) REFERENCES [dbo].[DimEmployee] ([EmployeeSK]),
    CONSTRAINT [FK_FactSales_DimProduct] FOREIGN KEY ([ProductSK]) REFERENCES [dbo].[DimProduct] ([ProductSK]),
    CONSTRAINT [FK_FactSales_DimShipLocation] FOREIGN KEY ([ShipLocationSK]) REFERENCES [dbo].[DimShipLocation] ([ShipLocationSK]),
    CONSTRAINT [FK_FactSales_DimShipper] FOREIGN KEY ([ShipperSK]) REFERENCES [dbo].[DimShipper] ([ShipperSK])
);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_OrderDateKey]
    ON [dbo].[FactSales]([OrderDateKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_CustomerSK]
    ON [dbo].[FactSales]([CustomerSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ProductSK]
    ON [dbo].[FactSales]([ProductSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_EmployeeSK]
    ON [dbo].[FactSales]([EmployeeSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipperKey]
    ON [dbo].[FactSales]([ShipperSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipLocationSK]
    ON [dbo].[FactSales]([ShipLocationSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_CustomerKey]
    ON [dbo].[FactSales]([CustomerSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ProductKey]
    ON [dbo].[FactSales]([ProductSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipperSK]
    ON [dbo].[FactSales]([ShipperSK] ASC);


CREATE TABLE [staging].[Sales] (
    [SalesKey]        BIGINT   NULL,
    [OrderID]         INT      NOT NULL,
    [ProductID]       INT      NOT NULL,
    [OrderDateKey]    INT      NULL,
    [RequiredDateKey] INT      NULL,
    [ShippedDateKey]  INT      NULL,
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
    [FreightAmount]   MONEY    NULL
);


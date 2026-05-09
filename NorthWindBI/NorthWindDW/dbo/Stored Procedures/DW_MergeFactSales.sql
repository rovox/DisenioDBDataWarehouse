CREATE PROCEDURE [dbo].[DW_MergeFactSales]
AS
BEGIN

	UPDATE fs
	SET [OrderDateKey]     = sc.[OrderDateKey]
	   ,[RequiredDateKey]  = sc.[RequiredDateKey]
	   ,[ShippedDateKey]   = sc.[ShippedDateKey]
	   ,[CustomerSK]       = sc.[CustomerSK]
	   ,[ProductSK]        = sc.[ProductSK]
	   ,[EmployeeSK]       = sc.[EmployeeSK]
	   ,[ShipperSK]        = sc.[ShipperSK]
	   ,[ShipLocationSK]   = sc.[ShipLocationSK]
	   ,[UnitPrice]        = sc.[UnitPrice]
	   ,[Quantity]         = sc.[Quantity]
	   ,[Discount]         = sc.[Discount]
	   ,[GrossAmount]      = sc.[GrossAmount]
	   ,[DiscountAmount]   = sc.[DiscountAmount]
	   ,[NetAmount]        = sc.[NetAmount]
	   ,[FreightAmount]    = sc.[FreightAmount]

	FROM [dbo].[FactSales] fs
	INNER JOIN [staging].[Sales] sc ON (fs.[OrderID] = sc.[OrderID] AND fs.[ProductID] = sc.[ProductID])
END

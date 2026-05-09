CREATE PROCEDURE [dbo].[DW_MergeDimProduct]
AS
BEGIN

	UPDATE dc
	SET [ProductName]          = sc.[ProductName]
       ,[QuantityPerUnit]      = sc.[QuantityPerUnit]
       ,[UnitPrice]            = sc.[UnitPrice]
       ,[UnitsInStock]         = sc.[UnitsInStock]
       ,[UnitsOnOrder]         = sc.[UnitsOnOrder]
       ,[ReorderLevel]         = sc.[ReorderLevel]
       ,[Discontinued]         = sc.[Discontinued]
       ,[CategoryName]         = sc.[CategoryName]
       ,[CategoryDescription]  = sc.[CategoryDescription]
       ,[SupplierName]         = sc.[SupplierName]
       ,[SupplierContactName]  = sc.[SupplierContactName]
       ,[SupplierContactTitle] = sc.[SupplierContactTitle]
       ,[SupplierCity]         = sc.[SupplierCity]
       ,[SupplierRegion]       = sc.[SupplierRegion]
       ,[SupplierCountry]      = sc.[SupplierCountry]

	FROM [dbo].[DimProduct]         dc
	INNER JOIN [staging].[product] sc ON (dc.[ProductSK]=sc.[ProductSK])
END

CREATE PROCEDURE [dbo].[DW_MergeDimProduct]
AS
BEGIN

	UPDATE dc
	SET [ProductName]     = sc.[ProductName]
       ,[SupplierName]    = sc.[CompanyName]
       ,[CategoryName]    = sc.[CategoryName]
       ,[QuantityPerUnit] = sc.[QuantityPerUnit]
       ,[UnitPrice]       = sc.[UnitPrice]
       ,[UnitsInStock]    = sc.[UnitsInStock]
       ,[UnitsOnOrder]    = sc.[UnitsOnOrder]
       ,[ReorderLevel]    = sc.[ReorderLevel]
       ,[Discontinued]    = sc.[Discontinued]
	FROM [dbo].[DimProduct]         dc
	INNER JOIN [staging].[product] sc ON (dc.[ProductSK]=sc.[ProductSK])
END

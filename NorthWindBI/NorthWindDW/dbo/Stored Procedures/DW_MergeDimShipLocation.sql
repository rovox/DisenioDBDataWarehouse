CREATE PROCEDURE [dbo].[DW_MergeDimShipLocation]
AS
BEGIN

	UPDATE ds
	SET [OrderID]        = sc.[OrderID]
	   ,[ShipName]       = sc.[ShipName]
	   ,[ShipAddress]    = sc.[ShipAddress]
	   ,[ShipCity]       = sc.[ShipCity]
	   ,[ShipRegion]     = sc.[ShipRegion]
	   ,[ShipPostalCode] = sc.[ShipPostalCode]
	   ,[ShipCountry]    = sc.[ShipCountry]

	FROM [dbo].[DimShipLocation] ds
	INNER JOIN [staging].[ShipLocation] sc ON (ds.[ShipLocationSK]=sc.[ShipLocationSK])
END

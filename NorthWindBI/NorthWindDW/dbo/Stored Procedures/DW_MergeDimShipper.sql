CREATE PROCEDURE [dbo].[DW_MergeDimShipper]
AS
BEGIN

	UPDATE ds
	SET [CompanyName] = sc.[CompanyName]
       ,[Phone]       = sc.[Phone]

	FROM [dbo].[DimShipper] ds
	INNER JOIN [staging].[Shipper] sc ON (ds.[ShipperSK]=sc.[ShipperSK])
END

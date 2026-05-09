CREATE PROCEDURE [dbo].[GetShipLocationChangesByRowVersion]
(
   @startRow BIGINT 
   ,@endRow  BIGINT 
)
AS
BEGIN
  SELECT o.[OrderID]
      ,o.[ShipName]
	  ,o.[ShipAddress]
	  ,o.[ShipCity]
	  ,o.[ShipRegion]
	  ,o.[ShipPostalCode]
	  ,o.[ShipCountry]

  FROM 
	[dbo].[Orders] o
  WHERE 
	(o.[rowversion] > CONVERT(ROWVERSION,@startRow) AND o.[rowversion] <= CONVERT(ROWVERSION,@endRow))
END

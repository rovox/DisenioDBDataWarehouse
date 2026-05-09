CREATE PROCEDURE [dbo].[GetShipperChangesByRowVersion]
(
   @startRow BIGINT 
   ,@endRow  BIGINT 
)
AS
BEGIN
  SELECT s.[ShipperID]
      ,s.[CompanyName]
      ,s.[Phone]
  FROM 
	[dbo].[Shippers] s
  WHERE 
	(s.[rowversion] > CONVERT(ROWVERSION,@startRow) AND s.[rowversion] <= CONVERT(ROWVERSION,@endRow))
END

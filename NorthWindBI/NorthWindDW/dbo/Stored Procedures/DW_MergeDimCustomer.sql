CREATE PROCEDURE [dbo].[DW_MergeDimCustomer]
AS
BEGIN

	UPDATE dc
	SET [CompanyName]     = sc.[CompanyName]
       ,[ContactName]     = sc.[ContactName]
       ,[ContactTitle]    = sc.[ContactTitle]
       ,[Address]         = sc.[Address]
       ,[City]            = sc.[City]
       ,[Region]          = sc.[Region]
       ,[PostalCode]      = sc.[PostalCode]
       ,[Country]         = sc.[Country]
       ,[Phone]           = sc.[Phone]
       ,[Fax]             = sc.[Fax]

	FROM [dbo].[DimCustomer]         dc
	INNER JOIN [staging].[Customer] sc ON (dc.[CustomerSK]=sc.[CustomerSK])
END

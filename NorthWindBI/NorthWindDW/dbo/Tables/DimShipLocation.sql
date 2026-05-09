CREATE TABLE [dbo].[DimShipLocation] (
    [ShipLocationSK] INT           IDENTITY (1, 1) NOT NULL,
    [OrderID]        INT           NULL,
    [ShipName]       NVARCHAR (40) NULL,
    [ShipAddress]    NVARCHAR (60) NULL,
    [ShipCity]       NVARCHAR (15) NULL,
    [ShipRegion]     NVARCHAR (15) NULL,
    [ShipPostalCode] NVARCHAR (10) NULL,
    [ShipCountry]    NVARCHAR (15) NULL,
    CONSTRAINT [PK_DimShipLocation] PRIMARY KEY CLUSTERED ([ShipLocationSK] ASC)
);


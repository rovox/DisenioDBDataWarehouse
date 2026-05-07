USE [master]
GO
/****** Objeto: Database [NorthWindDW] Fecha de script: 06/05/2026 23:28:55 ******/
CREATE DATABASE [NorthWindDW]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'NorthWindDW', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\NorthWindDW.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'NorthWindDW_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\NorthWindDW_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [NorthWindDW] SET COMPATIBILITY_LEVEL = 170
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [NorthWindDW].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [NorthWindDW] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [NorthWindDW] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [NorthWindDW] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [NorthWindDW] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [NorthWindDW] SET ARITHABORT OFF 
GO
ALTER DATABASE [NorthWindDW] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [NorthWindDW] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [NorthWindDW] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [NorthWindDW] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [NorthWindDW] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [NorthWindDW] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [NorthWindDW] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [NorthWindDW] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [NorthWindDW] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [NorthWindDW] SET  DISABLE_BROKER 
GO
ALTER DATABASE [NorthWindDW] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [NorthWindDW] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [NorthWindDW] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [NorthWindDW] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [NorthWindDW] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [NorthWindDW] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [NorthWindDW] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [NorthWindDW] SET RECOVERY FULL 
GO
ALTER DATABASE [NorthWindDW] SET  MULTI_USER 
GO
ALTER DATABASE [NorthWindDW] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [NorthWindDW] SET DB_CHAINING OFF 
GO
ALTER DATABASE [NorthWindDW] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [NorthWindDW] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [NorthWindDW] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [NorthWindDW] SET OPTIMIZED_LOCKING = OFF 
GO
ALTER DATABASE [NorthWindDW] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'NorthWindDW', N'ON'
GO
ALTER DATABASE [NorthWindDW] SET QUERY_STORE = ON
GO
ALTER DATABASE [NorthWindDW] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [NorthWindDW]
GO
/****** Objeto: Schema [staging] Fecha de script: 06/05/2026 23:28:56 ******/
CREATE SCHEMA [staging]
GO
/****** Objeto: Table [dbo].[DimCustomer] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimCustomer](
	[CustomerSK] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [nvarchar](15) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL,
 CONSTRAINT [PK_DimCustomer] PRIMARY KEY CLUSTERED 
(
	[CustomerSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[DimDate] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimDate](
	[DateKey] [int] NOT NULL,
	[FullDate] [date] NOT NULL,
	[DayNumber] [int] NOT NULL,
	[MonthNumber] [int] NOT NULL,
	[MonthName] [nvarchar](20) NOT NULL,
	[QuarterNumber] [int] NOT NULL,
	[YearNumber] [int] NOT NULL,
	[DayName] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[DimEmployee] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimEmployee](
	[EmployeeSK] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [int] NOT NULL,
	[LastName] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](10) NOT NULL,
	[FullName]  AS (([FirstName]+' ')+[LastName]),
	[Title] [nvarchar](30) NULL,
	[TitleOfCourtesy] [nvarchar](25) NULL,
	[BirthDate] [datetime] NULL,
	[HireDate] [datetime] NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [nvarchar](15) NULL,
	[HomePhone] [nvarchar](24) NULL,
	[Extension] [nvarchar](4) NULL,
	[ReportsTo] [int] NULL,
 CONSTRAINT [PK_DimEmployee] PRIMARY KEY CLUSTERED 
(
	[EmployeeSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[DimProduct] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimProduct](
	[ProductSK] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](40) NOT NULL,
	[QuantityPerUnit] [nvarchar](20) NULL,
	[UnitPrice] [money] NULL,
	[UnitsInStock] [smallint] NULL,
	[UnitsOnOrder] [smallint] NULL,
	[ReorderLevel] [smallint] NULL,
	[Discontinued] [bit] NOT NULL,
	[CategoryName] [nvarchar](15) NULL,
	[CategoryDescription] [nvarchar](max) NULL,
	[SupplierName] [nvarchar](40) NULL,
	[SupplierContactName] [nvarchar](30) NULL,
	[SupplierContactTitle] [nvarchar](30) NULL,
	[SupplierCity] [nvarchar](15) NULL,
	[SupplierRegion] [nvarchar](15) NULL,
	[SupplierCountry] [nvarchar](15) NULL,
 CONSTRAINT [PK_DimProduct] PRIMARY KEY CLUSTERED 
(
	[ProductSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[DimShipLocation] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimShipLocation](
	[ShipLocationSK] [int] IDENTITY(1,1) NOT NULL,
	[ShipName] [nvarchar](40) NULL,
	[ShipAddress] [nvarchar](60) NULL,
	[ShipCity] [nvarchar](15) NULL,
	[ShipRegion] [nvarchar](15) NULL,
	[ShipPostalCode] [nvarchar](10) NULL,
	[ShipCountry] [nvarchar](15) NULL,
 CONSTRAINT [PK_DimShipLocation] PRIMARY KEY CLUSTERED 
(
	[ShipLocationSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[DimShipper] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimShipper](
	[ShipperSK] [int] IDENTITY(1,1) NOT NULL,
	[ShipperID] [int] NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[Phone] [nvarchar](24) NULL,
 CONSTRAINT [PK_DimShipper] PRIMARY KEY CLUSTERED 
(
	[ShipperSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[FactSales] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactSales](
	[SalesKey] [bigint] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[OrderDateKey] [int] NULL,
	[RequiredDateKey] [int] NULL,
	[ShippedDateKey] [int] NULL,
	[CustomerSK] [int] NOT NULL,
	[ProductSK] [int] NOT NULL,
	[EmployeeSK] [int] NULL,
	[ShipperSK] [int] NULL,
	[ShipLocationSK] [int] NULL,
	[UnitPrice] [money] NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [real] NOT NULL,
	[GrossAmount] [money] NOT NULL,
	[DiscountAmount] [money] NOT NULL,
	[NetAmount] [money] NOT NULL,
	[FreightAmount] [money] NULL,
 CONSTRAINT [PK_FactSales] PRIMARY KEY CLUSTERED 
(
	[SalesKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[PackageConfig] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PackageConfig](
	[PackageID] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [varchar](50) NOT NULL,
	[LastRowVersion] [bigint] NULL,
 CONSTRAINT [PK_PackageConfig] PRIMARY KEY CLUSTERED 
(
	[PackageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [staging].[Customer] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [staging].[Customer](
	[CustomerSK] [int] NULL,
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [nvarchar](15) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL
) ON [PRIMARY]
GO
/****** Objeto: Table [staging].[Employee] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [staging].[Employee](
	[EmployeeSK] [int] NULL,
	[EmployeeID] [int] NOT NULL,
	[LastName] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](10) NOT NULL,
	[FullName]  AS (([FirstName]+' ')+[LastName]),
	[Title] [nvarchar](30) NULL,
	[TitleOfCourtesy] [nvarchar](25) NULL,
	[BirthDate] [datetime] NULL,
	[HireDate] [datetime] NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [nvarchar](15) NULL,
	[HomePhone] [nvarchar](24) NULL,
	[Extension] [nvarchar](4) NULL,
	[ReportsTo] [int] NULL
) ON [PRIMARY]
GO
/****** Objeto: Table [staging].[product] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [staging].[product](
	[ProductSK] [int] NULL,
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](40) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[CategoryName] [nvarchar](15) NOT NULL,
	[QuantityPerUnit] [nvarchar](20) NULL,
	[UnitPrice] [money] NULL,
	[UnitsInStock] [smallint] NULL,
	[UnitsOnOrder] [smallint] NULL,
	[ReorderLevel] [smallint] NULL,
	[Discontinued] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Objeto: Table [staging].[Sales] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [staging].[Sales](
	[SalesKey] [bigint] NULL,
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[OrderDateKey] [int] NULL,
	[RequiredDateKey] [int] NULL,
	[ShippedDateKey] [int] NULL,
	[CustomerSK] [int] NOT NULL,
	[ProductSK] [int] NOT NULL,
	[EmployeeSK] [int] NULL,
	[ShipperSK] [int] NULL,
	[ShipLocationSK] [int] NULL,
	[UnitPrice] [money] NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [real] NOT NULL,
	[GrossAmount] [money] NOT NULL,
	[DiscountAmount] [money] NOT NULL,
	[NetAmount] [money] NOT NULL,
	[FreightAmount] [money] NULL
) ON [PRIMARY]
GO
/****** Objeto: Table [staging].[ShipLocation] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [staging].[ShipLocation](
	[ShipLocationSK] [int] NULL,
	[ShipName] [nvarchar](40) NULL,
	[ShipAddress] [nvarchar](60) NULL,
	[ShipCity] [nvarchar](15) NULL,
	[ShipRegion] [nvarchar](15) NULL,
	[ShipPostalCode] [nvarchar](10) NULL,
	[ShipCountry] [nvarchar](15) NULL
) ON [PRIMARY]
GO
/****** Objeto: Table [staging].[Shipper] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [staging].[Shipper](
	[ShipperSK] [int] NULL,
	[ShipperID] [int] NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[Phone] [nvarchar](24) NULL
) ON [PRIMARY]
GO
/****** Objeto: Index [IX_FactSales_CustomerKey] Fecha de script: 06/05/2026 23:28:56 ******/
CREATE NONCLUSTERED INDEX [IX_FactSales_CustomerKey] ON [dbo].[FactSales]
(
	[CustomerSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_FactSales_CustomerSK] Fecha de script: 06/05/2026 23:28:56 ******/
CREATE NONCLUSTERED INDEX [IX_FactSales_CustomerSK] ON [dbo].[FactSales]
(
	[CustomerSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_FactSales_EmployeeSK] Fecha de script: 06/05/2026 23:28:56 ******/
CREATE NONCLUSTERED INDEX [IX_FactSales_EmployeeSK] ON [dbo].[FactSales]
(
	[EmployeeSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_FactSales_OrderDateKey] Fecha de script: 06/05/2026 23:28:56 ******/
CREATE NONCLUSTERED INDEX [IX_FactSales_OrderDateKey] ON [dbo].[FactSales]
(
	[OrderDateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_FactSales_ProductKey] Fecha de script: 06/05/2026 23:28:56 ******/
CREATE NONCLUSTERED INDEX [IX_FactSales_ProductKey] ON [dbo].[FactSales]
(
	[ProductSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_FactSales_ProductSK] Fecha de script: 06/05/2026 23:28:56 ******/
CREATE NONCLUSTERED INDEX [IX_FactSales_ProductSK] ON [dbo].[FactSales]
(
	[ProductSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_FactSales_ShipLocationSK] Fecha de script: 06/05/2026 23:28:56 ******/
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipLocationSK] ON [dbo].[FactSales]
(
	[ShipLocationSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_FactSales_ShipperKey] Fecha de script: 06/05/2026 23:28:56 ******/
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipperKey] ON [dbo].[FactSales]
(
	[ShipperSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_FactSales_ShipperSK] Fecha de script: 06/05/2026 23:28:56 ******/
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipperSK] ON [dbo].[FactSales]
(
	[ShipperSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FactSales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_DimCustomer] FOREIGN KEY([CustomerSK])
REFERENCES [dbo].[DimCustomer] ([CustomerSK])
GO
ALTER TABLE [dbo].[FactSales] CHECK CONSTRAINT [FK_FactSales_DimCustomer]
GO
ALTER TABLE [dbo].[FactSales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_DimDate_OrderDate] FOREIGN KEY([OrderDateKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO
ALTER TABLE [dbo].[FactSales] CHECK CONSTRAINT [FK_FactSales_DimDate_OrderDate]
GO
ALTER TABLE [dbo].[FactSales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_DimDate_RequiredDate] FOREIGN KEY([RequiredDateKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO
ALTER TABLE [dbo].[FactSales] CHECK CONSTRAINT [FK_FactSales_DimDate_RequiredDate]
GO
ALTER TABLE [dbo].[FactSales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_DimDate_ShippedDate] FOREIGN KEY([ShippedDateKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO
ALTER TABLE [dbo].[FactSales] CHECK CONSTRAINT [FK_FactSales_DimDate_ShippedDate]
GO
ALTER TABLE [dbo].[FactSales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_DimEmployee] FOREIGN KEY([EmployeeSK])
REFERENCES [dbo].[DimEmployee] ([EmployeeSK])
GO
ALTER TABLE [dbo].[FactSales] CHECK CONSTRAINT [FK_FactSales_DimEmployee]
GO
ALTER TABLE [dbo].[FactSales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_DimProduct] FOREIGN KEY([ProductSK])
REFERENCES [dbo].[DimProduct] ([ProductSK])
GO
ALTER TABLE [dbo].[FactSales] CHECK CONSTRAINT [FK_FactSales_DimProduct]
GO
ALTER TABLE [dbo].[FactSales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_DimShipLocation] FOREIGN KEY([ShipLocationSK])
REFERENCES [dbo].[DimShipLocation] ([ShipLocationSK])
GO
ALTER TABLE [dbo].[FactSales] CHECK CONSTRAINT [FK_FactSales_DimShipLocation]
GO
ALTER TABLE [dbo].[FactSales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_DimShipper] FOREIGN KEY([ShipperSK])
REFERENCES [dbo].[DimShipper] ([ShipperSK])
GO
ALTER TABLE [dbo].[FactSales] CHECK CONSTRAINT [FK_FactSales_DimShipper]
GO
/****** Objeto: StoredProcedure [dbo].[DW_MergeDimCustomer] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO
/****** Objeto: StoredProcedure [dbo].[DW_MergeDimEmployee] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DW_MergeDimEmployee]
AS
BEGIN

	UPDATE dc
	SET [LastName]        = sc.[LastName]
       ,[FirstName]       = sc.[FirstName]
       ,[Title]           = sc.[Title]
       ,[TitleOfCourtesy] = sc.[TitleOfCourtesy]
       ,[BirthDate]       = sc.[BirthDate]
       ,[HireDate]        = sc.[HireDate]
       ,[Address]         = sc.[Address]
       ,[City]            = sc.[City] 
       ,[Region]          = sc.[Region]
       ,[PostalCode]      = sc.[PostalCode]
       ,[Country]         = sc.[Country]
       ,[HomePhone]       = sc.[HomePhone]
       ,[Extension]       = sc.[Extension]
       ,[ReportsTo]       = sc.[ReportsTo]

	FROM [dbo].[DimEmployee]         dc
	INNER JOIN [staging].[Employee] sc ON (dc.[EmployeeSK]=sc.[EmployeeSK])
END
GO
/****** Objeto: StoredProcedure [dbo].[DW_MergeDimProduct] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO
/****** Objeto: StoredProcedure [dbo].[GetLastPackageRowVersion] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetLastPackageRowVersion]
(
	@tableName VARCHAR(50)
)
  AS
  BEGIN
	SELECT LastRowVersion
	FROM [dbo].[PackageConfig]
	WHERE TableName = @tableName;
  END
GO
/****** Objeto: StoredProcedure [dbo].[UpdateLastPackageRowVersion] Fecha de script: 06/05/2026 23:28:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateLastPackageRowVersion]
  (
	@tableName VARCHAR(50)
	,@lastRowVersion BIGINT
  )
  AS
  BEGIN
	UPDATE [dbo].[PackageConfig]
	SET LastRowVersion = @lastRowVersion
	WHERE TableName = @tableName;
  END
GO
USE [master]
GO
ALTER DATABASE [NorthWindDW] SET  READ_WRITE 
GO

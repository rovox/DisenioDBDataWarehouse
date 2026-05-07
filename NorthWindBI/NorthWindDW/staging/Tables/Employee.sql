CREATE TABLE [staging].[Employee] (
    [EmployeeSK]      INT           NULL,
    [EmployeeID]      INT           NOT NULL,
    [LastName]        NVARCHAR (20) NOT NULL,
    [FirstName]       NVARCHAR (10) NOT NULL,
    [FullName]        AS            (([FirstName]+' ')+[LastName]),
    [Title]           NVARCHAR (30) NULL,
    [TitleOfCourtesy] NVARCHAR (25) NULL,
    [BirthDate]       DATETIME      NULL,
    [HireDate]        DATETIME      NULL,
    [Address]         NVARCHAR (60) NULL,
    [City]            NVARCHAR (15) NULL,
    [Region]          NVARCHAR (15) NULL,
    [PostalCode]      NVARCHAR (10) NULL,
    [Country]         NVARCHAR (15) NULL,
    [HomePhone]       NVARCHAR (24) NULL,
    [Extension]       NVARCHAR (4)  NULL,
    [ReportsTo]       INT           NULL
);


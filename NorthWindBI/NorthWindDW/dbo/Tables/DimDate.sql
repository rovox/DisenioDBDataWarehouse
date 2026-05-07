CREATE TABLE [dbo].[DimDate] (
    [DateKey]       INT           NOT NULL,
    [FullDate]      DATE          NOT NULL,
    [DayNumber]     INT           NOT NULL,
    [MonthNumber]   INT           NOT NULL,
    [MonthName]     NVARCHAR (20) NOT NULL,
    [QuarterNumber] INT           NOT NULL,
    [YearNumber]    INT           NOT NULL,
    [DayName]       NVARCHAR (20) NOT NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateKey] ASC)
);


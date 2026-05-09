CREATE TABLE [dbo].[DimDate] (
    [DateKey]           INT           NOT NULL,
    [FullDate]          DATE          NOT NULL,
    [DayNumberOfWeek]   TINYINT       NOT NULL,
    [DayNameOfWeek]     NVARCHAR (10) NOT NULL,
    [DayNumberOfMonth]  TINYINT       NOT NULL,
    [DayNumberOfYear]   SMALLINT      NOT NULL,
    [WeekNumberOfYear]  TINYINT       NOT NULL,
    [MonthName]         NVARCHAR (10) NOT NULL,
    [MonthNumberOfYear] TINYINT       NOT NULL,
    [CalendarQuarter]   TINYINT       NOT NULL,
    [CalendarYear]      SMALLINT      NOT NULL,
    [CalendarSemester]  TINYINT       NOT NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateKey] ASC)
);


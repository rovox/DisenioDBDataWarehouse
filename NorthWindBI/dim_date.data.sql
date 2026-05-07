USE Northwind_DW;
GO

DELETE FROM dw.FactSalesLine;
DELETE FROM dw.DimDate;

DECLARE @StartDate DATE = '1996-01-01';
DECLARE @EndDate DATE = '1998-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO dw.DimDate (DateKey, FullDate, [Year], QuarterOfYear, MonthOfYear, MonthName, DayOfMonth, DayOfWeek, DayName, WeekOfYear, IsWeekend)
    VALUES (
        CONVERT(INT, CONVERT(VARCHAR(8), @StartDate, 112)), 
        @StartDate, 
        YEAR(@StartDate), 
        DATEPART(QUARTER, @StartDate), 
        MONTH(@StartDate), 
        DATENAME(MONTH, @StartDate) COLLATE DATABASE_DEFAULT, 
        DAY(@StartDate), 
        DATEPART(WEEKDAY, @StartDate), 
        DATENAME(WEEKDAY, @StartDate) COLLATE DATABASE_DEFAULT, 
        DATEPART(WEEK, @StartDate), 
        CASE WHEN DATEPART(WEEKDAY, @StartDate) IN (1, 7) THEN 1 ELSE 0 END
    );
    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END
GO

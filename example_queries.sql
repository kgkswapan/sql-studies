CREATE DATABASE Practice;
GO
USE Practice;
GO

CREATE TABLE dbo.[task](
  [Task Id]   INT PRIMARY KEY,
  [Task Name] NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.[report](
  [User Name] NVARCHAR(100) NOT NULL,
  [Task Id]   INT NOT NULL,
  [Score]     INT NOT NULL
);

INSERT INTO dbo.[task] ([Task Id], [Task Name]) VALUES
(1, 'Joins'),
(2, 'Aggregations'),
(3, 'Case Statements');

INSERT INTO dbo.[report] ([User Name], [Task Id], [Score]) VALUES
(N'Alice', 1, 92),
(N'Alice', 2, 75),
(N'Bob',   1, 45),
(N'Bob',   3, 81),
(N'Cara',  2, 66);

SELECT r.[User Name], r.[Score], t.[Task Name]
FROM dbo.[report] AS r
LEFT JOIN dbo.[task] AS t
  ON r.[Task Id] = t.[Task Id];

SELECT
  r.[User Name],
  AVG(CASE WHEN r.[Score] >= 80 THEN r.[Score] END)               AS avg_hard,
  AVG(CASE WHEN r.[Score] BETWEEN 50 AND 79 THEN r.[Score] END)   AS avg_medium,
  AVG(CASE WHEN r.[Score] < 50 THEN r.[Score] END)                AS avg_easy
FROM dbo.[report] AS r
JOIN dbo.[task]   AS t ON t.[Task Id] = r.[Task Id]
WHERE r.[User Name] = N'Alice'      -- change user here
GROUP BY r.[User Name];

SELECT r.[User Name], r.[Score], t.[Task Name]
FROM dbo.[report] AS r
LEFT JOIN dbo.[task] AS t
  ON r.[Task Id] = t.[Task Id]
ORDER BY r.[Score] DESC;

SELECT 
    r.[User Name],
    r.[Score],
    r.[Score] * 1.10 AS [Score +10%]
FROM dbo.[report] AS r;

SELECT DISTINCT r.[User Name]
FROM dbo.[report] AS r;

SELECT r.[User Name], r.[Score]
FROM dbo.[report] AS r
WHERE r.[User Name] IN (N'Alice', N'Cara');

SELECT r.[User Name], r.[Score]
FROM dbo.[report] AS r
WHERE r.[Score] IS NULL;

SELECT TOP (5) r.[User Name], r.[Score]
FROM dbo.[report] AS r;

SELECT r.[User Name], r.[Score]
FROM dbo.[report] AS r
ORDER BY r.[Score] DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;


SELECT r1.[User Name] AS User1,
       r2.[User Name] AS User2,
       r1.[Task Id],
       r1.[Score] AS Score1,
       r2.[Score] AS Score2
FROM dbo.[report] r1
JOIN dbo.[report] r2
  ON r1.[Task Id] = r2.[Task Id]
 AND r1.[User Name] <> r2.[User Name];


-- Suppose we have a new table
CREATE TABLE dbo.[department](
  [Dept Id] INT PRIMARY KEY,
  [Dept Name] NVARCHAR(100)
);

-- Example data
INSERT INTO dbo.[department] VALUES
(1, 'Front Office'), (2, 'Back Office');

-- Now join all three
SELECT r.[User Name],
       r.[Score],
       t.[Task Name],
       d.[Dept Name]
FROM dbo.[report] AS r
JOIN dbo.[task]      AS t ON r.[Task Id] = t.[Task Id]
JOIN dbo.[department] AS d ON r.[Task Id] = d.[Dept Id];  -- pretend dept is linked by Task Id

-- Suppose report has both Task Id and Score that must match
SELECT r1.[User Name], r2.[User Name], r1.[Task Id], r1.[Score]
FROM dbo.[report] r1
JOIN dbo.[report] r2
  ON r1.[Task Id] = r2.[Task Id]
 AND r1.[Score]   = r2.[Score]
WHERE r1.[User Name] <> r2.[User Name];

SELECT r.[User Name], t.[Task Name]
FROM dbo.[report] AS r
CROSS JOIN dbo.[task] AS t;

SELECT r.[User Name] AS Person
FROM dbo.[report] r

UNION

SELECT t.[Task Name] AS Person
FROM dbo.[task] t;

SELECT COUNT(*) AS HighScoreCount
FROM dbo.[report]
WHERE [Score] >= 80;

SELECT SUM([Score]) AS TotalHighScores
FROM dbo.[report]
WHERE [Score] >= 80;

SELECT 
    r.[User Name],
    COUNT(r.[Task Id]) AS TaskCount,
    AVG(r.[Score])     AS AvgScore
FROM dbo.[report] r
GROUP BY r.[User Name]
HAVING AVG(r.[Score]) >= 70
ORDER BY AvgScore DESC;

-- WHERE filters rows
SELECT [User Name], [Score]
FROM dbo.[report]
WHERE [Score] > 50;

-- HAVING filters groups
SELECT [User Name], AVG([Score]) AS AvgScore
FROM dbo.[report]
GROUP BY [User Name]
HAVING AVG([Score]) > 70;

CREATE VIEW dbo.UserTaskScore AS
SELECT
    r.[User Name],
    t.[Task Name],
    r.[Score]
FROM dbo.[report] AS r
JOIN dbo.[task] AS t
    ON r.[Task Id] = t.[Task Id];

ALTER PROCEDURE dbo.GetUserTaskScores
    @UserName NVARCHAR(100)
AS
BEGIN
    SELECT
        r.[User Name],
        t.[Task Name],
        r.[Score]
    FROM dbo.[report] AS r
    JOIN dbo.[task] AS t
        ON r.[Task Id] = t.[Task Id]
    WHERE r.[User Name] = @UserName
END;

EXEC dbo.GetUserTaskScores @UserName = N'Alice';


CREATE FUNCTION dbo.GetGrade (@Score INT)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @Grade NVARCHAR(10);

    IF @Score >= 80 SET @Grade = 'Hard';
    ELSE IF @Score >= 50 SET @Grade = 'Medium';
    ELSE SET @Grade = 'Easy';

    RETURN @Grade;
END;

SELECT 
    r.[User Name],
    r.[Score],
    dbo.GetGrade(r.[Score]) AS Difficulty
FROM dbo.[report] AS r;

-- First create an audit table
CREATE TABLE dbo.[report_audit](
    [User Name] NVARCHAR(100),
    [Task Id] INT,
    [Score] INT,
    [ChangedAt] DATETIME DEFAULT GETDATE()
);

-- Create trigger on INSERT
CREATE TRIGGER trg_Report_Insert
ON dbo.[report]
AFTER INSERT
AS
BEGIN
    INSERT INTO dbo.[report_audit] ([User Name], [Task Id], [Score])
    SELECT [User Name], [Task Id], [Score]
    FROM INSERTED;
END;
GO

-- Create non-clustered index on User Name
CREATE NONCLUSTERED INDEX IX_UserName ON dbo.[report]([User Name]);

CREATE NONCLUSTERED INDEX IX_UserTask 
ON dbo.[report]([User Name], [Task Id]);

-- Show all indexes on a table
EXEC sp_helpindex 'dbo.report';


-- ######################


-- General notes

-- SELECT 

-- — DISTINCT — unique entries only

-- — column1, column2

-- — *

-- — column1 * + 110 — multiple math operation is possible with a selected column to represent data  

-- — as value1 — label of calculated column

-- FROM table 

-- WHERE 

-- — column1 = 1 — logical comparisons ( <, >, ≤, ≥,  =, ≠)

-- — AND OR NOT

-- — arithmetic operation

-- — IN operator 

-- — ( state = ‘VA' OR state = ‘FL’ can be replaced with (state IN (’VA’, ‘FL’)

-- — NOT operator also works

-- — BETWEEN operator works ( BETWEEN 1000 AND 3000)

-- — LIKE

-- — ‘b%’ — string strats with b

-- — ‘%b%’ — string contains b

-- — ‘%b’ — string ends with b

-- — ‘_____y’ - string is 6 char ending with y

-- — REGEXP

-- — 'field’ — contains field

-- — ^ represents beginning of the string

-- — $ represents ending of the string

-- — | represents OR for multiple condition

-- — ‘[gim]e’ — search for string containing ge or ie or me

-- — ‘[a-h]e’ — search for string containing any combination of e starting with letter a to h, i.e., ae, be, ce, de etc.

-- — IS NULL operator

-- — IS NOT NULL - opposite

-- ORDER_BY column2

-- — default ascending

-- — DESC - for descending order

-- JOIN

-- — INNER JOIN

-- — JOIN customers ON orders.customer_id = customers.customer_id

-- — SELF JOIN
-- — IMPLICIT JOIN

-- — CROSS JOIN

-- — OUTER JOIN

-- — LEFT JOIN

-- — RIGHT JOIN

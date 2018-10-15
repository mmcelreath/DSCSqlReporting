USE [DSC]
GO

CREATE FUNCTION [dbo].[Split] (
@InputString VARCHAR(8000),
@Delimiter VARCHAR(50)
)

RETURNS @Items TABLE (
Item VARCHAR(8000)
)

AS
BEGIN
IF @Delimiter = ' '
BEGIN
SET @Delimiter = ','
SET @InputString = REPLACE(@InputString, ' ', @Delimiter)
END

IF (@Delimiter IS NULL OR @Delimiter = '')
SET @Delimiter = ','

DECLARE @Item VARCHAR(8000)
DECLARE @ItemList VARCHAR(8000)
DECLARE @DelimIndex INT

SET @ItemList = @InputString
SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
WHILE (@DelimIndex != 0)
BEGIN

SET @Item = SUBSTRING(@ItemList, 0, @DelimIndex)
INSERT INTO @Items VALUES (@Item)

-- Set @ItemList = @ItemList minus one less item
SET @ItemList = SUBSTRING(@ItemList, @DelimIndex+1, LEN(@ItemList)-@DelimIndex)
SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
END
-- End WHILE

IF @Item IS NOT NULL
-- At least one delimiter was encountered in @InputString
BEGIN
SET @Item = @ItemList
INSERT INTO @Items VALUES (@Item)
END

-- No delimiters were encountered in @InputString, so just return @InputString
ELSE INSERT INTO @Items VALUES (@InputString)
RETURN
END
-- End Function
GO

CREATE FUNCTION [dbo].[tvfGetRegistrationData] ()
RETURNS TABLE 
AS
RETURN
(
SELECT NodeName, AgentId,
(SELECT TOP (1) Item FROM dbo.Split(dbo.RegistrationData.IPAddress, ';') AS IpAddresses) AS IP,
(SELECT(SELECT [Value] + ',' AS [text()] FROM OPENJSON([ConfigurationNames]) FOR XML PATH (''))) AS ConfigurationName,
(SELECT COUNT(*) FROM (SELECT [Value] FROM OPENJSON([ConfigurationNames]))AS ConfigurationCount ) AS ConfigurationCount
FROM dbo.RegistrationData
)
GO

CREATE FUNCTION [dbo].[tvfGetNodeStatus] ()
RETURNS TABLE
AS
RETURN
(
SELECT [dbo].[StatusReport].[NodeName]
,[dbo].[StatusReport].[Status]
,[dbo].[StatusReport].[Id] AS [AgentId]
,[dbo].[StatusReport].[EndTime] AS [Time]
,[dbo].[StatusReport].[RebootRequested]
,[dbo].[StatusReport].[OperationType]
,(


SELECT [HostName] FROM OPENJSON(
(SELECT [value] FROM OPENJSON([StatusData]))
) WITH (HostName nvarchar(200) '$.HostName')) AS HostName
,(


SELECT [ResourceId] + ',' AS [text()]
FROM OPENJSON(
(SELECT [value] FROM
OPENJSON((SELECT [value] FROM OPENJSON([StatusData]))) WHERE [key] = 'ResourcesInDesiredState')
)
WITH (
ResourceId nvarchar(200) '$.ResourceId'
) FOR XML PATH ('')) AS ResourcesInDesiredState
,(


SELECT [ResourceId] + ',' AS [text()]
FROM OPENJSON(
(SELECT [value] FROM OPENJSON((SELECT [value] FROM OPENJSON([StatusData]))) WHERE [key] = 'ResourcesNotInDesiredState')
)
WITH (
ResourceId nvarchar(200) '$.ResourceId'
) FOR XML PATH (''))
AS ResourcesNotInDesiredState
,(


SELECT SUM(CAST(REPLACE(DurationInSeconds,',','.') AS float)) AS Duration
FROM OPENJSON(
(SELECT [value] FROM OPENJSON((SELECT [value] FROM OPENJSON([StatusData]))) WHERE [key] = 'ResourcesInDesiredState')
)


WITH (
DurationInSeconds nvarchar(50) '$.DurationInSeconds',
InDesiredState bit '$.InDesiredState'
)
) AS Duration
,(


SELECT [DurationInSeconds] FROM OPENJSON(
(SELECT [value] FROM OPENJSON([StatusData]))
) WITH (DurationInSeconds nvarchar(200) '$.DurationInSeconds')) AS DurationWithOverhead
,(


SELECT COUNT(*)
FROM OPENJSON(
(SELECT [value] FROM OPENJSON((SELECT [value] FROM OPENJSON([StatusData]))) WHERE [key] = 'ResourcesInDesiredState')
)) AS ResourceCountInDesiredState
,(


SELECT COUNT(*)
FROM OPENJSON(
(SELECT [value] FROM OPENJSON((SELECT [value] FROM OPENJSON([StatusData]))) WHERE [key] = 'ResourcesNotInDesiredState')
)) AS ResourceCountNotInDesiredState
,(


SELECT [ResourceId] + ':' + ' (' + [ErrorCode] + ') ' + [ErrorMessage] + ',' AS [text()]
FROM OPENJSON(
(SELECT TOP 1 [value] FROM OPENJSON([Errors]))
)


WITH (
ErrorMessage nvarchar(200) '$.ErrorMessage',
ErrorCode nvarchar(20) '$.ErrorCode',
ResourceId nvarchar(200) '$.ResourceId'
) FOR XML PATH ('')) AS ErrorMessage
,(


SELECT [value] FROM OPENJSON([StatusData])
) AS RawStatusData
FROM dbo.StatusReport INNER JOIN
(SELECT MAX(EndTime) AS MaxEndTime, NodeName
FROM dbo.StatusReport AS StatusReport_1
WHERE EndTime > '1.1.2000'
GROUP BY [StatusReport_1].[NodeName]) AS SubMax ON dbo.StatusReport.EndTime = SubMax.MaxEndTime AND [dbo].[StatusReport].[NodeName] = SubMax.NodeName
)
GO

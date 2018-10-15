USE [DSC]
GO


CREATE TRIGGER [dbo].[DSCStatusReportOnUpdate]
ON [dbo].[StatusReport]
AFTER UPDATE
AS
SET NOCOUNT ON
BEGIN
DECLARE @JobId nvarchar(50) = (SELECT JobId FROM inserted);
DECLARE @StatusData nvarchar(MAX) = (SELECT StatusData FROM inserted);
IF @StatusData LIKE '\[%' ESCAPE '\'
SET @StatusData = REPLACE(SUBSTRING(@StatusData, 3, Len(@StatusData) - 4), '\', '')


DECLARE @Errors nvarchar(MAX) = (SELECT [Errors] FROM inserted);
IF @Errors IS NULL
SET @Errors = (SELECT Errors FROM StatusReport WHERE JobId = @JobId)


IF @Errors LIKE '\[%' ESCAPE '\' AND Len(@Errors) > 4
SET @Errors = REPLACE(SUBSTRING(@Errors, 3, Len(@Errors) - 4), '\', '')


UPDATE StatusReport
SET StatusData = @StatusData, Errors = @Errors
WHERE JobId = @JobId
END
GO


ALTER TABLE [dbo].[StatusReport] ENABLE TRIGGER [DSCStatusReportOnUpdate]
GO

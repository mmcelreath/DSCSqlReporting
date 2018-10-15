USE [DSC]
GO
CREATE VIEW [dbo].[vRegistrationData]
AS
SELECT GetRegistrationData.*
FROM dbo.tvfGetRegistrationData() AS GetRegistrationData
GO


CREATE VIEW [dbo].[vNodeStatusSimple]
AS
SELECT dbo.StatusReport.NodeName, dbo.StatusReport.Status, dbo.StatusReport.EndTime AS Time
FROM dbo.StatusReport INNER JOIN
(SELECT MAX(EndTime) AS MaxEndTime, NodeName
FROM dbo.StatusReport AS StatusReport_1
GROUP BY NodeName) AS SubMax ON dbo.StatusReport.EndTime = SubMax.MaxEndTime AND dbo.StatusReport.NodeName = SubMax.NodeName
GO


CREATE VIEW [dbo].[vNodeStatusComplex]
AS
SELECT GetNodeStatus.*
FROM dbo.tvfGetNodeStatus()
AS GetNodeStatus
GO


CREATE VIEW [dbo].[vNodeStatusCount]
AS
SELECT NodeName, COUNT(*) AS NodeStatusCount
FROM dbo.StatusReport
WHERE (NodeName IS NOT NULL)
GROUP BY NodeName
GO

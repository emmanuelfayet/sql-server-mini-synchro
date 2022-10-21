/****** Object:  StoredProcedure [dbo].[Proc_FetchEvent]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Return last 100 data changes made in table Organization. 
	Each change is returned as a XML document and associated change ID from table Event.
*/
CREATE PROCEDURE [dbo].[Proc_FetchEvent]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TraceInternalData bit 
	DECLARE @OrganizationIDs Integer_List_TableType
	DECLARE	@XMLOrganizations XML

	DECLARE @Event TABLE(
		  EventID int,
		  EventTypeName nvarchar(50),
		  DataID int,
		  DataXML XML
	)

	SET @TraceInternalData = 0 --Set to 1 to output internal tables/variables used

	--Store in @Event temporary table infos related to last 100 changes made in table Organization
	INSERT INTO @Event( EventID, EventTypeName, DataID )
	SELECT 
		  TOP 100
		  e.EventID,
		  et.EventTypeName,
		  e.EventRowID
	FROM Event e
	JOIN EventType et ON e.EventTypeID = et.EventTypeID
	WHERE 
	(e.EventProcessingStatus in ('TODO', 'ERROR' )) 
	AND (et.EventTypeName IN (
		'organization.update', 
		'organization.insert', 
		'organization.delete'
	 ) ) 
	 ORDER BY EventID ASC
	
	--Store in @OrganizationIDs temporary table all ID related to those changes
	INSERT @OrganizationIDs(n)
	SELECT DISTINCT DataID FROM @Event WHERE (EventTypeName IN ('organization.update', 'organization.insert') )

	--Get a XML representation of organization data for each ID
	EXECUTE [dbo].[Proc_OrganizationsToXML] 
		   @OrganizationIDs
		  ,@XMLOrganizations OUTPUT

	--Store each XML representation in @Event.DataXML for Organization insert/update events
	UPDATE @Event
	SET DataXML = (
		SELECT 
			EventID as '@id',
			'create' as '@type',
			'organization' as '@data',
			DataID as '@data_id',
			(
				SELECT @XMLOrganizations.query('/organizations/organization[@id=sql:column("DataID")]')
			)
		FOR XML PATH('synchro')
	)
	WHERE EventTypeName = 'organization.insert'

	UPDATE @Event
	SET DataXML = (
		SELECT 
			EventID as '@id',
			'update' as '@type',
			'organization' as '@data',
			DataID as '@data_id',
			(
				SELECT @XMLOrganizations.query('/organizations/organization[@id=sql:column("DataID")]')
			)
		FOR XML PATH('synchro')
	)
	WHERE EventTypeName = 'organization.update'

	--For organization delete event, store in @Event.DataXML only id value
	UPDATE @Event
	SET DataXML = (
		SELECT 
			EventID as '@id',
			'delete' as '@type',
			'organization' as '@data',
			DataID as '@data_id',
			(
				SELECT DataID as '@id' FOR XML PATH('organization'), TYPE
			)
		FOR XML PATH('synchro')
	)
	WHERE EventTypeName = 'organization.delete'

	IF @TraceInternalData = 1 
	BEGIN 
		SELECT '@Event' as TableName, * FROM @Event
		
		SELECT '@OrganizationIDs' as TableName, * FROM @OrganizationIDs
		
		SELECT @XMLOrganizations as '@XMLOrganizations'
	END 

	SELECT 
		EventID, 
		DataXML
	FROM @Event
END
GO
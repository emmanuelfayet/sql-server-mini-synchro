/* ============================================================================
 * SQL Server Mini Synchro project
 * Emmanuel Fayet  - October 2022 
 * ----------------------------------------------------------------------------
 * How to run this script:
 *
 * 1. Open the script inside SQL Server Management Studio and enable SQLCMD mode. 
 *    This option is in the Query menu.
 * 
 * 2. Set the following environment variable to your own database name.
 *    :setvar DatabaseName "mini_synchro"
 * 
 * ----------------------------------------------------------------------------
 * Initial setup:
 * 
 * Populate table EventType with following entries:
 * INSERT INTO EventType(EventTypeName) VALUES ('organization.insert');
 * INSERT INTO EventType(EventTypeName) VALUES ('organization.update');
 * INSERT INTO EventType(EventTypeName) VALUES ('organization.delete');
 * 
 * ----------------------------------------------------------------------------
 * First test:
 * 
 * 1. Create a first organization 
 * INSERT INTO Organization( Name, URL ) VALUES ( 'Desjardins', 'https://www.desjardins.com/' ); 
 * 
 * 2. Verify the fact that this new entry has been correctly captured in table Event
 * SELECT * FROM Event
 *
 * 3. Use stored proc Proc_FetchEvent to get a "ready to send" XML data representation of this new entry. 
 * EXEC Proc_FetchEvent
 * 
*/

:setvar DatabaseName "mini_synchro"

PRINT '';
PRINT 'Starting...' 
GO

IF DB_ID('$(DatabaseName)') IS NULL
BEGIN
    RAISERROR('$(DatabaseName) database not found', 127, 127) WITH NOWAIT, LOG;
END

USE $(DatabaseName);
GO

-- ******************************************************
-- Create tables
-- ******************************************************

PRINT '';
PRINT '*** Creating Tables';
GO

/****** Object:  Table [dbo].[EventType]   ******/

PRINT 'Table EventType';
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EventType](
	[EventTypeID] [int] IDENTITY(1,1) NOT NULL,
	[EventTypeName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_EventType] PRIMARY KEY CLUSTERED 
(
	[EventTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[Event]   ******/

PRINT 'Table Event';
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Event](
	[EventID] [int] IDENTITY(1,1) NOT NULL,
	[EventTypeID] [int] NOT NULL,
	[EventTime] [datetime] NOT NULL,
	[EventRowID] [int] NOT NULL,
	[EventProcessingStatus] [nvarchar](5) NOT NULL,
	[EventProcessingTime] [datetime] NULL,
	[EventProcessingData] [xml] NULL,
 CONSTRAINT [PK_Event] PRIMARY KEY CLUSTERED 
(
	[EventID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Event]  WITH CHECK ADD FOREIGN KEY([EventTypeID])
REFERENCES [dbo].[EventType] ([EventTypeID])
GO


/****** Object:  Table [dbo].[Organization]   ******/

PRINT 'Table Organization';
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Organization](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[URL] [nvarchar](50) NULL
) ON [PRIMARY]

GO

-- ******************************************************
-- Create tables triggers.
-- ******************************************************

PRINT '';
PRINT '*** Creating Table Triggers';
GO

/****** Object:  Trigger [dbo].[TRG_Organization_Delete] ******/

PRINT 'Trigger TRG_Organization_Delete';
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TRG_Organization_Delete]
   ON  [dbo].[Organization]
   FOR DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorMessage nvarchar(255) 
	DECLARE @EventTypeName nvarchar(50)
	DECLARE @EventTypeID int

	SET @EventTypeName = 'organization.delete'
	IF NOT EXISTS (select EventTypeID from EventType where EventTypeName = @EventTypeName)
	BEGIN	
	  SET @ErrorMessage = 'EventType Not Found: Name=' + @EventTypeName
	  RAISERROR (@ErrorMessage, 16, 1) 
	  RETURN 
	END

	SELECT @EventTypeID= EventTypeID FROM EventType where EventTypeName = @EventTypeName
		
  INSERT INTO Event( EventTypeID, EventTime, EventProcessingStatus, EventProcessingTime, EventRowID) 
  SELECT 
    @EventTypeID, 
    GETDATE(), 
    'TODO', 
    GETDATE(),
    ID
  FROM Deleted 
END

GO

/****** Object:  Trigger [dbo].[TRG_Organization_Insert] ******/

PRINT 'Trigger TRG_Organization_Insert';
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TRG_Organization_Insert]
   ON  [dbo].[Organization] 
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorMessage nvarchar(255) 
	DECLARE @EventTypeName nvarchar(50)
	DECLARE @EventTypeID int
	DECLARE @EventTypeProcessable bit

	SET @EventTypeName = 'organization.insert'
	IF NOT EXISTS (select EventTypeID from EventType where EventTypeName = @EventTypeName)
	BEGIN	
	  SET @ErrorMessage = 'EventType Not found: TypeName=' + @EventTypeName
	  RAISERROR (@ErrorMessage, 16, 1) 
	  RETURN 
	END

	SELECT @EventTypeID= EventTypeID FROM EventType where EventTypeName = @EventTypeName
		
	INSERT INTO Event( EventTypeID, EventTime, EventProcessingStatus, EventProcessingTime, EventRowID) 
	SELECT 
		@EventTypeID, 
		GETDATE(), 
		'TODO',
		GETDATE(), 
		ID
	FROM Inserted i 
END

GO

/****** Object:   Trigger [dbo].[TRG_Organization_Update]  ******/

PRINT 'Trigger TRG_Organization_Update';
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TRG_Organization_Update]
   ON  [dbo].[Organization] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorMessage nvarchar(255) 
	DECLARE @EventTypeName nvarchar(50)
	DECLARE @EventTypeID int

	SET @EventTypeName = 'organization.update'
	IF NOT EXISTS (select EventTypeID from EventType where EventTypeName = @EventTypeName)
	BEGIN	
	  SET @ErrorMessage = 'EventType not found: Name=' + @EventTypeName
	  RAISERROR (@ErrorMessage, 16, 1) 
	  RETURN 
	END

	SELECT @EventTypeID= EventTypeID FROM EventType where EventTypeName = @EventTypeName
		
  INSERT INTO Event( EventTypeID, EventTime, EventProcessingStatus, EventProcessingTime, EventRowID) 
  SELECT 
		@EventTypeID, 
		GETDATE(), 
		'TODO',
		GETDATE(),
		ID
	FROM Inserted i 
END
GO

-- ******************************************************
-- Create types
-- ******************************************************

PRINT '';
PRINT '*** Creating Types';
GO

/****** Object:  UserDefinedTableType [dbo].[Integer_List_TableType] ******/

PRINT 'Type Integer_List_TableType';
GO

CREATE TYPE [dbo].[Integer_List_TableType] AS TABLE(
	[n] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[n] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO

-- ******************************************************
-- Create stored procedures
-- ******************************************************

PRINT '';
PRINT '*** Creating Stored Procedures';
GO

/****** Object:  StoredProcedure [dbo].[Proc_OrganizationsToXML] ******/

PRINT 'Stored Procedure Proc_OrganizationsToXML';
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Load @XMLOrganizations with a XML document containing Organization infos from a given set of IDs. 
*/
CREATE PROCEDURE [dbo].[Proc_OrganizationsToXML]
	@OrganizationIDs Integer_List_TableType READONLY,
	@XMLOrganizations XML Output
AS
BEGIN
	DECLARE @OrganizationsCount INT
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT @OrganizationsCount = COUNT(*) FROM @OrganizationIDs

	SET @XMLOrganizations = (
		SELECT 
			@OrganizationsCount as '@count', 
			(
				SELECT 
					ID as '@id', 
					Name as 'name', 
					URL as 'url'
				FROM Organization
				WHERE ID IN (SELECT N FROM @OrganizationIDs)
				FOR XML PATH('organization'),
				TYPE
			)
		FOR XML PATH ('organizations'), 
		TYPE
	)

	--SELECT @XMLOrganizations
END
GO

/****** Object:  StoredProcedure [dbo].[Proc_FetchEvent]   ******/

PRINT 'Stored Procedure Proc_FetchEvent';
GO

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

PRINT '';
PRINT 'Done.'
GO

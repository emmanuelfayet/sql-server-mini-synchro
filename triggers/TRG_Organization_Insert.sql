/****** Object:  Trigger [dbo].[TRG_Organization_Insert] ******/
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



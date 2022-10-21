/****** Object:  Trigger [dbo].[TRG_Organization_Delete] ******/
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



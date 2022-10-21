/****** Object:  StoredProcedure [dbo].[Proc_OrganizationsToXML] ******/

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
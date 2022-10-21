/****** Object:  UserDefinedTableType [dbo].[Integer_List_TableType] ******/
CREATE TYPE [dbo].[Integer_List_TableType] AS TABLE(
	[n] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[n] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO



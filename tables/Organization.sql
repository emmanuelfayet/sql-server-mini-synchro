/****** Object:  Table [dbo].[Organization]   ******/
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



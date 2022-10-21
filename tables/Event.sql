/****** Object:  Table [dbo].[Event]   ******/
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



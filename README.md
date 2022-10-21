# sql-server-mini-synchro
A test project to implement SQL Server data synchronization.
Works with SQL Server 2008R2.

# Ideas
Use a table named Event to collect data changes (insert/update/delete) from a Organization table.  

Data changes are captured by a set of triggers attached to Organization table.

Write a stored procedure Proc_FetchEvent to get a "ready to send" XML data representation of each change. 

The transmission 

# Installation
Open [install.sql](/scripts/install.sql) inside SQL Server Management Studio and enable SQLCMD mode. This option is in the Query menu.
  
Set the following environment variable to your own database name.

     :setvar DatabaseName "mini_synchro"

Run the script. 

# Initial setup

Populate table EventType with following entries:

    INSERT INTO EventType(EventTypeName) VALUES ('organization.insert');
    INSERT INTO EventType(EventTypeName) VALUES ('organization.update');
    INSERT INTO EventType(EventTypeName) VALUES ('organization.delete');

# First test

 Create a first organization 
 
    INSERT INTO Organization( Name, URL ) VALUES ( 'Desjardins', 'https://www.desjardins.com/' ); 

 Verify the fact that this new entry has been correctly captured in table Event
 

    SELECT * FROM Event

 Use stored proc Proc_FetchEvent to get a "ready to send" XML data representation of this new entry. 
 
    EXEC Proc_FetchEvent
    
Output:

   ```
<synchro id="1" type="create" data="organization" data_id="2">
  <organization id="2">
    <name>Desjardins</name>
    <url>https://www.desjardins.com/</url>
  </organization>
</synchro>

   ```
The transmission of this XML data to a remote host is outside of this project 's scope.

--truncate table Publication

--alter index [GRAPH_UNIQUE_INDEX_Publication] on publication disable
--CREATE CLUSTERED COLUMNSTORE INDEX [CCI_Keyword] ON Keyword;
--ALTER INDEX [GRAPH_UNIQUE_INDEX_Keyword] ON [dbo].[Keyword] DISABLE

--select count(*) from Publication
--where fileNum = 166

use OpenAcademicGraph
GO

select count(distinct fileNum) from Publication WITH (NOLOCK)

select * from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('Publication')

select sum(total_rows), count(*) from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('PubRefs_Exploded')

select * from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('Keyword')

select * from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('Keyword_Exploded')

select * from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('URL')

select sum(total_rows) from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('URL')

select * from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('URL_Exploded')

select * from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('Author')

select * from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('Author_Exploded')

select * from sys.partitions
where object_id = object_id('CollaboratesWith')

select * from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('CollaboratesWith_Exploded')

select * from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('FOS')

select * from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('FOS_Exploded')

select * from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('Venue')

select sum(total_rows), count(*) from sys.dm_db_column_store_row_group_physical_stats
where object_id = object_id('References')

select count(*) from [References]

exec sp_spaceused 'Publication'
exec sp_spaceused 'keyword_Exploded'
exec sp_spaceused 'keyword'
exec sp_spaceused 'Author_Exploded'
exec sp_spaceused 'Author'
exec sp_spaceused 'CollaboratesWith_Exploded'
exec sp_spaceused 'CollaboratesWith'
exec sp_spaceused 'URL_Exploded'
exec sp_spaceused 'URL'
exec sp_spaceused 'FOS_Exploded'
exec sp_spaceused 'FOS'
exec sp_spaceused 'Venue'
exec sp_spaceused 'PubRefs_Exploded'

exec sp_spaceused 'References'
exec sp_spaceused 'CollaboratesWith'
exec sp_spaceused 'IsAuthorOf'
exec sp_spaceused 'InField'
exec sp_spaceused 'PresentedIn'
exec sp_spaceused 'MentionedIn'

select * from sys.dm_exec_query_memory_grants

select sum(CASE WHEN T.is_node = 1 THEN P.rows ELSE 0 END) as TotalNodes,
	sum(CASE WHEN T.is_edge = 1 THEN P.rows ELSE 0 END) as TotalEdges
from sys.partitions P 
join sys.tables T on P.object_id = T.object_id

select is_disabled, * from sys.indexes I join sys.tables T
on i.object_id = t.object_id
where (t.is_edge = 1 or t.is_node = 1)
and i.type_desc != 'CLUSTERED COLUMNSTORE'
and i.is_disabled = 0

/*
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE. 

This sample code is not supported under any Microsoft standard support program or service.  
The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.  
In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts 
be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, 
business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability 
to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages. 
*/
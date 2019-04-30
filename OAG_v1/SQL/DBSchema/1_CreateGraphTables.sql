/*
This sample code shows how to import and work with the Open Academic Graph (https://www.openacademic.ai/oag/) using Microsoft SQL Server 2017.

Citations:
Jie Tang, Jing Zhang, Limin Yao, Juanzi Li, Li Zhang, and Zhong Su. ArnetMiner: Extraction and Mining of Academic Social Networks. In Proceedings of the Fourteenth ACM SIGKDD International Conference on Knowledge Discovery and Data Mining (SIGKDD’2008). pp.990-998.
Arnab Sinha, Zhihong Shen, Yang Song, Hao Ma, Darrin Eide, Bo-June (Paul) Hsu, and Kuansan Wang. 2015. An Overview of Microsoft Academic Service (MAS) and Applications. In Proceedings of the 24th International Conference on World Wide Web (WWW ’15 Companion). ACM, New York, NY, USA, 243-246.
*/

USE OpenAcademicGraph
GO

CREATE FULLTEXT CATALOG [FT_catalog] WITH ACCENT_SENSITIVITY = ON
GO

DROP TABLE IF EXISTS [dbo].[Publication]
GO

CREATE TABLE [dbo].[Publication](
	[fileNum]	tinyint NOT NULL,
	[id] [varchar](200) NOT NULL,
	[title] [nvarchar](1500) NULL,
	[authors] [nvarchar](max) NULL,		-- ADJUST for client-vs-server JSON processing
	[venue] [nvarchar](500) NULL,
	[pub_year] [int] NULL,
	[keywords] nvarchar (max) NULL,	-- ADJUST for client-vs-server JSON processing
	[fos] [nvarchar](max) NULL,	-- ADJUST for client-vs-server JSON processing
	[num_citation] [int] NULL,
	[pub_references] nvarchar (max) NULL,	-- ADJUST for client-vs-server JSON processing
	[page_start] [varchar](100) NULL,
	[page_end] [varchar](100) NULL,
	[doc_type] [varchar](100) NULL,
	[lang] [varchar](100) NULL,
	[publisher] [nvarchar](500) NULL,
	[volume] [nvarchar](100) NULL,
	[issue] [nvarchar](500) NULL,
	[issn] [varchar](20) NULL,
	[isbn] [varchar](20) NULL,
	[doi] [nvarchar](500) NULL,
	[pdf_url] [nvarchar](1500) NULL,
	[urls] nvarchar (max) NULL,	-- ADJUST for client-vs-server JSON processing
	[abstract] [nvarchar](max) NULL,
	[is_mag] bit,
	INDEX [GRAPH_UNIQUE_INDEX_Publication] UNIQUE NONCLUSTERED ($node_id) WITH (DATA_COMPRESSION = PAGE),
	INDEX [CCI_Publication] CLUSTERED COLUMNSTORE
) 
AS NODE
GO

DROP TABLE IF EXISTS [dbo].[PubRefs_Exploded]
GO

CREATE TABLE [dbo].[PubRefs_Exploded](
	[id] [varchar](200) NOT NULL,
	[id_ref] [varchar](200) NOT NULL,
	INDEX CCI_PubRefs_Exploded CLUSTERED COLUMNSTORE
) 
GO

-- Edge table for Publication references (this is an edge connecting Publication -> Publication)
DROP TABLE IF EXISTS [dbo].[References]
GO

CREATE TABLE [dbo].[References]
(
	INDEX CCI_References CLUSTERED COLUMNSTORE,
	INDEX [GRAPH_UNIQUE_INDEX_References] UNIQUE NONCLUSTERED ($edge_id)  WITH (DATA_COMPRESSION = PAGE),
	INDEX [GRAPH_FromTo_INDEX_References] ($from_id, $to_id) WITH (DATA_COMPRESSION = PAGE)
)
AS EDGE
GO

DROP TABLE IF EXISTS [dbo].[Author]
GO

CREATE TABLE [dbo].[Author](
	[author_name] [nvarchar](500) NOT NULL,	-- we are restricting this because longer names really don't make sense 
	[org] nvarchar(500) NULL,
	auth_hash char(24) NOT NULL,
	INDEX [CCI_Author] CLUSTERED COLUMNSTORE,
	INDEX [GRAPH_UNIQUE_INDEX_Author] UNIQUE NONCLUSTERED ($node_id) WITH (DATA_COMPRESSION = PAGE)
) 
AS NODE
GO

-- Staging table to store PubId -> Author edges. This also is a perf enhancement as trying to split JSON / strings within T-SQL is much slower, 
-- and anyways in the client JSON processing we already have the authors for each publication.
DROP TABLE IF EXISTS [dbo].[Author_Exploded]
GO

CREATE TABLE [dbo].[Author_Exploded](
	[id] [varchar](200) NOT NULL,
	[author_name] [nvarchar](500) NOT NULL,	-- we are restricting this because longer names really don't make sense 
	[org] nvarchar(500) NULL,
	auth_hash char(24),
	INDEX CCI_Author_Exploded CLUSTERED COLUMNSTORE
) 
GO

-- Staging table to store Author -> Author edges.
DROP TABLE IF EXISTS [dbo].[CollaboratesWith_Exploded]
GO

CREATE TABLE [dbo].[CollaboratesWith_Exploded](
	[first_auth_hash] char(24) NOT NULL,
	[second_auth_hash] char(24) NOT NULL,
	INDEX CCI_CollaboratesWith_Exploded CLUSTERED COLUMNSTORE
)
GO

-- Edge table for "CollaboratesWith" (this is an edge connecting Author -> Author)
DROP TABLE IF EXISTS [dbo].[CollaboratesWith]
GO

CREATE TABLE [dbo].[CollaboratesWith]
(
	INDEX CCI_CollaboratesWith CLUSTERED COLUMNSTORE,
	INDEX [GRAPH_UNIQUE_INDEX_CollaboratesWith] UNIQUE NONCLUSTERED ($edge_id) WITH (DATA_COMPRESSION = PAGE),
	INDEX NCI_FromTo_CollaboratesWith NONCLUSTERED ($from_id, $to_id) WITH (DATA_COMPRESSION = PAGE)
)
AS EDGE
GO

-- Edge table for "IsAuthorOf" (this is an edge connecting Publication -> Author)
DROP TABLE IF EXISTS [dbo].[IsAuthorOf]
GO

CREATE TABLE [dbo].[IsAuthorOf]
(
	INDEX [CCI_IsAuthorOf] CLUSTERED COLUMNSTORE,
	INDEX NCI_FromTo_IsAuthorOf NONCLUSTERED ($from_id, $to_id) WITH (DATA_COMPRESSION = PAGE),
	INDEX [GRAPH_UNIQUE_INDEX_IsAuthorOf] UNIQUE NONCLUSTERED ($edge_id) WITH (DATA_COMPRESSION = PAGE)
)
AS EDGE
GO

DROP TABLE IF EXISTS [dbo].[Keyword]
GO

CREATE TABLE [dbo].[Keyword](
	[keyword] [nvarchar](1000) NOT NULL,	-- again MAG seems to restrict to 999 chars
	INDEX [CCI_Keyword] CLUSTERED COLUMNSTORE,
	INDEX [GRAPH_UNIQUE_INDEX_Keyword] UNIQUE NONCLUSTERED ($node_id) WITH (DATA_COMPRESSION = PAGE)
) 
AS NODE
GO

-- Staging table to store PubId -> Keyword edges. This also is a perf enhancement as trying to split JSON / strings within T-SQL is much slower, 
-- and anyways in the client JSON processing we already have the Keywords for each publication.
DROP TABLE IF EXISTS [dbo].[Keyword_Exploded]
GO

CREATE TABLE [dbo].[Keyword_Exploded](
	[id] [varchar](200) NOT NULL,
	[keyword] [nvarchar](1000) NOT NULL, 
	INDEX CCI_Keyword_Exploded CLUSTERED COLUMNSTORE
) 
GO

-- Edge table for "has keyword" (this is an edge connecting Publication -> Keyword)
DROP TABLE IF EXISTS [dbo].[HasKeyword]
GO

CREATE TABLE [dbo].[HasKeyword]
(
	INDEX [CCI_HasKeyword] CLUSTERED COLUMNSTORE,
	INDEX [GRAPH_UNIQUE_INDEX_HasKeyword] UNIQUE NONCLUSTERED ($edge_id) WITH (DATA_COMPRESSION = PAGE)
)
AS EDGE
GO

DROP TABLE IF EXISTS [dbo].[URL]
GO

CREATE TABLE [dbo].[URL](
	[url] [nvarchar](500) NOT NULL,	-- looks like the MAG restricts this length
	INDEX CCI_URL CLUSTERED COLUMNSTORE,
	INDEX [GRAPH_UNIQUE_INDEX_URL] UNIQUE NONCLUSTERED ($node_id) WITH (DATA_COMPRESSION = PAGE)
) 
AS NODE
GO

DROP TABLE IF EXISTS [dbo].[URL_Exploded]
GO

CREATE TABLE [dbo].[URL_Exploded](
	[id] [varchar](200) NOT NULL,
	[url] [nvarchar](500) NOT NULL, 
	INDEX CCI_URL_Exploded CLUSTERED COLUMNSTORE
) 
GO

-- Edge table for "mentioned in" (this is an edge connecting Publication -> URL)
DROP TABLE IF EXISTS [dbo].[MentionedIn]
GO

CREATE TABLE [dbo].[MentionedIn]
(
	INDEX CCI_MentionedIn CLUSTERED COLUMNSTORE,
	INDEX [GRAPH_UNIQUE_INDEX_MentionedIn] UNIQUE NONCLUSTERED ($edge_id) WITH (DATA_COMPRESSION = PAGE)
)
AS EDGE
GO

DROP TABLE IF EXISTS [dbo].[FOS]
GO

CREATE TABLE [dbo].[FOS](
	[fos] [nvarchar](500) NOT NULL,
	INDEX CCI_FOS CLUSTERED COLUMNSTORE,
	INDEX [GRAPH_UNIQUE_INDEX_FOS] UNIQUE NONCLUSTERED ($node_id) WITH (DATA_COMPRESSION = PAGE)
) AS NODE
GO

DROP TABLE IF EXISTS [dbo].[FOS_Exploded]
GO

CREATE TABLE [dbo].[FOS_Exploded](
	[id] [varchar](200) NOT NULL,
	[fos] [nvarchar](500) NOT NULL,
	INDEX CCI_FOS_Exploded CLUSTERED COLUMNSTORE
)
GO

-- Edge table for "InField" (this is an edge connecting Publication -> F.O.S.)
DROP TABLE IF EXISTS [dbo].[InField]
GO

CREATE TABLE [dbo].[InField]
(
	INDEX [CCI_InField] CLUSTERED COLUMNSTORE,
	INDEX [GRAPH_UNIQUE_INDEX_InField] UNIQUE NONCLUSTERED ($edge_id) WITH (DATA_COMPRESSION = PAGE)
)
AS EDGE
GO

DROP TABLE IF EXISTS [dbo].[Venue]
GO

CREATE TABLE [dbo].[Venue](
	[venue] [nvarchar](500) NULL,
	INDEX CCI_Venue CLUSTERED COLUMNSTORE,
	INDEX [GRAPH_UNIQUE_INDEX_Venue] UNIQUE NONCLUSTERED ($node_id) WITH (DATA_COMPRESSION = PAGE)
) AS NODE
GO

-- Edge table for "PresentedIn" (this is an edge connecting Publication -> Venue)
DROP TABLE IF EXISTS [dbo].[PresentedIn]
GO

CREATE TABLE [dbo].[PresentedIn]
(
	INDEX CCI_PresentedIn CLUSTERED COLUMNSTORE,
	INDEX [GRAPH_UNIQUE_INDEX_PresentedIn] UNIQUE NONCLUSTERED ($edge_id) WITH (DATA_COMPRESSION = PAGE)
)
AS EDGE
GO

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
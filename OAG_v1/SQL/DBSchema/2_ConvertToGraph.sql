/*
This sample code shows how to import and work with the Open Academic Graph (https://www.openacademic.ai/oag/) using Microsoft SQL Server 2017.

Citations:
Jie Tang, Jing Zhang, Limin Yao, Juanzi Li, Li Zhang, and Zhong Su. ArnetMiner: Extraction and Mining of Academic Social Networks. In Proceedings of the Fourteenth ACM SIGKDD International Conference on Knowledge Discovery and Data Mining (SIGKDD’2008). pp.990-998.
Arnab Sinha, Zhihong Shen, Yang Song, Hao Ma, Darrin Eide, Bo-June (Paul) Hsu, and Kuansan Wang. 2015. An Overview of Microsoft Academic Service (MAS) and Applications. In Proceedings of the 24th International Conference on World Wide Web (WWW ’15 Companion). ACM, New York, NY, USA, 243-246.
*/

USE [OpenAcademicGraph]
GO

CREATE OR ALTER PROCEDURE TruncateAllTables
AS
BEGIN
	TRUNCATE TABLE [Publication]
	TRUNCATE TABLE [Author]
	TRUNCATE TABLE [IsAuthorOf]
	TRUNCATE TABLE [CollaboratesWith]
	TRUNCATE TABLE [Keyword]
	TRUNCATE TABLE [HasKeyword]
	TRUNCATE TABLE [URL]
	TRUNCATE TABLE [MentionedIn]
	TRUNCATE TABLE [FOS]
	TRUNCATE TABLE [InField]
	TRUNCATE TABLE [Venue]
	TRUNCATE TABLE [PresentedIn]
	TRUNCATE TABLE [References]
END
GO

CREATE OR ALTER PROCEDURE DisableAllGraphNodeUniqueIndexes
AS
BEGIN
	ALTER INDEX [GRAPH_UNIQUE_INDEX_Publication] ON [dbo].[Publication] DISABLE
	ALTER INDEX [GRAPH_UNIQUE_INDEX_Author] ON [dbo].[Author] DISABLE
	ALTER INDEX [GRAPH_UNIQUE_INDEX_Keyword] ON [dbo].[Keyword] DISABLE
	ALTER INDEX [GRAPH_UNIQUE_INDEX_URL] ON [dbo].[URL] DISABLE
	ALTER INDEX [GRAPH_UNIQUE_INDEX_FOS] ON [dbo].[FOS] DISABLE
	ALTER INDEX [GRAPH_UNIQUE_INDEX_Venue] ON [dbo].[Venue] DISABLE
END
GO

CREATE OR ALTER PROCEDURE RebuildAllGraphNodeUniqueIndexes
AS
BEGIN
	-- The FOS and Venue tables need their CCI rebuilt as in those we get a lot of small rowgroups
	ALTER TABLE [FOS] REBUILD
	ALTER TABLE [Venue] REBUILD

	ALTER INDEX [GRAPH_UNIQUE_INDEX_Publication] ON [dbo].[Publication] REBUILD WITH (MAXDOP = 24); -- ADJUST!

	ALTER TABLE [dbo].[Publication]
	ADD CONSTRAINT PK_Publication PRIMARY KEY (id) WITH (MAXDOP = 24); -- ADJUST!

	CREATE FULLTEXT INDEX ON [dbo].[Publication]
		(Title, Abstract)
		KEY INDEX PK_Publication
		ON [FT_catalog];

	ALTER INDEX [GRAPH_UNIQUE_INDEX_Author] ON [dbo].[Author] REBUILD  WITH (MAXDOP = 24); -- ADJUST!
	ALTER TABLE [dbo].[Author]
	ADD CONSTRAINT PK_Author PRIMARY KEY (auth_hash) WITH (MAXDOP = 24); -- ADJUST!

	CREATE FULLTEXT INDEX ON [dbo].[Author]
		(author_name, org)
		KEY INDEX PK_Author
		ON [FT_catalog];

	ALTER INDEX [GRAPH_UNIQUE_INDEX_Keyword] ON [dbo].[Keyword] REBUILD WITH (MAXDOP = 24); -- ADJUST!
	ALTER INDEX [GRAPH_UNIQUE_INDEX_URL] ON [dbo].[URL] REBUILD WITH (MAXDOP = 24); -- ADJUST!
	ALTER INDEX [GRAPH_UNIQUE_INDEX_FOS] ON [dbo].[FOS] REBUILD WITH (MAXDOP = 24); -- ADJUST!
	ALTER INDEX [GRAPH_UNIQUE_INDEX_Venue] ON [dbo].[Venue] REBUILD WITH (MAXDOP = 24); -- ADJUST!
END
GO

CREATE OR ALTER PROCEDURE DisableAllGraphEdgeUniqueIndexes
AS
BEGIN
	ALTER INDEX [GRAPH_UNIQUE_INDEX_HasKeyword] ON [dbo].[HasKeyword] DISABLE
	
	ALTER INDEX [GRAPH_UNIQUE_INDEX_References] ON [dbo].[References] DISABLE
	ALTER INDEX [GRAPH_FromTo_INDEX_References] ON [dbo].[References] DISABLE

	ALTER INDEX [GRAPH_UNIQUE_INDEX_CollaboratesWith] ON [dbo].[CollaboratesWith] DISABLE
	ALTER INDEX [NCI_FromTo_CollaboratesWith] ON [dbo].[CollaboratesWith] DISABLE
	ALTER INDEX [NCI_FromTo_IsAuthorOf] ON [dbo].[IsAuthorOf] DISABLE
	ALTER INDEX [GRAPH_UNIQUE_INDEX_IsAuthorOf] ON [dbo].[IsAuthorOf] DISABLE
	ALTER INDEX [GRAPH_UNIQUE_INDEX_InField] ON [dbo].[InField] DISABLE
	ALTER INDEX [GRAPH_UNIQUE_INDEX_PresentedIn] ON [dbo].[PresentedIn] DISABLE
	ALTER INDEX [GRAPH_UNIQUE_INDEX_MentionedIn] ON [dbo].[MentionedIn] DISABLE
END
GO

CREATE OR ALTER PROCEDURE RebuildAllGraphEdgeUniqueIndexes
AS
BEGIN
	ALTER INDEX [GRAPH_UNIQUE_INDEX_HasKeyword] ON [dbo].[HasKeyword] REBUILD  WITH (MAXDOP = 24);

	ALTER INDEX [GRAPH_UNIQUE_INDEX_References] ON [dbo].[References] REBUILD  WITH (MAXDOP = 24);
	ALTER INDEX [GRAPH_FromTo_INDEX_References] ON [dbo].[References] REBUILD  WITH (MAXDOP = 24);
	ALTER INDEX [GRAPH_UNIQUE_INDEX_CollaboratesWith] ON [dbo].[CollaboratesWith] REBUILD  WITH (MAXDOP = 24);
	ALTER INDEX [NCI_FromTo_CollaboratesWith] ON [dbo].[CollaboratesWith] REBUILD  WITH (MAXDOP = 24);
	ALTER INDEX [GRAPH_UNIQUE_INDEX_IsAuthorOf] ON [dbo].[IsAuthorOf] REBUILD  WITH (MAXDOP = 24);
	ALTER INDEX [NCI_FromTo_IsAuthorOf] ON [dbo].[IsAuthorOf] REBUILD  WITH (MAXDOP = 24);
	ALTER INDEX [GRAPH_UNIQUE_INDEX_InField] ON [dbo].[InField] REBUILD  WITH (MAXDOP = 24);
	ALTER INDEX [GRAPH_UNIQUE_INDEX_PresentedIn] ON [dbo].[PresentedIn] REBUILD  WITH (MAXDOP = 24);
	ALTER INDEX [GRAPH_UNIQUE_INDEX_MentionedIn] ON [dbo].[MentionedIn] REBUILD  WITH (MAXDOP = 24);
END
GO

CREATE OR ALTER PROCEDURE PopulatePublicationFromStaging
(
	@fileNum tinyint,
	@suffix nvarchar(500)
)
AS
BEGIN
	DECLARE @sql nvarchar(max) = CONCAT(N'
		INSERT INTO [dbo].[Publication] 
		(
			[fileNum]
			,[id]
           ,[title]
           ,[authors]
           ,[venue]
           ,[pub_year]
           ,[keywords]
           ,[fos]
           ,[num_citation]
           ,[pub_references]
           ,[page_start]
           ,[page_end]
           ,[doc_type]
           ,[lang]
           ,[publisher]
           ,[volume]
           ,[issue]
           ,[issn]
           ,[isbn]
           ,[doi]
           ,[pdf_url]
           ,[urls]
           ,[abstract]
           ,[is_mag])
		SELECT 
			', @fileNum,'
			,[id]
           ,[title]
           ,[authors]
           ,[venue]
           ,[pub_year]
           ,[keywords]
           ,[fos]
           ,[num_citation]
           ,[pub_references]
           ,[page_start]
           ,[page_end]
           ,[doc_type]
           ,[lang]
           ,[publisher]
           ,[volume]
           ,[issue]
           ,[issn]
           ,[isbn]
           ,[doi]
           ,[pdf_url]
           ,[urls]
           ,[abstract]
           ,[is_mag]
		FROM   Publication_Stg_', @suffix);

	exec sp_executesql @sql;

	-- In the case of publications there is no question of duplicates so we do not need to check and delete duplicates here
END
GO

-- Populate nodes for distinct authors; de-duplication is purely based on author names and org (if applicable)
-- as the MAG and ArnetMiner data does not have any other unique ID
CREATE OR ALTER PROCEDURE DedupeAuthorsExploded
AS
BEGIN;
	INSERT Author WITH (TABLOCK) (author_name, org, auth_hash) 
	SELECT DISTINCT author_name, ISNULL(org, ''), auth_hash
	FROM Author_Exploded
	OPTION (MAXDOP 24);		-- ADJUST as needed !!
END
GO

-- Populate nodes for distinct keywords
CREATE OR ALTER PROCEDURE DedupeKeywordsExploded
AS
BEGIN;
	INSERT Keyword WITH (TABLOCK)
	SELECT DISTINCT keyword
	FROM Keyword_Exploded
	OPTION (MAXDOP 24);		-- ADJUST as needed !!
END
GO

-- Populate nodes for distinct URLs
CREATE OR ALTER PROCEDURE DedupeURLsExploded
AS
BEGIN;
	INSERT URL WITH (TABLOCK)
	SELECT DISTINCT url
	FROM URL_Exploded
	OPTION (MAXDOP 24);		-- ADJUST as needed !!
END
GO

-- Distinct fields of study
CREATE OR ALTER PROCEDURE DedupeFOSExploded
AS
BEGIN;
	INSERT FOS WITH (TABLOCK)
	SELECT DISTINCT fos
	FROM FOS_Exploded
	OPTION (MAXDOP 24);		-- ADJUST as needed !!
END
GO

-- Nodes for distinct venue of publication
CREATE OR ALTER PROCEDURE DedupeVenueExploded
AS
BEGIN;
	INSERT Venue WITH (TABLOCK)
	SELECT DISTINCT venue
	FROM Publication
	OPTION (MAXDOP 24);		-- ADJUST as needed !!
END
GO

-- ==== EDGES ====
-- HasKeyword

CREATE OR ALTER PROCEDURE InsertEdgeHasKeyword
AS
BEGIN
	INSERT [HasKeyword] WITH (TABLOCK) ($from_id, $to_id)
	SELECT P.$node_id, K.$node_id
	FROM Publication as P
	JOIN Keyword_Exploded as KE
	ON P.id = KE.id
	JOIN [Keyword] AS K
	ON KE.[keyword] = K.[keyword]
	OPTION (MAXDOP 24);		-- ADJUST as needed!
END
GO

-- References
-- Publication 'references' Publication edge
CREATE OR ALTER PROCEDURE InsertEdgeReferences
AS
BEGIN
	INSERT [References] WITH (TABLOCK) ($from_id, $to_id)
	SELECT F.$node_id, T.$node_id
	FROM [Publication] F
	JOIN PubRefs_Exploded AS R
	ON R.id = F.id
	JOIN [Publication] T
	ON R.id_ref = T.id
	OPTION (MAXDOP 24);		-- ADJUST as needed!
END
GO

-- CollaboratesWith
CREATE OR ALTER PROCEDURE InsertEdgeCollaboratesWith
AS
BEGIN
	--TRUNCATE TABLE CollaboratesWith_Deduped;

	--INSERT CollaboratesWith_Deduped WITH (TABLOCK)
	--SELECT DISTINCT first_author_name, first_org, second_author_name, second_org
	--FROM CollaboratesWith_Exploded
	--OPTION (HASH GROUP);

	INSERT [CollaboratesWith] WITH (TABLOCK) ($from_id, $to_id)
	SELECT DISTINCT A1.$node_id, A2.$node_id
	FROM Author as A1
	JOIN CollaboratesWith_Exploded as CW
	ON A1.auth_hash = CW.first_auth_hash
	JOIN Author AS A2
	ON A2.auth_hash = CW.second_auth_hash
	OPTION (MAXDOP 24);		-- ADJUST as needed!
END
GO

-- IsAuthorOf
CREATE OR ALTER PROCEDURE InsertEdgeIsAuthorOf
AS
BEGIN
	INSERT [IsAuthorOf] WITH (TABLOCK) ($from_id, $to_id)
	SELECT A.$node_id, P.$node_id
	FROM Publication as P
	JOIN Author_Exploded as AE
	ON P.id = AE.id
	JOIN [Author] A
	ON A.author_name = AE.author_name AND ISNULL(A.org, '') = ISNULL(AE.org, '')
	OPTION (MAXDOP 24);		-- ADJUST as needed!
END
GO

-- InField edge
CREATE OR ALTER PROCEDURE InsertEdgeInField
AS
BEGIN
	INSERT [InField] WITH (TABLOCK) ($from_id, $to_id)
	SELECT P.$node_id, F.$node_id
	FROM Publication as P
	JOIN FOS_Exploded as FE
	ON P.id = FE.id
	JOIN [FOS] F
	ON F.fos = FE.fos
	OPTION (MAXDOP 24);		-- ADJUST as needed!
END
GO

-- PresentedIn edge
CREATE OR ALTER PROCEDURE InsertEdgePresentedIn
AS
BEGIN
	INSERT [PresentedIn] WITH (TABLOCK) ($from_id, $to_id)
	SELECT P.$node_id, V.$node_id
	FROM Publication AS P
	JOIN [Venue] V
	ON P.[venue] = V.[venue]
	OPTION (MAXDOP 24);		-- ADJUST as needed!
END
GO

-- MentionedIn edge(Publication-(MentionedIn)->Url)
CREATE OR ALTER PROCEDURE InsertEdgeMentionedIn
AS
BEGIN
	INSERT [MentionedIn] WITH (TABLOCK) ($from_id, $to_id)
	SELECT P.$node_id, U.$node_id
	FROM Publication as P
	JOIN URL_Exploded as UE
	ON P.id = UE.id
	JOIN [Url] U
	ON U.url = UE.url
	OPTION (MAXDOP 24);		-- ADJUST as needed!
END;
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
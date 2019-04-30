USE OpenAcademicGraph
GO

CREATE TABLE #t (
    id VARCHAR (100)  UNIQUE CLUSTERED,
    level   INT           ,
    path    VARCHAR (8000)
);

CREATE INDEX il
    ON #t(level)
    INCLUDE(path);

DECLARE @OriginPublication AS VARCHAR (100) = '57ce6465-7133-4e53-8a20-a94a8f15b3ac';
DECLARE @DestPublication AS VARCHAR (100) = 'a39a2a55-50d2-435a-8d3a-49e0f4f695ea';	-- for a quicker test try '2cd81315-e2ff-447f-9f47-ba4dbb5fd470'
DECLARE @level AS INT = 0;

INSERT  #t
VALUES (@OriginPublication, @level, @OriginPublication);

WHILE @@rowcount > 0
      AND NOT EXISTS (SELECT *
                      FROM   #t
                      WHERE  id = @DestPublication)
    BEGIN
        SET @level += 1;
        INSERT #t
        SELECT id,
               level,
               concat(path, '~', id)
        FROM   (SELECT   u2.id,
                         @level AS level,
                         min(t1.path) AS path
                FROM     #t AS t1 , Publication AS u1, [References] AS f, Publication AS u2
                WHERE    t1.level = @level - 1
                         AND t1.id = u1.id
                         AND MATCH(u1-(f)->u2)
                         AND NOT EXISTS (SELECT *
                                         FROM   #t AS t2
                                         WHERE  t2.id = u2.id)
                GROUP BY u2.id) AS q;
    END

SELECT *
FROM   #t
WHERE  id = @DestPublication;

SELECT STRING_AGG(P.Title, '->') 
FROM
(
	SELECT SS.value AS id
	FROM   #t
	CROSS APPLY STRING_SPLIT(path, '~') as SS
	WHERE  id = @DestPublication
) AS SP
JOIN Publication as P
ON SP.id = P.id;

DROP TABLE #t;
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
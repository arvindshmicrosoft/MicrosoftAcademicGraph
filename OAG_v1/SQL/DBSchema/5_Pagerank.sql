-- compute page rank: formula from https://en.wikipedia.org/wiki/PageRank#Iterative

DROP TABLE IF EXISTS #t

-- get the total node count; exclude nodes with no outbound or no inbound edges
declare @node_count int
select @node_count = count(*)
from Publication u1
where exists (select * from Publication u2o, [References] fo where match(u1-(fo)->u2o)) and
       exists (select * from Publication u2i, [References] fi where match(u1<-(fi)-u2i))
select '@node_count', @node_count

-- get all connected nodes; compute the outbound edge count and set the initial weight
declare @initial_weight float = 1e0 / @node_count
create table #t (id varchar(100) primary key clustered, out_edge_count int, weight float, delta float)
insert #t
select u1.id, count(*), @initial_weight, @initial_weight
from Publication u1, Publication u2o, [References] fo
where match(u1-(fo)->u2o) and
       exists (select * from Publication u2i, [References] fi where match(u1<-(fi)-u2i))
group by u1.id

-- initial weights sum to 1
select 'sum(weight)', sum(weight) from #t

-- iterate until weights converge; stop when delta is less than 5%
declare @threshold float = 0.05
declare @damping_factor float = 0.85
declare @epsilon float = @initial_weight * @threshold
declare @iterations int = 0
while exists (select * from #t where delta > @epsilon)
begin
       update #t
       set weight = new_weight, delta = weight - new_weight
       from #t,
              (select u2.id, (1 - @damping_factor) / @node_count + (@damping_factor * sum(weight/out_edge_count)) as new_weight
              from #t, Publication u1, Publication u2, [References] f
              where #t.id = u1.id and match(u1-(f)->u2)
              group by u2.id) q
       where #t.id = q.id

       --select top 25 *, abs(delta)/weight from #t order by abs(delta)/weight desc
       --select top 25 * from #t order by abs(delta) desc
       --select sum(weight) from #t

       set @iterations += 1
	
	print @iterations
	select '@iterations', @iterations
	if (@iterations > 20) 
	break
end

-- final weights sum to 1
select 'sum(weight)', sum(weight) from #t

-- final results
DROP TABLE IF EXISTS PageRankOutput
SELECT * INTO PageRankOutput
FROM #t

select top 1000 Title, num_citation, weight 
from #t as PR
join Publication as P on PR.id = P.id
order by weight desc
-- drop table #t
go

-- select * from Publication where id = '1182ea42-b7a3-4b76-98f2-502fd02f687b'

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
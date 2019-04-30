<Query Kind="Program">
  <Reference Relative="FastMember.dll">C:\workarea\MicrosoftAcademicGraph\OAG_v1\SQL\BulkImportClient\FastMember.dll</Reference>
  <Reference Relative="Newtonsoft.Json.dll">C:\workarea\MicrosoftAcademicGraph\OAG_v1\SQL\BulkImportClient\Newtonsoft.Json.dll</Reference>
  <Reference Relative="System.Data.HashFunction.CityHash.dll">C:\workarea\MicrosoftAcademicGraph\OAG_v1\SQL\BulkImportClient\System.Data.HashFunction.CityHash.dll</Reference>
  <Reference Relative="System.Data.HashFunction.Interfaces.dll">C:\workarea\MicrosoftAcademicGraph\OAG_v1\SQL\BulkImportClient\System.Data.HashFunction.Interfaces.dll</Reference>
  <Namespace>FastMember</Namespace>
  <Namespace>Newtonsoft.Json</Namespace>
  <Namespace>Newtonsoft.Json.Bson</Namespace>
  <Namespace>Newtonsoft.Json.Converters</Namespace>
  <Namespace>Newtonsoft.Json.Linq</Namespace>
  <Namespace>Newtonsoft.Json.Schema</Namespace>
  <Namespace>Newtonsoft.Json.Serialization</Namespace>
  <Namespace>System.Collections.Concurrent</Namespace>
  <Namespace>System.Data.HashFunction.CityHash</Namespace>
  <Namespace>System.Threading</Namespace>
  <Namespace>System.Threading.Tasks</Namespace>
</Query>

/*
This sample code shows how to import and work with the Open Academic Graph (https://www.openacademic.ai/oag/) using Microsoft SQL Server 2017.

Citations:
Jie Tang, Jing Zhang, Limin Yao, Juanzi Li, Li Zhang, and Zhong Su. ArnetMiner: Extraction and Mining of Academic Social Networks. In Proceedings of the Fourteenth ACM SIGKDD International Conference on Knowledge Discovery and Data Mining (SIGKDD’2008). pp.990-998.
Arnab Sinha, Zhihong Shen, Yang Song, Hao Ma, Darrin Eide, Bo-June (Paul) Hsu, and Kuansan Wang. 2015. An Overview of Microsoft Academic Service (MAS) and Applications. In Proceedings of the 24th International Conference on World Wide Web (WWW ’15 Companion). ACM, New York, NY, USA, 243-246.
*/

static int FilesMaxDoP = 30;	// adjust this number based on the number of cores in your client VM, and tune it based on memory availability and performance requirements
static BlockingCollection<string> waitqueue = new BlockingCollection<string>();
static Dictionary<string, int> timings = new Dictionary<string, int> ();

void Main()
{
	var sqlPassword = Util.GetPassword("SQLDB");
	
	WorkerThread.SQLConnStr += sqlPassword;
	
	Console.WriteLine(DateTime.Now);
	
	timings.Clear();
	timings.Add("ReadParseJSON", 0);
	timings.Add("InsertPublication", 0);
	timings.Add("PubRefs_Exploded", 0);
	timings.Add("Keyword_Exploded", 0);
	timings.Add("URL_Exploded", 0);
	timings.Add("Author_Exploded", 0);
	timings.Add("CollaboratesWith_Exploded", 0);
	timings.Add("FOS_Exploded", 0);

	// Prologue
	if (true) 	// SWITCH
	{
		using (var con = new SqlConnection(WorkerThread.SQLConnStr))
		{
			con.Open();
		    using(var cmd = new SqlCommand())
			{
		        cmd.Connection = con;
				cmd.CommandTimeout = 0;
		        cmd.CommandText = string.Format(@"
					EXEC TruncateAllTables;
					EXEC DisableAllGraphNodeUniqueIndexes;
					EXEC DisableAllGraphEdgeUniqueIndexes;
					");
					
		        cmd.CommandType = CommandType.Text;
		        
		        cmd.ExecuteNonQuery();
			 }
			 con.Close();
		}
	}

	var allFiles = Directory.GetFiles(@"\\sqlclient\e$\MAGTxt", "mag_papers_*.txt");
	
	Console.WriteLine("Filecount to process: " + allFiles.Length.ToString());	
	Console.WriteLine(DateTime.Now);
	
	// "queue" up all the files
	foreach (var fileName in allFiles) 
	{
		waitqueue.Add(fileName);
	}
	
	List<WorkerThread> allThreads = new List<WorkerThread>();
	for (var threadOrdinal = 0; threadOrdinal < FilesMaxDoP; threadOrdinal++)
	{
		var tmpWorker = new WorkerThread();
		tmpWorker.queueref = waitqueue;
		tmpWorker.myWorker = new Thread(tmpWorker.ThreadLoop);
		
		allThreads.Add(tmpWorker);
		tmpWorker.myWorker.Start();
	}
	
	// block until everyone is done
	foreach(var tmpWorker in allThreads)
	{
		tmpWorker.myWorker.Join();
	}
	
	Console.WriteLine(DateTime.Now);

	// Epilogue
	if (true)	// SWITCH
	{
		using (var con = new SqlConnection(WorkerThread.SQLConnStr))
		{
			string[] sqlcmds = {"DedupeAuthorsExploded",
				"DedupeKeywordsExploded",
				"DedupeURLsExploded",
				"DedupeFOSExploded",
				"DedupeVenueExploded",
				"RebuildAllGraphNodeUniqueIndexes",
				"InsertEdgeHasKeyword",
				"InsertEdgeReferences",
				"InsertEdgeIsAuthorOf",
				"InsertEdgeCollaboratesWith",
				"InsertEdgeInField",
				"InsertEdgePresentedIn",
				"InsertEdgeMentionedIn",
				"RebuildAllGraphEdgeUniqueIndexes"
			};
			
			foreach (var cmdtext in sqlcmds)
			{
				con.Open();
				using(var cmd = new SqlCommand())
				{
					Console.WriteLine(string.Format("Start: {0}", cmdtext));
					cmd.Connection = con;
					cmd.CommandTimeout = 0;
					cmd.CommandText = "EXEC " + cmdtext;
						
					cmd.CommandType = CommandType.Text;
					
					var watch = System.Diagnostics.Stopwatch.StartNew();
					cmd.ExecuteNonQuery();
					watch.Stop();
					
					Console.WriteLine(string.Format("End: {0}; time taken in seconds: {1}", cmdtext, watch.ElapsedMilliseconds / 1000));
					
					timings.Add(cmdtext, (int) (watch.ElapsedMilliseconds / 1000));
				}
				
				con.Close();
			}
		}
	}
	
	timings.Dump();
	
	Console.WriteLine(DateTime.Now);
}

public class WorkerThread
{
	public static string SQLConnStr = @"Server=yoursql.database.windows.net;Initial Catalog=MAG_BC;Integrated Security=false;Connection Timeout=60;User=sqlsatadmin;Password=";
	public static int SQLBulkCopyBatchSize = 150000;
	public Thread myWorker;
	public BlockingCollection<string> queueref;
	
	public void ThreadLoop()
	{
		// read from BlockingCollection and loop till no new work has arrived for a timeout period.
		while(true)
		{
			string currFile;
			if (!queueref.TryTake(out currFile, 15000))	// wait for 15 seconds
			{
				Console.WriteLine("Worker thread exiting due to no work.");
				break;
			}
			
			var fileNum = int.Parse(Regex.Match(Path.GetFileNameWithoutExtension(currFile), @"(?<fileNum>\d+)").Groups["fileNum"].Value);

			Console.WriteLine(string.Format("Started Processing {0}", currFile));
			ProcessFile(currFile, fileNum, timings);
			Console.WriteLine(string.Format("Finished Processing {0}", currFile));
		}
	}

	public void ProcessFile(string fileName, int fileNum, Dictionary<string, int> timings)
	{
		var watch = System.Diagnostics.Stopwatch.StartNew();
		
		var config = new CityHashConfig()
        {
            HashSizeInBits = 128
        };

		var hasher = CityHashFactory.Instance.Create(config);		

		var pubs = new List<Publication>();
	
		watch.Restart();
		using (var rdr = new StreamReader(fileName))
		{
			using (var jsonRdr = new JsonTextReader(rdr))
			{
				jsonRdr.SupportMultipleContent = true;
				
			    var serializer = new JsonSerializer();
				
				while (true)
				{
				    if (!jsonRdr.Read())
				    {
				        break;
				    }

					Publication.FileNumber = fileNum;
				    Publication currPub = serializer.Deserialize<Publication>(jsonRdr);
					
				    pubs.Add(currPub);
				}
			}
			
			rdr.Close();
		}
		
		watch.Stop();
		lock(timings)
		{
			timings["ReadParseJSON"] += (int) (watch.ElapsedMilliseconds / 1000);
		}
			
		// ====== PUBLICATION ======
		if (true)	// SWITCH
		{
			watch.Restart();
			
			using(var rdrPubs = ObjectReader.Create(pubs, "fileNum", "id", "title", "venue", "year"
			, "n_citation", "page_start", "page_end", "doc_type"
			, "lang", "publisher", "volume", "issue", "issn", "isbn", "doi", "pdf"
			, "Abstract", "is_mag"))
			{
				try
				{
					using (var sqlConn = new SqlConnection(SQLConnStr))
					{
						sqlConn.Open();
						
					    using (var s = new SqlBulkCopy(sqlConn))
					    {
							s.BulkCopyTimeout = 0;
							s.BatchSize = SQLBulkCopyBatchSize;
					        s.DestinationTableName = "dbo.Publication";
					
							s.ColumnMappings.Add("fileNum", "fileNum");
							s.ColumnMappings.Add("id", "id");
							s.ColumnMappings.Add("title", "title");
							s.ColumnMappings.Add("venue", "venue");
							s.ColumnMappings.Add("year", "pub_year");
							s.ColumnMappings.Add("n_citation", "num_citation");
							s.ColumnMappings.Add("page_start", "page_start");
							s.ColumnMappings.Add("page_end", "page_end");
							s.ColumnMappings.Add("doc_type", "doc_type");
							s.ColumnMappings.Add("lang", "lang");
							s.ColumnMappings.Add("publisher", "publisher");
							s.ColumnMappings.Add("volume", "volume");
							s.ColumnMappings.Add("issue", "issue");
							s.ColumnMappings.Add("issn", "issn");
							s.ColumnMappings.Add("isbn", "isbn");
							s.ColumnMappings.Add("doi", "doi");
							s.ColumnMappings.Add("pdf", "pdf_url");
							s.ColumnMappings.Add("Abstract", "abstract");
					
				        	s.WriteToServer(rdrPubs);
					        s.Close();
							
							rdrPubs.Close();
					    }
						
						sqlConn.Close();
					}
				}
				catch(SqlException ex)
				{
					Console.WriteLine(string.Format("Exception processing Publication for file {0}: {1}", fileName, ex.Message));
					throw;
				}
				
				watch.Stop();
				lock(timings)
				{
					timings["InsertPublication"] += (int) (watch.ElapsedMilliseconds / 1000);
				}
			}
		}

		// ====== Pub_References (exploded) ======
		if (true)	// SWITCH
		{
			watch.Restart();
			
			var pubrefs_exploded = from p in pubs
									where p.references != null
									from r in p.references
									select new { id = p.id, id_ref = r.Left(200).TrimEx() };
									
			using(var rdrPubRefs = ObjectReader.Create(pubrefs_exploded, "id", "id_ref"))
			{
				try
				{
					using (var sqlConn = new SqlConnection(SQLConnStr))
					{
						sqlConn.Open();
						
						using (var s = new SqlBulkCopy(sqlConn))
					    {
							s.BulkCopyTimeout = 0;
							s.BatchSize = SQLBulkCopyBatchSize;
					        s.DestinationTableName = "dbo.PubRefs_Exploded";
					
							s.ColumnMappings.Add("id", "id");
							s.ColumnMappings.Add("id_ref", "id_ref");
					
				        	s.WriteToServer(rdrPubRefs);
							rdrPubRefs.Close();
						
					        s.Close();
					    }
						
						sqlConn.Close();
					}
				}
				catch(SqlException ex)
				{
					Console.WriteLine(string.Format("Exception processing PubRefs for file {0}: {1}", fileName, ex.Message));
					throw;
				}

				watch.Stop();
				lock(timings)
				{
					timings["PubRefs_Exploded"] += (int) (watch.ElapsedMilliseconds / 1000);
				}
			}

			foreach(var pub in pubs)
			{	
				// set pub.references to null to remove reference
				pub.references = null;
			}
		}

		// ====== KEYWORD (exploded) ======
		if (true)	 // SWITCH
		{
			watch.Restart();
			
			var keywords_exploded = from p in pubs
							where p.keywords != null
							from k in p.keywords
							select new { id = p.id, keyword = k.Left(1000).TrimEx() };
									
			using(var rdrKeywords = ObjectReader.Create(keywords_exploded, "id", "keyword"))
			{
				try
				{
					using (var sqlConn = new SqlConnection(SQLConnStr))
					{
						sqlConn.Open();
						
						using (var s = new SqlBulkCopy(sqlConn))
					    {
							s.BulkCopyTimeout = 0;
							s.BatchSize = SQLBulkCopyBatchSize;
					        s.DestinationTableName = "dbo.Keyword_Exploded";
					
							s.ColumnMappings.Add("id", "id");
							s.ColumnMappings.Add("keyword", "keyword");
					
				        	s.WriteToServer(rdrKeywords);
							rdrKeywords.Close();
							
					        s.Close();
					    }
						
						sqlConn.Close();
					}
				}
				catch(SqlException ex)
				{
					Console.WriteLine(string.Format("Exception processing Keyword for file {0}: {1}", fileName, ex.Message));
					throw;
				}

				watch.Stop();
				lock(timings)
				{
					timings["Keyword_Exploded"] += (int) (watch.ElapsedMilliseconds / 1000);
				}
			}
			
			foreach(var pub in pubs)
			{	
				// release reference
				pub.keywords = null;
			}
		}
	
		// ====== URL ======
		if (true)	// SWITCH
		{
			watch.Restart();
			
			var url_exploded = from p in pubs
					where p.url != null
					from u in p.url
					select new { id = p.id, url = u.Left(500).TrimEx() };
									
			using(var rdrURLs = ObjectReader.Create(url_exploded, "id", "url"))
			{
				try
				{
					using (var sqlConn = new SqlConnection(SQLConnStr))
					{
						sqlConn.Open();
						
						using (var s = new SqlBulkCopy(sqlConn))
					    {
							s.BulkCopyTimeout = 0;
							s.BatchSize = SQLBulkCopyBatchSize;
					        s.DestinationTableName = "dbo.URL_Exploded";
					
							s.ColumnMappings.Add("id", "id");
							s.ColumnMappings.Add("url", "url");
					
					        s.WriteToServer(rdrURLs);
							rdrURLs.Close();
							
					        s.Close();
					    }
					
						sqlConn.Close();
					}
				}
				catch(SqlException ex)
				{
					Console.WriteLine(string.Format("Exception processing URL for file {0}: {1}", fileName, ex.Message));
					throw;
				}			

				watch.Stop();
				lock(timings)
				{
					timings["URL_Exploded"] += (int) (watch.ElapsedMilliseconds / 1000);
				}
			}

			foreach(var pub in pubs)
			{				
				pub.url = null;
			}			
		}
	
		// ====== Author ======
		if (true)	// SWITCH
		{
			watch.Restart();
			
			var authors_exploded = from p in pubs
									where p.authors != null
									from a in p.authors
									select new { p.id, name = a.name.Left(500).TrimEx(), org = a.org.Left(500).TrimEx(), 
										auth_hash = hasher.ComputeHash(Encoding.UTF8.GetBytes(string.Concat(a.name.Left(500).TrimEx(), '+', a.org.Left(500).TrimEx()))).AsBase64String()};
									
			using(var rdrAuthors = ObjectReader.Create(authors_exploded, "id", "name", "org", "auth_hash"))
			{
				try
				{
					using (var sqlConn = new SqlConnection(SQLConnStr))
					{
						sqlConn.Open();
						
						using (var s = new SqlBulkCopy(sqlConn))
					    {
							s.BulkCopyTimeout = 0;
							s.BatchSize = SQLBulkCopyBatchSize;
					        s.DestinationTableName = "dbo.Author_Exploded";
					
							s.ColumnMappings.Add("id", "id");
							s.ColumnMappings.Add("name", "author_name");
							s.ColumnMappings.Add("org", "org");
							s.ColumnMappings.Add("auth_hash", "auth_hash");
					
				        	s.WriteToServer(rdrAuthors);
							rdrAuthors.Close();
							
					        s.Close();
					    }
						
						sqlConn.Close();
					}
				}
				catch(SqlException ex)
				{
					Console.WriteLine(string.Format("Exception processing Author for file {0}: {1}", fileName, ex.Message));
					throw;
				}
				
				watch.Stop();
				lock(timings)
				{
					timings["Author_Exploded"] += (int) (watch.ElapsedMilliseconds / 1000);
				}
			}
			
			watch.Restart();
			var allCollaborations = from p in pubs 
									from collaborations in GetCollaborations(p, hasher)
									select collaborations;
									
			var collabs_Exploded = (from c in allCollaborations select new { first_auth_hash = c.Item1, second_auth_hash = c.Item2}).Distinct();

			using(var rdrCollaborations = ObjectReader.Create(collabs_Exploded, "first_auth_hash", "second_auth_hash"))
			{
				try
				{
					using (var sqlConn = new SqlConnection(SQLConnStr))
					{
						sqlConn.Open();
						
						using (var s = new SqlBulkCopy(sqlConn))
					    {
							s.BulkCopyTimeout = 0;
							s.BatchSize = SQLBulkCopyBatchSize;
					        s.DestinationTableName = "dbo.CollaboratesWith_Exploded";
					
							s.ColumnMappings.Add("first_auth_hash", "first_auth_hash");
							s.ColumnMappings.Add("second_auth_hash", "second_auth_hash");
							
				        	s.WriteToServer(rdrCollaborations);
							rdrCollaborations.Close();
							
					        s.Close();
					    }
						
						sqlConn.Close();
					}
				}
				catch(SqlException ex)
				{
					Console.WriteLine(string.Format("Exception processing Collaborations for file {0}: {1}", fileName, ex.Message));
					throw;
				}
				
				watch.Stop();
				lock(timings)
				{
					timings["CollaboratesWith_Exploded"] += (int) (watch.ElapsedMilliseconds / 1000);
				}
			}

			// reset all authors references to null
			authors_exploded = null;
			allCollaborations = null;
			
			foreach (var pub in pubs)
			{
				pub.authors = null;
			}									
		}
	
		// ====== FOS ======
		if (true)	// SWITCH
		{
			watch.Restart();
			
			var fos_exploded = from p in pubs
				where p.fos != null
				from f in p.fos
				select new { id = p.id, fos = f.Left(500).TrimEx() };
									
			using(var rdrFOS = ObjectReader.Create(fos_exploded, "id", "fos"))
			{
				try
				{
					using (var sqlConn = new SqlConnection(SQLConnStr))
					{
						sqlConn.Open();
						
						using (var s = new SqlBulkCopy(sqlConn))
					    {
							s.BulkCopyTimeout = 0;
							s.BatchSize = SQLBulkCopyBatchSize;
					        s.DestinationTableName = "dbo.FOS_Exploded";
					
							s.ColumnMappings.Add("id", "id");
							s.ColumnMappings.Add("fos", "fos");
					
				        	s.WriteToServer(rdrFOS);
							rdrFOS.Close();
							
					        s.Close();
					    }
						
						sqlConn.Close();
					}
				}
				catch(SqlException ex)
				{
					Console.WriteLine(string.Format("Exception processing FOS for file {0}: {1}", fileName, ex.Message));
					throw;
				}
			}
			
			watch.Stop();
			lock(timings)
			{
				timings["FOS_Exploded"] += (int) (watch.ElapsedMilliseconds / 1000);
			}	
				
			foreach(var pub in pubs)
			{
				pub.fos = null;
			}
		}	
	}
}

public static List<Tuple<string, string>> GetCollaborations(Publication p, ICityHash hasher)
{
	var allCollabs = new List<Tuple<string, string>>();
	
	if (p.authors is null)
	{
		return allCollabs;
	}
	
	allCollabs = 	(from a1 in p.authors
						from a2 in p.authors
						where a1.name != a2.name && a1.org != a2.org
						select new Tuple<string, string> (
							hasher.ComputeHash(Encoding.UTF8.GetBytes(string.Concat(a1.name.Left(500).TrimEx(), '+', a1.org.Left(500).TrimEx()))).AsBase64String(),
							hasher.ComputeHash(Encoding.UTF8.GetBytes(string.Concat(a2.name.Left(500).TrimEx(), '+', a2.org.Left(500).TrimEx()))).AsBase64String()
							)).Take(int.MaxValue).ToList();	// TODO arbitrary limit of 500 collaborations per paper
						
	if (allCollabs is null)
	{
		return new List<Tuple<string, string>>();
	}

	return allCollabs;
}

public static class StringExtn
{
	public static string Left( this string str, int length ) {
	  if (str == null)
	    return str;
	  return str.Substring(0, Math.Min(Math.Max(0,length), str.Length));
	}

	public static string TrimEx( this string str ) {
	  if (str == null)
	    return str;
	  return str.ToLower().Trim();
	}
}

public class Author
{
	public string name {get;set;}
	public string org {get;set;}
}

public class Publication
{
	[JsonIgnore]
	[ThreadStatic]
	public static int FileNumber;	
	
	[JsonIgnore]
	public int fileNum { get { return Publication.FileNumber; } }

	[JsonIgnore]
	[ThreadStatic]
	public static bool IsMag;	

	[JsonIgnore]
	public bool is_mag { get { return Publication.IsMag; } }

    public string id {get;set;}
	
	[JsonProperty("title")]
	public string _title {get;set;}
	
	[JsonIgnore]
	public string title { get { return _title.Left(1500); } }

	public List<Author> authors {get;set;}
	
	[JsonProperty("venue")]
	public string _venue {get;set;}

	[JsonIgnore]
	public string venue { get { return _venue.Left(500); } }
	
	public int year {get;set;}
	
	public List<string> keywords {get;set;}

	public List<string> fos {get;set;}
	
	public int n_citation {get;set;}
	
	public List<string> references {get;set;}
		
	[JsonProperty("page_start")]
	public string _page_start {get;set;}
	
	[JsonIgnore]
	public string page_start { get { return _page_start.Left(100); } }
	
	[JsonProperty("page_end")]
	public string _page_end {get;set;}
	
	[JsonIgnore]
	public string page_end { get { return _page_end.Left(100); } }

	[JsonProperty("doc_type")]
	public string _doc_type {get;set;}
	
	[JsonIgnore]
	public string doc_type { get { return _doc_type.Left(100); } }

	[JsonProperty("lang")]
	public string _lang {get;set;}
	
	[JsonIgnore]
	public string lang { get { return _lang.Left(100); } }
	
	[JsonProperty("publisher")]
	public string _publisher {get;set;}
	
	[JsonIgnore]
	public string publisher { get { return _publisher.Left(500); } }
	
	[JsonProperty("volume")]
	public string _volume {get;set;}
	
	[JsonIgnore]
	public string volume { get { return _volume.Left(100); } }

	[JsonProperty("issue")]
	public string _issue {get;set;}
	
	[JsonIgnore]
	public string issue { get { return _issue.Left(500); } }
	
	[JsonProperty("issn")]
	public string _issn {get;set;}
	
	[JsonIgnore]
	public string issn { get { return _issn.Left(20); } }
	
	[JsonProperty("isbn")]
	public string _isbn {get;set;}
	
	[JsonIgnore]
	public string isbn { get { return _isbn.Left(20); } }
	
	[JsonProperty("doi")]
	public string _doi {get;set;}
	
	[JsonIgnore]
	public string doi { get { return _doi.Left(500); } }

	[JsonProperty("pdf")]
	public string _pdf {get;set;}
	
	[JsonIgnore]
	public string pdf { get { return _pdf.Left(1500); } }
	
	public List<string> url {get;set;}
	
	[JsonProperty("abstract")]
	public string Abstract {get;set;}
}

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
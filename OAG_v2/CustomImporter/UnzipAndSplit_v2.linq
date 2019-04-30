<Query Kind="Program">
  <Reference Relative="FastMember.dll">C:\CustomLoader\FastMember.dll</Reference>
  <Reference Relative="Newtonsoft.Json.dll">C:\CustomLoader\Newtonsoft.Json.dll</Reference>
  <Reference>&lt;RuntimeDirectory&gt;\System.IO.Compression.dll</Reference>
  <Namespace>FastMember</Namespace>
  <Namespace>Newtonsoft.Json</Namespace>
  <Namespace>Newtonsoft.Json.Bson</Namespace>
  <Namespace>Newtonsoft.Json.Converters</Namespace>
  <Namespace>Newtonsoft.Json.Linq</Namespace>
  <Namespace>Newtonsoft.Json.Schema</Namespace>
  <Namespace>Newtonsoft.Json.Serialization</Namespace>
  <Namespace>System.Collections.Concurrent</Namespace>
  <Namespace>System.IO.Compression</Namespace>
  <Namespace>System.Threading</Namespace>
  <Namespace>System.Threading.Tasks</Namespace>
</Query>

// this script will unzip and split the MAG_v2 files from the OAG site
// the splitting is necessary to parallelize JSON parse and further data loads into SQL

// globals which are used
static int FilesMaxDoP = 4;	// adjust this number based on the number of cores in your client VM, and tune it based on memory availability and performance requirements
static BlockingCollection<string> waitqueue = new BlockingCollection<string>();
static int OutputFileNum = 0;
static Dictionary<string, int> GlobalLineCounts = new Dictionary<string, int>();

void Main()
{
	GlobalLineCounts.Add("Author", 0);
	GlobalLineCounts.Add("Paper", 0);
	
	// Phase 1: unzip and split the authors ZIP files
	// "C:\oag_v2"
	var authorZIPs = Directory.GetFiles(@"C:\oag_v2", "mag_authors_*.zip");
	foreach (var fileName in authorZIPs) 
	{
		waitqueue.Add(fileName);
	}
	
	OutputFileNum = 0;
	var allThreads = new List<WorkerThread>();
	for (var threadOrdinal = 0; threadOrdinal < FilesMaxDoP; threadOrdinal++)
	{
		var tmpWorker = new WorkerThread();
		tmpWorker.queueref = waitqueue;
		tmpWorker.LineCountKey = "Author";
		tmpWorker.OutFileNamePrefix = @"E:\MAG_v2\mag_authors_";
		tmpWorker.LinesPerOutputFile = 1000000;	// 1 million
		tmpWorker.myWorker = new Thread(tmpWorker.ThreadLoop);
		
		allThreads.Add(tmpWorker);
		tmpWorker.myWorker.Start();
	}
	
	// block until everyone is done
	foreach(var tmpWorker in allThreads)
	{
		tmpWorker.myWorker.Join();
	}
	
	Console.WriteLine($"Count of authors is {GlobalLineCounts["Author"]}");

	// Phase 2: unzip and split the papers ZIP files
	var paperZIPs = Directory.GetFiles(@"C:\oag_v2", "mag_papers_*.zip");
	foreach (var fileName in paperZIPs) 
	{
		waitqueue.Add(fileName);
	}

	OutputFileNum = 0;
	allThreads = new List<WorkerThread>();
	for (var threadOrdinal = 0; threadOrdinal < FilesMaxDoP; threadOrdinal++)
	{
		var tmpWorker = new WorkerThread();
		tmpWorker.queueref = waitqueue;
		tmpWorker.LineCountKey = "Paper";
		tmpWorker.OutFileNamePrefix = @"E:\MAG_v2\mag_papers_";
		tmpWorker.LinesPerOutputFile = 1000000;	// 1 million
		tmpWorker.myWorker = new Thread(tmpWorker.ThreadLoop);
		
		allThreads.Add(tmpWorker);
		tmpWorker.myWorker.Start();
	}
	
	// block until everyone is done
	foreach(var tmpWorker in allThreads)
	{
		tmpWorker.myWorker.Join();
	}
	
	Console.WriteLine($"Count of papers is {GlobalLineCounts["Paper"]}");
}

public class WorkerThread
{
	public Thread myWorker;
	public BlockingCollection<string> queueref;
	public string OutFileNamePrefix;
	public int LinesPerOutputFile;
	public string LineCountKey;
	
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
			
			Console.WriteLine(string.Format("Started Processing {0}", currFile));
			ProcessFile(currFile, OutFileNamePrefix);
			Console.WriteLine(string.Format("Finished Processing {0}", currFile));
		}
	}

	public void ProcessFile(string fileName, string prefix)
	{
		using (var data = new FileStream(fileName, FileMode.Open, FileAccess.Read, FileShare.Read))
		{
			Stream unzippedEntryStream; // Unzipped data from a file in the archive
		
			var archive = new ZipArchive(data);
			foreach (var entry in archive.Entries)
			{
			    if(entry.FullName.EndsWith(".txt", StringComparison.OrdinalIgnoreCase))
			    {
					Console.WriteLine($"Handling {entry.FullName}");
			        unzippedEntryStream = entry.Open();
					
					using (var rdr = new StreamReader(unzippedEntryStream, Encoding.UTF8))
					{
						int numLinesWrittenToThisOutputFile = 0;
						
						var retVal = CloseOrCreateNewOutputFile(null, this.OutFileNamePrefix, true, entry.FullName);
						var outFile = retVal.Item1;
						var currOutFileName = retVal.Item2;
						
						while (true)
						{
							var line = rdr.ReadLine();
							if (null == line)
							{
								CloseOrCreateNewOutputFile(outFile, null, false, entry.FullName);
								
								if (0 == numLinesWrittenToThisOutputFile)
								{
									Console.WriteLine($"Output file {currOutFileName} is empty; deleting!");
									File.Delete(currOutFileName);
								}

								lock(GlobalLineCounts)
								{
									GlobalLineCounts[this.LineCountKey] += numLinesWrittenToThisOutputFile;
								}

								break;
							}
												
							outFile.WriteLine(line);
							numLinesWrittenToThisOutputFile++;
							
							if (this.LinesPerOutputFile == numLinesWrittenToThisOutputFile)
							{
								lock(GlobalLineCounts)
								{
									GlobalLineCounts[this.LineCountKey] += numLinesWrittenToThisOutputFile;
								}

								retVal = CloseOrCreateNewOutputFile(outFile, this.OutFileNamePrefix, true, entry.FullName);
								outFile = retVal.Item1;
								currOutFileName = retVal.Item2;
								
								numLinesWrittenToThisOutputFile = 0;
							}							
						}
					}
			    }
			}
		}		
	}
	
	public Tuple<StreamWriter, string> CloseOrCreateNewOutputFile(StreamWriter prev, string prefix, bool createNew, string srcFile)
	{
		if (null != prev)
		{
			prev.Flush();
			prev.Close();
			prev.Dispose();
		}
		
		if (!createNew)
		{
			return null;
		}
		
		string outFileName = string.Empty;
		lock (waitqueue)
		{
			outFileName = string.Concat(this.OutFileNamePrefix, OutputFileNum, ".txt");
			OutputFileNum++;	// safe to do under global lock without Interlocked.Increment
		}
		
		Console.WriteLine($"Writing to {outFileName} from source entry {srcFile}");
		var outFile = new StreamWriter(outFileName, false, Encoding.UTF8);
		outFile.AutoFlush = false;

		return new Tuple<StreamWriter, string>(outFile, outFileName);
	}
}
# Working with the Microsoft Academic Graph (MAG)
This sample code shows how to import and work with the <a href="https://www.openacademic.ai/oag/" target="_blank">Open Academic Graph snapshot</a> of the Microsoft Academic Graph using various data platforms - SQL Server / Azure SQL DB, Azure Cosmos DB, Apache Spark etc. For now, the repo only contains scripts for SQL Server / Azure SQL DB.

# Setup with SQL Server 2017 / Azure SQL DB
You need a client VM to run the custom bulk import tool. This VM can ideally be matched in terms of # of CPUs to the VM running SQL / to the Azure SQL DB database size. I use E32s_v3 sized VMs for the SQL instance and for the client, with a 1TB managed disk for the SQL instance to hold the database. For Azure SQL DB, I recommend a Gen 5  database with 32 vCores. For best performance with Azure SQL DB, make sure the client VM is in the same region as the Azure SQL DB instance, and for increased security, please use a VNET service endpoint + firewall rules to only permit that VNET to access Azure SQL DB.

## Create the database
If you choose to use a SQL Server instance, start by running the code in 0_CreateDB.sql. Ideally you need a large VM (I tested with 32-vCPU VMs in Azure) but if you do choose to use smaller VM sizes, the number of data files, the number of threads in the custom importer tool etc. need to be adjusted accordingly. The code is generally very parallelizable, so tweak these parameters according to the hardware at your disposal.

If you choose to run against Azure SQL DB, you can just create a database. Skip running the 0_CreateDB.sql file.

## Create tables and procedures
Next, create the tables and objects by running scripts in 1_CreateGraphTables.sql and 2_ConvertToGraph.sql. If you are in Azure SQL DB, please skip the "USE [OpenAcademicGraph]" lines.

## Run the custom bulk import tool
On the client VM, download and extract the OAG v1 files from https://www.openacademic.ai/oag/. There's a helper PowerShell script to do this in the repo (download_client.ps1).

The actual bulk load is done by running the ParseAndExplodeBlockingCollection_FastMember.linq or ParseAndExplodeBlockingCollection_FastMember_SQLDB.linq scripts in LinqPad.NET. Before running either of these scripts please check:
* the path to the extracted OAG v1 TXT files
* the connection string to connect to SQL Server / Azure SQL DB
* the number of threads to use (the default is 30)

## Sample queries
Basic search is in the 3_BFS.sql file. Pagerank implementation is in 4_PageRank.sql

# References
* Jie Tang, Jing Zhang, Limin Yao, Juanzi Li, Li Zhang, and Zhong Su. ArnetMiner: Extraction and Mining of Academic Social Networks. In Proceedings of the Fourteenth ACM SIGKDD International Conference on Knowledge Discovery and Data Mining (SIGKDD’2008). pp.990-998.
* Arnab Sinha, Zhihong Shen, Yang Song, Hao Ma, Darrin Eide, Bo-June (Paul) Hsu, and Kuansan Wang. 2015. An Overview of Microsoft Academic Service (MAS) and Applications. In Proceedings of the 24th International Conference on World Wide Web (WWW ’15 Companion). ACM, New York, NY, USA, 243-246.

# Disclaimers
##### THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

##### By running the scripts against your Microsoft Azure subscription, you assume full responsibility for any charges incurred.

##### This sample code is not supported under any Microsoft standard support program or service. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages.

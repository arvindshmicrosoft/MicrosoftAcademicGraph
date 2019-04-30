/*
This sample code shows how to import and work with the Open Academic Graph (https://www.openacademic.ai/oag/) using Microsoft SQL Server 2017.

Citations:
Jie Tang, Jing Zhang, Limin Yao, Juanzi Li, Li Zhang, and Zhong Su. ArnetMiner: Extraction and Mining of Academic Social Networks. In Proceedings of the Fourteenth ACM SIGKDD International Conference on Knowledge Discovery and Data Mining (SIGKDD’2008). pp.990-998.
Arnab Sinha, Zhihong Shen, Yang Song, Hao Ma, Darrin Eide, Bo-June (Paul) Hsu, and Kuansan Wang. 2015. An Overview of Microsoft Academic Service (MAS) and Applications. In Proceedings of the 24th International Conference on World Wide Web (WWW ’15 Companion). ACM, New York, NY, USA, 243-246.
*/

-- This script NOT APPLICABLE for Azure SQL DB
-- Database creation for the Open Academic Graph in SQL Server 2017. Please read the comments at the bottom as well.
-- Also: change the paths depending on your disk layout. Exercise for the reader!
CREATE DATABASE [OpenAcademicGraph]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'OAGData_1', FILENAME = N'f:\data\OAGData_1.mdf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_2', FILENAME = N'f:\data\OAGData_2.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_3', FILENAME = N'f:\data\OAGData_3.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_4', FILENAME = N'f:\data\OAGData_4.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_5', FILENAME = N'f:\data\OAGData_5.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_6', FILENAME = N'f:\data\OAGData_6.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_7', FILENAME = N'f:\data\OAGData_7.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_8', FILENAME = N'f:\data\OAGData_8.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_9', FILENAME = N'f:\data\OAGData_9.mdf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_10', FILENAME = N'f:\data\OAGData_10.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_11', FILENAME = N'f:\data\OAGData_11.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_12', FILENAME = N'f:\data\OAGData_12.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_13', FILENAME = N'f:\data\OAGData_13.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_14', FILENAME = N'f:\data\OAGData_14.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_15', FILENAME = N'f:\data\OAGData_15.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_16', FILENAME = N'f:\data\OAGData_16.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_17', FILENAME = N'f:\data\OAGData_17.mdf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_18', FILENAME = N'f:\data\OAGData_18.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_19', FILENAME = N'f:\data\OAGData_19.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_20', FILENAME = N'f:\data\OAGData_20.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_21', FILENAME = N'f:\data\OAGData_21.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_22', FILENAME = N'f:\data\OAGData_22.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_23', FILENAME = N'f:\data\OAGData_23.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_24', FILENAME = N'f:\data\OAGData_24.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_25', FILENAME = N'f:\data\OAGData_25.mdf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_26', FILENAME = N'f:\data\OAGData_26.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_27', FILENAME = N'f:\data\OAGData_27.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_28', FILENAME = N'f:\data\OAGData_28.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_29', FILENAME = N'f:\data\OAGData_29.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_30', FILENAME = N'f:\data\OAGData_30.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_31', FILENAME = N'f:\data\OAGData_31.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB ),
( NAME = N'OAGData_32', FILENAME = N'f:\data\OAGData_32.ndf' , SIZE = 5000MB , FILEGROWTH = 512000KB )
 LOG ON 
( NAME = N'OAGLog', FILENAME = N'F:\Log\OAGLog.ldf' , SIZE = 50GB, FILEGROWTH = 500MB )
GO

ALTER DATABASE OpenAcademicGraph
SET RECOVERY SIMPLE
GO

backup database OpenAcademicGraph to disk = 'NUL'
GO

ALTER DATABASE [OpenAcademicGraph] SET QUERY_STORE = ON
GO

ALTER DATABASE [OpenAcademicGraph] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, DATA_FLUSH_INTERVAL_SECONDS = 300, INTERVAL_LENGTH_MINUTES = 5)
GO

-- We need to add a memOpt FG to allow schema-only Publication_Main table to be created
--ALTER DATABASE OpenAcademicGraph 
--ADD FILEGROUP imoltp_fg 
--CONTAINS MEMORY_OPTIMIZED_DATA
--GO

---- We only create one container, because the only memOpt table we will create is a schema-only one
---- hence no major dependency on the memOpt containers
--ALTER DATABASE OpenAcademicGraph 
--ADD FILE (name='imoltp_file1', filename='f:\data\imoltp_file1') TO FILEGROUP imoltp_fg 
--GO

/* TEMPDB optimization - if needed. Please note that if your instance already has more than 1 TEMPDB file, you need to change the ADD FILE commands to MODIFY file commands as needed

exec tempdb..sp_helpfile
GO

ALTER DATABASE tempdb MODIFY FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = tempdev, FILENAME = 'd:\tempdb\tempdev.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp2, FILENAME = 'd:\tempdb\tempdev2.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp3, FILENAME = 'd:\tempdb\tempdev3.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp4, FILENAME = 'd:\tempdb\tempdev4.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp5, FILENAME = 'd:\tempdb\tempdev5.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp6, FILENAME = 'd:\tempdb\tempdev6.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp7, FILENAME = 'd:\tempdb\tempdev7.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp8, FILENAME = 'd:\tempdb\tempdev8.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp9, FILENAME = 'd:\tempdb\tempdev9.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp10, FILENAME = 'd:\tempdb\tempdev10.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp11, FILENAME = 'd:\tempdb\tempdev11.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp12, FILENAME = 'd:\tempdb\tempdev12.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp13, FILENAME = 'd:\tempdb\tempdev13.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp14, FILENAME = 'd:\tempdb\tempdev14.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp15, FILENAME = 'd:\tempdb\tempdev15.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp16, FILENAME = 'd:\tempdb\tempdev16.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp17, FILENAME = 'd:\tempdb\tempdev17.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp18, FILENAME = 'd:\tempdb\tempdev18.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp19, FILENAME = 'd:\tempdb\tempdev19.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp20, FILENAME = 'd:\tempdb\tempdev20.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp21, FILENAME = 'd:\tempdb\tempdev21.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp22, FILENAME = 'd:\tempdb\tempdev22.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp23, FILENAME = 'd:\tempdb\tempdev23.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp24, FILENAME = 'd:\tempdb\tempdev24.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp25, FILENAME = 'd:\tempdb\tempdev25.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp26, FILENAME = 'd:\tempdb\tempdev26.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp27, FILENAME = 'd:\tempdb\tempdev27.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp28, FILENAME = 'd:\tempdb\tempdev28.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp29, FILENAME = 'd:\tempdb\tempdev29.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp30, FILENAME = 'd:\tempdb\tempdev30.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp31, FILENAME = 'd:\tempdb\tempdev31.mdf');
ALTER DATABASE tempdb ADD FILE (SIZE = 3000mb, FILEGROWTH = 500MB, NAME = temp32, FILENAME = 'd:\tempdb\tempdev32.mdf');

ALTER DATABASE tempdb MODIFY FILE (SIZE = 5000MB, FILEGROWTH = 500MB, NAME = templog, FILENAME = 'd:\tempdb\tempdb.ldf');

-- Need to drop TEMPDB files?? Optional cleanup script below
ALTER DATABASE tempdb REMOVE FILE temp2;
ALTER DATABASE tempdb REMOVE FILE temp3;
ALTER DATABASE tempdb REMOVE FILE temp4;
ALTER DATABASE tempdb REMOVE FILE temp5;
ALTER DATABASE tempdb REMOVE FILE temp6;
ALTER DATABASE tempdb REMOVE FILE temp7;
ALTER DATABASE tempdb REMOVE FILE temp8;
ALTER DATABASE tempdb REMOVE FILE temp9;
ALTER DATABASE tempdb REMOVE FILE temp10;
ALTER DATABASE tempdb REMOVE FILE temp11;
ALTER DATABASE tempdb REMOVE FILE temp12;
ALTER DATABASE tempdb REMOVE FILE temp13;
ALTER DATABASE tempdb REMOVE FILE temp14;
ALTER DATABASE tempdb REMOVE FILE temp15;
ALTER DATABASE tempdb REMOVE FILE temp16;
ALTER DATABASE tempdb REMOVE FILE temp17;
ALTER DATABASE tempdb REMOVE FILE temp18;
ALTER DATABASE tempdb REMOVE FILE temp19;
ALTER DATABASE tempdb REMOVE FILE temp20;
ALTER DATABASE tempdb REMOVE FILE temp21;
ALTER DATABASE tempdb REMOVE FILE temp22;
ALTER DATABASE tempdb REMOVE FILE temp23;
ALTER DATABASE tempdb REMOVE FILE temp24;
ALTER DATABASE tempdb REMOVE FILE temp25;
ALTER DATABASE tempdb REMOVE FILE temp26;
ALTER DATABASE tempdb REMOVE FILE temp27;
ALTER DATABASE tempdb REMOVE FILE temp28;
ALTER DATABASE tempdb REMOVE FILE temp29;
ALTER DATABASE tempdb REMOVE FILE temp30;
ALTER DATABASE tempdb REMOVE FILE temp31;
ALTER DATABASE tempdb REMOVE FILE temp32;

*/

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
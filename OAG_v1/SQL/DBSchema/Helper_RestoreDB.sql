USE [master]
RESTORE DATABASE [OpenAcademicGraph] FROM  
DISK = N'C:\temp\MAG_2019\OpenAcademicGraph_1.bak',  
DISK = N'C:\temp\MAG_2019\OpenAcademicGraph_2.bak',  
DISK = N'C:\temp\MAG_2019\OpenAcademicGraph_3.bak',  
DISK = N'C:\temp\MAG_2019\OpenAcademicGraph_4.bak',  
DISK = N'C:\temp\MAG_2019\OpenAcademicGraph_5.bak',  
DISK = N'C:\temp\MAG_2019\OpenAcademicGraph_6.bak',  
DISK = N'C:\temp\MAG_2019\OpenAcademicGraph_7.bak',  
DISK = N'C:\temp\MAG_2019\OpenAcademicGraph_8.bak' 
WITH  FILE = 1,  MOVE N'OAGData_1' TO N'G:\MAG_2019\OAGData_1.mdf',  
MOVE N'OAGData_2' TO N'G:\MAG_2019\OAGData_2.ndf',  
MOVE N'OAGData_3' TO N'G:\MAG_2019\OAGData_3.ndf',  
MOVE N'OAGData_4' TO N'G:\MAG_2019\OAGData_4.ndf',  
MOVE N'OAGData_5' TO N'G:\MAG_2019\OAGData_5.ndf',  
MOVE N'OAGData_6' TO N'G:\MAG_2019\OAGData_6.ndf',  
MOVE N'OAGData_7' TO N'G:\MAG_2019\OAGData_7.ndf',  
MOVE N'OAGData_8' TO N'G:\MAG_2019\OAGData_8.ndf',  
MOVE N'OAGData_9' TO N'G:\MAG_2019\OAGData_9.mdf',  
MOVE N'OAGData_10' TO N'G:\MAG_2019\OAGData_10.ndf',  
MOVE N'OAGData_11' TO N'G:\MAG_2019\OAGData_11.ndf',  
MOVE N'OAGData_12' TO N'G:\MAG_2019\OAGData_12.ndf',  
MOVE N'OAGData_13' TO N'G:\MAG_2019\OAGData_13.ndf',  
MOVE N'OAGData_14' TO N'G:\MAG_2019\OAGData_14.ndf',  
MOVE N'OAGData_15' TO N'G:\MAG_2019\OAGData_15.ndf',  
MOVE N'OAGData_16' TO N'G:\MAG_2019\OAGData_16.ndf',  
MOVE N'OAGData_17' TO N'G:\MAG_2019\OAGData_17.mdf',  
MOVE N'OAGData_18' TO N'G:\MAG_2019\OAGData_18.ndf',  
MOVE N'OAGData_19' TO N'G:\MAG_2019\OAGData_19.ndf',  
MOVE N'OAGData_20' TO N'G:\MAG_2019\OAGData_20.ndf',  
MOVE N'OAGData_21' TO N'G:\MAG_2019\OAGData_21.ndf',  
MOVE N'OAGData_22' TO N'G:\MAG_2019\OAGData_22.ndf',  
MOVE N'OAGData_23' TO N'G:\MAG_2019\OAGData_23.ndf',  
MOVE N'OAGData_24' TO N'G:\MAG_2019\OAGData_24.ndf',  
MOVE N'OAGData_25' TO N'G:\MAG_2019\OAGData_25.mdf',  
MOVE N'OAGData_26' TO N'G:\MAG_2019\OAGData_26.ndf',  
MOVE N'OAGData_27' TO N'G:\MAG_2019\OAGData_27.ndf',  
MOVE N'OAGData_28' TO N'G:\MAG_2019\OAGData_28.ndf',  
MOVE N'OAGData_29' TO N'G:\MAG_2019\OAGData_29.ndf',  
MOVE N'OAGData_30' TO N'G:\MAG_2019\OAGData_30.ndf',  
MOVE N'OAGData_31' TO N'G:\MAG_2019\OAGData_31.ndf',  
MOVE N'OAGData_32' TO N'G:\MAG_2019\OAGData_32.ndf',  
MOVE N'OAGLog' TO N'G:\MAG_2019\OAGLog.ldf',  NOUNLOAD,  STATS = 5

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
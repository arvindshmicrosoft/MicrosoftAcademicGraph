# Working with the Microsoft Academic Graph (MAG)
This sample code shows how to import and work with the <a href="https://www.openacademic.ai/oag/" target="_blank">Open Academic Graph snapshot</a> of the Microsoft Academic Graph using various data platforms - SQL Server, Apache Spark etc.

# Setup with SQL Server 2017
We recommend using the provided Microsoft Azure deployment template to conveniently deploy the configuration used for loading and testing the Microsoft Academic Graph. To do this, you must have Azure PowerShell installed and then run the following commands:

    CD <folder where you cloned this repo>
    New-AzureRmResourceGroup -Name "MAG"
    New-AzureRmResourceGroupDeployment -ResourceGroupName "mag" -TemplateFile template.json

The above command will prompt you for the location where you want to deploy and administrator credentials to use for the new VMs. The command typically takes around 5 minutes to complete.

# References
* Jie Tang, Jing Zhang, Limin Yao, Juanzi Li, Li Zhang, and Zhong Su. ArnetMiner: Extraction and Mining of Academic Social Networks. In Proceedings of the Fourteenth ACM SIGKDD International Conference on Knowledge Discovery and Data Mining (SIGKDD’2008). pp.990-998.
* Arnab Sinha, Zhihong Shen, Yang Song, Hao Ma, Darrin Eide, Bo-June (Paul) Hsu, and Kuansan Wang. 2015. An Overview of Microsoft Academic Service (MAS) and Applications. In Proceedings of the 24th International Conference on World Wide Web (WWW ’15 Companion). ACM, New York, NY, USA, 243-246.

# Disclaimers
##### THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

##### By running the scripts against your Microsoft Azure subscription, you assume full responsibility for any charges incurred.

##### This sample code is not supported under any Microsoft standard support program or service. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages.
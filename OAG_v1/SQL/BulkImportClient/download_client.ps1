# first we need to get LinqPad
$lpfolder = "c:\LinqPad\"
if (!(test-path -path $lpfolder)) {
    New-Item -ItemType directory -Path $lpfolder
}

Invoke-WebRequest -uri "http://www.linqpad.net/GetFile.aspx?LINQPad5-AnyCPU.zip" -OutFile ($lpfolder + "LINQPad5-AnyCPU.zip")

cd $lpfolder

function unzip($filename) 
{ 
    if (!(test-path $filename)) { throw "$filename does not exist" } 
    $shell = new-object -com shell.application 
    $shell.namespace($pwd.Path).copyhere($shell.namespace($filename).items()) 
}

unzip ($lpfolder + "LINQPad5-AnyCPU.zip")

# next get the MAG files
# first we need to get LinqPad
$magzipfolder = "F:\MAG\"
if (!(test-path -path $magzipfolder)) {
    New-Item -ItemType directory -Path $magzipfolder
}

for ($index = 0; $index -le 8; $index++)
{
    # https://academicgraphv2.blob.core.windows.net/oag-v1/mag/mag_papers_0.zip
    $url = "https://academicgraphv2.blob.core.windows.net/oag-v1/mag/mag_papers_$index.zip"
    $filename = "mag_papers_$index.zip"
    if (-not (Test-Path ($magzipfolder + $filename))) { Invoke-WebRequest -uri $url -OutFile ($magzipfolder + $filename) }
}

invoke-webrequest -uri "http://aka.ms/downloadazcopy" -outfile "azcopy.msi"
.\azcopy.msi /q
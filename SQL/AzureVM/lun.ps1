$physicaldisktolunmapping = @{}

Get-WmiObject -Namespace "root/Microsoft/Windows/Storage" -Class MSFT_PhysicalDisk | % { 
    $lun = ""
    if (($_.PhysicalLocation) -match "LUN (?<LUN>\d+)")
    {
        $lun = [int]::Parse($Matches["LUN"])
        $physicaldisktolunmapping.Add(($_.DeviceId), $lun)
    }
}

$datadisks = @()
# $datadisknames = @()
Get-PhysicalDiskSNV | ForEach-Object {
    [string] $disknum = ($_.DiskNumber)

    $disknum

    if ($physicaldisktolunmapping.ContainsKey($disknum))
    {
        $lunnum = $physicaldisktolunmapping[$disknum]

        if ($lunnum -ge 0 -and $lunnum -le 5) { $datadisks += ($_.PhysicalDisk) } 
    }
}

$datadisks 

New-StoragePool -FriendlyName "Data" -PhysicalDisks $datadisks -StorageSubSystemFriendlyName "Windows Storage on magdb"

# Destination folder
$mainFolder = "E:\Filmagens"

$date = Get-Date -Format "yyyy-MM-dd"
$startTime = Get-Date -Format "HH:mm:ss"
$totalFileSize = 0
$number = 0

$device = "gopro"
$fileFolder = "\DCIM\100GOPRO"
$extensionProxy = "lrv"
$extensionTrash = "thm"



# Create folder with custom name
Write-Host "-------------------------------------------------------------"
$name = Read-Host "Enter the name for the folder"
$destinationFolder = "$mainFolder\$device\$date-$name"

# $destinationFolder = "$mainFolder\$device\$date"


if (-not (Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Path "$destinationFolder" | Out-Null
}

# Create Strabilized
$stabilizedFolder = "$destinationFolder\stabilized"
if (-not (Test-Path -Path $stabilizedFolder)) {
    New-Item -ItemType Directory -Path $stabilizedFolder -Force | Out-Null
}

# Sum folder size
Get-ChildItem -File -Recurse -Path $fileFolder -Force | ForEach-Object {
    $totalFileSize += $_.Length
}




Write-Host "-------------------------------------------------------------"
$totalFileSizeGB = "{0:F2}" -f ($totalFileSize / 1GB)
Write-Host "Total size of files in the folder: $($totalFileSizeGB) GB"

#  Copy mp4 files
$files = Get-ChildItem -Path $fileFolder -Filter *.mp4 -Force
if ($files.Count -gt 0) {
    Write-Host "-------------------------------------------------------------"
    Write-Host "Moving video files..."
    $totalFiles = $files.Count
    $fileCounter = 0

    foreach ($file in $files) {
        $fileCounter += 1
        Write-Host "Moving file: $($file.Name) - File $($fileCounter) of $($totalFiles)"
        Move-Item $file.FullName -Destination $destinationFolder
    }
}

# Move Proxy files
$proxyFiles = Get-ChildItem -Path $fileFolder -Filter *.LRV -Force
if ($proxyFiles.Count -gt 0) {
    Write-Host "-------------------------------------------------------------"
    Write-Host "Moving proxy files..."
    $totalFiles = $proxyFiles.Count
    $fileCounter = 0

    $proxyFolder = Join-Path -Path $destinationFolder -ChildPath "proxy"
    New-Item -ItemType Directory -Path $proxyFolder -Force | Out-Null

    foreach ($file in $proxyFiles) {
        $fileCounter += 1
    
        $newFileName = $file.Name -replace "\.LRV", '.mp4'
        $newFilePath = Join-Path -Path $file.DirectoryName -ChildPath $newFileName
        
        Write-Host "Moving file: $($file.Name) - File $($fileCounter) of $($totalFiles)"
        Rename-Item -Path $file.FullName -NewName $newFileName
        Move-Item -Path $newFilePath -Destination $proxyFolder
    
        $movedFilePath = Join-Path -Path $proxyFolder -ChildPath $newFileName
        Set-ItemProperty -Path $movedFilePath -Name Attributes -Value ([System.IO.FileAttributes]::Normal)
    }
}


# Delete useless files
$trashFiles = Get-ChildItem -Path $fileFolder -Filter *.THM -Force
if ($trashFiles.Count -gt 0) {
    Write-Host "-------------------------------------------------------------"
    Write-Host "Remove trash files..."
    foreach ($file in $trashFiles) {
        Remove-Item $file.FullName -Force
    }
}


# Calculate time difference
$endTime = Get-Date -Format "HH:mm:ss"
$duration = (Get-Date $endTime) - (Get-Date $startTime)

# Extract minutes and seconds from duration
$minutes = [math]::Floor($duration.TotalMinutes)
$seconds = $duration.Seconds

Write-Host "-------------------------------------------------------------"
Write-Host "Folders created and files moved successfully!"
Write-Host " "
Write-Host "Elapsed time: $minutes minutes and $seconds seconds"
Write-Host "-------------------------------------------------------------"

$null = Read-Host

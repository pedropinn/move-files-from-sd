# Destination folder
$mainFolder = "E:\Filmagens"

$date = Get-Date -Format "yyyy-MM-dd"
$startTime = Get-Date -Format "HH:mm:ss"
$totalFileSize = 0
$number = 0

$device = "gopro"
$fileFolder = "\DCIM\100GOPRO"
$extensionProxy = "LRV"
$extensionTrash = "THM"
$destinationFolder = "$mainFolder\$device\$date"


if (-not (Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Path "$destinationFolder" | Out-Null
}

$stabilizedFolder = "$destinationFolder\stabilized"
if (-not (Test-Path -Path $stabilizedFolder)) {
    New-Item -ItemType Directory -Path "$stabilizedFolder" -Force | Out-Null
}


# Sum folder size
Get-ChildItem -File -Recurse -Path $fileFolder | ForEach-Object {
    $totalFileSize += $_.Length
}

Write-Host "-------------------------------------------------------------"
$totalFileSizeGB = "{0:F2}" -f ($totalFileSize / 1GB)
Write-Host "Total size of files in the folder: $($totalFileSizeGB) GB"

Write-Host "-------------------------------------------------------------"
Write-Host "Moving video files..."

# Get list of .mp4 files in the source folder
$files = Get-ChildItem -Path $fileFolder -Filter *.mp4
$totalFiles = $files.Count
$fileCounter = 0

foreach ($file in $files) {
    $fileCounter += 1
    Write-Host "Moving file: $($file.Name) - File $($fileCounter) of $($totalFiles)"
    Move-Item $file.FullName -Destination $destinationFolder
}


$proxyFiles = Get-ChildItem -Path $fileFolder -Filter "*.$extensionProxy"
if ($proxyFiles.Count -gt 0) {
    Write-Host "-------------------------------------------------------------"
    Write-Host "Moving proxy files..."
    $fileCounter = 0
    $proxyFolder = "$destinationFolder\proxy"
    New-Item -ItemType Directory -Path $proxyFolder -Force | Out-Null

    foreach ($file in $proxyFiles) {
        $fileCounter += 1
    
        $newFileName = $file.Name -replace "\.$extensionProxy", '.mp4'
        $newFilePath = Join-Path -Path $file.Directory.FullName -ChildPath $newFileName
        
        Write-Host "Moving file: $($file.Name) - File $($fileCounter) of $($totalFiles)"
        Rename-Item -Path $file.FullName -NewName $newFileName
        Move-Item -Path $newFilePath -Destination $proxyFolder
    }
}

# Delete useless files
$trashFiles = Get-ChildItem -Path $fileFolder -Filter "*.$extensionTrash"
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

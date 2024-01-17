# Destination folder
$mainFolder = "E:\Filmagens"

$deviceDrone = "drone"
$fileFolderDrone = "\DCIM\DJI_001\"
$proxyDrone = "lrf"

$deviceGoPro = "gopro"
$fileFolderGoPro = "\DCIM\100GOPRO\"
$proxyGopro = "lrv"

$date = Get-Date -Format "yyyy-MM-dd"
$startTime = Get-Date -Format "HH:mm:ss"
$totalFileSize = 0
$number = 0

$device = ""
$fileFolder = ""
$destinationFolder = ""
$extensionProxy = ""

# Get folder name
Write-Host "-------------------------------------------------------------"
$name = Read-Host "Enter the name for the folder"
Write-Host "-------------------------------------------------------------"


while ($true) {
     $number = Read-Host "Enter 1 for Drone and 0 for GoPro"
    # Check if the entered number is 1
    if ($number -eq 1) {
        Write-Host "-------------------------------------------------------------"
        Write-Host "Drone"
        Write-Host "-------------------------------------------------------------"
        $device = $deviceDrone
        $fileFolder = $fileFolderDrone
        $extensionProxy = $proxyDrone
        $destinationFolder = "$mainFolder\$device\$date-$name"
        New-Item -ItemType Directory -Path "$destinationFolder\sound" | Out-Null
        break 
    }
    # Check if the entered number is 2
    elseif ($number -eq 0) {
        Write-Host "-------------------------------------------------------------"
        Write-Host "GoPro"
        Write-Host "-------------------------------------------------------------"
        $device = $deviceGoPro
        $fileFolder = $fileFolderGoPro
        $extensionProxy = $proxyGopro
        $destinationFolder = "$mainFolder\$device\$date-$name"
        New-Item -ItemType Directory -Path "$destinationFolder" | Out-Null
        break  
    }
    else {
        Write-Host "1 or 0"
    }
}

$renderFolder = "$mainFolder\render\$date-$device-$name"
New-Item -ItemType Directory -Path $renderFolder | Out-Null

# Sum folder size
Get-ChildItem -File -Recurse -Path $fileFolder | ForEach-Object {
    $totalFileSize += $_.Length
}
$totalFileSizeGB = "{0:F2}" -f ($totalFileSize / 1GB)
Write-Host "Total size of files in the folder: $($totalFileSizeGB) GB"


Write-Host "-------------------------------------------------------------"
Write-Host "Moving video files. . ."
# Get list of .mp4 files in the source folder
$files = Get-ChildItem -Path $fileFolder -Filter *.mp4
$totalFiles = $files.Count
$fileCounter = 0

foreach ($file in $files) {
    $fileCounter += 1
    Write-Host "Moving file: $($file.Name) - File $($fileCounter) of $($totalFiles)"
    Move-Item $file.FullName -Destination $destinationFolder
}

Write-Host "-------------------------------------------------------------"
Write-Host "Moving proxy files. . ."

$proxyFolder = "$destinationFolder\proxy"
New-Item -ItemType Directory -Path $proxyFolder -Force | Out-Null

$proxyFiles = Get-ChildItem -Path $fileFolder -Filter "*.$extensionProxy"
$fileCounter = 0

foreach ($file in $proxyFiles) {
    $fileCounter += 1
    Write-Host "Moving file: $($file.Name) - File $($fileCounter) of $($totalFiles)"
    $newName = $file.FullName -replace "\.$extensionProxy$", '.mp4'
    Rename-Item -Path $file.FullName -NewName $newName 
    Move-Item $newName -Destination $proxyFolder
}

$jpgFiles = Get-ChildItem -Path $fileFolder -Filter *.jpg
if ($jpgFiles.Count -gt 0) {
    Write-Host "-------------------------------------------------------------"
    Write-Host "Moving image files. . ."

    $photoFolder = "$destinationFolder\photos\jpeg"
    New-Item -ItemType Directory -Path $photoFolder -Force | Out-Null
  
    $totalFiles = $jpgFiles.Count
    $fileCounter = 0
  
    foreach ($file in $jpgFiles) {
        $fileCounter += 1
        Write-Host "Moving file: $($file.Name) - File $($fileCounter) of $($totalFiles)"
        Move-Item $file.FullName -Destination $photoFolder
    }  

    $dngFiles  = Get-ChildItem -Path $fileFolder -Filter *.dng
    if ($dngFiles.Count -gt 0) {
        Write-Host "-------------------------------------------------------------"
        Write-Host "Moving raw files. . ."

        $rawFolder = "$destinationFolder\photos\raw"
        New-Item -ItemType Directory -Path $rawFolder -Force | Out-Null
       
        $totalFiles = $dngFiles.Count
        $fileCounter = 0

        foreach ($file in $dngFiles) {
            $fileCounter += 1
            Write-Host "Moving file: $($file.Name) - File $($fileCounter) of $($totalFiles)"
            Move-Item $file.FullName -Destination $rawFolder
        }
    }
}

# Delete useless files
Remove-Item *.thm -Force -ErrorAction SilentlyContinue
Remove-Item *.srt -Force -ErrorAction SilentlyContinue

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

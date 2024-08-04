# Destination folder
$mainFolder = "E:\Filmagens"

$deviceDrone = "drone"
$fileFolderDrone = "\DCIM\DJI_001\"
$proxyDrone = "LRF"
$trashDrone = "SRT"

$deviceGoPro = "gopro"
$fileFolderGoPro = "\DCIM\100GOPRO\"
$proxyGopro = "LRV"
$trashGopro = "THM"

$date = Get-Date -Format "yyyy-MM-dd"
$startTime = Get-Date -Format "HH:mm:ss"
$totalFileSize = 0
$number = 0

$device = ""
$fileFolder = ""
$destinationFolder = ""
$folderName = ""
$extensionProxy = ""
$extensionTrash = ""

while ($true) {
    Write-Host "-------------------------------------------------------------"
    $number = Read-Host "Enter 1 for Drone and 0 for GoPro"
    Write-Host "-------------------------------------------------------------"
    if ($number -eq 1) {
        Write-Host "Drone"
        Write-Host "-------------------------------------------------------------"
        $name = Read-Host "Enter the name for the folder"
        Write-Host "-------------------------------------------------------------"

        $device = $deviceDrone
        $fileFolder = $fileFolderDrone
        $extensionProxy = $proxyDrone
        $folderName = "$date-$name"
        $destinationFolder = "$mainFolder\$device\$folderName"
        $extensionTrash = $trashDrone
        if (-not (Test-Path -Path $destinationFolder)) {
            New-Item -ItemType Directory -Path "$destinationFolder\music" | Out-Null
        }
        break 
    }
    elseif ($number -eq 0) {
        Write-Host "GoPro"
        Write-Host "-------------------------------------------------------------"
        Write-Host "8 ou 12"
        Write-Host "-------------------------------------------------------------"
        $model = Read-Host "Enter the model for the gopro"
        Write-Host "-------------------------------------------------------------"

        $device = $deviceGoPro
        $fileFolder = $fileFolderGoPro
        $extensionProxy = $proxyGopro
        $folderName = $date
        $destinationFolder = "$mainFolder\$device\$folderName\$model"
        $extensionTrash = $trashGopro

        if (-not (Test-Path -Path $destinationFolder)) {
            New-Item -ItemType Directory -Path "$destinationFolder" | Out-Null
        }
        
        $stabilizedFolder = "$destinationFolder\stabilized"
        if (-not (Test-Path -Path $stabilizedFolder)) {
            New-Item -ItemType Directory -Path "$stabilizedFolder" -Force | Out-Null
        }  

        break  
    }
    else {
        Write-Host "1 or 0"
    }
}


$renderFolder = "$destinationFolder\render"
if (-not (Test-Path -Path $renderFolder)) {
    New-Item -ItemType Directory -Path $renderFolder | Out-Null
}

# Sum folder size
Get-ChildItem -File -Recurse -Path $fileFolder -Force | ForEach-Object {
    $totalFileSize += $_.Length
}

$totalFileSizeGB = "{0:F2}" -f ($totalFileSize / 1GB)
Write-Host "Total size of files in the folder: $($totalFileSizeGB) GB"
Write-Host "-------------------------------------------------------------"

# Get list of .mp4 files in the source folder
$files = Get-ChildItem -Path $fileFolder -Filter *.mp4 -Force
if ($files.Count -gt 0) {
    Write-Host "Moving video files..."
    Write-Host "-------------------------------------------------------------"
    $totalFiles = $files.Count
    $fileCounter = 0

    foreach ($file in $files) {
        $fileCounter += 1
        Write-Host "Moving file: $($file.Name) - File $($fileCounter) of $($totalFiles)"
        Move-Item $file.FullName -Destination $destinationFolder
    }
    Write-Host "-------------------------------------------------------------"
}

# Move proxy files
$proxyFiles = Get-ChildItem -Path $fileFolder -Filter "*.$extensionProxy" -Force
if ($proxyFiles.Count -gt 0) {
    Write-Host "Moving proxy files..."
    Write-Host "-------------------------------------------------------------"
    $totalFiles = $proxyFiles.Count
    $fileCounter = 0

    $proxyFolder = Join-Path -Path $destinationFolder -ChildPath "proxy"
    New-Item -ItemType Directory -Path $proxyFolder -Force | Out-Null

    foreach ($file in $proxyFiles) {
        $fileCounter += 1
    
        $newFileName = $file.Name -replace "\.$extensionProxy", '.mp4'
        $newFilePath = Join-Path -Path $file.DirectoryName -ChildPath $newFileName
        
        Write-Host "Moving file: $($file.Name) - File $($fileCounter) of $($totalFiles)"
        Rename-Item -Path $file.FullName -NewName $newFileName
        Move-Item -Path $newFilePath -Destination $proxyFolder
    
        $movedFilePath = Join-Path -Path $proxyFolder -ChildPath $newFileName
        Set-ItemProperty -Path $movedFilePath -Name Attributes -Value ([System.IO.FileAttributes]::Normal)
    }
    Write-Host "-------------------------------------------------------------"
}


# Delete useless files
$trashFiles = Get-ChildItem -Path $fileFolder -Filter *.THM -Force
if ($trashFiles.Count -gt 0) {
    Write-Host "Removing trash files..."
    foreach ($file in $trashFiles) {
        Remove-Item $file.FullName -Force
    }
    Write-Host "-------------------------------------------------------------"
}

# Move Images
$jpgFiles = Get-ChildItem -Path $fileFolder -Filter *.jpg -Force
if ($jpgFiles.Count -gt 0) {
    Write-Host "Moving image files..."
    Write-Host "-------------------------------------------------------------"

    $photoFolder = "$destinationFolder\photos\jpeg"
    New-Item -ItemType Directory -Path $photoFolder -Force | Out-Null
  
    $totalFiles = $jpgFiles.Count
    $fileCounter = 0
  
    foreach ($file in $jpgFiles) {
        $fileCounter += 1
        Write-Host "Moving file: $($file.Name) - File $($fileCounter) of $($totalFiles)"
        Move-Item $file.FullName -Destination $photoFolder
    }   
    Write-Host "-------------------------------------------------------------"

    $dngFiles  = Get-ChildItem -Path $fileFolder -Filter *.dng -Force
    if ($dngFiles.Count -gt 0) {
        Write-Host "Moving raw files..."
        Write-Host "-------------------------------------------------------------"  

        $rawFolder = "$destinationFolder\photos\raw"
        New-Item -ItemType Directory -Path $rawFolder -Force | Out-Null
       
        $totalFiles = $dngFiles.Count
        $fileCounter = 0

        foreach  ($file in $dngFiles) {
            $fileCounter += 1
            Write-Host "Moving file: $($file.Name) - File $($fileCounter) of $($totalFiles)"
            Move-Item $file.FullName -Destination $rawFolder
        }
        Write-Host "-------------------------------------------------------------"
    }
}

# Calculate time difference
$endTime = Get-Date -Format "HH:mm:ss"
$duration = (Get-Date $endTime) - (Get-Date $startTime)

# Extract minutes and seconds from duration
$minutes = [math]::Floor($duration.TotalMinutes)
$seconds = $duration.Seconds

Write-Host "Folders created and files moved successfully!"
Write-Host " "
Write-Host "Elapsed time: $minutes minutes and $seconds seconds"
Write-Host "-------------------------------------------------------------"

$null = Read-Host

# Destination folder
$mainFolder = "E:\Filmagens"

$date = Get-Date -Format "yyyy-MM-dd"
$startTime = Get-Date -Format "HH:mm:ss"
$totalFileSize = 0
$number = 0

$deviceDrone = "drone"
$deviceGoPro = "gopro"
$device = ""
$destinationFolder = ""

while ($true) {
    Write-Host "-------------------------------------------------------------"
    $number = Read-Host "Enter 1 for Drone and 0 for GoPro"
    # Check if the entered number is 1
    if ($number -eq 1) {
        Write-Host "-------------------------------------------------------------"
        Write-Host "Drone"
        Write-Host "-------------------------------------------------------------"
        $name = Read-Host "Enter the name for the folder"
        Write-Host "-------------------------------------------------------------"

        $device = $deviceDrone
        $folderName = "$date-$name"
        $destinationFolder = "$mainFolder\$device\$folderName\audio"
       
        if (-not (Test-Path -Path $destinationFolder)) {
            New-Item -ItemType Directory -Path "$destinationFolder" | Out-Null
        }
        break 
    }
    # Check if the entered number is 2
    elseif ($number -eq 0) {
        Write-Host "-------------------------------------------------------------"
        Write-Host "GoPro"
        Write-Host "-------------------------------------------------------------"
      
        $device = $deviceGoPro
        $folderName = "$date"
        $destinationFolder = "$mainFolder\$device\$folderName\audio"
       
        if (-not (Test-Path -Path $destinationFolder)) {
            New-Item -ItemType Directory -Path "$destinationFolder" | Out-Null
        }
        break  
    }
    else {
        Write-Host "1 or 0"
    }
}

# Funcion for move .wav files and remove empty folders
function Move-WavFiles {
    param (
        [string]$currentFolder
    )
    
    $files = Get-ChildItem -Path $currentFolder -Filter *.wav
    $totalFiles = $files.Count
    $fileCounter = 0

    foreach ($file in $files) {
        $fileCounter += 1
        Write-Host "Moving file: $($file.Name) - File $($fileCounter) of $($totalFiles)"
        Move-Item $file.FullName -Destination $destinationFolder
    }
   
}

$folders = Get-ChildItem -Path "." -Directory
$totalFolders = $folders.Count
$folderCounter = 0


foreach ($folder in $folders) {
    $folderCounter += 1
    Write-Host " Folder $($folderCounter) of $($totalFolders)"
    Write-Host "-------------------------------------------------------------"
    Move-WavFiles -currentFolder $folder.FullName
    Remove-Item -Path $folder.FullName -Recurse -Force
    Write-Host "-------------------------------------------------------------"
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

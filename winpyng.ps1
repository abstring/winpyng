# PowerShell Script to Check Network Connectivity

# Function to perform speed test
function Perform-SpeedTest {
    # URL to a large file for testing download speed
    $url = "http://speedtest.tele2.net/1MB.zip" 
    $startTime = Get-Date

    # Download file
    try {
        Invoke-WebRequest -Uri $url -OutFile "$env:TEMP\speedtest.tmp" -ErrorAction Stop
        $endTime = Get-Date
        $totalTime = $endTime - $startTime
        $fileSize = (Get-Item "$env:TEMP\speedtest.tmp").Length / 1MB # Size in MB

        # Calculate download speed in Mbps
        $speedMbps = (($fileSize / $totalTime.TotalSeconds) * 8).ToString("F1")
        Remove-Item "$env:TEMP\speedtest.tmp" # Clean up
    } catch {
        $speedMbps = "Failed"
    }

    return $speedMbps
}

# Do a 1-time speed test
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$daystamp = Get-Date -Format "yyyy-MM-dd"
$speed = Perform-SpeedTest
        $speedLogEntry = "$timestamp Speed $speed Mbps"
        $speedLogEntry | Out-File "connectivity_log_$daystamp.txt" -Append
        Write-Host $speedLogEntry

# Infinite loop
while ($true) {
    # Get the current timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $daystamp = Get-Date -Format "yyyy-MM-dd"
    

    # Check connectivity
    try {
        $ping = Test-Connection -ComputerName "8.8.8.8" -Count 1 -ErrorAction Stop
        $status = "UP"
    } catch {
        $status = "DOWN"
    }


    # Perform speed test every 10 minutes
    if ((Get-Date).Minute % 10 -eq 0) {
        $speed = Perform-SpeedTest
        $speedLogEntry = "$timestamp Speed $speed Mbps"
        $speedLogEntry | Out-File "connectivity_log_$daystamp.txt" -Append
        Write-Host $speedLogEntry
        Start-Sleep -Seconds 60 # To avoid multiple tests within the same minute
    }

    # Log result
    "$timestamp $status" | Out-File "connectivity_log_$daystamp.txt" -Append

    # Show result on screen
    Write-Host "$timestamp $status"

    # Wait for 30 seconds
    Start-Sleep -Seconds 30
}

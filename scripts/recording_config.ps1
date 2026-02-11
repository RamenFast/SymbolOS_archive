# SymbolOS Recording Configuration Script
# Manages display settings for normal work vs recording mode
# Maintains proper scaling to avoid blurry text

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Normal", "Record", "Status")]
    [string]$Mode = "Status"
)

# Display Configurations

# Normal work resolution (current detected setup)
$NormalConfig = @{
    Primary = @{
        Width = 2560
        Height = 1440
        Name = "Primary (2560x1440 - native)"
    }
    Secondary = @{
        Width = 1080
        Height = 1920
        Name = "Secondary (1080x1920 - portrait)"
    }
}

# Recording resolution (maintains aspect ratio for sharp scaling)
$RecordConfig = @{
    Primary = @{
        Width = 1920
        Height = 1080
        Name = "Primary (1920x1080 - 16:9)"
        ScaleFactor = 0.75  # 75% of native (clean scaling)
    }
    Secondary = @{
        Width = 1080
        Height = 1920
        Name = "Secondary (1080x1920 - portrait, unchanged)"
        ScaleFactor = 1.0   # Keep native for portrait
    }
}

# FFmpeg Recording Settings

$FFmpegSettings = @{
    FPS = 30
    Codec = "libx264"
    Preset = "fast"        # fast encoding, good quality
    CRF = 23               # Constant Rate Factor (18=visually lossless, 23=high quality, 28=ok)
    PixelFormat = "yuv420p"
    AudioCodec = "aac"
    AudioBitrate = "128k"

    # Estimated file sizes per hour at 1920x1080
    EstimatedSize_CRF18 = "~8-12 GB/hour"
    EstimatedSize_CRF23 = "~3-5 GB/hour"
    EstimatedSize_CRF28 = "~1-2 GB/hour"
}

# Recommended recording resolution for disk space balance
$RecommendedRecording = @{
    Width = 1920
    Height = 1080
    FPS = 30
    Quality = "CRF 23"
    ExpectedSize = "3-5 GB/hour"
    Notes = "1080p at 30fps with CRF 23 - excellent quality, reasonable size"
}

# Alternative for smaller files
$AlternativeRecording = @{
    Width = 1280
    Height = 720
    FPS = 30
    Quality = "CRF 23"
    ExpectedSize = "1-2 GB/hour"
    Notes = "720p at 30fps with CRF 23 - good quality, smaller files"
}

# Functions

function Show-Status {
    Write-Host "`n=====================================================" -ForegroundColor Cyan
    Write-Host "     SymbolOS Recording Configuration Status" -ForegroundColor Cyan
    Write-Host "=====================================================" -ForegroundColor Cyan

    Write-Host "`nDISPLAY MODES:" -ForegroundColor Yellow
    Write-Host "-----------------------------------------------------"

    Write-Host "`nNormal Work Mode:" -ForegroundColor Green
    Write-Host "  Primary:   $($NormalConfig.Primary.Width)x$($NormalConfig.Primary.Height) (native - crisp text)"
    Write-Host "  Secondary: $($NormalConfig.Secondary.Width)x$($NormalConfig.Secondary.Height) (portrait)"

    Write-Host "`nRecording Mode:" -ForegroundColor Yellow
    Write-Host "  Primary:   $($RecordConfig.Primary.Width)x$($RecordConfig.Primary.Height) (75`% scale - crisp)"
    Write-Host "  Secondary: $($RecordConfig.Secondary.Width)x$($RecordConfig.Secondary.Height) (portrait, unchanged)"
    Write-Host "  Note: Windows will handle scaling cleanly (75`% = 3/4 native)"

    Write-Host "`nFFMPEG SETTINGS (30fps):" -ForegroundColor Yellow
    Write-Host "-----------------------------------------------------"

    Write-Host "`nRecommended (1920x1080 at 30fps):" -ForegroundColor Green
    Write-Host "  Quality: CRF $($FFmpegSettings.CRF) (high quality)"
    Write-Host "  Size:    $($RecommendedRecording.ExpectedSize)"
    Write-Host "  Codec:   $($FFmpegSettings.Codec) ($($FFmpegSettings.Preset) preset)"
    Write-Host "  Audio:   $($FFmpegSettings.AudioCodec) at $($FFmpegSettings.AudioBitrate)"

    Write-Host "`nAlternative (1280x720 at 30fps):" -ForegroundColor Cyan
    Write-Host "  Quality: CRF $($FFmpegSettings.CRF) (high quality)"
    Write-Host "  Size:    $($AlternativeRecording.ExpectedSize)"
    Write-Host "  Note:    Use for longer recordings or limited disk space"

    Write-Host "`nCURRENT DISPLAY STATUS:" -ForegroundColor Yellow
    Write-Host "-----------------------------------------------------"

    Add-Type -AssemblyName System.Windows.Forms
    $screens = [System.Windows.Forms.Screen]::AllScreens
    foreach ($screen in $screens) {
        $type = if ($screen.Primary) { "Primary" } else { "Secondary" }
        Write-Host "  $type : $($screen.Bounds.Width)x$($screen.Bounds.Height)" -ForegroundColor $(if ($screen.Primary) { "Green" } else { "Cyan" })
    }

    Write-Host "`nUSAGE:" -ForegroundColor Yellow
    Write-Host "-----------------------------------------------------"
    Write-Host "  Switch to normal:    .\recording_config.ps1 -Mode Normal"
    Write-Host "  Switch to recording: .\recording_config.ps1 -Mode Record"
    Write-Host "  Check status:        .\recording_config.ps1 -Mode Status"
    Write-Host "`n  Note: Resolution changes require Windows Display Settings"
    Write-Host "        This script documents the configs and opens settings."
    Write-Host ""
}

function Set-RecordingMode {
    Write-Host "`nSwitching to Recording Mode..." -ForegroundColor Yellow
    Write-Host "  Target: $($RecordConfig.Primary.Width)x$($RecordConfig.Primary.Height) at 30fps"
    Write-Host "  Opening Windows Display Settings..."
    Write-Host "`n  Manual steps:"
    Write-Host "    1. Select Primary monitor"
    Write-Host "    2. Change resolution to 1920x1080"
    Write-Host "    3. Keep Secondary at 1080x1920 (portrait)"
    Write-Host "    4. Apply changes"
    Write-Host ""

    Start-Process ms-settings:display

    Write-Host "`nFFmpeg Recording Options:" -ForegroundColor Cyan
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $outputFile = "recording_$timestamp.mp4"
    
    Write-Host "`nOPTION 1: Primary Monitor Only (1920x1080) - RECOMMENDED" -ForegroundColor Green
    Write-Host "ffmpeg -f gdigrab -framerate 30 -offset_x 0 -offset_y 0 -video_size 1920x1080 -i desktop -c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p $outputFile" -ForegroundColor Yellow
    Write-Host "  Output: Clean 1920x1080 video (3-5 GB/hour)"
    
    Write-Host "`nOPTION 2: Both Monitors (3640x1920) - Large File" -ForegroundColor Yellow
    Write-Host "ffmpeg -f gdigrab -framerate 30 -i desktop -c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p $outputFile" -ForegroundColor Yellow
    Write-Host "  Output: Ultra-wide 3640x1920 video (15-20 GB/hour)"
    
    Write-Host "`nOPTION 3: With Webcam Overlay (Picture-in-Picture)" -ForegroundColor Cyan
    Write-Host "# List webcam devices first:"
    Write-Host "ffmpeg -list_devices true -f dshow -i dummy" -ForegroundColor Gray
    Write-Host "# Then record with overlay (replace 'USB Video Device' with your webcam name):"
    Write-Host "ffmpeg -f gdigrab -framerate 30 -offset_x 0 -offset_y 0 -video_size 1920x1080 -i desktop -f dshow -i video=`"USB Video Device`" -filter_complex `"[1:v]scale=320:240[webcam];[0:v][webcam]overlay=W-w-20:20`" -c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p $outputFile" -ForegroundColor Yellow
    Write-Host "  Output: 1920x1080 with webcam in top-right corner (320x240)"

    Start-Process ms-settings:display
}

# Main Execution

switch ($Mode) {
    "Normal" {
        Set-NormalMode
    }
    "Record" {
        Set-RecordingMode
    }
    "Status" {
        Show-Status
    }
}

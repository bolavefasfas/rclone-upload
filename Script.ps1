# Make rclone config url using gist make a remote named "remote:"
# This script asumes you have rclone installed in your windows using "https://github.com/rclone/rclone/wiki/Install-rclone-via-powershell-script" or isntalled manually and rclone is added to path 


Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Create a temporary file for the rclone config
$tempFile = [System.IO.Path]::GetTempFileName()

# Download and save the rclone config to the temporary file
Invoke-WebRequest -Uri "rclone.conf url" -OutFile $tempFile

# Set the RCLONE_CONFIG environment variable to point to the temporary config file
$env:RCLONE_CONFIG = $tempFile

# Add assemblies for creating custom dialog
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Create custom dialog window
$Window = New-Object System.Windows.Window -Property @{
    Title = "Rclone Upload"
    SizeToContent = "WidthAndHeight"
    ResizeMode = "NoResize"
    WindowStartupLocation = "CenterScreen"
}

# Add event handler for window close event
#$Window.Add_Closing({
#	Stop-Process -Id $pid
#   #Exit
#})

# Create StackPanel for organizing buttons and text
$StackPanel = New-Object System.Windows.Controls.StackPanel
$StackPanel.Orientation = [System.Windows.Controls.Orientation]::Vertical

# Create TextBlock for the description
$DescriptionText = New-Object System.Windows.Controls.TextBlock
$DescriptionText.Text = "Select what you want to upload:"
$DescriptionText.FontSize = 14
$DescriptionText.Margin = "10 10 10 10"

# Create StackPanel for organizing buttons horizontally
$ButtonStackPanel = New-Object System.Windows.Controls.StackPanel
$ButtonStackPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
$ButtonStackPanel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center

# Create Folder button
$FolderButton = New-Object System.Windows.Controls.Button -Property @{
    Content = "Folder"
    Width = 75
    Height = 25
    Margin = "5"
}
$FolderButton.Add_Click({$Window.DialogResult = $true; $Window.Tag = "Folder"; $Window.Close()})

# Create File button
$FileButton = New-Object System.Windows.Controls.Button -Property @{
    Content = "File"
    Width = 75
    Height = 25
    Margin = "5"
}
$FileButton.Add_Click({$Window.DialogResult = $true; $Window.Tag = "File"; $Window.Close()})

# Add buttons to ButtonStackPanel
$ButtonStackPanel.Children.Add($FolderButton)
$ButtonStackPanel.Children.Add($FileButton)

# Add description and ButtonStackPanel to StackPanel
$StackPanel.Children.Add($DescriptionText)
$StackPanel.Children.Add($ButtonStackPanel)

# Add StackPanel to Window
$Window.Content = $StackPanel

# Show dialog and get result
if ($Window.ShowDialog()) {
    $uploadType = $Window.Tag

    # Ask the user to select the file or folder to upload
    # Rest of the code...
}


# Ask the user to select the file or folder to upload
Add-Type -AssemblyName System.Windows.Forms
$dialog = $null
$path = $null

if ($uploadType -eq "Folder") {
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq "OK") {
        $path = $dialog.SelectedPath
    }
} else {
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.InitialDirectory = $env:USERPROFILE
    $dialog.Multiselect = $false
    if ($dialog.ShowDialog() -eq "OK") {
        $path = $dialog.FileName
    }
}

if ($path) {
    # Get the name of the local file or folder
	$name = Split-Path $path -Leaf
	
    if ($uploadType -eq "Folder") {
        # Upload the folder to rclone
        rclone copy "$path" "remote:rdp/$name" -vPP --ignore-existing
    } else {
        # Upload the file to rclone
        rclone copy "$path" "remote:rdp/" -vPP --ignore-existing
    }

    # Get the size of the local file or folder
    $localSize = rclone size $path --json | ConvertFrom-Json | Select-Object -Expand bytes

    

	#rclone size "remote:rdp/$name"
	#rclone size "$path"
	#rclone ls "remote:rdp"
	#Write-Host "name=$name" 
	#Write-Host "path=$path"
	
	# Extra Info For Nerds
	Write-Host "Tree Structure of if its a Folder only files not available"
    rclone tree "remote:rdp/$name" 

	#Write-Host "Tree Structure of root directory"
    #rclone tree "remote:rdp/" 


    # Get the size of the remote file or folder
    $remoteSize = rclone size "remote:rdp/$name" --json | ConvertFrom-Json | Select-Object -Expand bytes

    # Compare the sizes
    $sizeRatio = $remoteSize / $localSize * 100
    if ($sizeRatio -ge 100) {
        [System.Windows.MessageBox]::Show("Upload of all files completed `nTotal size of files/folder uploaded to cloud = $remoteSize bytes `nLocal Folder/File size = $localSize bytes", "Upload Status", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
    } elseif ($sizeRatio -ge 60) {
        [System.Windows.MessageBox]::Show("Some files skipped `nTotal size of files/folder uploaded to cloud = $remoteSize bytes `nLocal File/Folder size = $localSize bytes ", "Upload Status", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
    } else {
        [System.Windows.MessageBox]::Show("Something is wrong, please check logs `nTotal size of files/folder uploaded to cloud = $remoteSize bytes `nLocal File/Folder size = $localSize bytes ", "Upload Status", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }

    # Delete the temporary rclone config file
    Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
} else {
    Write-Host "No file or folder selected. Exiting..."

    # Delete the temporary rclone config file
    Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
    exit
}

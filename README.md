## What does the scipt do 
This script is a PowerShell script that creates a graphical user interface (GUI) for uploading files or folders to a remote server using rclone. It uses the Windows Forms assembly to create a dialog box that allows the user to select a file or folder to upload, and then uses rclone to upload the selected file or folder to a remote server. The script also includes code to compare the size of the uploaded file or folder with the size of the local file or folder, and displays a message box with the upload status.


This PowerShell script asumes you to create an rclone configuration file using a rclone terminal and sets up a remote named "remote:". 
It assumes that you already have rclone installed on your Windows machine using the 1st Prerequisite or manually.

## Prerequisites
1. Install rclone following the instructions from the official repository: https://github.com/rclone/rclone/wiki/Install-rclone-via-powershell-script

## Usage
1. Copy and paste this entire script into a new .ps1 file, e.g., Script.ps1.
Replace "https://gist.githubusercontent.com/yourusername/yourgistid/raw/rclone.conf" with the raw URL of your own encrypted rclone configuration stored in a private GitHub Gist. Google if your stuck on this step.
2. This script is used to upload files/folders to encrypted rclone remote mostly works with unencrypted also. 
3. Save the .ps1 file and run it by right-clicking the file and selecting 'Run with Powershell'. Alternatively, open PowerShell and navigate to the location where the .ps1 file is saved and execute .\Script.ps1
Follow the prompts within the graphical interface to complete the setup process. The script will ask you whether you would like to upload a file or a folder, then prompt you to select the specific item(s) to upload. Afterward, it will display information about the transfer progress and final status.

## This is in testing phase so report bugs or what features you want added.
1. Some things dont work like X Button 
2. And how to make the gui more asthetic like rounded corners and all.

let me know if anyone knows how to fix it and  

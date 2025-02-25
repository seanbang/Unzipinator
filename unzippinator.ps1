$shell = new-object -com shell.application
$wshell = New-Object -ComObject Wscript.Shell

$CurrentLocation=get-location
$CurrentPath=$CurrentLocation.path

# Find all the Zip files and Count them
$ZipFiles = @(get-childitem *.zip)
# write-host Number of .ZIP files - $ZipFiles.count
if ( $ZipFiles.count -eq 0 )
{
     
     $wshell.Popup("No .ZIP files found.  Exiting.",0,"Unzippinator")
     Exit
     
}

# For every zip file in the folder
foreach ($ZipFile in $ZipFiles)
{

    # Get the full path to the zip file
    write-host $ZipFile.fullname processing...

    # Set the location - Edit the line below to change the location to save files to
    $NewLocation = $CurrentPath + '\' + $ZipFile.BaseName
    
    # See if new path already exists and create it if it doesn't then move file and unzip
    if ( ! (test-path -path $NewLocation -pathType container)) {
    
        # Create a new folder to unzip the files into
        New-Item $NewLocation -type Directory | out-null

        # Move the zip file to the new folder so that you know which was the original file (can be changed to Copy-Item if needed)
        Move-Item $ZipFile.fullname $NewLocation | out-null

        # List up all of the zip files in the new folder 
        $NewZipFile = get-childitem $NewLocation *.zip

        # Get the COMObjects required for the unzip process
        $NewLocation = $shell.namespace($NewLocation)
        $ZipFolder = $shell.namespace($NewZipFile.fullname)

        # Copy the files to the new Folder
        # $NewLocation.copyhere($ZipFolder.items(), 0x04)
        foreach ($item in $ZipFolder.Items()) {
            if ($item.Name -like '*.pes') {
                $NewLocation.copyhere($item)
            }
            elseif ($item.Name -like '*.pdf') {
                $NewLocation.copyhere($item)
            }
            else {
                Write-Host No valid files found in zip file.
                Write-Host
            }
        }

		# Notify unzip was successful
		write-host $ZipFile.fullname unzipped successfully!
		write-host
    
    }
	
	else
	
	{
	
		# Notify unzip was unsuccessful
		write-host $NewLocation already exists! Not unzippinating.
		write-host
		
	}
    
}

# Notify unzip is complete
$wshell.Popup("Unzip complete.  Love ya!",0,"Unzippinator")
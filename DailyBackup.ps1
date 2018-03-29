<# This script will do:
    - Daily backups of *.bak files form a shared folder on Server01 (Source) to a Storage (Destination).
    - Also, ones the files are copied to the destination folder will check if they were copied successfully  
      and then will delete the files from Server01
#>

Param(
    [string] $source =  "\\Server01\Server01MSSQLBACKUP\Backup",
    [string] $destination = "\\Storage01\Backup-SQL\Server01")

Begin{}

Process{

function seekAndDestroy  {
	Param($folder)

	$listBAKFiles = Get-ChildItem -Path $source\$folder -filter *.bak 
		foreach ($f in $listBAKFiles){
			if (Test-Path $destination\$folder\$f)
				{
					Write-Host "El archivo esta en destination: $f	"
					Write-Host "The file can be deletedRemove command here"
					Remove-Item $source\$folder\$f
				}		
		}
	}

function backup {
    Param(
        [string] $source,
        [string] $destination)

    Process {
        Import-Module BitsTransfer
        $folders = Get-ChildItem $source | ?{ $_.PSIsContainer } 
    
        foreach ($f in $folders){
			
            If(!(test-path $destination\$f)) 
                    { New-Item -ItemType Directory -Force -Path $destination\$f}
            
			Copy-Item -Path $source\$f\*.bak -Destination $destination\$f -Force
			<#Process bit-transfer
            Start-BitsTransfer -Source $source\$f\*.bak -Destination $destination\$f -Description "Bakcup, copying the folder: $f " -DisplayName "KMAU3";    
            while (($Job.JobState -eq "Transferring") -or ($Job.JobState -eq "Connecting"))
                { sleep 5;} # Poll for status, sleep for 5 seconds, or perform an action. #>
            
			#Function to check if the files were moved -Seek, if does ... it deletes the files from the source -Destroy 
			seekAndDestroy $f 
        }                  
    }
}#End backup function

backup $source $destination

}

End{}

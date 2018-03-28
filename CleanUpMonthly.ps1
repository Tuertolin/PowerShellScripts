<# Descrpition: This script will keep one backup file per month into the source subfolders:
$sourceServer1 = "\\Server1\Backup-SQL\SQL-01"
$sourceServer2 = "\\Server2\Backup-SQL\SQL-02"
#>

#####   Main process   #####
Begin {
    Clear-Host
    Import-Module BitsTransfer
    if ((get-date).month -ne 1)
        {$month = ((get-date).month) - 1}
    else 
        {$month = 12}     
}

Process {
##  @@ MAIN Function @@ 
function mainF{
 
 Param ([string]$source)

 $folders = Get-ChildItem $source -Recurse | ?{ $_.PSIsContainer } 
 foreach ($f in $folders){
    for ($i=1; $i -le $month; $i++){
            $list = Get-ChildItem -Path $source\$f | ? { $_.LastWriteTime.Month -eq $i}
                if($list -is [system.array]){
                    $late = select-latest $list
                    Write-Host "   .... The latest file from the month $i is $late "
                    #$subfolder = New-Item -Name $f -ItemType directory -Path $destination -Force
                    delete-butLastone $list $late
                    }
            }
    }
}

## FUNCTIONS ##
function select-latest{  #Receives a list of BKPs files, and select the latest ones.

    Param ($lis)
    Process{
         $latest =  $lis | Sort-Object LastAccessTime -Descending | Select-Object -First 1
         return $latest
     }
}

#Receives a list of files per month, and the lastone from this month.
#It deletes all the files from that month but the lastone
function delete-butLastone{

    Param ($lis,$lastOne)
    Process{
        
        foreach ($l in $lis){
            if ($l -ne $lastOne) 
                { 
                    Write-Host "This file will be delete $l "
                    Remove-Item $source\$f\$l
                }
              } 
            }
    }#End delete-butLastone

$sourceServer1 = "\\Server1\Backup-SQL\SQL-01"
$sourceServer2 = "\\Server2\Backup-SQL\SQL-02"

mainF $sourceServer1
mainF $sourceServer2

}

End {}

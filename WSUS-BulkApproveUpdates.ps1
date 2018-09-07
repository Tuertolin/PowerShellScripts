<# Script to approve updates on Windows Server Update Services 
You need to create a TXT file with all the KB's to be arppoved and,
then you need to choose the group name to be approved for install.
#>
[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")   

$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer('WSUS-ServerName',$False,8530)

#Import list of KBs, find the updates and assign them to $approved, this takes a few minutes
# The updates.txt has the KB number, 1 per line
#$updates = cat "C:\WorkstationUpdates.txt"
$updates = cat "C:\ServerUpdates.txt"

#Get WSUS computer group
#$group = $wsus.GetComputerTargetGroups() | where {$_.Name -eq 'ComputerGroupName-SERVERS'}

$group = $wsus.GetComputerTargetGroups() | where {$_.Name -ne 'ComputerGroupName-SERVERS' -and $_.Name -ne 'All Computers' }

#Scan through list of KBs
 foreach ($u in $updates){
        #Search for update
        $toUpdate = $wsus.searchupdates($u)
        if(!$toUpdate){
            #do nothing if update not found
            Write-Host "$_ not found"
        }
        else{
             foreach ($g in $group){   
                $toUpdate.Approve("Install",$g)
                }
        }
    }

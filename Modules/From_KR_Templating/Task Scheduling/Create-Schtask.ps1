# Helper for task sheduling 
function Create-SCHTask {
    # Creating Task based on an XML File
    [CmdletBinding()]
    param (
        # Task Name 
        [Parameter(Mandatory = $true)]
        [ParameterType]
        $TaskName,

        # Who Is the Author
        [Parameter(Mandatory = $false)]
        [ParameterType]
        $Auther = 'Kristian',

        # Script To Run Location 
        [Parameter(Mandatory = $true)]
        [ParameterType]
        $ScriptToRun
    )
    
    begin {
        #Init Variables
        $lookupTable = @{
            '{{Author}}'             = "$Auther"
            '{{PowershellTaskName}}' = "$TaskName"
            '{{ScriptToRun}}'        = "$ScriptToRun"
            '{{UserId}}'             = "$env:USERDOMAIN\$env:USERNAME"
        }

        # Check if there is another task named that 
        if ([bool](Get-ScheduledTask -TaskName "$TaskName")) {
            Throw("Error a task with that name allready exist")
        }
    }
    
    Process {

        $PowerShellTaskScheduling = (Get-Content -Path "$Templates\Task-Scheduling-Templates\Task-Scheduling-template.xml" -Raw) | ForEach-Object {
            $line = $_
            $lookupTable.GetEnumerator() | ForEach-Object {
                if ($line -match $_.Key) {
                    $line = $line -replace $_.name, $_.Value
                }
            }
            $line
        }      
    }
    
    End {
        Register-ScheduledTask -Xml $PowerShellTaskScheduling -TaskName "$TaskName"
        
    }
}
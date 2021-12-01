Function Test-CloudFlare {
#

<#
.SYNOPSIS
Conducting a ping test on a remote computer.
.DESCRIPTION
User is told to give a computer name or address to create a remote session. 
The remote session is then created and used to ping the address 'one.one.one.one.'
The file will then be exported as a text file in the 'C:\powershell test' folder.
.PARAMETER Computername
A mandatory parameter to identify the computer used for the script.
.PARAMETER Output
Host is the default output but can also be output as Text and CSV. 
.Example
PS C:\powershell test> .\Test-CloudFlare -Computername 192.168.0.207 -Output Host 
This will output to display on screen
.Example
PS C:\powershell test> .\Test-CloudFlare -Computername 192.168.0.207 -Output Text
This will output to a text file
.Example
PS C:\powershell test> .\Test-CloudFlare -Computername 192.168.0.207 -Output CSV
This will output to a CSV file
.NOTES 
Author: Sean Paternoster
Last Edit: 2021-10-22
Version 1.0 - Initial Release of Test-CloudFlare
#>
[CmdletBinding()]
#Enables Cmdlet Binding

param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [Alias('CN', 'Name')][string]$Computername,
    [Parameter(Mandatory=$false)][string]$location = $env:USERPROFILE,
    [ValidateSet('Host','Text','CSV')]
    [string]$Output = 'Host'
) #Parameter
#Valid options for output with the default being Host. 

ForEach ($Computer in $ComputerName) {
    Try {
        $Params = @{
            'ComputerName' = $Computer
            'ErrorAction' = 'Stop'
        } #Try Parameters
    $RemoteSession = New-PSSession @Params
    #variable that makes a new remote session to the computer name.
    Enter-PSSession $RemoteSession
    #Enter remote session
    $DateTime = Get-Date
    #Gets the current date and time to save to a DateTime variable.
    $TestCF = Test-NetConnection -ComputerName 'One.One.One.One' -InformationLevel Detailed
    #Variable that runs a detailed ping test to 1.1.1.1
    $OBJ =[PSCustomObject]@{
        'ComputerName' = $Computername
        'PingSuccess' = $TestCF.PingSucceeded
        'NameResolve' = $TestCF.NameResolutionSucceeded
        'ResolvedAddresses' = $TestCF.ResolvedAddresses
    } #Custom PSObject props
    #Creates a variable that contains ComputerName and results of the ping test
    Exit-PSSession
    Remove-PSSession $RemoteSession
    #Creates a new object named $Props. Exits the remote session and removes it.
    }#Try
    Catch{ 
        Write-Host "Remote Connection for $Computer failed" -ForeGroundColor Red
    }#Catch
} #ForEach


switch ($Output) {
    'Host' { Write-Verbose "Generating Results"
            $OBJ}
    'Text' {Write-Verbose "Generating Results as txt file"
        $OBJ | Out-File '.\TestResults.txt'
        Add-Content '.\RemTestNest.txt' -value "Computer Tested: $Computername"
        Add-Content '.\RemTestNest.txt' -value "Date Tested: $DateTime"
        Add-Content '.\RemTestNest.txt' -value (Get-Content -Path '.\TestResults.txt')
        #Adds content to RemTestNet text file to include the computer's name, date the test was ran and contents of TestResults.txt. 
        Receive-Job -Name 'JobResults' | Out-File 'JobResults.txt'
        Write-Verbose "Opening Results"
        notepad.exe 'RemNetTest.txt'}
        #Opens RemTestNet on Notepad
    'CSV' {Write-Verbose "Generating Results as CSV file"
        $OBJ | Export-CSV '.\TestResults.csv'}
    default { Write-Output "$Output parameter you entered is not a valid parameter entry"}
}#Switch

} #Function 
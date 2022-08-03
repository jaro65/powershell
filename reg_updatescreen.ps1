
# ------------------------------------------------------------------------
# NAME: reg_updatescreen.ps1
# AUTHOR: Jaronas Flucher, BitHawk AG
# DATE: 2022-06-24
# 
# VERSION: 1.0 - Initial Versions
#
# KEYWORDS: updatescreen,
#
# COMMENTS:This Script will set a registry key to stop showing the 
# Windows update screen
# ------------------------------------------------------------------------

#----- Set Variables -----#
$LogFilePath = "C:\temp\sccm\log\"
$LogFile = $LogFilePath + "reg_updatescreen" + $(Get-Date -Format 'dd_MM_yyyy HH_mm') + ".txt"
$username = 'dsplayer'


#----- Event types -----#
Add-Type -TypeDefinition @"
   public enum ErrorLevel {
      INF,
      SUC,     
      WAR,
      ERR
   }
"@

#----- main-function -----#
function main {
    writeLog INF ("start main function")
    checkpath $LogFilePath
    get-usersid $username
    set-reg
    get-result
    writeLog INF ("end main function")
}

#----- get-usersid  -----#
function get-usersid ($username)
{
    try
    {$script:usersid= (New-Object System.Security.Principal.NTAccount($username)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    writeLog SUC ('Get SID from User: {0}' -f $username)}
    catch{
        writeLog ERR ('Get SID from User: {0} with Error; {1}' -f $username, $error[0])
    }
}

#----- set-reg -----#
function set-reg
{
    try
    {reg add ('HKEY_USERS\{0}\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -f $script:usersid) /v SubscribedContent-310093Enabled /t REG_DWORD /d 00000000 /f
    writeLog SUC ('set reg key')}
    catch{
        writeLog ERR ('set reg key Error: {0}' -f $Error[0])
    }
}


#----- Function checkpath -----#
function checkpath ($foldertocheck)
{
    if (Test-Path $foldertocheck )
    {
        writeLog INF ('Path: {0} already exsist' -f $foldertocheck)
    }
    Else
    {
        try{
        New-Item -ItemType Directory -Force -Path $foldertocheck
        writeLog SUC ('Created Path {0}' -f $foldertocheck)
    }
    catch{
        writeLog ERR ('Failed to create Folder: {0} with Error: {1}' -f $foldertocheck, $error[0])
    }
    }
}

#----- Function writeLog -----#
function writeLog([ErrorLevel]$Status, $Message) {    
    $Delimiter = " - "
    $TimeFix = Get-Date -F G
	$TimeFix + $Delimiter + $Status + $Delimiter + $Message + "`n" | Out-File $LogFile -Append
}

#----- Function clearScriptLogFiles -----#
function clearScriptLogFiles {
    writeLog INF ("clear obsolete script log files")
    $DateToDelete = (Get-Date).AddDays(-7)
	Get-ChildItem $LogFilePath | Where-Object {$_.LastWriteTime -lt $DateToDelete} | Remove-Item
}

#----- Function writeOutput -----#
function writeOutput($PermissionEntires, $FilePath) {
    if (Test-Path $FilePath) { Remove-Item $FilePath }
    $PermissionEntires | Export-Csv -Path $FilePath -NoTypeInformation -Encoding UTF8
}

function get-result{
    $path = (('registry::HKEY_USERS\{0}\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -f $script:usersid))
    try {
        $result = Get-ItemPropertyValue -Path $path -Name 'SubscribedContent-310093Enabled'
        writeLog INF ('reg: {0} is set to value: {1} ' -f $path, $result)
    }
    catch {
        writeLog ERR ('{0}' -f $error[0])
        Exit 2

    }
    writeLog INF ('value is: {0}' -f $result)
    if ($result -eq 0)
    {
        writeLog SUC ('Kontrolle erfolgreich')
        Exit 0
    }
    else {
        writeLog ERR ('REG KEY is availabe, but with wrong Value')
        EXIT 13
    }

    }

#----- Entry Point -----#
main



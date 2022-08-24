# ------------------------------------------------------------------------
# NAME: Kontrolle.ps1
# AUTHOR: Lukas Vogel & Jaronas Flucher, BitHawk AG
# DATE: 2022-04-25
# 
# VERSION: 1.0 - Initial Version
#
# KEYWORDS: schnuppi
#
# COMMENTS: This script will wirte...
# 
# ------------------------------------------------------------------------

#----- For test purposes -----#
# Clear-Host

#----- Set Log File -----#
$LogFilePath = "C:\temp\test1\tes1\2\3"
$LogFile = $LogFilePath + "xxx" + $(Get-Date -Format 'dd_MM_yyyy HH_mm') + ".txt"
$File = "C:\temp\test.csv"



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
    
    writeLog INF ("end main function")
}


function example {
    try 
    { 
        $z1 = 1
        $z2 = 0
        $z1 = $z1/$z2
    }
    catch
    {
        write-host $_.Exception.Message -ForegroundColor Red
        Write-Host $_.ScriptStackTrace #For Debug to find Errors at which line
        writelog ERR ('Failed with Error {0}' -f $Error[0])

        

    }
}

function save-secret ($pwplaintext){
    ConvertTo-SecureString $pwplaintext -AsPlainText -Force | ConvertFrom-SecureString | out-file $Pathcred
}

function read-secret{
    $script:secret read-host "please enter Password" -AsSecureString
}

#----- Function checkfile -----#
function checkfile ($filetocheck)
{
    if (Test-Path $filetocheck -PathType leaf )
    {
        writeLog INF ('File: {0} already exsist' -f $filetocheck)      
    }
    Else
    {
        writeLog INF ('File: {0} dont exsist' -f $filetocheck)
        try{
        New-Item -ItemType File -Force -Path $filetocheck
        writeLog SUC ('Created File {0}' -f $filetocheck)
    }
    catch{
        writeLog ERR ('Failed to create File: {0} with Error: {1}' -f $filetocheck, $error[0])
    }
    }
}

#----- Function checkpath -----#
function checkpath ($foldertocheck)
{
    if (Test-Path $foldertocheck )
    {
        writeLog INF ('Path: {0} already exsist' -f $foldertocheck)
        write-host ('Path: {0} already exsist' -f $foldertocheck) -ForegroundColor Green
    }
    Else
    {
        
        write-hoste ('Path: {0} dont exist' -f $foldertocheck) -ForegroundColor Gray 
        try{
        New-Item -ItemType Directory -Force -Path $foldertocheck
        writeLog SUC ('Created Path {0}' -f $foldertocheck)
        write-host ('Created Path {0}' -f $foldertocheck) -ForegroundColor Green
    }
    catch{
        writeLog ERR ('Failed to create Folder: {0} with Error: {1}' -f $foldertocheck, $error[0])
    }
    }
#----- Function checkfile-createfolder -----#
function checkfile-createfolder ($filetocheck)
{
    if (Test-Path $filetocheck -PathType leaf )
    {
        writeLog INF ('File: {0} already exsist' -f $filetocheck)      
    }
    Else
    {
        writeLog INF ('File: {0} dont exsist' -f $filetocheck)
        try{
        $Path = [System.IO.Path]::getdirectoryname($filetocheck)
        New-Item -ItemType Directory -Force -Path $Path
        writeLog SUC ('Created Folder {0}' -f $Path)
    }
    catch{
        writeLog ERR ('Failed to create File: {0} with Error: {1}' -f $filetocheck, $error[0])
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

#----- Function writeToFile -----#
function writeToFile($description, $vaule, $correct) {    
    $Delimiter = ";"
    
	$description + $Delimiter + $value + $correct +"`n" | Out-File $File -Append

}

#----- Entry Point -----#
main




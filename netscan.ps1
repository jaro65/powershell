#----- Variables-----#
<#
$ipstart = '192.168.1.1'
$ipend = 192.168.1.254

$port = '80'
#>
function testip {
    param (
        $ipstart,
        $ipend
    )
    $ipstart = ($ipstart -split '\.').Trim()
    $ipend = ($ipend -split '\.').Trim()

    $array= @($ipstart[3]..$ipend[3])
#Write-Host $array
    foreach ($i in $array)
    {
        $iptotest = $ipstart[0]+'.'+$ipstart[1]+'.'+$ipstart[2]+'.'+$i
        
        Test-NetConnection $iptotest
    }

}


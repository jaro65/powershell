#----- Variables-----#
<#
$ipstart = '192.168.1.1'
$ipend = 192.168.1.254

$port = '80'
#>
$path = 'C:\temp\del\net2.csv'
function testips {
    param (
        $ipstart,
        $ipend
    )
    $ipstart = ($ipstart -split '\.').Trim()
    $ipend = ($ipend -split '\.').Trim()

    $array= @($ipstart[3]..$ipend[3])

    foreach ($i in $array)
    {
        $iptotest = $ipstart[0]+'.'+$ipstart[1]+'.'+$ipstart[2]+'.'+$i
        
        #More Details
        #Test-NetConnection $iptotest | export-csv -Append -Path $path
        Test-NetConnection $iptotest | select remoteAddress, pingsucceeded | export-csv -Append -Path $path
    }

}


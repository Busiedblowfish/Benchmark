#Get the benchmark files for the appropriate windows product version
cls

$getOSversion = (Get-CimInstance Win32_OperatingSystem).Caption

#Initialize the variables to null
[xml]$oval = $null
[xml]$xccdf = $null

switch -Regex ($getOSversion.ToLower())
{
    "w(indows xp)"
    {
        [xml]$oval =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_XP_Benchmark_v3.1.0-oval.xml
        [xml]$xccdf =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_XP_Benchmark_v3.1.0-xccdf.xml
    }

    "w(indows 7)"
    {
        [xml]$oval =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_7_Benchmark_v2.1.0-oval.xml
        [xml]$xccdf =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_7_Benchmark_v2.1.0-xccdf.xml
    }

    "w(indows 8)"
    {
        [xml]$oval =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_8_Benchmark_v1.0.0-oval.xml
        [xml]$xccdf =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_8_Benchmark_v1.0.0-xccdf.xml
    }

    "w(indows 8.1)"
    {
        [xml]$oval =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_8.1_Benchmark_v2.1.0-oval.xml
        [xml]$xccdf =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_8.1_Benchmark_v2.1.0-xccdf.xml
    }   

    "w(indows 10)"
    {
        [xml]$oval =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_10_Enterprise_RTM_Release_1507_Benchmark_v1.0.0-oval.xml
        [xml]$xccdf =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_10_Enterprise_RTM_Release_1507_Benchmark_v1.0.0-xccdf.xml
    }

    "w(indows server 2003)"
    {
        [xml]$oval =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_Server_2003_Benchmark_v3.1.0-oval.xml
        [xml]$xccdf =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_Server_2003_Benchmark_v3.1.0-xccdf.xml
    }

    "w(indows server 2008)"
    {
        [xml]$oval =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_Server_2008_Benchmark_v2.1.0-oval.xml
        [xml]$xccdf =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_Server_2008_Benchmark_v2.1.0-xccdf.xml
    }

    "w(indows server 2008 r2)"
    {
        [xml]$oval =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_Server_2008_R2_Benchmark_v2.1.0-cpe-oval.xml
        [xml]$xccdf =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_Server_2008_R2_Benchmark_v2.1.0-xccdf.xml
    }   

    "w(indows server 2012)"
    {
        [xml]$oval =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_Server_2012_Benchmark_v1.0.0-oval.xml
        [xml]$xccdf =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_Server_2012_Benchmark_v1.0.0-xccdf.xml
    }

    "w(indows server 2012 r2)"
    {
        [xml]$oval =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_Server_2012_R2_Benchmark_v2.1.0-oval.xml
        [xml]$xccdf =  Get-Content -Path .\Documents\benchmarks\CIS_Microsoft_Windows_Server_2012_R2_Benchmark_v2.1.0-xccdf.xml
    }

    default 
    {
        Write-Output "$getOSversion is not supported at the moment, please contact your Security Manager for help"
    }
}

#Registry Objects from "CIS_Microsoft_Windows_7_Benchmark_v2.1.0-oval.xml"
$def_objects = $oval.oval_definitions.objects
$registry_objects = $def_objects.registry_object

#$Benchmark Objects from "CIS_Microsoft_Windows_7_Benchmark_v2.1.0-xccdf.xml"
$xccdf_benchmark = $xccdf.Benchmark
$benchmark_value = $xccdf.Benchmark.Value


$id = ($benchmark_value | ForEach-Object{$_.id})
$comment = ($registry_objects | ForEach-Object{$_.comment})

$comment > .\Desktop\comment.txt
$id  > .\Desktop\id.txt


$regex_test = [regex] "\d{1,3}.+\d{1,3}.{0}." 


<#REGEX MATCH { id:value_1.1.1.5.1.2_ -> comment:rule_1.1.1.5.1_}
1.2.1.3.1.1.3.7
Extract the Benchmark Items

EXAMPLE:
foreach($item in $comment)
{
    $item = @($($regex_test.Matches($item) | %{ $_.value}) -replace '_[^/]*$','')
    $item 
}

#>

$comment_var = (($comment | ForEach-Object{$regex_test.Match($_).Value}).Trim() -ne "") -replace '_[^/]*$'
$comment_var
[xml]$oval =  Get-Content -Path C:\Users\olao\Documents\Benchmark\CIS_Microsoft_Windows_7_Benchmark_v2.1.0-oval.xml
[xml]$xccdf =  Get-Content -Path C:\Users\olao\Documents\Benchmark\CIS_Microsoft_Windows_7_Benchmark_v2.1.0-xccdf.xml

#Registry Objects from "CIS_Microsoft_Windows_7_Benchmark_v2.1.0-oval.xml"
$def_objects = $oval.oval_definitions.objects
$registry_objects = $def_objects.registry_object

#$Benchmark Objects from "CIS_Microsoft_Windows_7_Benchmark_v2.1.0-xccdf.xml"
$xccdf_benchmark = $xccdf.Benchmark
$benchmark_value = $xccdf.Benchmark.Value

<#------------USAGE-------------
Compare the Registry Object rule # to the Benchmark rule ID.
If there is a match, extract the hive, key, name from the Registry Object and type, value from the Benchmark Objects.

--------------EXAMPLE-----------

    id          : xccdf_org.cisecurity.benchmarks_value_1.1.1.5.1.2_var
    operator    : equals
    type        : number
    title       : Check that 'Turn off Data Execution Prevention for Explorer' is configured to 'Disabled'
    description : This variable is used in Benchmark item "Set 'Turn off Data Execution Prevention for Explorer' to 'Disabled'" 
                -> "Check that 'Turn off Data   Execution Prevention for Explorer' is configured to 'Disabled'
    value       : 0


    xmlns   : http://oval.mitre.org/XMLSchema/oval-definitions-5#windows
    comment : xccdf_org.cisecurity.benchmarks_rule_1.1.1.5.1_Set_Turn_off_Data_Execution_Prevention_for_Explorer_to_Disabled
    id      : oval:org.cisecurity.benchmarks.o_microsoft:obj:1050
    version : 1
    hive    : HKEY_LOCAL_MACHINE
    key     : Software\Policies\Microsoft\Windows\Explorer
    name    : NoDataExecutionPrevention

    REGEX MATCH : value_1.1.1.5.1.2_ -> rule_1.1.1.5.1_
#>

#Get each childnode of the Registry and  Benchmark Objects
$hive = ($registry_objects | ForEach-Object{$_.hive})
$key = ($registry_objects | ForEach-Object{$_.key})
$name = ($registry_objects | ForEach-Object{$_.name})
$type = ($benchmark_value | ForEach-Object{$_.type})
$value = ($benchmark_value | ForEach-Object{$_.value})

<#Make a $fullpath and rootpath  to the registry using the registry object elements [hive, key]
--------------EXAMPLE-----------

hive    : HKEY_LOCAL_MACHINE
key     : Software\Microsoft\Windows\CurrentVersion\Policies\System
name    : ValidateAdminCodeSignatures

$fullpath = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\ValidateAdminCodeSignatures
#>

$fullpath = ($registry_objects | ForEach-Object{"Registry::" +  $_.hive + "\" + $_.key}) 
$rootpath = ($registry_objects | ForEach-Object{$_.hive + "\" + $_.key})

#Create folders to collect output data
new-item .\Desktop\regBackup -type directory -Force
new-item .\Desktop\mergedBackup -type directory -force
new-item .\Desktop\notFound -type directory -Force

#The total of registry paths
$count = $fullpath.Count

Write-Host "Attempting to backup the registry" 
foreach ($path in $fullpath)
{
    #Check if the registry path is valid
    $path + " : " + $(Test-path $path)
}
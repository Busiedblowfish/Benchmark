﻿[xml]$oval =  Get-Content -Path Documents\Benchmark\CIS_Microsoft_Windows_7_Benchmark_v2.1.0-oval.xml
[xml]$xccdf =  Get-Content -Path Documents\Benchmark\CIS_Microsoft_Windows_7_Benchmark_v2.1.0-xccdf.xml

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
$comment = ($registry_objects | ForEach-Object{$_.comment})
$type = ($benchmark_value | ForEach-Object{$_.type})
$value = ($benchmark_value | ForEach-Object{$_.value})
$id = ($benchmark_id | ForEach-Object{$_.id})


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
for($index = 0 ; $index -lt $count; $index++)
{
    #check if the registry path exists
    if(Test-path $fullPath[$index])
    {
        #Extract non-null objects 
        if($name[$index] -ne "" -and $type[$index] -ne "" -and $value[$index] -ne "")
        {                 
            Try
            {              
                #check if a property[name] exist in the registry for a corresponding valid registry path
                $propertyExist = (Get-ItemProperty -Path $fullPath[$index] | Select -ExpandProperty $name[$index] -EA stop)
                if($propertyExist)
                {
                    #Export each of the found registry values
                    
                    reg export $rootPath[$index] .\Desktop\regBackup\$index.reg /y
                    $inputFile = ".\Desktop\regBackup\*"
                    $outputFile = ".\Desktop\mergedBackup\mergedReg $(get-date -f MM-dd-yyyy-HH-mm).reg"
                     
                    #Display the output
                    write-host "PSParentPath: "$fullPath[$index]
                    write-host "RootPath: "$rootPath[$index]
                    write-host "Expanded Property: "$name[$index]
                    write-host "File Name: $index.reg" 
                    write-host "Current Value: " ($propertyExist)
                    
                    <#Set-ItemProperty -Path $fullPath[$index] -Name $name[$index] -Value $value[$index]
                    write-host "New Value: " ($propertyExist)
                    Write-host ""
                    #>
                }                                 
            }
            
            Catch [System.Exception]
            {
                #Export invalid property      
                $exceptionFile = ".\Desktop\notFound\propertynotFound $(get-date -f MM-dd-yyyy-HH-mm).txt"
                $_.Exception > $exceptionFile                        
            } 
        } 
    }
}
                
<# Merge each backup reg files into a single reg file
# Set an header and remove multiple instances of the header in each file
'Windows Registry Editor Version 5.00' | Set-Content $outputFile 
get-content $inputFile -include "*.reg" | Where-Object{$_ -notmatch 'Windows Registry Editor Version 5.00'} | Add-Content $outputFile
#>

# try {$SAN = ($Cert.Extensions | Where-Object {$_.Oid.Value -eq "2.5.29.17"}).Format(0) -split ", "}

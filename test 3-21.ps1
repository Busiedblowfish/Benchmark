$filePath = "K:\MIS\Ola\cis_win7.csv"
<# Create an Object Excel.Application using Com interface
$objExcel = New-Object -ComObject Excel.Application

# Disable the 'visible' property so the document won't open in excel
$objExcel.Visible = $false
#>
#Import the data from csv file and store in a variable
$rawData = Import-Csv -path $filePath

#select all hive objects
$cisData = ($rawData | Where-Object{$_.hive, $_.key, $_.name , $_.type, $_.value})

#create objects of each column entry in $cisData
$hive = ($cisData | ForEach-Object{$_.hive})
$key = ($cisData | ForEach-Object{$_.key})
$name = ($cisData | ForEach-Object{$_.name})
$value = ($cisData | ForEach-Object{$_.value})

#Join the cell elements to make a full path to the registry
$fullPath = ($cisData | ForEach-Object{"Registry::" +  $_.hive + "\" + $_.key})

#The total  number of rows in the csv file
$count = $fullPath.count

cls #Clear the screen


Write-Host "Attempting to backup the registry" 
for($index = 0 ; $index -lt $count; $index++)
{
    #check if the registry path exists
   if((Test-path $fullPath[$index]))
    {
        #get non-null values from the .csv column entries
        if($key[$index] -ne "" -and $name[$index] -ne "" -and $value[$index] -ne "")
        {
            #check if a property[name] exist in the registry for a corresponding valid registry path
            if(Get-ItemProperty -Path $fullPath[$index] | Select -ExpandProperty $name[$index] -EA SilentlyContinue)
            {
                write-host "PSParentPath: "$fullPath[$index]
                write-host "Expanded Property: "$name[$index]                
                Try
                {
                    write-host "Current Value: " (Get-ItemProperty -Path $fullPath[$index] | Select -ExpandProperty $name[$index] -EA stop)  
                    Set-ItemProperty -Path c -Name $name[$index] -Value $value[$index]
                    write-host "New Value: " (Get-ItemProperty -Path $fullPath[$index] | Select -ExpandProperty $name[$index] -EA stop)
                    Write-host ""                                  
                }
                
                Catch [System.Exception]
                {
                    #Get-Date >> "C:\Users\olao\Desktop\exceptionGet.txt"
                    $_.Exception >> "C:\Users\olao\Desktop\exceptionGet.txt"                                     
                } 
                
                Finally
                {
                    #Example: Reg export HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\Outlook exportedkey.reg
                    #$_.hive + "\" + $_.key
                    # Export ONLY the registy key values that changed / backup before the change
                    switch -regex ("$fullPath[$index]")
                    {
					
						"$fullPath[$index]" -match "HKEY_LOCAL_MACHINE" {									}
                        HKEY_LOCAL_MACHINE  {"$fullPath[$index] = $hive[$index] + '\' + $key[$index]"; break}
                        HKEY_CLASSES_ROOT   {"$fullPath[$index] = $hive[$index] + '\' + $key[$index]"; break}
                        HKEY_CURRENT_USER   {"$fullPath[$index] = $hive[$index] + '\' + $key[$index]"; break}
                        HKEY_USERS          {"$fullPath[$index] = $hive[$index] + '\' + $key[$index]"; break}
                        HKEY_CURRENT_CONFIG {"$fullPath[$index] = $hive[$index] + '\' + $key[$index]"; break}
                        default             {break}
                    }
                
                }
            }
        } 
    }
}

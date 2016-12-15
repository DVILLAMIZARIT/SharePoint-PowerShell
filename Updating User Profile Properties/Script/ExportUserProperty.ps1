write-host "Engine Start...3...2...1..." -foregroundcolor "Yellow"

#Powershell Add In
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

#Script Varibles #1 - SharePoint Site
$siteUrl = "https://..."

#Script Varibles #2 - Column Names from SharePoint
$GetField1 = "WorkEmail"  
$GetField2 = "SPS-Birthday" 

#Script Varibles #3 -  Directory File, Only Modify Working Folder Varible
$WorkfingFolder = "C:\Scripts\BirthdayExport\" 

#Script Varibles #4 - No Alterations Needed
$i = 0 
$HasData = 1
$outputFile = $WorkfingFolder + "UserProfileOnPremExportCSVTemp.csv"
$outputFileFinal = $WorkfingFolder + "UserProfileOnPremExportCSVFinal.csv"
$JsonOutputFile = $WorkfingFolder + "UserProfileOnPremExport.json"

#Clean Our Work Folder
Remove-Item -Recurse -Force $WorkfingFolder -exclude *.ps1

#Begin User Profile Data Collection, Add More $GetField Vars For Additional Columns Required
$serviceContext = Get-SPServiceContext -Site $siteUrl
$profileManager = New-Object Microsoft.Office.Server.UserProfiles.UserProfileManager($serviceContext);
$profiles = $profileManager.GetEnumerator()
$fields = @(
            $GetField1,   
            $GetField2
           )
$collection = @()

#Read User Fields and Save to File
write-host "Reading User Profile from SharePoint" -foregroundcolor "Yellow"
foreach ($profile in $profiles) {
   $user = "" | select $fields
   foreach ($field in $fields) {
     if($profile[$field].Property.IsMultivalued) {
       $user.$field = $profile[$field] -join "|"
     } else {
       $user.$field = $profile[$field].Value
       #Remove Only This If Statment To Include All Results (Blank Or Not) if Desired.
       if ($user.$field){$HasData=1}else {$HasData=0}
     }
   }
   if ($HasData -eq 1){
   $i++ 
   $collection += $user
   }
  }
write-host "Profiles Collected: " $i -foregroundcolor "Yellow"
$collection | Export-Csv $outputFile -NoTypeInformation
#Delay to Ensure Saved Successfully 
Start-Sleep -Milliseconds 1000
write-host "Temp File Saved" -foregroundcolor "Yellow"

#Convert Saved Values to Correct Date Format (MM/DD/YYYY)
$CSVColumnName = $GetField2
$CurrentYear = get-date –f yyyy
write-host "Starting Date Conversion Process" -foregroundcolor "Yellow"
Import-Csv $outputFile | % { 
$StringColumnName = $_.$CSVColumnName
    if ($StringColumnName.Length -gt 0)
    {
        $StringColumnName = ($StringColumnName).Substring(0,10)
        $StringColumnName = $StringColumnName.TrimEnd()
        $PositionOfYear = $StringColumnName.IndexOf($CurrentYear)
        if ($PositionOfYear -eq 4)
        {
            $_.$CSVColumnName = $StringColumnName.Substring(0,$StringColumnName.Length - 2)
        }
        else
        { $_.$CSVColumnName = $StringColumnName }
    }
    else { #$_.$CSVColumnName =  $_.$CSVColumnName 
    }
$_} | Export-Csv $outputFileFinal -NoTypeInformation
write-host "Date Conversion Process Complete" -foregroundcolor "Yellow"

#Convert CSV File to Final JSON Format
write-host "Converting CSV to JSON" -foregroundcolor "Yellow"
import-csv $outputFileFinal | ConvertTo-Json | Add-Content -Path $JsonOutputFile
write-host "Cleaning Up..." -foregroundcolor "Yellow"
Remove-Item -Recurse -Force $WorkfingFolder -exclude *.json, *.ps1
write-host "Job Complete, We have Lift Off" -foregroundcolor "Green"
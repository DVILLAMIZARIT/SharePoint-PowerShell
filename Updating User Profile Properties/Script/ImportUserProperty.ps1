Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

#Script Varibles #1
$userName = "email"
$Password = "password"
#Script Varibles #2 - Site Detaials for Document Library Name we want to Upload To
$SiteURL = "https://site.sharepoint.com/"
$DocLibName = "Document Librbary Name Here"
#Script Varibles #3 - Site Detaials for SharePoint Admin Centre
$adminUrl = "https://site-admin.sharepoint.com"
#Script Varibles #4 - Location Of Local Folder 
$Folder = "C:\Scripts\BirthdayExport"

#Create SharePoint Online Connection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Password = ConvertTo-SecureString $Password -AsPlainText -Force
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName,$Password)
$Context.Credentials = $Creds

#Get Document Lib
$List = $Context.Web.Lists.GetByTitle($DocLibName)
$Context.Load($List)
$Context.ExecuteQuery();

#Upload all files in Specific Folder
Foreach ($File in (dir $Folder -File))
{
 if ($File -ne "*.json")
 {
	$importFileUrl = $SiteURL + $DocLibName + "/" + $File
	$FileStream = New-Object IO.FileStream($File.FullName,[System.IO.FileMode]::Open)
	$FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
	$FileCreationInfo.Overwrite = $true
	$FileCreationInfo.ContentStream = $FileStream
	$FileCreationInfo.URL = $File
	$Upload = $List.RootFolder.Files.Add($FileCreationInfo)
	$Context.Load($Upload)
	$Context.ExecuteQuery()
 }
}

#Pause and Wait for Upload to Finish
Start-Sleep -Milliseconds 10000

# Get instances to the Office 365 tenant using CSOM
$uri = New-Object System.Uri -ArgumentList $adminUrl
$context = New-Object Microsoft.SharePoint.Client.ClientContext($uri)
$context.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $Password)
$o365 = New-Object Microsoft.Online.SharePoint.TenantManagement.Office365Tenant($context)
$context.Load($o365)

# Type of user identifier ["Email", "CloudId", "PrincipalName"] in the User Profile Service
$userIdType=[Microsoft.Online.SharePoint.TenantManagement.ImportProfilePropertiesUserIdType]::Email

# JSON Column name that maps to the user we want to update. 
$userLookupKey="AccountName"

$propertyMap = New-Object -type 'System.Collections.Generic.Dictionary[String,String]'
$propertyMap.Add("SPS-Birthday", "SPS-Birthday")
#Add The Line - $propertyMap.Add("JSONColumnName", "SharePoint Online Field Name") - to add more fields to map in the process

Write-Host $importFileUrl
$workItemId = $o365.QueueImportProfileProperties($userIdType, $userLookupKey, $propertyMap, $importFileUrl);
$context.ExecuteQuery();
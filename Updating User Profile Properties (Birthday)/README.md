# Updating User Profile Properties (Birthday)
Import and Export Scripts to extract user profile properties from SharePoint On-Prem to SharePoint Online


* Script 1: ExportUserProperty
  * Define Site URL 
  * Define Properties to return as GetField values
  * Define Working Folder to Output final file into
  * Process: 

* Script 2: ImportUserProperty
  * Define Username and Password for SharePoint Online Authentication
  * Define SiteURL, DocLib Name, SharePoint AdminURL and our Working Folder in Script 1
  * Define PropertyMap(Line-59) alligning to our returned field in Script 1 (SPS-Birthday)
  * Process: 

* Execution
  * Once all defined properties are filled out according to your enviroment run Script 1, script will create a .json output into our working folder. Simply then run Script 2 in SharePoint Online Management console to upload our .json to the defined Online site and let the script execute and update user profile properties.

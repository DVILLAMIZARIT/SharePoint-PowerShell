# Updating User Profile Properties (Birthday)
Import and Export Scripts to extract user profile properties from SharePoint On-Prem to SharePoint Online


* Script 1: ExportUserProperty
  * Define Site URL 
  * Define Properties to return as GetField values
  * Define Working Folder to Output final file into

* Script 2: ImportUserProperty
  * Define Username and Password for SharePoint Online Authentication
  * Define SiteURL, DocLib Name, SharePoint AdminURL and our Working Folder in Script 1
  * Define PropertyMap(Line-59) alligning to our returned field in Script 1 (SPS-Birthday)

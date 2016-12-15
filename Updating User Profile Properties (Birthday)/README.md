# Updating User Profile Properties (Birthday)
Import and Export Scripts to extract user profile properties from SharePoint On-Prem to SharePoint Online. I have commented where I saw fit in the scripts however see below for a more defined process flow of updating. 

* Scenario
  * User Profile Property (mainly SPS-Birthday comes into SharePoint On-Prem as a extendedProperty in AD which is then mapped to the users SPS-Birthday field. SharePoint Online does not allow profile property mapping and thus would not show the Users Birthday Value Online. The client requested that a Birthday webpart be built and since Hybrid Search was being used it required us to have these values available online. The problem came in when I extracted the SPS-Birthday field from SharePoint On-Prem which extracted the birthday value in full date format (MM/dd/YYYY HH:mm:ss) and then saved into CSV. SharePoint Online Bulk API firstly expected the data in. json and our SPS-Birthday field secondly required the date to be in MM/dd/YYYY format only. The following two scripts were created to overcome these challenges. 

* Script 1: ExportUserProperty
  * Define Site URL 
  * Define Properties to return as GetField values
  * Define Working Folder to Output final file into
  * Process: Data is collected from the Users Profile; our two fields are defined as the GetField variables (able to add more as you please). We use the WorkEmail field as the identifier when mapping in Script 2 as it contained our user’s emails. The data is then checked to ensure data is returned else it is not added to our CSV file. The CSV file is then loaded with only value returned fields and saved. This is the point where our date is then converted to a value format before our json is created, so the CSV file is loaded, manipulated and then saved as a final CSV file. The last phase of the script is to load the final CSV and convert it to. json format with the built in function, working folder is cleared on any csv files and we are left with only our .json final file. Please see comments in file for some more explanation at stages. 

* Script 2: ImportUserProperty
  * Define Username and Password for SharePoint Online Authentication
  * Define SiteURL, DocLib Name, SharePoint AdminURL and our Working Folder in Script 1
  * Define PropertyMap(Line-59) aligning to our returned field in Script 1 (SPS-Birthday)
  * Process: After Authenticating with SharePoint Online, we scan our working folder to upload our .json file into the defined SharePoint Online Site Library, after the file is uploaded (small break to account for slower networks) we begin the Bulk API update method, the property map section maps the column in our json file to the field that needs to be updated in UPS...simple. 

* Execution
  * Once all defined properties are filled out according to your environment run Script 1 on your SharePoint On-Prem server, script will create and output a single .json file into our defined working folder. Simply then run Script 2 in SharePoint Online Management console which will upload our .json to the defined Online site and update the user profile properties.

* Notice
  * Please feel free to branch and modify, Im sure a few steps can be done more efficiently and Im always open to learning new ways of doing things. 

* To-Do
  * Automatically Execute Script 2 from Script 1
  * Let user add more GetField properties without modifying the later code
  * Reduce to one CSV output
  * Upload specific output file in Script 2 not all files in working folder
  * Possibility to automatically map Properties by reading .json first

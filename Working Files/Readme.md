![](./../dbbest-logo-small.png)
# Covid-19-Power-BI - Working Files - Dev Branch
This folder contains the derived files from original sources to make it easier to process using Power BI. We use the following naming conventions for data files:

## Sources abbreviations used for file prefixes:
- **JHU:**  JSU CSSE GitHub Data Repository: https://github.com/CSSEGISandData/COVID-19
- **GLM:** docs.gaslamp.media https://docs.gaslamp.media/wp-content/uploads/2013/08/zip_codes_states.csv
- **DBT:** Derived data created the DBT workflow using code in [dev branch Powershell](https://github.com/db-best-technologies/Covid-19-Power-BI/tree/dev/PowerShell)
- **HIF:** Homeland Infrastructure Foundation-Level Data (HIFLD): https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals

## File naming pattern
### File names from GitHub sources
    [Source Appreviation]__[Branch]__[Branch Leaf]__[Original File Name Leaf]  
We use two underscore characters the delimiter.

### File names from other sources  
    [Source Appreviation]__[DNSSafeHost]__[Original File Name Leaf]  
We compute the **DNSSafeHost** value using PowerShell like this  
  
    ([System.Uri]$Uri = "https://docs.gaslamp.media/wp-content/uploads/2013/08/zip_codes_states.csv").DnsSafeHost  
      doc.gaslamp.media  

## Source metadata
Each set of files has an associated JSON file with the metadata for the sets of files or single file using using the prefix pattern.  
  
The JSON file includes a property called **Table Name** which includes the name of the file as it appears in the master brance for **Data-Files**.
This way, the Power BI tables look like tables in a traditional data warehouse. We use the following prefixes:  
  
    Fact.   
    Dimension.
    Measure.  
    
We also transform the file name used for the source into a meaningful table name that pest represents the event that happened
instead of the transaction that caused the event.
  
### Examples:
Source files from **master/csse_covid_19_data/csse_covid_19_daily_reports_us**  
  
    URL: https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports_us/04-12-2020.csv  
    Result: JHU__master_csv_csse_covid__19_daily_reports_us__04-12-2020.csv  
    Metadata file name: JHU__master_csv_csse_covid__19_daily_reports_us.json # Incudes information for the csv files  
    Table Name: Fact.US_Covid_19_Cases_By_State.csv
  
Source files from **master/csse_covid_19_data**  
  
    URL: https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv  
    Result: JHU__master__csse_covid_19data__UID_ISO_FIPS_LookUp_Table.csv  
    Metadata file name: JHU__master__csse_covid_19data__UID_ISO_FIPS_LookUp_Table.json  
    Table Name: Dimension.County_State_Country.csv # JHU represents the three values as Admin2, Province_State, Country_Region

Source files from **web-data/override**  
   
    URL: https://raw.githubusercontent.com/CSSEGISandData/COVID-19/web-data/override/override.csv
    Result: JHU__web-data__override__override.csv
    Metadata file name: JHU__web-data__override__override.json  
    Table Name: Dimension.Reported_Combined_Key_Mapping.csv   # Note: This table stays in the Dev branch for now. 

Source files from **GLM**  
  
    URL: https://docs.gaslamp.media/wp-content/uploads/2013/08/zip_codes_states.csv  
    Result: GML__doc.gaslamp.media__zip_codes_states.csv  
    Metadata file name: GML__doc.gaslamp.media__zip_codes_states.json  
    Table Name: Dimension.ZipCode_City_State_Mapping.csv  # Note: Stays in Dev branch to resolve Province/State.  

## How did we figure out how to markup this page?
If you want to learn more about how to use GitHub markup, check out the following resources.  
- [Basic writing and formatting syntax](https://help.github.com/en/github/writing-on-github/basic-writing-and-formatting-syntax). Provides a good overview of the essential syntax.  
- [GitHub Flavored Markdown Spec](https://github.github.com/gfm/). GitHub's formal specification.  
  

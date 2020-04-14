Starting on 04-12-2020, there is a new folder COVID-19\csse_covid_19_data\csse_covid_19_daily_reports_us that contains new columns for People_Tested, People_Hospitalized. The data is cumulative for each day. Here are the definitions for the columns.

csse_covid_19_daily_reports_us
- File_Name_Format: mm-dd-yyyy.csv
- Source_File_Location: https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports_us
- Raw_File_Path: https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports_us/
- Columns:
    Province_State
    Country_Region
    Last_Update
    Lat
    Long_
    Confirmed
    Deaths
    Recovered
    Active
    FIPS
    Incident_Rate
    People_Tested
    People_Hospitalized
    Mortality_Rate
    UID
    ISO3
    Testing_Rate
    Hospitalization_Rate
- Modifications_To_Original_File:
  "Date Reported": "Derived by taking the leaf name of the CSV file"
  "CSV File Name": "Uses the file name that is uses to append to the Raw_File_Path to retrieve the file"
- Data_Loading_Notes:
  Data_Rows: "Includes columns for all 50 states and territories along with Grand Princess cases assigned to US"
  Recovered_Row_Recovered_Value: "Contains the cumulative total of reported cases in the US"
  Recovered_Row_Active_Value: "Contains a negative value of the Recovered cases to offset the Active total when sumerizing the columns.
  
  

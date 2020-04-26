![](./../dbbest-logo-small.png)
# Covid-19-Power-BI - Data_Files - Dimension.Hospitals
This feature class/shapefile contains locations of Hospitals for 50 US states, Washington D.C., US territories of Puerto Rico, Guam, American Samoa, Northern Mariana Islands, Palau, and Virgin Islands. The dataset only includes hospital facilities based on data acquired from various state departments or federal sources which has been referenced in the SOURCE field.  
  
## Data source information
- Source web site: [HIFLD Open GP - Public Health](https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals)
- Shared by: [kiersten.hudson_geoplatform](https://hifld-geoplatform.opendata.arcgis.com/search?owner=kiersten.hudson_geoplatform)
- Cited source: [services1.arcgis.com](https://services1.arcgis.com/Hp6G80Pky0om7QvQ/arcgis/rest/services/Hospitals_1/FeatureServer/0)
- Source Metadata: [Dataset Metadata](https://www.arcgis.com/sharing/rest/content/items/6ac5e325468c4cb9b905f1728d6fbf0f/info/metadata/metadata.xml?format=default&output=html)
- Download CSV link: [Download CSV File](https://opendata.arcgis.com/datasets/6ac5e325468c4cb9b905f1728d6fbf0f_0.csv?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D)
- Retrieved On UTC: 2020-04-15T16:20:08Z"
- Retrieved On PST: 2020-04-15T09:20:08-07:00
## Derived Data File
- Master branch:  
- Master raw file:
- Dev branch: [Dimension.Hospitals](https://github.com/db-best-technologies/Covid-19-Power-BI/blob/dev/Data-Files/Dimension.Hospitals.csv)
- Dev raw file: [Dimension.Hospitals.csv](https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/dev/Data-Files/Dimension.Hospitals.csv)
## Proccess information
### Script file: [Get-HIFLD-Hospitals.ps1](../PowerShell/Get-HIFLD-Hospitals.ps1)
- Script change log: [History](https://github.com/db-best-technologies/Covid-19-Power-BI/commits/master/PowerShell/Get-HIFLD-Hospitals.ps1)
#### Overview
- Load CSV file from source
- Create a use the county and state fields to create a matching Combined_Key value to the Dimensions.Country_State_Country table
- Add a unique key to each record called Hospital_Key






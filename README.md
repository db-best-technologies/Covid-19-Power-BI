![](./dbbest-logo-small.png)
# COVID-19-Power-BI - Educational content - How to analyze data from CSSEGISandData/COVID-19 repository

This repository supports the blog articles from DB Best Technologies that uses data from the 2019 Novel Coronavirus COVID-19 (2019-nCoV) Data Repository by Johns Hopkins CSSE (JHU). You can find the related blog posts at:  
  
- **Power BI Dashboard Example:** [World view dashboard](https://app.powerbi.com/view?r=eyJrIjoiNTAzODMyYWYtOWY0OS00ZTE0LWI4ZWYtN2FhYTk3YWRiZGJkIiwidCI6ImZmNzgyOGY3LTQyMTYtNGY5NS05MmE4LTQyNzIyZmNlMGJlOCIsImMiOjZ9)  
- **DB Best Blogs:** [Power BI blog posts](https://www.dbbest.com/blog/category/bloggers/denisha-malone/)  

## Why, yet another GitHub project on COVID-19?
The team at Johns Hopkins Whiting School of Engineering - Center for Systems Science an Engineering - have done an amazing job at providing a central location for tracking all things related to COVID-19 stats. 
Here are the essentials of what the CSSE has assembled. 
  
- **JSU CSSE GitHub Data Repository:** [CSSEGISandData/COVID-19](https://github.com/CSSEGISandData/COVID-19)  
- **JSU CSSE COVID-19 Dashboard:** [COVID-19 Dashboard JHU CSSE Team](https://www.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6)  
- **npr.org -  Meet The Team Behind The Coronavirus Tracker Watched By Millions:** [Meet The Team Behind The Coronavirus Tracker Watched By Millions](https://www.npr.org/2020/04/13/833073670/mapping-COVID-19-millions-rely-on-online-tracker-of-cases-worldwide)  
- **JSU COVID-19 Map FAQs:** [COVID-19 Map FAQs](https://systems.jhu.edu/research/public-health/2019-ncov-map-faqs/)

However, there have been times where various dashboards using the data have had glitches in reporting the
numbers. Being the "authoritative" source for COVID-19 data, government decision makes may look at the
pretty dashboards and think - oh - it looks like the curve is flattening - let's open up the beaches.  

One such example happened around March 25, 2020 when the team decided to change the file names and data 
that was reported for the United States [Time series summary data](https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/README.md). Several popular dashboards
missed the deprecated warning.  

## Known Data Limitations
### Numerous issues are [on the data source Github](https://github.com/CSSEGISandData/COVID-19/issues?q=is%3Aopen+is%3Aissue+-label%3A"user+creation"++). A few issues of note:

#### Time-series datasets in disagreement with summarized datasets
Official datasets aren't succesfully keeping the daily data provided in sync with the summarized datasets. There could be various reasons for this, but what would be ideal is if the providers were transparent about what corrections they are applying in the summaries and for what reason.

#### Presumptive classification of Ncov-19 deaths

* Officials are revisiting past death certificates that were marked with other causes and adding them to the Covid-19 fatalities. However they aren't necessarily back-updating the time series data that has been provided earlier, and it may in fact prove impractical to do so.   

https://www.usnews.com/news/best-states/california/articles/2020-04-22/california-governor-to-update-plans-for-lifting-virus-orders

* Pneumonia deaths to be classified as Ncov-19 without testing  
NCov-19 fatality data may be less reliable than confirmed cases because testing may not be performed.

https://www.southernminn.com/owatonna_peoples_press/news/article_b1710f94-ac0e-59b2-adea-770dca8691fd.html

## What's Not Working
* Active Cases tooltips values are incorrect

## Documenting the data model for the CSSE COVID-19 Dataset

The team now has a description of the files that they generate around 4pm PST each day that you can find at
[CSSE COVID-19 Dataset - README.md](https://github.com/CSSEGISandData/COVID-19/blob/master/csse_COVID_19_data/README.md).   
  
We hope to provide better insight into the CSSE COVID-19 Dataset and use data from other sources to demonstrate to researchers how to extend the data model for new insights to the COVID-19 beast. 

## Other Data Sources:  
<!-- 
<ul>
<li><b>docs.gaslamp.media</b> Download - Zip Code Latitude Longitude City State County CSV: <br>
Used to resolve location information for other sources that use different country, state, and county information that doesn't align to JHU coding of their Combined_Key value. <br>
<b>Web site:</b> <a href="https://docs.gaslamp.media/download-zip-code-latitude-longitude-city-state-county-csv/">https://docs.gaslamp.media/download-zip-code-latitude-longitude-city-state-county-csv/</a><br>
<b>Data file:</b> <a href="https://docs.gaslamp.media/wp-content/uploads/2013/08/zip_codes_states.csv">https://docs.gaslamp.media/wp-content/uploads/2013/08/zip_codes_states.csv</a><br></li>
<b>Note:</b> For our solution, we use a derived version of this file that includes the "combined_key" that JHU uses in their data files to specify a unique value for a location.<br> 
<br>
-->
- **Homeland Infrastructure Foundation-Level Data (HIFLD) - Hospitals:**  
This feature class/shapefile contains locations of Hospitals for 50 US states, Washington D.C., US territories of Puerto Rico, Guam, American Samoa, Northern Mariana Islands, Palau, and Virgin Islands. The dataset only includes hospital facilities based on data acquired from various state departments or federal sources which has been referenced in the SOURCE field. Hospital facilities which do not occur in these sources will be not present in the database.  
**Website:** https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals  
**Data file:** https://opendata.arcgis.com/datasets/6ac5e325468c4cb9b905f1728d6fbf0f_0.csv?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D  

## Feel free to contact our team members:  

- **Bill Ramos**, DB Best Technologies - Chief Technology Storyteller - Project Architect
  - Email: [bill@dbbest.com](mailto:bill@dbbest.com)  
  - LinkedIn: [/in/billramo/](https://www.linkedin.com/in/billramo/)  
  - Twitter: [@billramo](https://twitter.com/billramo)
  
- **DeNisha Malone** - DB Best Technologies - Business Intelligence Consultant - Power BI Queen
  - Email: [denishaBI@dbbest.com](mailto:denishaBI@dbbest.com)
  - LinkedIn: [/in/denishamalone/](https://www.linkedin.com/in/denishamalone/)
  - Twitter: [@thepowerbiqueen](https://twitter.com/thepowerbiqueen)

- **Prashant Mishra** - DB Best Technologies - Senior Solutions Consultant - Data Wrangler
  - Email: [prashant@dbbest.com](mailto:prashant@dbbest.com)
  - LinkedIn: [/in/prashant-kumar-mishra/](https://www.linkedin.com/in/prashant-kumar-mishra/)

- **Keith McCammon** - DB Best Technologies - Sr. Technical Program Manager - Emphasis on Technical
  - Email: [keithmc@dbbest.com](mailto:keithmc@dbbest.com)
  - LinkedIn: [https://www.linkedin.com/in/keithmcc/](https://www.linkedin.com/in/keithmcc/)
  

## Terms of Use:
DB Best Technologies (DBT) derived the COVID-18 data from copywrited data on 2020 by Johns Hopkins University (JHU). JHU provides their data to the public strictly for educational and academic research purposes. Other data used for blog posts by DBT uses data from other publicly available data from multiple sources, that do not always agree.  
  
The DB Best Technologies hereby disclaims any and all representations and warranties with respect to the Website, including accuracy, fitness for use, and merchantability.  Reliance on the Website for medical guidance or use of the Website in commerce is strictly prohibited.  

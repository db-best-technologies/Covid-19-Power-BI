![](./dbbest-logo-small.png)
# Covid-19-Power-BI - Educational content - How to analyze data from CSSEGISandData/COVID-19 repository

This repository supports the blog articles from DB Best Technologies that uses data from the 2019 Novel Coronavirus COVID-19 (2019-nCoV) Data Repository by Johns Hopkins CSSE (JHU). You can find the related blog posts at:<br>

<ul>
<li><a href="https://www,dbbest.com/blogs" target="_blank">DB Best Technology Blogs Site - www.dbbest.com/blogs</a></li>
</ul>
<b>About our primary data sources:</b>
<ul>
<li><b>JSU CSSE GitHub Data Repository:</b> <a href="https://github.com/CSSEGISandData/COVID-19">https://github.com/CSSEGISandData/COVID-19</a></li>
<li><b>JSU CSSE Covid-19 Dashboard:</b> <a href="https://www.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6">https://www.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6</a></li>
<li><b>npr.org -  Meet The Team Behind The Coronavirus Tracker Watched By Millions:</b> <a href="https://www.npr.org/2020/04/13/833073670/mapping-covid-19-millions-rely-on-online-tracker-of-cases-worldwide">https://www.npr.org/2020/04/13/833073670/mapping-covid-19-millions-rely-on-online-tracker-of-cases-worldwide</a></li>
<li> JSU COVID-19 Map FAQs:</b> https://systems.jhu.edu/research/public-health/2019-ncov-map-faqs/</li>
</ul>
<b>Other Data Sources:</b><br>
<ul>
<li><b>docs.gaslamp.media</b> Download - Zip Code Latitude Longitude City State County CSV: <br>
Used to resolve location information for other sources that use different country, state, and county information that doesn't align to JHU coding of their Combined_Key value. <br>
<b>Web site:</b> <a href="https://docs.gaslamp.media/download-zip-code-latitude-longitude-city-state-county-csv/">https://docs.gaslamp.media/download-zip-code-latitude-longitude-city-state-county-csv/</a><br>
<b>Data file:</b> <a href="https://docs.gaslamp.media/wp-content/uploads/2013/08/zip_codes_states.csv">https://docs.gaslamp.media/wp-content/uploads/2013/08/zip_codes_states.csv</a><br></li>
<b>Note:</b> For our solution, we use a derived version of this file that includes the "combined_key" that JHU uses in their data files to specify a unique value for a location.<br> 
<br>
<li><b>Homeland Infrastructure Foundation-Level Data (HIFLD) - Hospitals:</b><br>
This feature class/shapefile contains locations of Hospitals for 50 US states, Washington D.C., US territories of Puerto Rico, Guam, American Samoa, Northern Mariana Islands, Palau, and Virgin Islands. The dataset only includes hospital facilities based on data acquired from various state departments or federal sources which has been referenced in the SOURCE field. Hospital facilities which do not occur in these sources will be not present in the database. <br>
<b>Website:</b> https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals<br>
<b>Data file</b>: https://opendata.arcgis.com/datasets/6ac5e325468c4cb9b905f1728d6fbf0f_0.csv?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D<br></li>
</ul>
<b>Feel free to contact our team members:</b>
<ul>
<li>Bill Ramos, DB Best Technologies, Architect, Email: <a href="mailto:bill@dbbest.com">bill@dbbest.com</a></li>
<li>DeNisha Malone, DB Best Technologies, Power BI Queen, <a href="mailto:denishaBI@dbbest.com">denishaBI@dbbest.com</a></li> 
<li>Prashant Mishra, DB Best Technologies, Senior Solutions Consultant,  <a href="mailto:prashant@dbbest.com">prashant@dbbest.com</a></li> 
<li>Keith McMannon, DB Best Technologies, Senior Technical Project Manager,  <a href="mailto:keithmc@dbbest.com">keithmc@dbbest.com</a></li> 

</ul>

<b>Terms of Use:</b><br>
DB Best Technologies (DBT) derived the Covid-18 data from copywrited data on 2020 by Johns Hopkins University (JHU). JHU provides their data to the public strictly for educational and academic research purposes. Other data used for blog posts by DBT uses data from other publicly available data from multiple sources, that do not always agree. <br>
<br>
The DB Best Technologies hereby disclaims any and all representations and warranties with respect to the Website, including accuracy, fitness for use, and merchantability.  Reliance on the Website for medical guidance or use of the Website in commerce is strictly prohibited.

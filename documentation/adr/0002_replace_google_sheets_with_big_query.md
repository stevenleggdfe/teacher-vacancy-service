# Replace Google Sheets with Big Query as a reporting database
Date: 20/01/2020

## Prologue (Summary)
As a result of TVS' Google Sheets approaching the [5 million cell limit](https://support.google.com/drive/answer/37603?hl=en). we decided for Google Big Query to replace Google Sheets as TVS' reporting database. With our current volume of data, we would be operating within the free tier of the pricing model, however we accept that we could fall outside the boundaries of this free tier in future.

### Status:
**Approved**

## Discussion (Context)
In our codebase, we were using the Google Sheets API to write data to Google Sheets - effectively using Google Sheets as a reporting database.

Advantage:
- It was free.

Disadvantages:
- Google Sheets has a cell limit per spreadsheet. We had reached the limit on a couple of these spreadsheets which meant that newer data could not be added without deleting older data. We estimated that the spreadsheet containing data on vacancies would run out of space in Q1 2020.
- Accidental edits to spreadsheets were common and these resulted in substantial maintenance effort to rectify them.
- Google Sheets formulae were more difficult to maintain and hand over than SQL queries.

We looked at a number of options to replace Google Sheets and assessed them based on:
- Amount of development work required to set them up.
- Ability to retain large volumes of anonymised historical data
- Storage of all data (historic and recent)
- Ability to remove personal data from reporting datasets
- Ease of integrating with existing tools
- Cost for usage

The options we looked at were:
- Creating a read replica of the production DB
- Data streaming from the API directly into the dashboard
- Creating a new DB solely for the purposes of reporting
- Using a data warehouse e.g Google Big Query, AWS RedShift

The table below describes the results of investigating each option:

|  Option                                                                                     |  Do nothing \(keep the Google Sheet\)            |  Read replica of the production database |  API\-to\-dashboard ‘data streaming’ |  PostgreSQL reporting database      |  Big Query data warehouse                     |  Amazon Redshift data warehouse                                               |   |   |
|---------------------------------------------------------------------------------------------|--------------------------------------------------|------------------------------------------|--------------------------------------|-------------------------------------|-----------------------------------------------|-------------------------------------------------------------------------------|---|---|
|  One\-off development required?                                                             | No                                               | Yes                                      | Yes                                  | Yes                                 | Yes                                           | Yes                                                                           |   |   |
|  Further development & reporting configuration required when new data needed for reporting? | Yes                                              | No                                       | Yes                                  | Yes                                 | Yes                                           | Yes                                                                           |   |   |
|  Further work required if we needed to migrate from AWS to Azure?                           | No                                               | Yes                                      | No                                   | Yes                                 | No                                            | Yes                                                                           |   |   |
|  Could store all data currently needed?                                                     | No                                               | Yes                                      | No                                   | Yes                                 | Yes                                           | Yes                                                                           |   |   |
|  Able to retain large volumes of anonymised historical data without extra development work  | No                                               | No                                       | No                                   | No                                  | Yes                                           |  No?                                                                          |   |   |
|  Would allow personal data to be removed from the reporting dataset                         | Yes                                              | No                                       | Yes                                  | Yes                                 | Yes                                           | Yes                                                                           |   |   |
|  Could connect to Data Studio                                                               | Yes                                              | Yes                                      | No                                   | Yes                                 | Yes                                           | Yes                                                                           |   |   |
|  Could connect to Power BI cloud                                                            | No                                               | No                                       | Yes                                  | No                                  | No                                            | No                                                                            |   |   |
|  Could connect to Tableau                                                                   | Yes                                              | Yes                                      | Yes                                  | Yes                                 | Yes                                           |  Yes                                                                          |   |   |
|  Cost / commercial model                                                                    |  Included in G Suite licence \(priced per user\) |  Extension of existing AWS contract      | ?                                    |  Extension of existing AWS contract |  Pay for above 1TB query usage / 10GB storage |  Pay for cluster per hour \($0\.32 per hour, or less on a reserved instance\) |   |   |
| Cost                                                                                        | None                                             |  ~£600 pa                                      | ?                                    | ~£600 pa                                   |  Assume free\!                                |  ~£2300 pa                                                                    |   |   |


## Solution
Use Google Big Query instead of Google Sheets and export our data into Big Query tables.

TVS had a GCP account which meant that we could setup a Big Query project quickly.
GCP allows us to manage access rights and set permissions for Big Query related jobs.
Our volume of data (~ 2 GB as of time of writing) means that we’re basically using it for free for now.
We use Google Data Studio which can easily be integrated with it.
Big Query also gives a range of BI tools to help with reporting.

## Consequences
For the volume of data we currently have at the time of writing, we can take advantage of Big Query's pricing model (Pay for above 1TB query usage / 10GB storage, our DB currently holds ~ 2 GB of data). However, the volume of the data stored in Big Query could increase over time and could therefore fall outside the boundaries of the free tier of the pricing model in future.

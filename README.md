# E-Commerce Funnel & Conversion Analysis (GA4 & BigQuery)

## Project Overview

This project analyzes Google Analytics 4 (GA4) e-commerce event data using Google BigQuery to understand user behavior across the conversion funnel.

The objective is to transform raw event-level data into session-based analytical tables and calculate key conversion metrics such as add-to-cart rate, checkout rate, and purchase conversion rate.

This project was completed as part of hands-on practice in GA4 data modeling and SQL-based funnel analysis.

---

## Project Goals

- Prepare a clean GA4 event dataset for BI analysis
- Perform session-level funnel analysis
- Calculate traffic channel conversion metrics
- Compare landing page performance based on purchase conversion
- Practice working with nested GA4 export schema in BigQuery

---

## Tech Stack

### Analytics & Database
- Google BigQuery  
- Google Analytics 4 (GA4 Export)

### SQL Techniques Used
- Common Table Expressions (CTEs)
- UNNEST for nested event parameters
- Conditional aggregation
- Date and timestamp transformations
- Session identification using `user_pseudo_id + session_id`
- GROUP BY aggregations

---

## Business Questions Answered

- How many sessions convert into purchases?
- Where do the largest funnel drop-offs occur?
- Which traffic channels have the highest conversion rates?
- Which landing pages contribute most effectively to purchases?

---

## Key Results

### Funnel Performance (2021)

- Total Sessions Analyzed: **116,514**
- Total Purchases: **1,092**
- Overall Purchase Conversion Rate: **0.94%**

The largest drop-off occurs between **add_to_cart** and **checkout**, indicating friction in the checkout initiation stage.

---

### Traffic Channel Conversion (2021)

- High session volume does not necessarily lead to high purchase conversion.
- Some low-volume channels show relatively high conversion efficiency.
- Conversion performance varies significantly across traffic sources.

Traffic quality matters more than traffic volume.

---

### Landing Page Conversion (2020)

- Some landing pages achieved very high conversion rates with low session counts.
- High-traffic pages do not always generate the highest number of purchases.
- Entry page intent strongly influences funnel progression.

Landing page structure and user intent alignment impact purchase performance.

---

## Project Structure

ecommerce_analysis.sql — Contains all SQL queries used in this project, including:

- Event-level data preparation (2021)
- Traffic channel conversion analysis
- Landing page conversion comparison (2020)

data/ — Directory containing the exported query results (.csv files) used to validate calculations and support the analysis.

report/ — Contains the full project report in PDF format.

---

## Key Metrics Calculated

- User Sessions  
- Add-to-Cart Rate  
- Checkout Rate  
- Purchase Conversion Rate  
- Channel-Level Conversion Rate  
- Landing Page Purchase Conversion Rate  

---

## What This Project Demonstrates

- Working with GA4 event-level data in BigQuery  
- Performing session-based funnel analysis  
- Writing structured SQL queries using CTEs  
- Translating raw data into measurable business insights  

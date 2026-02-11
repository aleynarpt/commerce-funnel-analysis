# E-commerce Funnel Analysis (GA4 & BigQuery)

This project focuses on analyzing Google Analytics 4 (GA4) sample e-commerce data using SQL queries on Google BigQuery.  
The dataset used in this project is:

`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

The main objective is to create event-level tables, build conversion funnels, and calculate page-level conversion rates for different years.

---

## Project Objectives

- Extract specific GA4 events for selected time periods  
- Build a conversion funnel based on user sessions  
- Analyze purchase performance by traffic source  
- Calculate page-level purchase conversion rates  

---

## Dataset

**Source:**  
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

This dataset contains anonymized GA4 e-commerce event data.

---

## Tasks Performed

### 1. Event Table Creation (2021)

An event-level table was created using only 2021 data and the following events:

- session_start  
- view_item  
- add_to_cart  
- begin_checkout  
- add_shipping_info  
- add_payment_info  
- purchase  

The following fields were extracted:

- event_timestamp  
- event_date  
- user_pseudo_id  
- session_id  
- event_name  
- country  
- device_category  
- source  
- medium  
- campaign  

This table represents user interactions and sessions for the selected events in 2021.

---

### 2. Conversion Funnel Analysis (2021)

A conversion funnel was built using the following events:

- session_start  
- add_to_cart  
- begin_checkout  
- purchase  

Sessions were identified using a combination of:

- user_pseudo_id  
- session_id  

The following metrics were calculated:

- Total number of sessions  
- Sessions with add_to_cart  
- Sessions with begin_checkout  
- Sessions with purchase  

In addition, the following conversion rates were computed:

- visit_to_cart_rate  
- visit_to_checkout_rate  
- visit_to_purchase_rate  

Results were grouped by:

- event_date  
- source  
- medium  
- campaign  

---

### 3. Page-Level Conversion Analysis (2020)

For this task, only 2020 data was used and the following events were selected:

- session_start  
- purchase  

The page location was extracted from the `page_location` parameter and used as `page_path`.

For each page, the following metrics were calculated:

- Unique session count  
- Purchase count  
- Purchase conversion rate  

Results were ordered by conversion rate in descending order.

---

## Technologies Used

- Google BigQuery  
- SQL  
- Google Analytics 4 sample e-commerce dataset  

---

## Notes

- Sessions were identified using both `user_pseudo_id` and `session_id`.  
- Year-based filtering was applied using the `_TABLE_SUFFIX` field.

---

## Author

**Aleyna Rapata**

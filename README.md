# Olist E-Commerce Analytics



End-to-end e-commerce analytics project built using PostgreSQL, SQL, and Power BI.



The project transforms raw Olist e-commerce data through a structured analytics pipeline, applies data quality checks and dimensional modeling, and delivers an interactive Power BI dashboard for analyzing orders, customers, products, sellers, payments, and reviews.



## Project Architecture



The project follows a layered data architecture:



**Raw → Staging → Analytics → Power BI**



- **Raw:** Source CSV files loaded into PostgreSQL with minimal changes.

- **Staging:** Data cleaning, standardization, deduplication, and data quality flags.

- **Analytics:** Business-ready dimensional model with fact and dimension tables.

- **Power BI:** Interactive reporting layer built on top of the analytics schema.



## Tech Stack



- **PostgreSQL** — relational database and analytics layer

- **SQL** — profiling, cleaning, transformations, modeling, and validation

- **pgAdmin** — database development and testing

- **Power BI** — data modeling, DAX, interactive dashboards, and reporting



## Data Model



The analytics layer uses a dimensional model designed for reporting and filtering in Power BI.



### Dimensions

- `dim\_customer`

- `dim\_product`

- `dim\_seller`

- `dim\_date`

- `dim\_order\_status`



### Facts

- `fact\_order`

- `fact\_order\_item`

- `fact\_order\_payment`

- `fact\_order\_review`



The model separates descriptive dimensions from transactional fact tables and uses one-to-many relationships to support consistent filtering across the dashboard.



## Data Quality \& Transformations



Key transformations and validation steps include:



- Standardized customer, seller, and geolocation fields.

- Removed exact duplicate geolocation records.

- Normalized city names for more reliable geographic matching.

- Added data quality flags for delivery-date and payment anomalies.

- Replaced invalid product weights with `NULL` while preserving issue flags.

- Enriched customer and seller dimensions with average latitude and longitude.

- Added English product category names using the category translation table.

- Added reusable date and order-status dimensions for dashboard filtering.

- Validated fact-table grain, dimension key uniqueness, relationship coverage, and dashboard baseline metrics.



## Dashboard Pages



The Power BI report contains four analytical pages:



### Executive Summary

Provides a high-level view of order volume, item value, delivered item value, freight value, order trends, and delivery status.



### Customers

Analyzes unique customers, repeat customers, repeat customer rate, customer distribution by state, and customer locations.



### Products \& Sellers

Analyzes product categories, seller activity, item value by seller state, and the relationship between item value and freight value.



### Payments \& Reviews

Analyzes payment methods, payment value, installment behavior, review scores, review trends, and review score distribution.



## Key Metrics



Validated dashboard baseline metrics include:



- **Total Orders:** 99,441

- **Unique Customers:** 96,096

- **Repeat Customers:** 2,997

- **Repeat Customer Rate:** 3.1%

- **Total Item Value:** 13.59M

- **Delivered Item Value:** 13.22M

- **Total Freight Value:** 2.25M

- **Total Payment Value:** 16.01M

- **Average Installments:** 2.85

- **Average Review Score:** 4.09

- **Total Reviews:** 99,224



## Dashboard Screenshots



### Executive Summary



!\[Executive Summary](screenshots/01\_executive\_summary.png)



### Customers



!\[Customers](screenshots/02\_customers.png)



### Products \& Sellers



!\[Products \& Sellers](screenshots/03\_products\_sellers.png)



### Payments \& Reviews



!\[Payments \& Reviews](screenshots/04\_payments\_reviews.png)



### Data Model



!\[Data Model](screenshots/05\_data\_model.png)



## Repository Structure



```text

olist-ecommerce-analytics/

├── data/

├── documentation/

│   ├── dax\_measures.md

│   └── assets/

├── powerbi/

│   └── olist\_ecommerce\_analytics.pbix

├── screenshots/

│   ├── 01\_executive\_summary.png

│   ├── 02\_customers.png

│   ├── 03\_products\_sellers.png

│   ├── 04\_payments\_reviews.png

│   └── 05\_data\_model.png

├── sql/

│   ├── 01\_create\_schemas.sql

│   ├── 02\_create\_raw\_tables.sql

│   ├── 03\_data\_profiling.sql

│   ├── 04\_staging\_transformations.sql

│   ├── 05\_analytics\_model.sql

│   └── 06\_model\_validation.sql

└── README.md



## How to Run



1\. Create a PostgreSQL database for the project.

2\. Run the SQL scripts in the `sql/` folder in numerical order:

&#x20;  - `01\_create\_schemas.sql`

&#x20;  - `02\_create\_raw\_tables.sql`

&#x20;  - `03\_data\_profiling.sql`

&#x20;  - `04\_staging\_transformations.sql`

&#x20;  - `05\_analytics\_model.sql`

&#x20;  - `06\_model\_validation.sql`

3\. Load the source Olist CSV files into the corresponding tables in the `raw` schema.

4\. Open `powerbi/olist\_ecommerce\_analytics.pbix`.

5\. Update the PostgreSQL connection settings if required, then refresh the report.



## Dataset



This project uses the Brazilian E-Commerce Public Dataset by Olist.



The raw CSV files are not included in this repository. Download the dataset separately and place the files in the local `data/raw/` folder before running the project.


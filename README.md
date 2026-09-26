# SQL-data-warehouse-project
# [Project Name: SALES DATA WAREHOUSE]

An end-to-end applied data warehousing project designed to transform raw transactional data into a structured, optimized star schema for enterprise reporting and business intelligence analytics.

---

## 📌 Project Overview

This project serves as an **applied implementation** of modern data warehousing principles. The goal was to solve real-world analytical challenges by taking disparate source data through a complete ETL pipeline into a centralized Data Warehouse, enabling fast, reliable reporting on key business metrics.

## 🏗️ Architecture & Pipeline Overview
 >>Will be using the medallion method to create the database into "bronze,silver,gold" as follows<<
<img width="1222" height="618" alt="data warehouse diagram" src="https://github.com/user-attachments/assets/d6bd87cf-0cda-4130-bfe9-e9f29ceddfba" />

1.Data source being used in this project are in the form of CSV files using 2 sources "CRM& ERP" being stored internally.

2.bronze layer: will be used to store RAW data into the first layer without any transformation or integration.

3.silver layer: Data will be loaded from bronze and performing data normalization, data cleansing, standarization 
filling data gaps and enriching the table .

4.gold layer: transforming the data from silver layer into business ready data set using star schema as a data model
and formatting the table into business friendly names to be ready for data analysis and visualisation.


# Data Warehouse SQL Project


A comprehensive, production-ready data warehouse solution demonstrating modern data engineering practices using the Medallion Architecture pattern. 
---

## 🏗️ Architecture Overview

### Medallion Architecture
This project implements a three-layered data warehouse design:



| Layer | Purpose | Characteristics |
|-------|---------|-----------------|
| **Bronze** | Raw Data | CSV ingestion from source systems (ERP, CRM) stored as-is |
| **Silver** | Cleansed Data | Data quality checks, standardization, and normalization |
| **Gold** | Analytics-Ready | Star schema with dimension and fact tables optimized for queries |

---

## 📊 Technical Competencies Demonstrated

This project covers essential data engineering and analytics competencies:

- **Data Architecture & Modeling** – Designing scalable, efficient data warehouses
- **ETL Pipeline Development** – Building robust extract, transform, load processes
- **SQL Optimization** – Writing efficient queries for data transformation and analysis
- **Documentation Standards** – Maintaining clear naming conventions and data catalogs

---

## 📚 Project Scope

### Data Engineering: Building the Warehouse

**Objective:** Consolidate multi-source sales data into a unified, analytical data warehouse.

**Key Activities:**
- Extract and load raw data from ERP and CRM CSV files into the Bronze layer
- Implement data cleansing and transformations in the Silver layer
- Build a star schema (dimensions & facts) in the Gold layer for analytical queries
- Validate data quality and integrity at each layer

**Output:** A production-grade data warehouse ready for reporting and analytics



## 📂 Repository Structure
```
data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)

│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for creating analytical models
│
│
└── README.md                           # Project overview and instructions


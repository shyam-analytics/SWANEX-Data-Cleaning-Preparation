# SWYNEX – Data Cleaning & Preparation

## Dataset
This project uses a **7-table e-commerce relational structure based on the Brazilian E-Commerce Public Dataset by Olist**. The public Olist dataset is a real, anonymised Brazilian e-commerce dataset with customers, orders, order items, payments, reviews, products and sellers.

**Important:** the `raw_data` files here are a prepared training copy with intentional data-quality issues added for this SWYNEX cleaning demonstration. They are not the untouched Olist downloads.

## Seven tables
- customers
- orders
- order_items
- payments
- reviews
- products
- sellers

## Five data-quality issues demonstrated
1. Missing values
2. Duplicate records
3. Incorrect data types
4. Inconsistent categorical values
5. Invalid values/outliers

## Cleaning performed
- Removed exact duplicate records.
- Filled missing customer city with `Unknown`.
- Filled missing product weight/dimensions using median where appropriate.
- Standardized text values with trim/lower/upper/title rules.
- Converted ZIP codes, prices, installments, scores and measurements to numeric types.
- Converted timestamp/date fields to datetime.
- Replaced invalid review scores outside 1–5 with the median valid score.
- Replaced negative/invalid product dimensions and prices using median imputation.
- Filled missing order approval timestamps with the purchase timestamp.
- Kept delivered-date blank for orders that are not delivered.

## Repository structure
```text
SWYNEX-Data-Cleaning-Preparation/
├── raw_data/
├── cleaned_data/
├── data_cleaning_summary.csv
└── README.md
```

## Public source
Brazilian E-Commerce Public Dataset by Olist (Kaggle). The source dataset contains approximately 100,000 Brazilian e-commerce orders and multiple relational tables.

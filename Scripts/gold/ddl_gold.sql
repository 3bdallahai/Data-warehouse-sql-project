/*
===========================================================================================
Create Gold layer Views
===========================================================================================
Script Purpose:  
-   This script preforme transformation and combines the data from the silver layer to the 
	gold views to produce business-ready datasets

-   The gold layer represents the final dimension and fact table (star schema) 
===========================================================================================
*/

PRINT '>>Creating dim_customers View';


IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT  ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		ci.cst_marital_status AS matrial_status,
		CASE WHEN ci.cst_gndr IN ('MALE','FEMALE') THEN ci.cst_gndr
			 ELSE COALESCE(ca.gen,'n/a')
		END AS gender,
		la.cntry AS country,
		ca.bdate AS birthday,
		ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid ;
GO


PRINT '>>Creating dim_product View'


IF OBJECT_ID('gold.dim_product','V') IS NOT NULL
	DROP VIEW gold.dim_product;
GO
CREATE VIEW gold.dim_product AS
SELECT	ROW_NUMBER() OVER (ORDER BY pri.prd_start_dt,pri.prd_key) AS product_key,
		pri.prd_id AS product_id, 
		pri.prd_key AS product_number,
		pri.prd_nm AS product_name,
		pri.cat_id AS category_id,
		pc.cat AS category,
		pc.subcat AS subcategory,
		pc.maintenance,
		pri.prd_cost AS product_cost,
		pri.prd_line AS product_line,
		pri.prd_start_dt AS start_date
		
FROM silver.crm_prod_info pri
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pri.cat_id = pc.id
WHERE pri.prd_end_dt IS NULL ;

GO

PRINT '>>Creating fact_sales View'


IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
SELECT  sls_ord_num AS order_number,
		pr.product_id ,
		c.customer_id,
		sls_order_dt AS order_date,
		sls_ship_dt AS shipping_date,
		sls_due_dt AS due_date,
		sls_sales AS sale,
		sls_quantity AS quantity,
		sls_price AS price
FROM silver.crm_sales_details 
LEFT JOIN gold.dim_product pr
ON sls_prd_key= pr.product_number
LEFT JOIN gold.dim_customers c
ON sls_cust_id= c.customer_id ;
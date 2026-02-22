/*
===========================================================================================
LOAD DATA FROM BRONZE TABLES TO SILVER TABLES
===========================================================================================
Script Purpose:  
-   This script load the data from bronze layer to the silver layer tables 
	removing any data from the table before loading.

-   The script preforms data cleaning for each table 
===========================================================================================
*/
exec silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

	DECLARE @start_time DATETIME , @end_time DATETIME, @batchstart DATETIME, @batchend DATETIME;
	BEGIN TRY
		PRINT '==================================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '==================================================================';

		SET @batchstart = GETDATE()
		PRINT '------------------------------------------------------------------';
		PRINT 'Loading CRM Tables'
		PRINT '------------------------------------------------------------------';
		
		SET @start_time = GETDATE();
		PRINT 'Truncationg table: silver.crm_cust_info '
		TRUNCATE TABLE silver.crm_cust_info
		PRINT 'Inserting Data Into: silver.crm_cust_info'
		INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
		)
		SELECT  
		cst_id ,
		cst_key	,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			 ElSE 'n/a'
		END cst_marital_status,
		CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			 ElSE 'n/a'
		END cst_gndr,
		cst_create_date 
		FROM(
		SELECT *, 
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last 
		FROM bronze.crm_cust_info) t
		WHERE flag_last =1
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds'
		PRINT '-----------'

		SET @start_time = GETDATE();
		PRINT 'Truncationg table: silver.crm_prod_info '
		TRUNCATE TABLE silver.crm_prod_info
		PRINT 'Inserting Data Into: silver.crm_prod_info'
		INSERT INTO silver.crm_prod_info
		(
		prd_id ,
		prd_key	,
		cat_id,
		prd_nm ,
		prd_cost ,
		prd_line ,
		prd_start_dt,
		prd_end_dt 
		)
		SELECT 
		prd_id ,
		REPLACE(SUBSTRING(prd_key,1,5), '-','_') AS cat_key,
		SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
		prd_nm,
		ISNULL(prd_cost,0) ,
		CASE UPPER(TRIM(prd_line))
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'M' THEN 'Mountain'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line ,
		prd_start_dt ,
		LEAD(prd_start_dt) OVER  (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS prd_end_dt 
		FROM bronze.crm_prod_info
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds'
		PRINT '-----------'
		
		SET @start_time = GETDATE();
		PRINT 'Truncationg table: silver.crm_sales_details '
		TRUNCATE TABLE silver.crm_sales_details
		PRINT 'Inserting Data Into: silver.crm_sales_details'
		INSERT INTO silver.crm_sales_details
		(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id, 
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
		)
		SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id, 
		CASE WHEN LEN(sls_order_dt) !=8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,
		CASE WHEN LEN(sls_ship_dt) !=8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE WHEN LEN(sls_due_dt) !=8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE
			WHEN sls_sales IS NULL OR sls_sales <1 THEN sls_quantity *ABS(sls_price) 
			ELSE sls_sales
		END AS sls_sales,
		CASE
			WHEN sls_quantity IS NULL OR sls_quantity <1 THEN sls_sales / ISNULL(sls_price,0) 
			ELSE sls_quantity
		END AS sls_quantity,
		CASE
			WHEN sls_price IS NULL OR sls_price <1 THEN sls_sales / ISNULL(sls_quantity,0) 
			ELSE sls_price
		END AS sls_price
		FROM bronze.crm_sales_details
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds'
		PRINT '-----------'

		PRINT '------------------------------------------------------------------';
		PRINT 'Loading ERP Tables'
		PRINT '------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT 'Truncationg table: silver.erp_cust_az12 '
		TRUNCATE TABLE silver.erp_cust_az12
		PRINT 'Inserting Data Into: silver.erp_cust_az12'
		INSERT INTO silver.erp_cust_az12
		(
		cid,
		bdate,
		gen
		)
		SELECT 
		CASE WHEN TRIM(cid) LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
			ELSE cid
		END AS cid,
		CASE WHEN bdate> GETDATE() THEN NULL
			 ELSE bdate
		END AS bdate,
		CASE WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'FEMALE'
			 WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'MALE'
			 ELSE 'n/a'
		END AS gen
		FROM bronze.erp_cust_az12
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds'
		PRINT '-----------'


		SET @start_time = GETDATE();
		PRINT 'Truncationg table: silver.erp_loc_a101 '
		TRUNCATE TABLE silver.erp_loc_a101
		PRINT 'Inserting Data Into: silver.erp_loc_a101'
		INSERT INTO silver.erp_loc_a101
		(
		cid,
		cntry
		)
		SELECT REPLACE(cid,'-','') AS cid,
		CASE WHEN TRIM(cntry) = ('DE') THEN 'Germany'
			 WHEN TRIM(cntry) IN ('USA','US') THEN 'United States'
			 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
			 ELSE TRIM(cntry)

		END AS cntry
		FROM bronze.erp_loc_a101

		SET @start_time = GETDATE();
		PRINT 'Truncationg table: silver.erp_px_cat_g1v2 '
		TRUNCATE TABLE silver.erp_px_cat_g1v2
		PRINT 'Inserting Data Into: silver.erp_px_cat_g1v2'
		INSERT INTO silver.erp_px_cat_g1v2
		(
		id,
		cat,
		subcat,
		maintenance
		)
		SELECT 
		id,
		cat,
		subcat,
		maintenance 
		FROM bronze.erp_px_cat_g1v2
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds'
		PRINT '-----------'

		SET @batchend = GETDATE();
		PRINT '=====================================================';
		PRINT 'LOADING COMPLETED'
		PRINT 'BATCH LOAD DURATION: ' + CAST(DATEDIFF(second,@batchstart,@batchend) AS NVARCHAR) + 'seconds'
		PRINT '=====================================================';
	END TRY
	
	BEGIN CATCH
		PRINT '=====================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER' + cast(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR STATE' + cast(ERROR_STATE() AS NVARCHAR);
		PRINT '=====================================================';
	END CATCH
END
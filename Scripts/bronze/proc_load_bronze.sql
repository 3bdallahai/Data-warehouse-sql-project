/*
===========================================================================================
LOAD DATA FROM CSV FILES TO BRONZE TABLES
===========================================================================================
Script Purpose:  This script load the data from the csv file preforming a full load by 
removing any data from the table before loading the data from the file 
===========================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME , @end_time DATETIME, @batchstart DATETIME, @batchend DATETIME;
	BEGIN TRY
		PRINT '==================================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '==================================================================';

		SET @batchstart = GETDATE()
		PRINT '------------------------------------------------------------------';
		PRINT 'Loading CRM Files'
		PRINT '------------------------------------------------------------------';

		PRINT '>>TRUNCATING TABLE: crm_cust_info';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>>INSERTING TABLE: crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'D:\Iti\self study\Baraa\My work\datasets\source_crm\cust_info.csv'
		WITH
		(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds'
		PRINT '-----------'

		SET @start_time = GETDATE();
		PRINT '>>TRUNCATING TABLE: crm_prod_info';
		TRUNCATE TABLE bronze.crm_prod_info;
		PRINT '>>INSERTING TABLE: crm_prod_info';
		BULK INSERT bronze.crm_prod_info
		FROM 'D:\Iti\self study\Baraa\My work\datasets\source_crm\prd_info.csv'
		WITH
		(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds'
		PRINT '-----------'

		SET @start_time = GETDATE();
		PRINT '>>TRUNCATING TABLE: crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>>INSERTING TABLE: crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'D:\Iti\self study\Baraa\My work\datasets\source_crm\sales_details.csv'
		WITH
		(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds'
		PRINT '-----------'

		PRINT '------------------------------------------------------------------';
		PRINT 'Loading ERP Files'
		PRINT '------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>TRUNCATING TABLE: erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>>INSERTING TABLE: erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'D:\Iti\self study\Baraa\My work\datasets\source_erp\cust_AZ12.csv'
		WITH
		(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds'
		PRINT '-----------'
	
		SET @start_time = GETDATE();
		PRINT '>>TRUNCATING TABLE: erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>>INSERTING TABLE: erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'D:\Iti\self study\Baraa\My work\datasets\source_erp\LOC_A101.csv'
		WITH
		(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds'
		PRINT '-----------'
	
		SET @start_time = GETDATE();
		PRINT '>>TRUNCATING TABLE: erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>>INSERTING TABLE: erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'D:\Iti\self study\Baraa\My work\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH
		(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
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
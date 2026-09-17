/* 1. truncating and deleting the data from the table and bulk 
inserting the desired data.
Note that this script will delete all the data in the tables and will
replace it with the data inside the file in the mentioned destination
*/--
PRINT'#################################'
PRINT'TRUNCATE data from bronze.crm_cust_info'
TRUNCATE TABLE bronze.crm_cust_info
-- loading the table--

PRINT'#################################'
PRINT'BULK insertion into bronze.crm_cust_info'

BULK INSERT    bronze.crm_cust_info
FROM 'C:\Users\shady\OneDrive\Desktop\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm/cust_info.csv'
WITH(
	FIRSTROW =2,
	FIELDTERMINATOR= ',',
	TABLOCK
);
--CRM_prd_info--
PRINT'#################################'
PRINT'TRUNCATE data from bronze.crm_prd_info '
TRUNCATE TABLE bronze.crm_prd_info
PRINT'#################################'
PRINT'BULK insertion into bronze.crm_prd_info'
BULK INSERT    bronze.crm_prd_info
FROM 'C:\Users\shady\OneDrive\Desktop\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm/prd_info.csv'
WITH(
FIRSTROW = 2,
FIELDTERMINATOR=',',
TABLOCK
);
--CRM_sales_details--
PRINT'#################################'
PRINT'TRUNCATE data from bronze.crm_sales_details'
TRUNCATE TABLE bronze.crm_sales_details
PRINT'#################################'
PRINT'TRUNCATE data from bronze.crm_sales_details'
BULK INSERT    bronze.crm_sales_details
FROM 'C:\Users\shady\OneDrive\Desktop\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm/sales_details.csv'
WITH(
FIRSTROW = 2,
FIELDTERMINATOR=',',
TABLOCK
);
--ERP_cust_az12--
PRINT'#################################'
PRINT'TRUNCATE data from bronze.erp_cust_az12'
TRUNCATE TABLE bronze.erp_cust_az12
PRINT'#################################'
PRINT'BULK insertion into bronze.erp_cust_az12'
BULK INSERT    bronze.erp_cust_az12
FROM 'C:\Users\shady\OneDrive\Desktop\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp/CUST_AZ12.csv'
WITH(
FIRSTROW = 2,
FIELDTERMINATOR=',',
TABLOCK
);
-- ERP_loc_a101--
PRINT'#################################'
PRINT'TRUNCATE data from bronze.erp_loc_a101'
TRUNCATE TABLE bronze.erp_loc_a101
PRINT'#################################'
PRINT'BULK insertion bronze.erp_loc_a101'
BULK INSERT    bronze.erp_loc_a101
FROM 'C:\Users\shady\OneDrive\Desktop\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp/LOC_A101.csv'
WITH(
FIRSTROW = 2,
FIELDTERMINATOR=',',
TABLOCK
);
--ERP_px_cat_g1v2--
PRINT'#################################'
PRINT'TRUNCATE data from bronze.erp_px_cat_g1v2'
TRUNCATE TABLE bronze.erp_px_cat_g1v2
PRINT'#################################'
PRINT'BULK insertion into bronze.erp_px_cat_g1v2'
BULK INSERT    bronze.erp_px_cat_g1v2
FROM 'C:\Users\shady\OneDrive\Desktop\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp/PX_CAT_G1V2'
WITH(
FIRSTROW = 2,
FIELDTERMINATOR=',',
TABLOCK
);

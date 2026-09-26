/*
>>Stored procedure:DML loading silver layer(bronze to silver)<<
                   SCRIPT PURPOSE
the purpose of this script is to 
1.extract from bronze
2.transform data from bronze layer into desired,clean and structured data
3.Insertion of the transformed data into silver layer tables

*/

CREATE OR ALTER PROCEDURE silver.Load_silver
	BEGIN

		PRINT'>>> Truncating data FROM silver.crm_cust_info'
		TRUNCATE TABLE silver.crm_cust_info
		PRINT'>>> Loading data into silver.crm_cust_info'
		INSERT INTO silver.crm_cust_info
		(cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)
		-- for this steps we are normalizing,cleaning and removing inconsistent data before the insertion
		SELECT
			cst_id,
			cst_key,
		-- using trim to clear empty spaces
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
				CASE 
				WHEN UPPER (TRIM(cst_marital_status))='S' THEN 'Single'
				WHEN UPPER (TRIM(cst_marital_status))='M' THEN 'Married'
				ELSE 'N/A'
			END AS cst_marital_status,
		--using case when to normalize and provide more clear info about the gender
		--to make it easy for the user to identify the gender
		--also using Upper to make sure we are selecting all values including lower case values
			CASE 
				WHEN UPPER (TRIM(cst_gndr))='M' THEN 'Male'
				WHEN UPPER (TRIM(cst_gndr))='F' THEN 'Female'
				ELSE 'N/A'
			END AS cst_gndr,
			cst_create_date

		FROM
		(
				SELECT
				*,
				ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flat_last
				FROM bronze.crm_cust_info
				WHERE cst_id IS NOT NULL
		)t 
		WHERE flat_last =1;
		/*======================*/
		/* DmL insertion into silver.crm_prd_info*/
		/*======================*/
		PRINT'>>> Truncating data FROM silver.crm_prd_info'
		TRUNCATE TABLE silver.crm_prd_info
		PRINT'>>> Loading data into silver.crm_prd_info'
		INSERT INTO silver.crm_prd_info
		(prd_id,cat_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt)
		SELECT
			prd_id,
			-- splitting the prd_key as we will be  merging the prd_key 
			--with id in the gold layer
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
			prd_nm,
			-- handling the nulls in the cost as we have values that are null
			-- relacing those nulls with 0 cost
			ISNULL(prd_cost,0) AS prd_cost,
			-- Converting abreaviations to friendly names to be readable for users and handling nullsx
				CASE 
				WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
				WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
				WHEN UPPER(TRIM(prd_line))='S' THEN 'Other sales'
				WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
				ELSE 'N/A'
				END as prd_line,
			CAST(prd_start_dt AS DATE) as prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_date
		FROM bronze.crm_prd_info;
		/*======================*/
		/* DmL insertion into silver.crm_sales_details*/
		/*======================*/
				PRINT '>> Truncating Table: silver.crm_sales_details';
				TRUNCATE TABLE silver.crm_sales_details;
				PRINT '>> Inserting Data Into: silver.crm_sales_details';
				INSERT INTO silver.crm_sales_details (sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price)
				SELECT 
					sls_ord_num,
					sls_prd_key,
					sls_cust_id,
					CASE 
						WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
						ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
					END AS sls_order_dt,
					CASE 
						WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
						ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
					END AS sls_ship_dt,
					CASE 
						WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
						ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
					END AS sls_due_dt,
					CASE 
						WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
							THEN sls_quantity * ABS(sls_price)
						ELSE sls_sales
					END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
					sls_quantity,
					CASE 
						WHEN sls_price IS NULL OR sls_price <= 0 
							THEN sls_sales / NULLIF(sls_quantity, 0)
						ELSE sls_price  -- Derive price if original value is invalid
					END AS sls_price
				FROM bronze.crm_sales_details;
		/*======================*/
		/* DmL insertion into silver.erp_cust_az12*/
		/*======================*/
		PRINT'>>> Truncating data FROM silver.erp_cust_az12'
		TRUNCATE TABLE silver.erp_cust_az12
		PRINT'>>> Loading data into silver.erp_cust_az12'
		INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
		SELECT
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,len(cid))
			ELSE cid
			END CID,
			CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
			END bdate,
			CASE 
			WHEN
				UPPER(TRIM(gen)) IN ('F','Female') THEN 'Female'
			WHEN
				UPPER(TRIM(gen)) IN ('M','Male') THEN 'Male'
			ELSE 'N/A'
			END gen
		FROM bronze.erp_cust_az12;
		/*======================*/
		/* DmL insertion into silver.erp_loc_a101*/
		/*======================*/
		PRINT'>>> Truncating data FROM silver.erp_loc_a101'
		TRUNCATE TABLE silver.erp_loc_a101
		PRINT'>>> Loading data into silver.erp_loc_a101'
		INSERT INTO silver.erp_loc_a101(cid,cntry)
		SELECT
			REPLACE(cid,'-','') AS cid,
			CASE WHEN 
				TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN
				TRIM(cntry) IN ('USA','US') THEN 'States'
				WHEN
				cntry IS NULL OR TRIM(cntry) Like'' THEN 'N/A'
				WHEN
				TRIM(cntry) Like'' THEN 'N/A'
				ELSE cntry
				END cntry
		FROM bronze.erp_loc_a101;

		/*======================*/
		/* DML insertion into silver.erp_px_cat_g1v2*/
		/*======================*/

		PRINT'>>> Truncating data FROM silver.erp_px_cat_g1v2'
		TRUNCATE TABLE silver.erp_px_cat_g1v2
		PRINT'>>> Loading data into silver.erp_px_cat_g1v2'
		INSERT INTO silver.erp_px_cat_g1v2(
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
		FROM bronze.erp_px_cat_g1v2;

		/*======================*/
		/* DmL insertion into silver.erp_loc_a101*/
		/*======================*/
		PRINT'>>> Truncating data FROM silver.erp_loc_a101'
		TRUNCATE TABLE silver.erp_loc_a101
		PRINT'>>> Loading data into silver.erp_loc_a101'
		INSERT INTO silver.erp_loc_a101(cid,cntry)
		SELECT
			REPLACE(cid,'-','') AS cid,
			CASE WHEN 
				TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN
				TRIM(cntry) IN ('USA','US') THEN 'States'
				WHEN
				cntry IS NULL OR TRIM(cntry) Like'' THEN 'N/A'
				WHEN
				TRIM(cntry) Like'' THEN 'N/A'
				ELSE cntry
				END cntry
		FROM bronze.erp_loc_a101;
END

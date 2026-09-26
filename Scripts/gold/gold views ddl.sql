/* >>DDL script: gold layer(creating views from silver layer)<<
                 SCRIPT PURPOSE
>>this script will create views for gold layers by merging and creating new data sets using the 
findings in the silver layer
>>the gold layer represent the final dimention and fact tables using"star schema"<<
                 FUNCTIONALITY
>>performs transformation on the data from silver layer 
to produce clean, enriched, readable and ready-business data-set
                USAGE
can be used directly for analytical purposes
*/
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/* creating dimension for products*/
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

IF OBJECT_ID('gold.dim_product', 'V') IS NOT NULL
    DROP VIEW gold.dim_product;
GO
CREATE VIEW gold.dim_product AS
SELECT
	ROW_NUMBER() OVER(ORDER BY PA.prd_start_dt,PA.prd_key) AS product_key,
	PA.prd_id AS product_id,
	PA.prd_key AS product_number,
	PA.prd_nm AS product_name,
	PA.cat_id AS category_id,
	PC.cat AS category,
	pc.maintenance AS maintenance,
	pc.subcat AS sub_category,
	PA.prd_cost AS product_cost,
	PA.prd_line AS product_line,
	PA.prd_start_dt AS product_start_date
FROM silver.crm_prd_info AS PA
LEFT JOIN silver.erp_px_cat_g1v2 AS PC
ON		  PA.cat_id=pc.id
WHERE prd_end_dt IS NULL -- filtering and removing all historical data

SELECT *
FROM GOLD.DIM_PRODUCT
	

/* the purpose of this code is to create customers dimension view to enrich and 
populate the table with new data and by merging the data we make sure that
we are fixing inconsistent data*/
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
		SELECT
			ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,--adding unique identifier for each customer"surrigate key"
			ci.cst_id AS customer_id,
			ci.cst_key AS customer_number,
			ci.cst_firstname AS first_name,
			ci.cst_lastname AS last_name,
			ci.cst_marital_status AS marital_status,
			ca.bdate AS birth_date,
			la.cntry AS country,
			-- enriching the bdate column by merging both bdate in CRM and ERP to fill gaps
			CASE WHEN
					ci.cst_gndr !='N/A' THEN ci.cst_gndr 
					ELSE COALESCE(ca.gen,'N/A')
					END AS gender,
			ci.cst_create_date AS customer_create_date
			
		FROM silver.crm_cust_info AS ci
		LEFT JOIN silver.erp_cust_az12 AS ca
		ON		  ci.cst_key=ca.cid
		LEFT JOIN silver.erp_loc_a101 AS la
		ON		  CI.cst_key=la.cid
	
	/* creating fact table for sales*/
	IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

	CREATE VIEW gold.fact_sales AS
	SELECT 
		sd.sls_ord_num AS order_number,
		pr.product_key AS product_key,
		cu.customer_key AS customer_key,
		sd.sls_order_dt AS order_date,
		sd.sls_ship_dt AS shipping_date,
		sd.sls_due_dt AS due_date,
		sd.sls_sales AS sales_amount,
		sd.sls_quantity AS quantity,
		sd.sls_price AS price 
	FROM silver.crm_sales_details AS sd
	LEFT JOIN gold.dim_product AS pr
	ON		  sd.sls_prd_key=pr.product_number
	LEFT JOIN gold.dim_customers AS cu
	ON		 sd.sls_cust_id= cu.customer_id
END

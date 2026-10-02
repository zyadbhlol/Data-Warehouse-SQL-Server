CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id                              AS customer_id,
    ci.cst_key                             AS customer_number,
    ci.cst_firstname                       AS first_name,
    ci.cst_lastname                        AS last_name,
    loc.cntry                              AS country,
    ci.cst_marital_status                  AS marital_status,
    CASE
    WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
    ELSE COALESCE(az.gen, 'n/a')
    END                                    AS gender,
    az.bdate                               AS birthdate,
    ci.cst_create_date                     AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 az  ON ci.cst_key = az.cid
LEFT JOIN silver.erp_loc_a101  loc ON ci.cst_key = loc.cid;
GO

CREATE OR ALTER VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY p.prd_start_dt, p.prd_id) AS product_key,
    p.prd_id                                               AS product_id,
    p.prd_key                                              AS product_number,
    p.prd_nm                                               AS product_name,
    p.cat_id                                               AS category_id,
    c.cat                                                  AS category,
    c.subcat                                               AS subcategory,
    c.maintenance,
    p.prd_cost                                             AS cost,
    p.prd_line                                             AS product_line,
    p.prd_start_dt                                         AS start_date
FROM silver.crm_prd_info p
LEFT JOIN silver.erp_px_cat_g1v2 c ON p.cat_id = c.id
WHERE p.prd_end_dt IS NULL;
GO

CREATE OR ALTER VIEW gold.fact_sales AS
SELECT
    s.sls_ord_num  AS order_number,
    dp.product_key,
    dc.customer_key,
    s.sls_order_dt AS order_date,
    s.sls_ship_dt  AS ship_date,
    s.sls_due_dt   AS due_date,
    s.sls_sales    AS sales_amount,
    s.sls_quantity AS quantity,
    s.sls_price    AS unit_price
FROM silver.crm_sales_details s
LEFT JOIN gold.dim_products  dp ON s.sls_prd_key = dp.product_number
LEFT JOIN gold.dim_customers dc ON s.sls_cust_id = dc.customer_id
GO
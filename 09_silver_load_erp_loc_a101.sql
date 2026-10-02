USE bisDataWarhouse
GO

TRUNCATE TABLE [silver].[erp_loc_a101];
INSERT INTO [silver].[erp_loc_a101] (cid, cntry)
SELECT
cid,
CASE
WHEN TRIM(cntry) = 'DE' THEN 'Germany'
WHEN TRIM(cntry) IN ('US', 'USA', 'United States') THEN 'United States'
WHEN TRIM(cntry) =  '' OR cntry IS NULL THEN 'n/a'
ELSE TRIM(cntry)
END AS cntry
FROM [bronze].[erp_loc_a101];
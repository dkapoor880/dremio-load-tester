CREATE OR REPLACE VDS 
HealthCheck.Preparation.results 
AS 
SELECT 
	CASE WHEN SPLIT_PART(replace(SPLIT_PART(queryTextFirstChunk, ' ',2), '--Test-', ''), '|', 2) = 'CONCURRENCY' THEN 
        replace(SPLIT_PART(queryTextFirstChunk, ' ',2), '--Test-', '') 
    ELSE NULL 
    END AS "query_header", 
	CASE WHEN POSITION('Q' IN ltrim(SPLIT_PART(queryTextFirstChunk, ' ',1), '-')) > 0 THEN 
        ltrim(SPLIT_PART(queryTextFirstChunk, ' ',1), '-') 
    ELSE NULL 
    END AS jmeterQueryId, 
	* 
FROM PSHealthCheck.results
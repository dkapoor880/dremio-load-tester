CREATE OR REPLACE VDS 
HealthCheck.Application.LoadTestFailedQueries 
AS 
SELECT testId, jmeterQueryId, COUNT(jmeterQueryId) AS numFailures 
FROM HealthCheck.Application.LoadTestResults 
WHERE outcome = 'FAILED' 
GROUP BY testId, jmeterQueryId 
ORDER BY testId, jmeterQueryId
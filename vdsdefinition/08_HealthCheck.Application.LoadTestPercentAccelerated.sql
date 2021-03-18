CREATE OR REPLACE VDS 
HealthCheck.Application.LoadTestPercentAccelerated 
AS 
SELECT 
    originalTestId, 
    testId, 
    outcome, 
    COUNT(testId) AS testCount, 
    SUM(CASE WHEN accelerated = 'true' THEN 1 ELSE 0 END) AS acceleratedCount, 
    SUM(CASE WHEN accelerated = 'true' THEN 1 ELSE 0 END) / CAST(COUNT(testId) AS FLOAT) * 100 AS pctAccelerated 
FROM HealthCheck.Application.LoadTestResults 
GROUP BY originalTestId, testId, outcome 
HAVING outcome = 'COMPLETED' 
ORDER BY originalTestId asc
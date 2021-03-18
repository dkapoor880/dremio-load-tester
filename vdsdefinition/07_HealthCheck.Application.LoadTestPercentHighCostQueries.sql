CREATE OR REPLACE VDS 
HealthCheck.Application.LoadTestPercentHighCostQueries 
AS 
SELECT 
    originalTestId, 
    testId, 
    outcome, 
    COUNT(testId) as testCount, 
    SUM(CASE WHEN queueName = 'High Cost User Queries' THEN 1 ELSE 0 END) AS highCostCount, 
    SUM(CASE WHEN queueName = 'High Cost User Queries' THEN 1 ELSE 0 END) / CAST(COUNT(testId) AS FLOAT) * 100 AS pctHighCost 
FROM HealthCheck.Application.LoadTestResults 
GROUP BY originalTestId, testId, outcome 
HAVING outcome = 'COMPLETED' 
ORDER BY originalTestId ASC
CREATE OR REPLACE VDS 
HealthCheck.Application.LoadTestQueueUsage 
AS 
SELECT
    originalTestId,
    testId, 
    queueName, 
    numQueriesPerQueue, 
    (CAST(numQueriesPerQueue AS FLOAT) / 
     CAST(SUM (numQueriesPerQueue) OVER (PARTITION BY testId) AS FLOAT)) * 100 as queueUsagePct 
FROM
    (SELECT 
        originalTestId,
        testId, 
        queueName, 
        COUNT(queueName) as numQueriesPerQueue 
    FROM HealthCheck.Application.LoadTestResults
    GROUP BY originalTestId, testId, queueName) a 
ORDER BY 
    a.originalTestId ASC, 
    a.queueName ASC
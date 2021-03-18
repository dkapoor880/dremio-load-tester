CREATE OR REPLACE VDS 
HealthCheck.Application.LoadTestAvgQueueEnqueuedTime 
AS 
SELECT testId, queueName, AVG(enqueuedTime) avgEnqueuedTimeMS 
FROM HealthCheck.Application.LoadTestResults 
WHERE queueName != '' 
GROUP BY testId, queueName 
ORDER BY testId ASC, queueName DESC 
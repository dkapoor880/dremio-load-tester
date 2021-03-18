CREATE OR REPLACE VDS 
	HealthCheck.Application.LoadTestDescription 
AS 
SELECT 
	originalTestId, 
	testId, 
	numExecutors, 
	numConcurrentUsers, 
	numQPU,
	dremioHost,
	testDescription, 
	MIN(queryStartTime) AS testStartTime, 
	MAX(queryFinishTime) AS testFinishTime, 
	TIMESTAMPDIFF(SECOND, MIN(queryStartTime), MAX(queryFinishTime)) AS testDurationSecs 
FROM HealthCheck.Application.LoadTestResults 
GROUP BY 
	originalTestId, 
	testId, 
	numExecutors, 
	numConcurrentUsers, 
	numQPU,
	dremioHost,
	testDescription	
/*HAVING COUNT("testId") > 10*/ 
ORDER BY 
	originalTestId ASC

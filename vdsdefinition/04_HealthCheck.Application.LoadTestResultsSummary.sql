CREATE OR REPLACE VDS 
HealthCheck.Application.LoadTestResultsSummary 
AS 
  SELECT 
    testId, 
    jmeterQueryId,  
	numExecutors, 
	numConcurrentUsers,  
	numQPU, 
    COUNT(*) cnt, 
	queueName, 
	ROUND(AVG(queryCost)) AS avgQueryCost, 
    ROUND(AVG(poolWaitTime) / 1000.0, 3) as avgPoolWaitTimeSec, 
    ROUND(AVG(planningTime) / 1000.0, 3) as avgPlanningTimeSec,
	ROUND(AVG(enqueuedTime)/1000.0, 3)  as avgEnqueuedTimeSec, 
	ROUND(AVG(executionTime) / 1000.0, 3) AS avgExecutionTimeSec, 
    ROUND(AVG(totalDurationMS)/1000.0, 3)  as avgTotalDurationSec, 
    ROUND(STDDEV(totalDurationMS)/1000.0, 3) as stdDevDurationSec, 
    ROUND(STDDEV(totalDurationMS) / AVG(totalDurationMS) * 100) as coeffVarPercent, 
    ROUND(MIN(totalDurationMS)/1000.0, 3) as minTotalDurationSec, 
    ROUND(MAX(totalDurationMS)/1000.0, 3) as maxTotalDurationSec 
  FROM 
    HealthCheck.Application.LoadTestResults 
  WHERE 
    outcome='COMPLETED' 
  GROUP BY 
    testId, 
    jmeterQueryId, 
	numExecutors, 
	numConcurrentUsers,  
	numQPU, 
	queueName 
  Order by  
    testId, 
    coeffVarPercent DESC

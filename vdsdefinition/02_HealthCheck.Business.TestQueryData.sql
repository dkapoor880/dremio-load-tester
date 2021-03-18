CREATE OR REPLACE VDS 
HealthCheck.Business.TestQueryData 
AS 
SELECT 
	CAST(SPLIT_PART(query_header, '|', 1) AS INTEGER) AS testId, 
	TO_TIMESTAMP(CAST(SPLIT_PART(query_header, '|', 1) AS INTEGER)) AS testStartTime, 
	jmeterQueryId, 
	SPLIT_PART(query_header, '|', 2) AS testType, 
	CAST(SPLIT_PART(SPLIT_PART(query_header, '|', 3), '-', 2) AS INTEGER) AS numExecutors, 
	CAST(SPLIT_PART(SPLIT_PART(query_header, '|', 4), '-', 2) AS INTEGER) AS numConcurrentUsers, 
	CAST(SPLIT_PART(SPLIT_PART(query_header, '|', 5), '-', 2) AS INTEGER) AS numQPU, 
	CAST(SPLIT_PART(SPLIT_PART(query_header, '|', 6), '-', 2) AS INTEGER) AS usersRampTime, 
	CAST(SPLIT_PART(SPLIT_PART(query_header, '|', 7), '-', 2) AS INTEGER) AS userId, 
	SPLIT_PART(SPLIT_PART(query_header, '|', 8), '-', 2) AS dremioHost, 
	SPLIT_PART(SPLIT_PART(query_header, '|', 9), '-', 2) AS testDescription, 
	CAST(REGEXP_REPLACE(SPLIT_PART(SPLIT_PART(query_header, '|', 10), '-', 2), '\r\nSELECT', '') AS INTEGER) AS queryCounter, 
	"finish" - ("start" - poolWaitTime) AS totalDurationMS, 
	queryId, 
	/*"schema", */
	queryTextFirstChunk as queryText, 
	queryChunkSizeBytes, 
	nrQueryChunks, 
	"start", 
	finish, 
	outcome, 
	username, 
	requestType, 
	queryType, 
	queueName, 
    poolWaitTime, 
	planningTime, 
	enqueuedTime, 
	executionTime, 
	accelerated, 
	parentsList, 
	LIST_TO_DELIMITED_STRING(reflectionRelationships, '|') AS reflectionRelationships, 
	inputRecords, 
	inputBytes, 
	outputRecords, 
	outputBytes, 
	queryCost, 
	CONCAT(CONCAT(CONCAT('http://', SPLIT_PART(SPLIT_PART(query_header, '|', 8), '-', 2)), ':9047/jobs?#'), queryId) AS profileUrl 
FROM 
	HealthCheck.Preparation.results 
WHERE 
	SPLIT_PART(query_header, '|', 2) IN ('SEQUENTIAL', 'CONCURRENCY') 
	AND queryType = 'JDBC'
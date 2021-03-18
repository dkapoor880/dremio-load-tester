#!/usr/bin/python
import os
import requests
import sys
import time
import yaml
import argparse
import json


def login(url, user, password, tls_verify):
    login_path = '/apiv2/login'
    login_data = {"userName": user, "password": password}

    response = requests.post(url+login_path, json=login_data, verify=tls_verify, timeout=30)
    if response.status_code != 200:
        sys.exit('Login failure, Status code : {}'.format(response.status_code))
    else:
        return '_dremio'+response.json()['token']


def post_catalog(url, auth_string, payload, sleep_time=100, tls_verify=True):
    assert sleep_time > 0
    response = requests.post(url + "/api/v3/catalog", headers={'Authorization': auth_string, "content-type": "application/json"}, verify=tls_verify,
                            data=payload)
    return response


def query(url, auth_string, query, context=None, sleep_time=10, tls_verify=True):
    assert sleep_time > 0
    job = requests.post(url + "/api/v3/sql", headers={'Authorization': auth_string}, verify=tls_verify, json={"sql": query, "context": context})
    job_id = job.json()["id"]
    while True:
        state = get_job_status(url, auth_string, job_id, tls_verify)
        if state["jobState"] == "COMPLETED":
            status = state["jobState"]
            break
        if state["jobState"] in {"CANCELED", "FAILED"}:
            # todo add info about why did it fail
            if state["errorMessage"]:
                status = state["jobState"] + ": " + state["errorMessage"]
            else:
                status = state["jobState"]
            break
        time.sleep(sleep_time)
    return status


def get_job_status(url, auth_string, queryId, tls_verify):
    job_status_path = '/api/v3/job/' + queryId
    response = requests.get(url+job_status_path, headers={'Authorization': auth_string}, verify=tls_verify)
    if response.status_code != 200:
        return None
    else:
        return response.json()


def main():
    catalog = [
        "space.HealthCheck", 
		"folder.HealthCheck.Preparation",
		"folder.HealthCheck.Business", 
		"folder.HealthCheck.Application"]

    try:
        if not os.path.isdir(vds_def_dir):
            raise Exception("Directory " + vds_def_dir + " does not exist")
        if not tls_verify:
            requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)
        auth_string = login(url, user, password, tls_verify)
        # Create space and folders from the catalog list
        for item in catalog:
            entity = item.split(".");
            entityType = entity[0];
            for i in range(1, len(entity)):
                entity[i] = '\"' + entity[i] + '\"'
            entityName = ",".join(entity[1:])

            if entityType == "space":
                payload = "{\"entityType\": \"" + entityType + "\", \"name\": " + entityName + "}"
            else:
                #assume entityType is folder
                payload = "{\"entityType\": \"" + entityType + "\", \"path\": [" + entityName + "]}"
            response = post_catalog(url, auth_string, payload)
            if response.status_code == 200:
                print(entityType + " " + entityName.replace(",", ".") + " created.")
            elif response.status_code == 409:
                print(entityType + " " + entityName.replace(",", ".") + " already exists, continuing")
            else:
                raise Exception("Unexpected Response Code while creating " + entityType + " " + entityName.replace(",", "\\.") + ": " + response.text)
        sqlFiles = os.listdir(vds_def_dir)
        for sqlFile in sorted(sqlFiles):
            if sqlFile.endswith(".sql"):
                print("Processing SQL file: " + sqlFile)
                str = open(os.path.join(vds_def_dir, sqlFile), 'r').read()
                status = query(url, auth_string, str, None, 2, tls_verify)
                print(status)
    except Exception as e:
        print("Failed to create VDS Definitions for Load Test Analysis: " + str(e))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Script to refresh metadata for the specified PDS in Dremio')
    parser.add_argument('--url', type=str, help='Dremio url, example: https://localhost:9047', required=True)
    parser.add_argument('--user', type=str, help='Dremio user', required=True)
    parser.add_argument('--password', type=str, help='Dremio user password', required=True)
    parser.add_argument('--tls-verify', action='store_true')
    parser.add_argument('--vds-def-dir', type=str, help='Fully qualified path to PDS to refresh', required=True)

    args = parser.parse_args()
    url = args.url
    user = args.user
    password = args.password
    vds_def_dir = args.vds_def_dir
    tls_verify = args.tls_verify
    main()

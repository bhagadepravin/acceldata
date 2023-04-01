# Pulse

## Overview
Acceldata Pulse provides real-time intelligence across all your observability needs. You can build your workflows, and extend alerts for business requirements with algorithmic anomaly detection. Acceldata Pulse also provides recommendations and automation to keep your data systems performant, secure, and reliable.

Acceldata Pulse provides the following features.

- Monitor and analyze hundreds of jobs to find outliers.
- Debug applications efficiently using the entire application history.
- Reduce MTTR from hours to minutes with advanced root cause analysis and error correlation.
- Receive custom recommendations tailored for your system.
- Integrate natively into data engines to extract data.
- Manage all of your data systems with a powerful JavaScript- based dashboard builder.

![image](https://user-images.githubusercontent.com/28974904/229293219-59d9d58d-19da-44de-9b3e-08eb38b984e8.png)

## [Pulse Architecture](https://docs.acceldata.io/pulse/architecture)

![image](https://user-images.githubusercontent.com/28974904/229293849-33a9e7a2-6bce-4f2e-b549-7790e8770ada.png)

![image](https://user-images.githubusercontent.com/28974904/229295857-1bb86f1a-03c5-4d43-b4b7-de481c4cf654.png)


* [Dashboard](https://docs.acceldata.io/pulse/dashboard)
  - [Recommendations](https://docs.acceldata.io/pulse/dashboard#recommendations)
  - [Pulse Ribbon](https://docs.acceldata.io/pulse/dashboard#pulse-ribbon)
     - Cluster
     - Health
     - Alerts
     - [User Management](https://docs.acceldata.io/pulse/user-management#overview)
     - View
     - User
     - Filtering by Time
* [User Management](https://docs.acceldata.io/pulse/user-management#overview)
  - Roles
    - Creating a Role
    - Viewing Role details
    - Modify a Role
    - Deleting a Role
  - Users
    - Creating a User 
    - Modifying a User
    - Deleting a User
  - SSH Keys
    - Creating an SSH Key
    - Deleting an SSH Key
  - Keytabs
    - Uploading a Keytab
    - Deleting the Keytab

* [HDFS Dashboard](https://docs.acceldata.io/pulse/hdfs-dashboard)
<sub>Enabling HDFS monitoring on Pulse gives you an in-depth overview of the Hadoop file system within your cluster.</sub>
  - Charts on HDFS Dashboard
  - [HDFS Analytics](https://docs.acceldata.io/pulse/hdfs-analytics)
  - [HDFS File Explorer](https://docs.acceldata.io/pulse/hdfs-file-explorer)

* Yarn Dashboard
  - [YARN Capacity](https://docs.acceldata.io/pulse/yarn-capacity)
  - [YARN Services](https://docs.acceldata.io/pulse/services)
  - [Application Explorer](https://docs.acceldata.io/pulse/application-explorer)
  - [YARN-Application Explorer](https://docs.acceldata.io/pulse/yarn-application-explorer)

* [MR Dashboard](https://docs.acceldata.io/pulse/mrdashboard)
  - [MapReduce Queries](https://docs.acceldata.io/pulse/mapreduce-queries)
  - [MapReduce Query Details](https://docs.acceldata.io/pulse/mapreduce-query-details)
  - [MapReduce Tables](https://docs.acceldata.io/pulse/mapreduce-tables)
  - [MapReduce Details](https://docs.acceldata.io/pulse/mapreduce-details)

* [Spark Dashboard](https://docs.acceldata.io/pulse/spark-dashboard)
  - [Spark Batch Details](https://docs.acceldata.io/pulse/spark-batch-details)
  - [Spark Jobs](https://docs.acceldata.io/pulse/spark-jobs)
    - [Spark Job Details](https://docs.acceldata.io/pulse/spark-job-details)
       - Summary Panel
       - Job Trends
       - Configurations
       - Spark Stages
       - Timeseries Information
       - Reports
       - Application Logs
  - [Spark Stage Details](https://docs.acceldata.io/pulse/spark-stage-details)
     - Tasks Analysis by Metrics

* [Tez Dashboard](https://docs.acceldata.io/pulse/tez-dashboard)
<sub>Using Pulse, you can monitor the tables and queries executed in Tez. </sub>
  - [Tez Queries](https://docs.acceldata.io/pulse/tez-queries)
  - [Tez Query Details](https://docs.acceldata.io/pulse/tez-query-details)
    - Summary Panel
    - Query Trends
    - Recommendations
    - Query
    - YARN Diagnostics
    - Map Reduce Stats
    - Query Execution Metrics
    - Query DAG and Plan
  - [Tez Tables](https://docs.acceldata.io/pulse/tez-tables)
     - [Tez Table Details](https://docs.acceldata.io/pulse/tez-table-details)

* [Alerts](https://docs.acceldata.io/pulse/alerts)
  - [Creating Alerts](https://docs.acceldata.io/pulse/creating-an-alert)
  - [Incidents](https://docs.acceldata.io/pulse/incidents)
  - [Stock Alerts](https://docs.acceldata.io/pulse/stock-alerts)

* [Enabling Notifications for All Channels](https://docs.acceldata.io/pulse/enabling-notifications-for-all-channels)
  - Email
  - Slack
  - PagerDuty Notifications
  - Telegram
  - Line
  - ServiceNow
  - Webhooks
  - Actions
  - Opsgenie
  - File Log
  - Hangouts
  - Jira

* [Database Explorer](https://docs.acceldata.io/pulse/database-explorer)

* [Nodes](https://docs.acceldata.io/pulse/nodes-dashboard)
  - Nodes Dashboard
    - Overall
    - Utilization
    - Search Option
    - Sort By
    - Utilization Table
  - [Node Details](https://docs.acceldata.io/pulse/node-details)
  - [Node Aggregated Details](https://docs.acceldata.io/pulse/node-aggregated-details)

* [Logs](https://docs.acceldata.io/pulse/application-logs)
  - [Audit Logs](https://docs.acceldata.io/pulse/audit-logs)
  - [Query Examples](https://docs.acceldata.io/pulse/query-examples)

* [Dashplot](https://docs.acceldata.io/pulse/dashplot)
  - Dashplot Visualizations
  - Creating New Visualizations
  - Adding Visualizations
  - Editing Visualizations
  - Cloning Visualizations
  - Observing Visualizations
  - [Dashboard](https://docs.acceldata.io/pulse/dashboards)
     - [Using Variables](https://docs.acceldata.io/pulse/using-variables)
  - [Visualization](https://docs.acceldata.io/pulse/visualization)
  - Visualization Dashboard

* [Actions](https://docs.acceldata.io/pulse/actions)
  - [Action Playbooks](https://docs.acceldata.io/pulse/action-playbooks)
  - [Custom Playbook](https://docs.acceldata.io/pulse/custom-playbook)

* [Chargeback Reports](https://docs.acceldata.io/pulse/chargeback-reports)
  - [Yarn Reports](https://docs.acceldata.io/pulse/yarn-reports)
  - [Node Label Reports](https://docs.acceldata.io/pulse/node-label-reports)

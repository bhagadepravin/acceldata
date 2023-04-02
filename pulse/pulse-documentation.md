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

<img width="861" alt="image" src="https://user-images.githubusercontent.com/28974904/229337305-0d142d4b-c661-41f2-a7e0-1852dddc8531.png">

Pulse collects logs from various systems, stores them, and displays insights and analyses as an observability platform. **Acceldata agents** run different platforms such as Spark, Hive, Tez, or HBase. For each of the platforms, Pulse collects multiple other metrics. For example, **Yarn metrics** are collected for **Spark**, **Time series data** are collected for **Hive**, **App data** are collected for **Tez**.

The data from the metrics are collected in one of the following three Acceldata Services such as Database, Time Series Data or Log Indices, and It is deployed via docker container.

<img width="508" alt="image" src="https://user-images.githubusercontent.com/28974904/229342330-ba6f4ca8-7053-4c03-bff4-02f2519b7f10.png">

## Platform Architecture
<img width="992" alt="image" src="https://user-images.githubusercontent.com/28974904/229337384-57fc1144-4828-42e4-a960-7f2d3f43d20d.png">

The following diagram displays how various Pulse components such as **User Interface(UI), Data Stores,** and **Notifications** interact with each other to process the data.

Information from the **Distributed Data Stores** is processed into the **Time Series Database(TSDB), Document Store,** and **Search DB**. Different services then read the data from the Data Stores in Pulse. Finally, they are displayed to the user through the **UI** or the **notification** channels.

## Deployment Architecture
<img width="965" alt="image" src="https://user-images.githubusercontent.com/28974904/229337335-de159340-3a29-4993-bae9-fae82d33c97f.png">


The Hadoop clusters such as **Master Nodes, Compute Nodes,** and **Edge Nodes** contain the **Acceldata Agents**. All the nodes report to Acceldata Server. The **Acceldata Server** includes **MongoDB, TSDB, Accelo CI, AD AI,** and **AD UI.**

<img width="986" alt="image" src="https://user-images.githubusercontent.com/28974904/229337327-7a0323e1-f37a-4d2b-9127-1dc0e77b07e8.png">


<img width="855" alt="image" src="https://user-images.githubusercontent.com/28974904/229337427-44b89d17-0042-4b8b-b52a-639b486596ed.png">



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

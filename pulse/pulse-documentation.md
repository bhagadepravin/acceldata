<p align="center">
  <a href="[https://docs.acceldata.io/pulse]">
    <img alt="Jamify" src="https://user-images.githubusercontent.com/28974904/229342524-8e473930-911d-4233-b411-0357b6d42fe9.png" />
  </a>
</p>
<h1 align="center">
   Pulse <br/>
</h1>

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

<img width="965" alt="image" src="https://user-images.githubusercontent.com/28974904/229342330-ba6f4ca8-7053-4c03-bff4-02f2519b7f10.png">

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


What components get deployed with **accelo deploy core** ?
List of **CORE** components:

1. **ad-graphql** - Container service running all UI components, creates connection to internal datasources
2. **ad-streaming** - Container service used for collecting events multiple internal sources such as connectors, kafka, impala and store into respective datastores/databases
3. **ad-db** - Container service running MongoDB instance
4. **ad-tsdb** - (Decommissioned 3.x onwards) Container service running Influx DB instance
5. **ad-vmselect** - Container service used for fetching and merging data from vmstorage during queries
6. **ad-vmstorage** - Container service used for storing timeseries data
7. **ad-vminsert** - Container service used for spreading timeseries across available storage nodes

 
What are the available addon components and their purpose ?

List of **ADDON** components:

1. **Acceldata SQL Analysis service** - **ad-sql-analyser** - Service that connects directly with Hive metastore DB and fetch table stats and displays on following UI panels

<p align="center">
  <a href="[https://docs.acceldata.io/pulse]">
    <img alt="Jamify" src="https://user-images.githubusercontent.com/28974904/229343113-55430f2c-a889-4363-8e33-d7e608560f80.png" />
  </a>
</p>
<h4 align="center">
   Database Explorer <br/>
</h4>

2. **Alerts** (Agents MUST be configured) - **ad-alerts** - Service that enable stock alerts based on available metrics and connect with MongoDB for storing incidents and new alert details

<p align="center">
  <a href="[https://docs.acceldata.io/pulse]">
    <img alt="Jamify" src="https://user-images.githubusercontent.com/28974904/229343239-167c9ded-3b3c-489a-8735-b36677bea92e.png" />
  </a>
</p>
<h4 align="center">
   Alerts & Incidents <br/>
</h4>

3. **Core Connectors** -  **ad-connectors** - Service that creates connection to Namenode URL for reading Hive event logs stored on **HDFS**, connects with YARN to fetch latest applications**(Spark/Tez/MR)** and collect stats on defined polling intervals


<p align="center">
  <a href="[https://docs.acceldata.io/pulse]">
    <img alt="Jamify" src="https://user-images.githubusercontent.com/28974904/229343295-68735830-6661-47db-82b5-d91d74c6c97e.png" />
  </a>
</p>
<h4 align="center">
    YARN Capacity/App Explorer, Tez, LLAP, Spark, Hive on MR, Hive on Spark<br/>
</h4>

4. **Dashplot** - **ad-dashplots** & **ad-pg** - Service that creates connection to different datastores and provide studio to create and store custom reports

<p align="center">
  <a href="[https://docs.acceldata.io/pulse]">
    <img alt="Jamify" src="https://user-images.githubusercontent.com/28974904/229343353-2ed37e4f-f719-4ab4-8e29-f920a1244ba1.png" />
  </a>
</p>
<h4 align="center">
    Dashplots<br/>
</h4>

5. **Director** (Agents MUST be configured) - **ad-director** - Service that enable an ansible framework backed automation utility to run any playbook on accessible host via Pulse UI

<p align="center">
  <a href="[https://docs.acceldata.io/pulse]">
    <img alt="Jamify" src="https://user-images.githubusercontent.com/28974904/229343405-aa4d53e9-47b0-4a66-8c9b-a8723b9b72c5.png" />
  </a>
</p>
<h4 align="center">
    Actions & Executions<br/>
</h4>


6. **FS Analytics V2** - **ad-fsanalyticsv2-connector** - Service that connects with one of the Namenode UI to fetch FSImage, store critical attributes (such as file size, last modified, user, last accessed timestamp) as an index entity in Elastic search and run aggregated queries and store these reports on MongoDB(ad-db), this cycle is scheduled to run once per day

<p align="center">
  <a href="[https://docs.acceldata.io/pulse]">
    <img alt="Jamify" src="https://user-images.githubusercontent.com/28974904/229343481-72b8f245-619e-4eca-ba8d-eaec94e39693.png" />
  </a>
</p>
<h4 align="center">
    HDFS - FSAnalytics & File Explorer, Database - Hive File Analytics<br/>
</h4>

7. **FS Elastic** - **ad-fs-elastic** - Service that runs elastic service on port 19038, used only for standalone purposes on separate host

8. **HA GraphQL** - **ad-ha-graphql** - Service that runs standalone UI component on separate host and connects with available datastores to provide an HA

9. **HYDRA** - **ad-hydra** - Service to manage Hydra agent deployed across all hosts on cluster

10. **Kafka 0.10.2 Connector** - **ad-kafka-0-10-2-connector** - Service that launches kafka connector for versions less than equal to Kafka v0.10.2 to collect Kafka events and object statistics

11. **Kafka Connector** - **ad-kafka-connector** - Service that launches kafka connector for versions greater than Kafka v0.10.2 to collect Kafka events and object statistics

<p align="center">
  <a href="[https://docs.acceldata.io/pulse]">
    <img alt="Jamify" src="https://user-images.githubusercontent.com/28974904/229344233-3ca01f79-d50d-4807-a20d-a3674a5c2168.png" />
  </a>
</p>
<h4 align="center">
    Kafka<br/>
</h4>

12. **Impala Connector** - **ad-impala-connector** - Service that launches container to collect Impala queries and corresponding stats

<p align="center">
  <a href="[https://docs.acceldata.io/pulse]">
    <img alt="Jamify" src="https://user-images.githubusercontent.com/28974904/229344239-b992c117-20cd-46b4-903a-f1b2d6b2c741.png" />
  </a>
</p>
<h4 align="center">
    Impala<br/>
</h4>


13. **LDAP** - **ad-ldap** - Service that connects with LDAP server to allow SSO based login to Pulse UI

14. **LogSearch** - Service that collects log messages from all hosts and store as indices on Elastic search

**ad-logstash** -  Intercept log messages and parse messages into required attributes

**ad-elastic** - Storage for all log service messages and FS image indices

**ad-logsearch-curator** - Curator to run cleanup on intervals for retaining indices for specified days

<p align="center">
  <a href="[https://docs.acceldata.io/pulse]">
    <img alt="Jamify" src="https://user-images.githubusercontent.com/28974904/229344334-555ddbf7-e384-4ea6-adfd-525fee2ef6e1.gif" />
  </a>
</p>
<h4 align="center">
    Logsearch<br/>
</h4>

15. **Notifications** - **ad-notifications** - Service that connects with multiple notification channels to send raised incidents

<p align="center">
  <a href="[https://docs.acceldata.io/pulse]">
    <img alt="Jamify" src="https://user-images.githubusercontent.com/28974904/229344393-78696a6b-5b34-4d58-b77e-bd37094dbdac.png" />
  </a>
</p>
<h4 align="center">
    Notifications<br/>
</h4>

16. **Proxy** - **ad-proxy** - Service that provides support to enable TLS on Pulse UI


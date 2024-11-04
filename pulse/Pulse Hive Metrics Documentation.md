# Pulse Hive Metrics Documentation

## Overview
Pulse offers robust monitoring and analysis for Apache Hive workloads, enabling users to improve query performance, resource usage, and overall system efficiency. By using Pulse's Hive metrics, users gain actionable insights into their Hive operations, promoting data-driven decision-making and proactive system management.

---

## Accessing the Hive Dashboard

To access the Hive dashboard in Pulse:

1. Log in to the Pulse interface.
2. From the left-hand menu, select either:
   - **TEZ** to access the Tez-specific metrics, or
   - **Dashplots** > **HIVE-SERVICE-NEW Dashboard** to view comprehensive Hive service metrics.

The Hive dashboard provides an overview of Hive activities, covering query execution stats, resource usage, and user interactions.

---

## Tez Dashboard

The Tez dashboard in Pulse enables monitoring of tables and queries executed within the Tez execution engine.

To access:

1. Click **Tez > Dashboard** from the left pane.

The dashboard displays key metrics through summary panels and charts, including insights into query statistics, resource consumption, and other related data. By default, the dashboard shows data for the last 24 hours. To view data from a specific time range, adjust the time frame and timezone settings.

### Summary Panel
The summary tiles provide aggregated values, such as:

- **Users**: Total number of users executing Hive queries.
- **Number of Queries**: Total count of Hive queries executed in the selected timeframe.
- **Average CPU Allocated**: Mean CPU resources allocated per query.
- **Average Memory Allocated**: Mean memory allocated across all queries.
- **Succeeded Queries**: Count of successfully completed queries.
- **Running Queries**: Number of queries currently in progress.
- **Failed Queries**: Count of queries that encountered errors.
- **Killed Queries**: Number of queries terminated before completion.

These metrics help users:

- Monitor active user operations and identify frequent query executors.
- Assess system load based on query counts and status.
- Evaluate CPU and memory efficiency.
- Identify and resolve failed or killed queries to improve system reliability.

### Additional Tez Charts

The Tez dashboard includes several additional metrics:

- **Vcore Usage**: Number of virtual cores used by queues in the cluster.
- **Memory Usage**: Memory consumed by queues in the cluster.
- **Query Execution Count**: Number of queries executed over a time period.
- **Average Query Time**: Mean time to complete queries, showing total execution time as well.

![Tez Metrics Example](https://github.com/user-attachments/assets/a82a3de4-5eef-46ff-857b-706f859a9c91)

Other metrics:

- **Top 20 Users (By Query)**: Users with the highest number of executed queries.
- **Top 20 Tables (By Query)**: Tables most accessed by queries.
- **Total Connections (hive_metastore)**: Established connections to the Hive Metastore, with status filtering options (e.g., Established, Listen, Close_wait).
- **Total Connections (hive_server2)**: Established connections to Hive Server2, with similar status filtering.

<img width="1510" alt="image" src="https://github.com/user-attachments/assets/477b100a-f6de-422e-9f85-d24352214d19">

- **Top 10 Connections hive_metastore** :- This bar chart ranks the top 10 connections to the Hive Metastore based on the number of established connections from different hosts. You can change the status of connections for the chart by clicking the status drop-down and selecting one of these options: Established, Listen, Close_wait, etc.
- **Top 10 Connections hive_server2** :- This bar chart ranks the top 10 connections to Hive Server2 based on the number of established connections from different hosts. You can change the status of connections for the chart by clicking the status drop-down and selecting one of the these options: Established, Listen, Close_wait, etc.

![Tez Connections Example](https://github.com/user-attachments/assets/9a49c8b2-8299-40b6-8fe4-a78f742bd323)

To view memory capacity for queues, select a queue under the **Queues** tab.

---

## Dashplots: HIVE-SERVICE-NEW Dashboard

The HIVE-SERVICE-NEW dashboard in Dashplots provides real-time metrics and visualizations of Hive services, enabling administrators to monitor the health and performance of Hive components.

### Key Metrics and Visualizations

- **HIVE-SERVICE-SUMMARY**: Overview of Hive services, including active servers and metastore instances with operational statuses.
- **Live Count of Hive Servers**: Active Hive server instances. Monitors server availability to handle current workloads.
- **Live Count of Hive Metastores**: Active metastore instances for metadata management and query planning.

- **Active Hive Server Process State**: Status of each Hive server process (e.g., running, stopped, error), identifying issues with server operations.
- **Active Hive Metastore Process State**: Status of Hive metastore processes, essential for operational insights.
- **Hive Server CPU Utilization**: CPU usage of Hive server instances for identifying performance bottlenecks.
- **Hive Metastore CPU Utilization**: CPU consumption of Hive metastore services, assisting in capacity planning.

![Hive Service Metrics](https://github.com/user-attachments/assets/d8b48f85-ea92-4bb0-9272-ff3fe0cdaaca)

Other key visualizations:

- **Hive Servers JVM Usage**: JVM metrics (e.g., heap memory) for diagnosing memory-related issues.
- **Hive Metastore JVM Usage**: JVM metrics for Hive metastore, aiding memory management.
- **Active Operations**: Lists current operations on Hive servers, like running queries, for workload tracking.
- **Hive GET Request API**: Monitors GET requests to the Hive API for API performance.

![Hive Service API Metrics](https://github.com/user-attachments/assets/dbd63ccc-7a9d-44da-8180-20ab62dcd8ac)

Additional metrics:

- **Hive Server Application Stop Events**: Logs instances of stopped Hive servers.
- **Hive Metastore Application Stop Events**: Logs metastore stoppages.
- **HS2 Query Count Trend**: Trend analysis of queries processed by HiveServer2.
- **Hive Server Open Connections**: Number of active connections to Hive servers, offering insights into user activity.
- **Hive Metastore Open Connections**: Active connections to metastore services, aiding connection management.
- **Hive Query Status Trend**: Status distribution of queries (e.g., succeeded, failed, running), for identifying performance trends.

![Query Status Metrics](https://github.com/user-attachments/assets/d2c2846f-e330-4fed-8d8f-b293dcda73e2)

### Nodes Page and Services

The **Nodes Page** displays details about each node in the cluster, including service statuses.

![Nodes Page Example](https://github.com/user-attachments/assets/1629308c-69c7-4bed-a9d9-1e53c441ebbb)
![Nodes Page Services](https://github.com/user-attachments/assets/09c0de82-94b7-415d-8171-da31a929aec4)

---

## Benefits of Utilizing Pulse Hive Metrics

Using Pulse's Hive metrics provides these key benefits:

- **Improved Performance**: Identify performance issues and optimize query execution.
- **Resource Optimization**: Ensure CPU and memory are allocated efficiently.
- **Proactive Troubleshooting**: Quickly detect and resolve slow or failed queries.
- **Data-Driven Decisions**: Use insights on user activity and query patterns for planning and policy-making.

By integrating these Hive metrics, organizations can maintain a reliable, efficient, and optimized Hive environment.

For further details, refer to the [Tez Dashboard documentation](https://docs.acceldata.io/pulse/documentation/tez-dashboard).

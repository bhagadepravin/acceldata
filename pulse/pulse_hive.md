# Pulse Hive Metrics Documentation

## Overview
Pulse provides comprehensive monitoring and analysis of Apache Hive workloads, enabling users to optimize query performance, resource utilization, and overall efficiency. By leveraging Pulse's Hive metrics, users can gain actionable insights into their Hive operations, facilitating informed decision-making and proactive system management.

## Accessing the Hive Dashboard

To access the Hive dashboard in Pulse:

1. Log in to the Pulse interface.
2. Navigate to the left-hand menu and select **TEZ**.
3. Or Navigate to the left-hand menu and select **Dashplots** HIVE-SERVICE-NEW Dashboard.

The dashboard presents a comprehensive overview of Hive activities, including query execution statistics, resource consumption, and user interactions.

# Tez Dashboard:

Using Pulse, you can monitor the tables and queries executed in Tez.
Click Tez > Dashboard in the left pane to access the Tez dashboard. The dashboard consists of summary panels, charts that display information about queries and other related metrics.

Note: The default time range is Last 24 hrs. To view statistics from a custom date range, click the icon and select a time frame and timezone of your choice.

## Summary Panel
The summary tiles display several aggregated values. You can click the number on each field to view detailed information about that metric.

### Key Metrics and Their Usage

The Hive dashboard offers several critical metrics:

- **Users**: Total number of users executing Hive queries.
- **Number of Queries**: Total count of Hive queries executed within the selected timeframe.
- **Average CPU Allocated**: Mean CPU resources allocated across all queries.
- **Average Memory Allocated**: Mean memory allocated across all queries.
- **Succeeded Queries**: Count of successfully executed queries.
- **Running Queries**: Number of queries currently in progress.
- **Failed Queries**: Count of queries that failed to execute.
- **Killed Queries**: Number of queries terminated before completion.

These metrics enable users to:

- Monitor user activity and identify high-frequency query executors.
- Assess system load by analyzing the number of running and completed queries.
- Evaluate resource allocation efficiency through average CPU and memory usage.
- Identify and troubleshoot failed or killed queries to enhance system reliability.

## Additional Tez Charts

The dashboard also includes:

- **Vcore Usage** :- The number of physical virtual cores used by a queue in the cluster.
- **Memory Usage** :- The amount of memory used by a queue in the cluster.
- **Query Execution Count** :- The number of queries executed within a timeframe.
- **Average Query Time** :- The average time taken to execute queries. This metric also displays the Total Execution Time.
<img width="1505" alt="image" src="https://github.com/user-attachments/assets/a82a3de4-5eef-46ff-857b-706f859a9c91">

- **Top 20 Users (By Query)**: Lists users with the highest number of executed queries.
- **Top 20 Tables (By Query)**: Lists tables most frequently accessed by queries.
- **Total Connections hive_metastore** :- The total number of established connections to the Hive Metastore over a specified time period. You can change the status of connections for the chart by clicking the status drop-down and selecting one of these options: Established, Listen, Close_wait, etc.
- **Total Connections hive_server2** :- The total number of established connections to Hive Server2 over a specified time period. You can change the status of connections for the chart by clicking the status drop-down and selecting one of these options: Established, Listen, Close_wait, etc.
<img width="1510" alt="image" src="https://github.com/user-attachments/assets/477b100a-f6de-422e-9f85-d24352214d19">

- **Top 10 Connections hive_metastore** :- This bar chart ranks the top 10 connections to the Hive Metastore based on the number of established connections from different hosts. You can change the status of connections for the chart by clicking the status drop-down and selecting one of these options: Established, Listen, Close_wait, etc.
- **Top 10 Connections hive_server2** :- This bar chart ranks the top 10 connections to Hive Server2 based on the number of established connections from different hosts. You can change the status of connections for the chart by clicking the status drop-down and selecting one of the these options: Established, Listen, Close_wait, etc.
<img width="1309" alt="image" src="https://github.com/user-attachments/assets/9a49c8b2-8299-40b6-8fe4-a78f742bd323">

Note: To view memory capacity allocated to or used by resources on a queue, click the queue in the Queues tab.

## Benefits of Utilizing Pulse Hive Metrics

Leveraging Pulse's Hive metrics offers several advantages:

- **Enhanced Performance**: Identify and address performance bottlenecks by analyzing query execution times and resource usage.
- **Resource Optimization**: Monitor CPU and memory allocation to ensure efficient utilization and prevent over-provisioning.
- **Proactive Issue Resolution**: Detect and troubleshoot failed or slow queries promptly, minimizing downtime.
- **Informed Decision-Making**: Gain insights into user activity and data access patterns to inform capacity planning and policy development.

By integrating Pulse's Hive metrics into their monitoring practices, organizations can achieve a more efficient, reliable, and optimized Hive environment.

For more detailed information, refer to the [Tez Dashboard documentation](https://docs.acceldata.io/pulse/documentation/tez-dashboard). 

# Dashplots:

## HIVE-SERVICE-NEW Dashboard

The HIVE-SERVICE-NEW dashboard provides a consolidated view of the current state and performance of Hive services. It includes real-time metrics and visualizations that assist administrators in monitoring the health and efficiency of Hive components

## Key Metrics and Visualizations

- HIVE-SERVICE-SUMMARY :- This section offers an overview of the Hive services, summarizing critical information such as the number of active servers, metastore instances, and their operational statuses.
 - LIVE COUNT OF HIVE SERVERS :- Displays the current number of active Hive server instances. Monitoring this count helps ensure that the appropriate number of servers are running to handle the workload.
 - LIVE COUNT OF HIVE METASTORES :- Shows the number of active Hive metastore instances. Maintaining the correct number of metastore services is crucial for metadata management and query planning.

- ACTIVE-HIVE-SERVER-PROCESS-STATE :- Indicates the operational state of each Hive server process, such as running, stopped, or in error. This metric aids in identifying and addressing issues with specific server processes.
- ACTIVE-HIVE-METASTORE-PROCESS-STATE :- Reflects the current state of Hive metastore processes, providing insights into their operational health and availability.
- HIVE-SERVER-CPU-UTLISATION :- Measures the CPU usage of Hive server instances. Monitoring CPU utilization helps in detecting performance bottlenecks and ensuring efficient resource usage.
- HIVE-METASTORE-CPU-UTILISATION :- Tracks the CPU consumption of Hive metastore services, assisting in performance tuning and capacity planning.
<img width="753" alt="image" src="https://github.com/user-attachments/assets/d8b48f85-ea92-4bb0-9272-ff3fe0cdaaca">

- HIVE SERVERS JVM USAGE :- Displays Java Virtual Machine (JVM) metrics for Hive servers, including heap memory usage. These metrics are vital for diagnosing memory-related issues and optimizing JVM performance.
- HIVE METASTORE JVM USAGE :- Provides JVM metrics for Hive metastore services, offering insights into memory utilization and JVM health.

- ACTIVE-OPERATIONS :- Lists the currently active operations on Hive servers, such as running queries and data processing tasks. This information is useful for tracking ongoing activities and managing workloads.
- HIVE GET REQUEST API :- Monitors the number and performance of GET requests to the Hive API, helping to identify potential issues with API responsiveness or usage patterns.
<img width="1473" alt="image" src="https://github.com/user-attachments/assets/dbd63ccc-7a9d-44da-8180-20ab62dcd8ac">

- HIVE-SERVER-APP-STOP :- Logs instances where Hive server applications have stopped, either intentionally or due to errors. This metric is essential for maintaining service availability and troubleshooting unexpected downtimes.
- HIVE-METASTORE-APP-STOP :- Records occurrences of Hive metastore application stoppages, aiding in diagnosing and resolving service interruptions.
- HS2-QUERY-COUNT-TREND :- Presents a trend analysis of the number of queries processed by HiveServer2 over time. This visualization helps in understanding query load patterns and planning for capacity needs.

- HIVE-SERVER-OPEN-CONNECTIONS :- Shows the number of open connections to Hive servers, providing insights into user activity and potential connection management issues.
- HIVE-METASTORE-OPEN-CONNECTIONS :- Displays the count of open connections to Hive metastore services, assisting in monitoring client interactions and connection pooling effectiveness.
- HIVE-QUERY-STATUS-TREND :- Illustrates the status distribution of Hive queries over time, categorizing them into succeeded, failed, or running. This trend analysis aids in identifying systemic issues affecting query performance and reliabilit

<img width="1289" alt="image" src="https://github.com/user-attachments/assets/d2c2846f-e330-4fed-8d8f-b293dcda73e2">


Nodes Page:

<img width="754" alt="image" src="https://github.com/user-attachments/assets/1629308c-69c7-4bed-a9d9-1e53c441ebbb">

Nodes Page Services:
<img width="317" alt="image" src="https://github.com/user-attachments/assets/09c0de82-94b7-415d-8171-da31a929aec4">



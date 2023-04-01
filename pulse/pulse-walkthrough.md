# Pulse Walkthrough

## 1. Dashboard

##### The dashboard displays an overview of the core usage of metrics within your Hadoop ecosystem.

![image](https://user-images.githubusercontent.com/28974904/229271978-9afba59d-cbef-4bb7-8747-18e81e1bb38a.png)

The following metric tiles are displayed.

<img width="846" alt="image" src="https://user-images.githubusercontent.com/28974904/229271860-1b354892-0fdf-4d6f-8a4e-2dd123a012bc.png">

#### Recommendations
Based on the usage of clusters installed in your ecosystem and the jobs you submit for every application type, Pulse gives you recommendations on the Dashboard screen. Click the application name in the tile to view the recommendations.

As an example, the following image displays Spark and YARN recommendations. Hovering over the Spark recommendation displays the percentage and the number of currently running jobs.

<img width="831" alt="image" src="https://user-images.githubusercontent.com/28974904/229271923-b13b3a30-dfeb-4257-872f-bd4ba0a9898c.png">

Clicking any recommendation redirects you to the `Recommendations` page for a detailed overview.

#### Pulse Ribbon
The Pulse header ribbon on the top right corner of the home page displays buttons and icons for easy navigation and quick, actionable information.

<img width="406" alt="image" src="https://user-images.githubusercontent.com/28974904/229272049-1722da10-1dd2-4f8e-9ac2-3fa726628aa6.png">

The Pulse ribbon contains the following buttons, from left to right:

**Cluster** - It displays the name of the cluster. In the example, accelqe is the cluster name. To know more about clusters and how they work when multiple clusters are added, 

see Multiple Clusters if added.

*Clusters*
A cluster is a bunch of computers linked together, in order to perform parallel computation tasks in data science, data engineering, and data analytics. Pulse captures metadata of these computation tasks, by which you can manage and improve the operations of these tasks.

Perform the following to view statistics of all the Clusters in Pulse together in a single page:

![image](https://user-images.githubusercontent.com/28974904/229272145-78bfe3a9-edb7-4813-9c53-2ec3402c9b2e.png)

![image](https://user-images.githubusercontent.com/28974904/229272154-8d923c1c-06d8-42c2-8b67-6e9d68a131a3.png)
The following metric tiles are displayed in the Clusters page.

<img width="859" alt="image" src="https://user-images.githubusercontent.com/28974904/229272171-05b502ad-93cd-4e12-ac24-eb813376298b.png">


**Health** - It displays the health of the services running on a node. The green dot on the top right of the icon indicates that all the services are working at expected levels. Change in the dot color from green to amber or red indicates that one or more services is down on that node. Click on the icon to view the services impacted. Click on the service to view the details. It is demonstrated in the following example.

![Health Button](https://user-images.githubusercontent.com/28974904/229272221-67a4ecf4-377a-40f5-93ed-8909342efbb7.gif)

**Alerts** - Alerts display incident messages about clusters in your Hadoop ecosystem that may need attention depending upon the severity levels such as Critical, High, Medium and Low. Click the button for detailed incident notifications raised as shown in the following image. To manage alerts and associated incident messages, see Incidents.

![image](https://user-images.githubusercontent.com/28974904/229272258-7ec45b7e-bad7-4148-8d48-d3832f4f540f.png)



## 2. Incidents

If an alert continues to occur consecutively for a particular threshold, then an incident is created for the alert. This is specified with either the number of times the alert has occurred or number of seconds it has lasted.

**Viewing Incident Details**
To view the details of an incident, perform the following:

![incident details page](https://user-images.githubusercontent.com/28974904/229272430-9758c3e8-dd78-4016-a5c0-5d077b322add.png)


2. Specify the name of an incident in the search bar. All the incidents related to it are displayed in the incidents panel.
3. Click the name of the incident from the incidents panel to view its details on the right. From the incident details page you can also view the date and time at which the incident was raised. Click -> **Raised at** to view the **Evaluated at** details.
4. Click the Alert tab to view the alert details for which the incident was created upon.

![image](https://user-images.githubusercontent.com/28974904/229272425-dac4afef-52bd-42d8-a372-6869fb1656f7.png)

#### Editing Details from the Incidents Page
Once the incident is resolved, perform the following to change the status from **raised** to **cleared**:

1. Select the alert for which you want to change the status.
2. Click the **Clear** button. A **Reason** pop-up window is displayed.
3. Enter the reason to clear an incident.
4. Click **Ok**.

#### Editing an Alert from the Incidents Page
Click Edit button to make changes to the alert that you are viewing.

#### Filtering & Sorting Incidents
From the Alert Type panel, click the type of alert you want to view in the incident panel. Click ≡ to hide or view the Alert Type panel.

Click the Sort By button and select one of the following:

Date in ascending order
Date in descending order
Severity level
By default, the incidents panel displays incidents that occurred in the last 24 hours. Click the <iframe src="calendar.svg"></iframe> icon to select a custom date and time.

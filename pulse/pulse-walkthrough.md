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


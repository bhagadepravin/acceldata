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
By default, the incidents panel displays incidents that occurred in the last 24 hours. Click the :calendar: icon to select a custom date and time.

![image](https://user-images.githubusercontent.com/28974904/229272790-af4baf1c-1acf-4cd2-bec7-f13598c5d2a2.png)

## 3. User Management

**Overview**

User Management or Role based access control (RBAC) in Pulse enables administrators to govern user access to Pulse and integrated services. With RBAC, administrators can limit the operations that other users perform. For example, an Apache Spark developer can only be given access to Spark-related integrations in the Hadoop stack.

The following table shows the roles and privileges given to that role.

<img width="774" alt="image" src="https://user-images.githubusercontent.com/28974904/229272861-a8190717-a65e-4fe0-9837-9725f343fb5f.png">


### Roles Dashboard

The Roles dashboard displays the following tabs.

Roles
Users
SSH Keys
Keytabs

#### Roles

A role represents the level of privileges and authorization related to the user.

The following details are displayed in the **Roles** dashboard.

<img width="794" alt="image" src="https://user-images.githubusercontent.com/28974904/229272908-991064c4-64fd-407f-874c-4d92ff8cdf02.png">

##### Creating a Role

To create a role, perform the following:

![image](https://user-images.githubusercontent.com/28974904/229272961-4523dfa8-b151-4c96-966f-438c2c1c4edd.png)

1. Click the **Create Role** button. The **Create Role** wizard is displayed.

2. Fill the following role assignment details.
  - **Role Details**
    - **Name:** The name of the role.
  -  **Permissions**
     - **Page Permissions:** The list of services and pages to enable for the role. Click the checkbox next to these services and pages you want to enable. You can also expand the list of services and select specific modules to assign to that role.
     - **All Clusters:** Click the drop-down menu and select the clusters for which you would like to add queues and users for. Individual panels are                               displayed for the clusters selected.
        - **Queues:** The list of queues in YARN. Select the queue name from the list and press enter. You can assign multiple queues to a role.
        - **Users:** The list of users to assign to a role. Select the user from the list and press enter. You can assign multiple users to a role.

  - **AD Mapping**
    - **Groups:** The group of users in the active directory. Type the name of a group you want to add and press enter. You can add multiple groups to an active directory.

3. Click **Save**.

The new role is created.

##### Viewing Role details
To view the details of all the roles that you just created, click the Roles icon  from the main menu bar. The Roles page is displayed with the following table details:

<img width="787" alt="image" src="https://user-images.githubusercontent.com/28974904/229273221-67d7f6c5-8056-40df-85ea-4ccf42ee9c0c.png">

Click the  icon beside any column name to display the list of roles in either ascending or descending order respectively.

##### Modify a Role
To modify a role, perform the following:

1. Click the role entry displayed in the **Roles** table.
2. Edit the fields you want to modify.
3. Click **Save**.
The role is modified.

##### Deleting a Role
To delete a role, perform the following:

1. Click the three dots icon towards the right of a role entry in the **Roles** table
2. Select **Delete**.
The role is deleted.

##### Users
A user represents a person interacting with Pulse, with certain privileges.

The following details are displayed in the Users dashboard:

<img width="789" alt="image" src="https://user-images.githubusercontent.com/28974904/229273315-2ea253a1-56a2-4831-a91a-329253a70ed9.png">


##### Creating a User

To create a user, perform the following.

1. Click the **Create Role** button. The **Create User** wizard displays.

2. Fill the following user details.

  a. **User Name**: Login name of the user. Enter a unique value.
  b. **Password**: Password of the user to login with.
  c. **Confirm Password**: Password of the user. Enter the same value as **Password**.
  d. **Role**: The nature of authorization assigned to the user. Select a value from the list. You can add only one to a user.
  e. (Optional) **LDAP User**: User with directory services authentication.
3. Click **Save**.

The user is created.

##### Modifying a User

To modify a user, perform the following.

1. Click the user entry displayed in the **Users** table.
2. Edit the fields you want to modify. This also lets you change the role of a user.
3. Click **Save**.
The user details are modified.

##### Deleting a User

To delete a user, perform the following:

1. Click the three dots icon towards the right of a user entry in the **Users** table > **Delete**.
The user is deleted.

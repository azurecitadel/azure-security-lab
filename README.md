# Securing Azure Infrastructure - Hands on Lab Guide

**Authors:**

Adam Raffe - Microsoft

Tom Wilde - Microsoft 

# Contents

**[Prerequisites](#prereqs)**

**[Lab Introduction](#intro)**

**[Initial Lab Setup](#setup)**

**[Lab 1: Azure Security Center](#asc)**

- [1.1: Enable Azure Security Center](#enableasc)

- [1.2: Explore Azure Security Center](#exploreasc)

**[Lab 2: Securing Azure Storage](#storage)**

- [2.1: Enable Logging for the Storage Account](#storagelogging)

- [2.2: Remove Public Access to Blob Storage](#removeblobaccess)

- [2.3: Implement Shared Access Signatures](#sas)

- [2.4: Inspect Logs](#storagelogs)

**[Lab 3: Securing Azure Networking](#azurenetworking)**

**[Lab 4: Just in Time VM Access](#jit)**

- [4.1: Apply Just in Time Access](#applyjit)

- [4.2: Request Access to VMs](#requestjit)

**[Lab 5: Encrypting Virtual Machines](#ade)**

**[Lab 6: Securing Azure SQL](#sql)**

- [6.1: Enable SQL Database Firewall](#sqlfirewall)

- [6.2: Enable SQL Database Audting and Threat Detection](#sqlaudit)

**[Lab 7: Privileged Identity Management](#pim)**

- [7.1: Enable and Configure PIM](#enablepim)

- [7.2: Test PIM Access](#testpim)

- [7.3: Assign Users and Roles to Resources](#assignroles)

- [7.4: Managing Azure Resources](#managingresources)

**[Lab 8: Azure Resource Policies](#arp)**

**[Decommission the lab](#decommission)**

**[Conclusion](#conclusion)**

**[Useful References](#ref)**

# Prerequisites <a name="prereqs"></a>

To complete this workshop, the following will be required:

- A valid subscription to Azure. If you don't currently have a subscription, consider setting up a free trial. If this workshop is being hosted by a Microsoft Cloud Solution Architect, Azure passes should be provided.

- Multiple browser windows will be required to log in as different users simultaneously.

- A mobile phone, used to respond to multi-factor authentication challenges.

# Lab Introduction <a name="intro"></a>

Contoso have recently migrated several of their on-premises resources to Microsoft Azure. These resources include virtual machines (both Windows 2016 and Ubuntu Linux), virtual networks and storage accounts. Unfortunately, as this is the first migration carried out, Contoso are somewhat unfamiliar with Azure (and public cloud platforms in general) – as a result, they have failed to consider the security implications of the infrastructure.

The Contoso security team have requested your help to secure the infrastructure resources that they have migrated to Azure.

The environment deployed by Contoso is shown in figure 1.

![Main Lab Image](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/Overview.jpg "Security Lab Environment")

**Figure 1:** Contoso Environment

The migrated Contoso environment has the following issues:

- The storage account / container used has open, public access.

- There is no access control in place for the virtual network / subnet.

- Virtual Machines are not encrypted.

- No Role Based Access Control (RBAC) is in place to determine which users have access to which resources. Contoso would like only the minimum amount of access to be given to users, including time limited access.

- The Azure SQL Database has no firewall rules configured.


# Initial Lab Setup <a name="setup"></a>

*All usernames and passwords for virtual machines are set to labuser / M1crosoft123*

Perform the following steps to initialise the lab environment:

**1)** As we need an Azure subscription licensed for Office 365 and EM+S, the best process for this is to first create an Office 365 trial account by navigating here: http://go.microsoft.com/fwlink/p/?LinkID=698279&culture=en-GB&country=GB

**2)** Fill in the details, complete the sign-up process and create an “admin” user, as shown in figure 2. **Please ensure the user is "admin" as shown below.**

![Office 365 Signup](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/O365-Signup.jpg "Office 365 Signup")

**Figure 2:** Office 365 Signup

**3)** Once the sign-up process is complete, open to https://www.microsoftazurepass.com/ and claim the promo code to your new tenant (making sure you’re logged in as the admin user you just created)

**4)** Open http://portal.azure.com and click Azure Active Directory > Licenses > All Products > Try/buy > Free Trial under ENTERPRISE MOBILITY + SECURITY E5 > Activate

**5)** Open a Cloud Shell window using the “>_”  on the top right hand side of the screen.

**6)** Make sure the Cloud Shell window is set to “Powershell” (not “Bash”) as shown in Figure 3.

![Cloud Shell](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/cloudshell.jpg "Cloud Shell")

**Figure 3:** Azure Cloud Shell - Powershell

**7)** To create the users, copy the code below and paste into the Powershell Cloud Shell window:

<pre lang="...">
$script = Invoke-WebRequest https://raw.githubusercontent.com/azurecitadel/azure-security-lab/master/CreateUsers.ps1 -UseBasicParsing

Invoke-Expression $($script.Content)
 </pre>

**8)** To deploy the lab infrastructure, enter the following commands into the Powershell Cloud Shell window:

<pre lang="...">
$script = Invoke-WebRequest https://raw.githubusercontent.com/azurecitadel/azure-security-lab/master/CreateLab.ps1 -UseBasicParsing

Invoke-Expression $($script.Content)
 </pre>

The lab environment will deploy using an Azure ARM template – this will take approximately 10 – 15 mins.

Finally, assign directory roles and licenses to the users that have been created.

**9)** In the Azure portal, navigate to Azure Active Directory > Users > All Users > Isaiah Langer > Directory Role > Global Administrator > Save.

![Assign Role](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/assignroles.jpg "Assign Role")

**Figure 4:** Assign Global Admin Role

**10)** Navigate to Azure Active Directory > Licenses > All Products > Enterprise Mobility + Security E5 > select all of the users > Assign

**11)** Repeat the above process to assign Office 365 to the users _Alex_ and _Isaiah_, your admin user should already be licensed as part of the trial sign up process.

# Lab 1: Azure Security Center <a name="asc"></a>

In this lab, we’ll use Azure Security Center (ASC) to view recommendations and implement security policies in the Contoso environment. ASC provides centralized security policy management, actionable recommendations, alerting and incident reporting for both Azure and on-premises environments (as well other cloud platforms).

## 1.1: Enable Azure Security Center <a name="enableasc"></a>

**1)** In the Azure portal, click on Security Center on the left hand menu.

**2)** It may take a few minutes before Security Center is ready – resources will show as “refreshing” during this time. (Figure 5).

![ASC Initial Screen](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/ascoverview.jpg "ASC Initial Screen")

**Figure 5:** Initial Security Center Screen

**3)** At the top of the Security Center main pane, you will see a message stating that “Your security experience may be limited”. Click this message and you will be taken to a new pane entitled “Enable advanced security for subscriptions”. Click on your subscription and you will be taken to a new screen, as shown in Figure 6.

![ASC Pricing](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/ascpricing.jpg "ASC Pricing")

**Figure 6:** Azure Security Center Pricing

**4)** Select the “Standard” tier and then click “save”.

You have just upgraded to the “Standard” tier of Azure Security Center. This tier provides additional functionality over the free tier, including advanced threat detection and adaptive security controls. More details on the Standard tier are available from https://docs.microsoft.com/en-us/azure/security-center/security-center-pricing.

## 1.2: Explore Azure Security Center <a name="exploreasc"></a>

In this section of the lab, we’ll take a look around Azure Security Center and explore what it has to offer.

**1)** In the Azure portal, click on Security Center on the left hand menu.

**2)** The overview section of the Security Center shows an 'at-a-glance' view of any security recommendations, alerts and prevention items relating to compute, storage, networking and applications, as shown in Figure 7.

![ASC Main](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/ascmain.jpg "ASC Main")

**Figure 7:** Azure Security Center Main Screen

**3)** Click on 'Recommendations' in the Security Center menu. You will see a list of recommendations relating to various areas of the environment - for example, the need to add Network Security Groups on subnets and VMs, or the recommendation to apply disk encryption to VMs.

![ASC Recommendations](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/ascrecommendations.jpg "ASC Recommendations")

**Figure 8:** Azure Security Center Recommendations

**4)** Click on 'Compute & Apps' in the left hand menu. This will take you to a compute specific recommendations page where we can begin to apply recommendations.

**5)** Click on the ‘VMs and Computers’ tab where you will see a list of all VMs in your subscription and the issues that ASC has found.

**6)** One of the common warnings is related to endpoint protection on virtual machines. Click on the 'Compute' item in the menu and then click on the warning for ‘Endpoint Protection Issues’. This will take you to a screen showing how many VMs are not protected.

![ASC Endpoint Protection](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/ascendpoint.jpg "ASC Endpoint Protection")

**Figure 9:** Azure Security Center Endpoint Protection

**7)** Click on the ‘Endpoint Protection Not Installed’ item and then select the eligible VMs (VM1 & VM2 in your case). Click the button ‘Install on 2 VMs’.

**8)** Select ‘Microsoft Anti-Malware’ and then select all defaults before clicking ‘OK’ and letting the anti-malware software install on your VMs.

**9)** Return to the ‘Overview’ page within the Compute section and click on ‘Add a vulnerability assessment solution’. Select all four virtual machines and then click ‘Install’. From here, you can install a 3rd party vulnerability assessment tool (Qualys) on your VMs. Do not proceed with the installation, but instead proceed to the next step.

**10)** Return to the main ASC screen and then click on Networking. From here, you’ll be able to see that your VMs (VM1 – 4) are listed as ‘Internet Facing Endpoints’ but have no protection from either Network Security Groups or Next Generation Firewalls (Figure 10). You’ll add Network Security Groups to the environment later.

![ASC Networking](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/ascnetworking.jpg "ASC Networking")

**Figure 10:** Azure Security Center Networking Recommendations

**11)** From the main ASC page, click on Security Policy on the left hand menu. Click on your subscription.

**12)** From here, you can control the security policy recommendations (in the security policy section), set up email addresses for automated alerting and configure the pricing tier.

**13)** From the ‘Data Collection’ page, turn on the automatic provisioning of the monitoring agent and click save. This will allow Azure Security Center to automatically install the monitoring agent on the VMs in your subscription.

# Lab 2: Securing Azure Storage <a name="storage"></a>

As part of the migration, Contoso now have a number of files stored in Azure blob storage which are critical to their application. You can view these files by navigating to the storage account in your ‘Contoso-IaaS’ resource group. This storage account will be named ‘contosoiaas’ followed by a random string of numbers and letters (Azure storage accounts must be globally unique). Within the ‘Blobs’ section, you’ll find a container named ‘contoso’. Inside this container, there are several files, including documents, spreadsheets and images.

Unfortunately, Contoso have not secured this storage account correctly. To demonstrate this, choose one of the files (e.g. contoso.docx) and click the ‘…’ on the right hand side. Select ‘Blob Properties’ and copy the URL – paste this directly into your browser. You’ll see that you are able to download this item directly – in other words, it is completely open to the Internet.

In this lab, you’ll fix this by locking down the storage account and using Shared Access Signatures to grant access only when needed. We’ll also enable logging for the storage account to gain visibility into the requests being made.

## 2.1: Enable Logging for the Storage Account <a name="storagelogging"></a>

**1)** In the Azure portal, navigate to the storage account within the ‘Contoso-IaaS’ resource group. Click on ‘Diagnostic Settings (Classic)’ on the menu (under 'Monitoring').

**2)** Under ‘Logging’ select ‘Read’, ‘Write’, ‘Delete’ and ‘Delete Data’. Click ‘Save’.

**3)** Storage account logs will be sent to a container called ‘$logs’. This container is not viewable from the Azure portal, so to view it, you’ll need to download Azure Storage Explorer. You can download this app from https://azure.microsoft.com/en-us/features/storage-explorer/.

**4)** Download and run the installer for Storage Explorer – once installed, run the program and log on using your account details.

## 2.2: Remove Public Access to Blob Storage <a name="removeblobaccess"></a>

**1)** To begin, click on the ‘Access Policies’ button at the top of the screen (assuming you are still in the ‘contoso’ container section.

**2)** Note that the ‘Public Access Level’ is set to ‘Container’ – this means that anonymous access is available into this container.

**3)** Change the access level to ‘Private’ and click to save.

**4)** Browse to the same URL you copied earlier for one of your files (e.g. contoso.docx).

**5)** This time, note that we are unable to download the file – public access has been removed.

## 2.3: Implement Shared Access Signatures <a name="sas"></a>

Now that we have removed public access, how do we give access to the users that require it? There are two ways in which to do that. The first option is to give users the access key to the storage account (you’ll find this in the ‘Access Keys’ item in the storage account menu). However, this comes with a downside – that key will give permanent, unlimited access into the storage account until the key is revoked.

It would be better if we could grant users only the access they required, for a limited amount of time. To do this, we use Shared Access Signatures. Follow these steps to set up a SAS and Stored Access Policy.

**1)** We’ll use Powershell to create our SAS and Stored Access Policy. These commands can be pasted in to the Azure portal Cloud Shell (in Powershell mode). Let’s step through the commands to achieve this.

First, we’ll create a few variables relating to the storage account, container, resource group and the name of our policy. Note that you will need to replace the storage account name in the storageAccount variable with your own storage account name.

<pre lang="...">
$storageAccount = 'contosoiaas<unique string>'
$container = 'contoso'
$rg = 'Contoso-IaaS'
$policyName = 'contosopolicy' 
 </pre>

Next, we’ll create our ‘storage context’, create a stored access policy and then store the SAS token in a variable called $sasToken. A storage context is simply an object within Powershell that contains details such as the storage account name and the key that gives access to that account.

<pre lang="...">
$accountKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $storageAccount

$storageContext = New-AzureStorageContext -StorageAccountName $storageAccount -StorageAccountKey $accountKeys[0].Value

$storedPolicy = New-AzureStorageContainerStoredAccessPolicy -Container $container -Policy $policyName -Context $storageContext -StartTime $(Get-Date).ToUniversalTime().AddMinutes(-5) -ExpiryTime $(Get-Date).ToUniversalTime().AddYears(10) -Permission rwld

$sasToken = New-AzureStorageContainerSASToken -name $container -Policy $storedPolicy -Context $storageContext 
 </pre>

Now let’s create a new storage context using the SAS token we just created:

<pre lang="...">
$storageContext = New-AzureStorageContext -StorageAccountName $storageAccount -SasToken $sasToken
</pre>

Finally, we can attempt to list out the files that exist within our storage account / container:

<pre lang="...">
get-azurestorageblob -context $storageContext -Container $container
</pre>

You should see the files listed out, as shown in Figure 11.

![Blob List](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/bloblist.jpg "Blob List")

**Figure 11:** Storage Account Blob List

**6)** We’ve seen that we can now access the items in our storage account using the Shared Access Signature and Stored Access Policy. But what happens if we need to revoke the access at some point? To do this, we can modify (or delete) the stored access policy. In the Azure portal, navigate to the ‘contoso’ container under your storage account. Click on ‘Access Policies’.

**7)** Remove the policy and click ‘Save’.

**8)** Use the ‘get-azurestorageblob’ Powershell command shown above to list the blobs in the storage account. This now fails as the stored access policy has been deleted.

## 2.4: Inspect Logs <a name="storagelogs"></a>

In this section, you’ll check the storage logs that you enabled in exercise 1 – it may take around 10-15 minutes for these logs to populate, so feel free to come back to this exercise.

**1)** Using Storage Explorer, navigate to ‘Blob Containers’ under your storage account. You should see a ‘$logs’ container.

**2)** Drill down through the directory structure – eventually should get to a file named ‘000000.log’ or ‘000001.log’. Download this file and open with your favourite text editor (e.g. Visual Studio Code).

**3)** Inspect the log file – you should see references to ‘ListBlob’ and ‘SASSuccess’ (indicating that authentication was successful using a SAS token).

# Lab 3: Securing Azure Networking <a name="azurenetworking"></a>

To support the migration, Contoso have configured a single virtual network and subnet in Azure. At the moment, the virtual machines and subnet are completely unprotected from a network point of view; there is no access list or firewall capability in place and the VMs are fully accessible on every port from the Internet.

In this section, we are going to implement Network Security Groups (NSGs) to allow only TCP port 80 into our virtual machines – NSGs are a feature native to Azure that allows a user to lock down network access to a virtual machine or subnet from certain IP addresses and ports.

**1)** In the Azure portal, navigate to the ‘Contoso-IaaS’ resource group. Click ‘Add’ and then search for ‘Network Security Group’ from the marketplace. Choose Network Security Group and then click ‘Create’.

**2)** Name the NSG Contoso-NSG and make sure the correct resource group is selected.

**3)** Once the NSG has been created, navigate to it in the portal.

**4)** You should see a list of default rules that have been applied to the NSG, as shown in Figure 12. These rules allow access from other virtual networks, access to the Internet, as well as denying all other traffic.

![Default NSG Rules](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/defaultnsgrules.jpg "Default NSG Rules")

**Figure 12:** Default NSG Rules

**5)** We need to add a rule allowing HTTP through the NSG. Click on ‘Inbound Security Rules’ on the menu, followed by ‘Add’.

**6)** Fill in the details as follows:

**Destination Port Ranges:** _80_
**Name:** _Allow-HTTP_
**Protocol:** _TCP_

Leave all other values at their defaults. Your rule should look the same as shown in Figure 13. Click OK.

![Contoso NSG Rule](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/httprule.jpg "Contoso NSG Rule")

**Figure 13:** Contoso-NSG Rule

**7)** The next step is to apply this rule to the environment. There are two methods for applying an NSG – directly to a virtual machine, or to the entire subnet. In this scenario, we’ll apply the NSG to our virtual machines individually – generally, it is recommended to apply an NSG to a subnet, however we are going to apply it to our VMs as the next lab requires this.

**8)** Click on ‘Network Interfaces’ from the menu.

**9)** Click ‘Associate’. Select ‘VM1-nic’ and click OK. Repeat the process for VM2-nic, VM3-nic and VM4-nic.

**10)** Now that the NSG has been applied, let’s make sure we can still access our website. From the Azure portal, click on the ‘VM1-PIP’ resource within the ‘Contoso-IaaS’ resource group. Copy the IP address and then attempt to browse to it. You should still have access to the website.

# Lab 4: Just in Time VM Access <a name="jit"></a>

In the last lab, we applied an NSG to our single VM (VM1) to allow HTTP traffic in. Now, Contoso need to carry out some administration on their VMs, which means they need to RDP in to the Windows machines and SSH into the Linux VMs. However, Contoso have complained that they can’t reach any of their machines to administer them (although the website is still accessible). 

To test this, from the Azure portal select the public IP address ‘VM3-pip’ and copy the IP address. Try and SSH into this Linux virtual machine (e.g. ssh labuser@\<ip address\>) from your local machine (using a terminal emulator such as Putty or Windows 10 Linux Subsystem. This fails because your NSG does not allow TCP port 22 (or port 3389 for the Windows machines). 

We could simply add a rule to our NSG that allows these ports, however that would allow access on a permanent basis – it would be nice if we could open these ports up only when an administrator requires access. The ‘Just in Time Access’ feature of Azure Security Center (currently in preview) allows this functionality.

## 4.1: Apply Just in Time Access <a name="applyjit"></a>

**1)** In the Azure portal, navigate to Security Center from the left hand menu.

**2)** Under ‘Advanced Cloud Defense’, select ‘Just in Time Access (Preview).

**3)** In the main pane under ‘Virtual Machines’ click ‘Recommended’. This page displays a list of VMs that are recommended for JIT protection.

**4)** You should see all four VMs listed here. Select them all and then click on ‘Enable JIT on 4 VMs’, as shown in Figure 14.

![Apply JIT](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/applyjit.jpg "Apply JIT")

**Figure 14:** Applying Just in Time Access

**5)** The suggested ports are shown – port 22, 3389 are suggested, as well as ports 5985 and 5986 (used for Powershell remote). Click ‘Save’.

## 4.2: Request Access to VMs <a name="requestjit"></a>

Now that JIT access is configured, let’s say we want to gain access to one of our VMs. To do this, follow these steps:

**1)** Go to the ‘configured’ tab under Just in Time Access.

**2)** Select VM-3 and then click ‘Request’

**3)** As this is a Linux VM, we only need SSH access, so toggle port 22 to ‘on’. Leave all other settings at their default value. Click on ‘Open ports’. This is shown in Figure 15.

![Request JIT](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/applyjit.jpg "Request JIT")

**Figure 15:** Requesting VM Access

**4)** Try to SSH into VM-3 again (using the public IP address you obtained at the beginning of this lab). You may need to try this twice to allow time for the NSG to be modified, but it should succeed.

**6)** Return to your ‘Contoso-IaaS’ resource group and click on the NSG you created earlier (Contoso-NSG). You should see a list of rules for the various ports – at the top, you should see an ‘allow’ rule for port 22, using your IP address as shown in Figure 16 (source IP address removed from image).

![JIT Rules](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/jitrules.jpg "JIT Rules")

**Figure 16:** Just in Time Access - NSG Rules

# Lab 5: Encrypting Virtual Machines <a name="ade"></a>

One of the recommendations from Azure Security Center is to enable disk encryption on your virtual machines. This is achieved using Azure Disk Encryption.

In this lab, you’ll encrypt one of the Contoso virtual machines – the instructions on how to do this are listed in the following documentation page:

https://docs.microsoft.com/en-us/azure/security-center/security-center-disk-encryption

Rather than listing out all steps in this lab guide, please follow the steps on the documentation page to encrypt VM1 in the ‘Contoso-IaaS’ resource group.
Note that during the running of the prerequisites script, you’ll need to supply some information – you can use the following parameters for this:

- **Resource Group:** _Contoso-IaaS_

- **Key Vault Name:** _Use a globally unique name for this resource._

- **Location:** _westus2_

- **Subscription ID:** _You can obtain this from the portal by going to ‘All Services’ and then ‘Subscriptions’._

- **Azure AD App Name:** _Contosoade_

Note that the _Set-AzureRmVMDiskEncryptionExtension_ command provided in the document may not work correctly – instead use the following command after running the prerequisites script to enable disk encryption:

Set the ‘vmName’ variable:

<pre lang="...">
$vmName = “vm1”
</pre>

Enable encryption on the VM:

<pre lang="...">
Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $resourceGroupName -VMName $vmName -AadClientID $aadClientID.guid -AadClientSecret $secureAadClientSecret -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $keyVaultResourceId -VolumeType All
</pre>

# Lab 6: Securing Azure SQL <a name="sql"></a>

In addition to IaaS components, Contoso make use of an Azure SQL Database. Azure SQL is a PaaS service, where Microsoft assume responsibility for the underlying infrastructure and offer SQL ‘as a service’. However, there are still some security considerations that Contoso would like your assistance with.

In this lab, we’ll lock the SQL database down to allow only certain IP addresses, as well as enable additional auditing and logging.

## 6.1: Enable SQL Database Firewall <a name="sqlfirewall"></a>

**1)** In the Azure portal, navigate to the Contoso-PaaS resource group. Within this resource, navigate to the SQL server resource named ‘contososql<random-string>’.

**2)** From the menu, select Firewall / Virtual Networks’.

**3)** You’ll see that no firewall rules are currently configured, however you’ll also see a suggested ‘client IP’ address based on your IP, as shown in Figure 17.

![SQL Firewall](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/sqlfirewall.jpg "SQL Firewall")

**Figure 17:** Enabling SQL Database Firewall

**4)** Click ‘Add Client IP’ at the top of the page and then save.

**5)** If you have SQL Server Management installed on your PC, you may test access to the SQL database. To do this, obtain the full server name by returning the 'overview' page and copying the server name from here. Use this server name to connect to your SQL database server from SQL management studio. You should be able to connect as the firewall is configured with your IP address.

## 6.2: Enable SQL Database Auditing and Threat Detection <a name="sqlaudit"></a>

In this exercise, we’ll enable auditing and threat detection for the Contoso SQL database. Auditing tracks database events and writes them to an audit log in Azure storage (similar to the storage logs you configured earlier). Threat Detection provides security alerts for suspicious activities relating to the SQL database.

**1)** In the Azure portal, navigate to the Contoso-PaaS resource group and then select the SQL database server resource named ‘contososql<random-string>’.

**2)** Select ‘Auditing’ from the menu.

**3)** Change auditing to ‘On’ and select the storage account you used earlier (contosoiaas<random-string>). Change the retention to 2 days.

**4)** Select 'Advanced Threat Protection' from the menu.

**5)** Click 'Enable Advanced Threat Protection on the Server'. 

**Note: It is possible to enable auditing at both the server and SQL database level, however it is recommended to enable server level auditing only as this will also apply to all databases. More guidelines are available at https://docs.microsoft.com/en-us/azure/sql-database/sql-database-auditing.**

**6)** Navigate to the SQL database (‘ContosoDB’). Under the ‘Auditing’ menu item, click on ‘View Audit Logs’.

**7)** If you are able to log on to the database (i.e. if you have SQL Server Management Studio installed), you can do so (try a few failed attempts as well). After some time, you should see the audit log populated.

# Lab 7: Privileged Identity Management <a name="pim"></a>

With Azure Active Directory (AD) Privileged Identity Management (PIM), you can manage, control, and monitor access within your organization. Organisations want to minimise the number of people who have access to secure information or resources, as that reduces the chance of a malicious user gaining access, or an authorised user inadvertently impacting a sensitive resource.

## 7.1: Enable and Configure PIM <a name="enablepim"></a>

In this exercise we will enable PIM for the tenant and then change a user (Isaiah Langer) from a 24/7 Global Administrator to an eligible user where they must respond to an MFA challenge to become a Global Administrator for 4 hours. We'll also view the audit log for PIM.

**1)** Log into Azure Portal as the ‘admin’ user.

**2)** In the left navigation, click All Services >, type priv, then select Azure AD Privileged Identity Management, as shown in Figure 18.

![Selecting PIM](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/selectpim.jpg "Selecting PIM")

**Figure 18:** Selecting Privileged Identity Management

**3)** Under MANAGE, click Azure AD Directory Roles.

**4)** Click Verify my identity.

**5)** Follow the prompts to set up and verify using Multi-Factor Authentication (MFA) using phone verification.

**6)** On the Azure AD Directory Roles – Sign up PIM for Azure AD Directory Roles blade, click Sign Up, then click Yes, as shown in Figure 19.


![PIM Signup](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/pimsignup.jpg "PIM Signup")

**Figure 19:** Privileged Identity Management - Signing Up

**7)** Click Admin view.

**8)** View "Notification and Directory Roles".

**9)** Under Directory Roles, click the Global Administrator role.

**10)** In the Global Administrator blade, click on "Isaiah Langer".

**11)** On the right, click Make Eligible, as shown in Figure 20.

![PIM Eligibility](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/pimeligibility.jpg "PIM Eligibility")

**Figure 20:** PIM User Eligibility

**12)** In the main Azure AD directory roles page, Under MANAGE, click Settings.

**13)** Click Roles, then click Global Administrator.

**14)** Move the Maximum Activation duration slider to the left, to 4 hours.

**15)** Set email Notifications to Enable, as shown in Figure 21.

![PIM Role](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/pimrole.jpg "PIM Role")

**Figure 21:** PIM - Role Settings

**16)** Click Save.

**17)** Verify this change, click Azure Active Directory >Users > All users > Isaiah Langer > Directory role, Isaiah is now a user and no longer a Global Administrator.

## 7.2: Test PIM Access <a name="testpim"></a>

**1)** In a separate browser browse to the following URL: https://outlook.office365.com/ to view Isaiah Langer’s email.

**2)** Sign in as isaiah.langer@\<Tenant\>.onmicrosoft.com. The password is “M1crosoft123”

**3)** Open the email from Microsoft Azure AD Notification Service for Activating Global Administrator access, as shown in Figure 22.

![PIM Notification](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/pimnotify.jpg "PIM Notification")

**Figure 22:** PIM Notification Email

**4)** Click on the Azure Portal link in the email.

**5)** In the Azure Portal, click All Services > then search for priv and select Azure AD Privileged Identity Management.

**6)** Click My roles.

**7)** Click Global Administrator.

**8)** Click Verify your identity before proceeding.

**9)** Click Verify my identity.

**10)** Respond to the phone verification.

**11)** You will be returned to the Global Administrator Role Activation Details blade. If not, follow these steps:

- In the left navigation, click All Services, and then select Azure AD Privileged Identity Management.

- Click My roles.

- Click Global Administrator.

**12)** In the top navigation, click Activate.

In the Reason for role activation text box, type User administration.

**14)** Click OK.

**15)** On the Global Administrator blade, look at the Expiration field - it will be +4 hours from activation time.

**16)** Verify this change, click Azure Active Directory >Users and groups > All users > Isaiah Langer > Directory role, Isaiah is now a Global Administrator and no longer a user.

**17)** In the left navigation, click All Services, and then select Azure AD Privileged Identity Management.

**18)** Click on Azure AD Directory Roles.

**19)** Under ACTIVITY, click Directory Roles Audit History.

**20)** Note the business justification entered above (User administration), which is displayed in the Reasoning column.

**21)** Close all browsers

## 7.3: Assign Users and Roles to Resources <a name="assignroles"></a>

In this exercise we will create new Azure resources and assign direct (permanent) permissions. 

**1)** Sign into the Azure Portal as the admin user (admin@\<tenant\>.onmicrosoft.com)

**2)** Navigate to the resource group ‘Contoso-PaaS’ and then select ‘Access Control (IAM)’.

**3)** Add the user ‘Alex Wilber’ as a Contributor Add > choose Contributor > Alex Wilber.

![Assigning Users](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/assignusers.jpg "Assigning Users")

**Figure 23:** Assigning Users / Roles to Resources

**4)** In a separate browser sign into the Azure Portal as alex.wilber@\<Tenant\>.onmicrosoft.com. The password is “M1crosoft123”

**5)** Click on Resource Groups – Note that Alex can only see the resources in the Contoso-PaaS resource group as he does not have permissions to the Contoso-IaaS resources.

## 7.4: Managing Azure Resources <a name="managingresources"></a>

As some of the new resources have varying business impact we will increase our security posture using PIM to convert from direct permissions to “Just in Time” access and assign direct permissions that have an expiry date.

New permissions required for Alex Wilber:

|  Resource | Business Impact  |  Access Type | Project Time  | PIM Task   |
|---|---|---|---|---|
|  All Contoso PaaS Resources | Medium  |  Intermittent full access | 1 month  | JIT contributor access for 1 month  |
| Contoso Web App  | Low  |  Read only | 1 month  | Direct read access for 1 month  |


**All Contoso PaaS Resources**

**1)** Let’s use PIM to make the necessary access changes to the sales resources by changing the access on the sales resource group itself as permissions will roll down to all the resources in it. As the admin user, click Privileged Identity Management > Azure resources (preview) > click Resource Filter > Resource Group > Contoso-PaaS

**2)** By default, the Contributor role is set to not require MFA so we need to modify this. In MANAGE click Role Settings > Contributor > Edit > tick Require Multi-Factor Authentication on activation > Update. Notice once the role has been updated you can see it has been modified, when and by who. This is shown in Figure 24.

![Role Settings](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/rolesettings.jpg "Role Settings")

**Figure 24:** Role Settings

**3)** In the Admin view click Contributor, you should see Alex Wilber with direct assignment. Click Alex > Change Settings. As Alex needs Just in Time access for 1 month, choose assignment type Just in Time > assignment start date Current day > assignment end date Current day + 1 month.

![JIT User Settings](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/jitusersettings.jpg "JIT User Settings")

**Figure 25:** Just in Time User Settings

**Contoso Web App Web Site**

**1)** Let’s use PIM to make the necessary access changes to the marketing resource by changing the access specifically on the Contoso Web App Web Site. Click Privileged Identity Management > Azure resources (preview) > click Resource Filter > choose Resource > contosoapp<randomstring>.

**2)** In MANAGE click Roles > Reader.

**3)** Click Add User > select Alex Wilber > set the membership settings as followed, membership choose Direct > assignment start date Current day > assignment end date Current day + 1 month > type a justification for the change > Done

# Lab 8 : Implementing Azure Resource Policies <a name="arp"></a>

Azure resource policies are used to place restrictions on what actions can be taken at a subscription or resource group level. For example, a resource policy could specify that only certain VM sizes are allowed, or that encryption is required for storage accounts. In this section of the lab, we'll apply built-in resource policies to one of our resource groups to restrict what can and can't be done in our environment.

**1)** In the Azure portal, navigate to the Contoso-PaaS resource group and then click on Policies in the menu.

**2)** Select *Definitions* and then *Policy Definitions* in the right hand pane.

**3)** Scroll down to the policy entitled 'Allowed Resource Types', click the '...', select 'View Definition' and then click on 'JSON'. This shows you the JSON policy document - this simple example takes a list of resource types and prevents the ability to create them.

![Azure Resource Policy Example](https://github.com/azurecitadel/azure-security-lab/blob/master/Images/armpolicies1.jpg "Azure Resource Policy Example")

**Figure 26:** Azure Resource Policy Example


**4)** Click on 'Assignments' in the menu and then click 'Assign Policy'.

**5)** Use the following details to create the policy:

Policy: Allowed Resource Types
Allowed Resource Types: Select all 'Microsoft.Network' resources
Display Name: Allow Network
ID: Allow-Network

**6)** Use the Azure Cloud Shell to attempt to create a virtual machine using the following commands:

<pre lang="...">
New-azurermvm -resourcegroupname "contoso-paas" -name "policy-test-VM"  -imagename "UbuntuLTS"
 </pre>

**7)** Type in a username and password for the new virtual machine

**8)** The validation should fail with a message stating "The template deployment failed because of policy violation. Please see details for more information." Azure Resource Policy was successfully applied and blocked the new virtual machine creation.

**9)** Return to the 'Policies' page and remove the 'Allow-Network' resource policy assignment.



# Decommission the Lab <a name="decommission"></a>

To decommission the lab, simply remove both resource groups (Contoso-IaaS and Contoso-PaaS) using the Azure portal. All resources created for this lab will be removed.

# Conclusion <a name="conclusion"></a>

Well done, you made it to the end of the lab! Hopefully this guide has given you a good grounding in Azure security concepts. There's more we could have covered but space is limited! We hope you enjoyed running through the lab and that you learnt a few useful things from it. Don't forget to delete your resources after you have finished!

# Useful References <a name="ref"></a>

- **Introduction to Azure Security:** https://docs.microsoft.com/en-us/azure/security/azure-security

- **Microsoft Trust Center:** https://www.microsoft.com/en-us/trustcenter/security/azure-security

- **Azure Security and Compliance:** https://azure.microsoft.com/en-gb/services/security-compliance/

- **Azure AD Documentation:** https://docs.microsoft.com/en-gb/azure/active-directory/

- **Azure Security Center Documentation:** https://docs.microsoft.com/en-gb/azure/security-center/

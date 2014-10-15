# SSRS plugin #

This document describes the functionality provided by the SSRS plugin.

See the **Deployit Reference Manual** for background information on Deployit and deployment concepts.

# Overview #


##Features##

* Deploys SSRS Reports to an MSSQLClient container
* Creates a DataSource and applies that DataSource to all reports in specified path
* Compatible with SQL Server 2005 and 2008

# Requirements #

* **Deployit requirements**
	* **Deployit**: version 3.9+
	* requires the database plugin (see `DEPLOYIT_SERVER_HOME/available-plugins`)

# Installation

Place the plugin JAR file into your `DEPLOYIT_SERVER_HOME/plugins` directory.

# Usage #

The mssql.RSReports deployable consists of a folder artifact containing all reports. Only files with the default reports extension (*.rdl) are processed.
The plugin creates a datasource based on the properties entered. It then reads the *.rdl files from the provided folder artifact and upload them to the server. After the reports have been uploaded they will be linked to the created dataSource.
The mssql.RSReports deployable needs to deploy to a sql.msSqlClient container due to the dependency on MS SQL Server.

# Known limitations #

* Uses the 2005 (/ReportServer/ReportService2005.asmx) endpoint. This should work with SQL Server 2005 and 2008.
* When undeploying all reports from the serverPath will be removed. Including any reports that may have been there prior to the Deployit dep
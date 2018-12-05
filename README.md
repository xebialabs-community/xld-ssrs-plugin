# SSRS plugin

[![Build Status][xld-ssrs-plugin-travis-image] ][xld-ssrs-plugin-travis-url]
[![License: MIT][xld-ssrs-plugin-license-image]][xld-ssrs-plugin-license-url]
![Github All Releases][xld-ssrs-plugin-downloads-image]
[![Codacy Badge][xld-ssrs-plugin-codacy-image] ][xld-ssrs-plugin-codacy-url]
[![Code Climate][xld-ssrs-plugin-code-climate-image] ][xld-ssrs-plugin-code-climate-url]

[xld-ssrs-plugin-travis-image]: https://travis-ci.org/xebialabs-community/xld-ssrs-plugin.svg?branch=master
[xld-ssrs-plugin-travis-url]: https://travis-ci.org/xebialabs-community/xld-ssrs-plugin
[xld-ssrs-plugin-license-image]: https://img.shields.io/badge/License-MIT-yellow.svg
[xld-ssrs-plugin-license-url]: https://opensource.org/licenses/MIT
[xld-ssrs-plugin-downloads-image]: https://img.shields.io/github/downloads/xebialabs-community/xld-ssrs-plugin/total.svg
[xld-ssrs-plugin-codacy-image]: https://api.codacy.com/project/badge/Grade/c22530fe75554e8283856e4a5eeed0c5
[xld-ssrs-plugin-codacy-url]: https://www.codacy.com/app/joris-dewinne/xld-ssrs-plugin
[xld-ssrs-plugin-code-climate-image]: https://codeclimate.com/github/xebialabs-community/xld-ssrs-plugin/badges/gpa.svg
[xld-ssrs-plugin-code-climate-url]: https://codeclimate.com/github/xebialabs-community/xld-ssrs-plugin


# Overview

This document describes the functionality provided by the SSRS plugin.

See the **XL Deploy Reference Manual** for background information on XL Deploy and deployment concepts.


## Features

* Deploys SSRS Reports to an MSSQLClient container
* Creates a DataSource and applies that DataSource to all reports in specified path
* Compatible with SQL Server 2005 and 2008

# Requirements

* **XL Deploy requirements**
	* **XL Deploy**: version 5.x+
	* requires the database plugin (see `XL_DEPLOY_SERVER_HOME/available-plugins`)
	* **WinRM Native** *Overthere* connection

# Installation

Place the plugin xldp file into your `XL_DEPLOY_SERVER_HOME/plugins` directory.

# Usage

The `mssql.RSReports` deployable consists of a folder artifact containing all reports. Only files with the default reports extension (*.rdl) are processed.
The plugin creates a datasource based on the properties entered. It then reads the *.rdl files from the provided folder artifact and upload them to the server. After the reports have been uploaded they will be linked to the created dataSource.
The `mssql.RSReports` deployable needs to deploy to a `sql.msSqlClient` container due to the dependency on MS SQL Server.

# Known limitations

* Uses the 2005 (/ReportServer/ReportService2005.asmx) endpoint. This should work with SQL Server 2005 and 2008.
* When undeploying all reports from the serverPath will be removed. Including any reports that may have been there prior to the XL Deploy dep

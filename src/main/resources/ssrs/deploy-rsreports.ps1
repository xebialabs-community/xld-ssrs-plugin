#
# Copyright 2018 XEBIALABS
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
function CreateReportDataSource($reportServerName = $(throw "reportServerName is required."),
    $DataSourceName = $(throw "DataSourceName is required."),
    $DataSourceParent = $(throw "DataSourceParent is required."),
    $DatabaseServer = $(throw "DatabaseServer is required."),
    $DatabaseName = $(throw "DatabaseName is required."))
{
  Write-Host "Connecting to $reportServerName"
    $reportServerUri = "http://{0}/ReportServer/ReportService2005.asmx?WSDL" -f $reportServerName
    $proxy = New-WebServiceProxy -Uri $reportServerUri -UseDefaultCredential

    $proxyNamespace = $proxy.GetType().Namespace

    $myDataSourceDefinition = New-Object ("$proxyNamespace.DataSourceDefinition")
    $myDataSourceDefinition.Enabled = $true
    $myDataSourceDefinition.ConnectString = "Data Source={0};Initial Catalog={1}" -f $DatabaseServer,$DatabaseName
    $myDataSourceDefinition.Extension = "SQL"
    $myDataSourceDefinition.CredentialRetrieval = "Integrated"
    Write-Host "Creating DataSource for environment."
    $proxy.CreateDataSource($DataSourceName, $DataSourceParent, $true, $myDataSourceDefinition, $null)

}

function UploadReports($reportServerName = $(throw "reportServerName is required."), $fromDirectory = $(throw "fromDirectory is required."), $serverPath = $(throw "serverPath is required."), $DataSourceName = $(throw "DataSourceName is required."), $DataSourcePath = $(throw "DataSourcePath is required."))
{

  Write-Host "Connecting to $reportServerName"

    $reportServerUri = "http://{0}/ReportServer/ReportService2005.asmx?WSDL" -f $reportServerName
    $proxy = New-WebServiceProxy -Uri $reportServerUri -UseDefaultCredential

    Write-Host "Inspecting $fromDirectory"

    # coerce the return to be an array with the @ operator in case only one file
    $files = @(get-childitem $fromDirectory *.rdl|where-object {!($_.psiscontainer)})

    $uploadedCount = 0

    $reports = @()

    foreach ($fileInfo in $files)
    {

      $file = [System.IO.Path]::GetFileNameWithoutExtension($fileInfo.FullName)
        $reports += $file
        $percentDone = (($uploadedCount/$files.Count) * 100)
        Write-Progress -activity "Uploading to $reportServerName$serverPath" -status $file -percentComplete $percentDone
        Write-Output "%$percentDone : Uploading $file to $reportServerName$serverPath"
        $bytes = [System.IO.File]::ReadAllBytes($fileInfo.FullName)
        $warnings = $proxy.CreateReport($file, $serverPath, $true, $bytes, $null)
        if ($warnings)
        {
          foreach ($warn in $warnings)
          {
            Write-Warning $warn.Message
          }
        }
      $uploadedCount += 1
    }

    #Set Datasource for alle reports in serverPath location
    $reports = $proxy.ListChildren($serverPath, $false)
    $reports | ForEach-Object {
      if($reports -contains $_.name)
      {
        $reportPath = $_.path
          Write-Host "Report: " $reportPath
          $dataSources = $proxy.GetItemDataSources($reportPath)
          $dataSources | ForEach-Object {
            $proxyNamespace = $_.GetType().Namespace
              $myDataSource = New-Object ("$proxyNamespace.DataSource")
              $myDataSource.Name = $DataSourceName
              $myDataSource.Item = New-Object ("$proxyNamespace.DataSourceReference")
              $myDataSource.Item.Reference = $DataSourcePath
              $_.item = $myDataSource.Item
              $proxy.SetItemDataSources($reportPath, $_)
              Write-Host "Report's DataSource Reference ($($_.Name)): $($_.Item.Reference)"
          }
      }
    }
}

Write-Host "Create Datasource " $deployed.dataSourceName
CreateReportDataSource $deployed.reportServername $deployed.dataSourceName $deployed.dataSourceParent $deployed.dataSourceServerInstance $deployed.dataBaseName

Write-Host "Upload Reports from " $deployed.file " to " $deployed.reportServername
UploadReports  $deployed.reportServername $deployed.file $deployed.serverPath $deployed.dataSourceName $deployed.dataSourcePath
###############################################################################

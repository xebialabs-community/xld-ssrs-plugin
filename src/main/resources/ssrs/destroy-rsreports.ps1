#
# Copyright 2018 XEBIALABS
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
function Uninstall-Report
(
	$webServiceUrl = $(throw "webServiceUrl is required."),
	$reportPath = $(throw "reportPath is required.")
)
{
	#Create Proxy
	Write-Host "Creating Proxy, connecting to : $webServiceUrl"
	$ssrsProxy = New-WebServiceProxy -Uri $webServiceUrl -UseDefaultCredential

	#Set Report Folder
	if(!$reportPath.StartsWith("/")) { $reportPath = "/" + $reportPath }

	try
	{
		Write-Host "Deleting: $reportPath"
		#Call Proxy to upload report
		$ssrsProxy.DeleteItem($reportPath)
		Write-Host "Delete Success."
	}
	catch [System.Web.Services.Protocols.SoapException]
	{
		$msg = "Error while deleting report : '{0}', Message: '{1}'" -f $reportPath, $_.Exception.Detail.InnerText
		Write-Error $msg
	}

}

function RemoveReports($reportServerName = $(throw "reportServerName is required."), $fromDirectory = $(throw "fromDirectory is required."), $serverPath = $(throw "serverPath is required."))
{
	Write-Host "Connecting to $reportServerName"

    $reportServerUri = "http://{0}/ReportServer/ReportService2005.asmx?WSDL" -f $reportServerName
    $proxy = New-WebServiceProxy -Uri $reportServerUri -UseDefaultCredential

    Write-Host "Inspecting $fromDirectory"

    # coerce the return to be an array with the @ operator in case only one file
    $files = @(get-childitem $fromDirectory *.rdl|where-object {!($_.psiscontainer)})

    $uploadedCount = 0

    foreach ($fileInfo in $files)
    {
        $file = [System.IO.Path]::GetFileNameWithoutExtension($fileInfo.FullName)
        $reportPath = $serverPath + "/" + $file
        Uninstall-Report($reportServerUri, $reportPath)
    }
}

RemoveReports $deployed.reportServername $deployed.folder $deployed.serverPath

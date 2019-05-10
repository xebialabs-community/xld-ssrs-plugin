#
# Copyright 2019 XEBIALABS
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
$optionalParameters = @()
$binPath = $deployed.file

if($deployed.username){
    $optionalParameters += "-u"
	$optionalParameters += $deployed.username
}

if($deployed.password){
    $optionalParameters += "-p"
	$optionalParameters += $deployed.password
}

if($deployed.timeOut){
    $optionalParameters += "-l"
	$optionalParameters += $deployed.timeOut
}

if($deployed.endpoint){
    $optionalParameters += "-e"
	$optionalParameters +=$deployed.endpoint
}

if($deployed.batchMode){
    $optionalParameters += "-b"
}

#Build variable String
foreach ($var in $deployed.variables) {
    $variableValue=$($var.variableValue);

	if($var.variableValue.StartsWith("$","CurrentCultureIgnoreCase")){
      $nameOfVariableWithoutDollarSign= $($var.variableValue.Substring(1))
      $variableValue=Get-Variable $nameOfVariableWithoutDollarSign -valueOnly
    }
	Write-Host "Adding report variable: $($var.variableName) with value: $variableValue"
	$optionalParameters += "-v"
    $optionalParameters += "$($var.variableName)=`"$($variableValue)`""
}

& "$($deployed.rsExecutablePath)" -i "$binPath\$($deployed.rssFileName)" -s "$($deployed.serverURL)" $optionalParameters -t

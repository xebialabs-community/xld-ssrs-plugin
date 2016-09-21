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
param (
    [string]$databaseName,
    [string]$covid19BaseUri,
    [string]$databaseBackupName,
    [string]$sqlUserName,
    [string]$sqlPassword,
    [string]$cosmosDBConnectionString,
    [string]$cosmosDBDatabaseName
)

$dataFolder = "data/"
$covidFileName = "covid_policy_tracker.csv"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri https://www.microsoft.com/en-us/download/details.aspx?id=46436 -OutFile dt-1.7.zip
Expand-Archive -Path dt-1.7.zip -DestinationPath .
$dtutil = Get-ChildItem -Recurse | Where-Object { $_.Name -ieq "Dt.exe" }
$env:path += ";$($dtutil.DirectoryName)"
$azcopy = Get-ChildItem -Recurse | Where-Object { $_.Name -ieq "azcopy.exe" }
$env:path += ";$($azcopy.DirectoryName)"

Invoke-WebRequest -Uri "$($covid19BaseUri)$($dataFolder)$($covidFileName)" -OutFile $($covidFileName)
dt.exe /s:CsvFile /s.Files:.\$($covidFileName) /t:DocumentDBBulk /t.ConnectionString:"$($cosmosDBConnectionString);Database=$($cosmosDBDatabaseName)" /t.Collection:covidpolicy /t.CollectionThroughput:10000
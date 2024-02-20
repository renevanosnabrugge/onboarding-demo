param(
    [string]$sourceRepoName,
    [string]$employeeName,
    [string]$backofficeRepoName
)

function New-Repository {
    param (
        [string] $targetRepoName
    )
    
    . gh repo create $($targetRepoName) --public  
}

function New-Issues {
    param (
        [string] $sourceRepoName,
        [string] $targetRepoName,
        [string] $label
    )
    $issuesJson = gh issue list --repo $($sourceRepoName) -l $($label) --json "body","title","labels"
    $issues = $issuesJson | ConvertFrom-Json 
    
    Write-Host $issuesJson
    # for each issue create a new issue with the same title and body
    foreach ($issue in $issues) {
        Write-Host $issue.title
        gh issue create -t $issue.title -b $issue.body --repo $targetRepoName
    } 
}

function New-Labels {
    param (
        [string] $sourceRepoName,
        [string] $targetRepoName
    )
    #get labels
    $labels = gh label list --repo $($sourceRepoName) --json "name,color" | ConvertFrom-Json
    foreach ($label in $labels) {
        gh label create $($label.name) --repo $targetRepoName -c $($label.color)
    }
}

#make sure you strip all spaces out of the employee name and make it pascal case

$employeePascalCase = $employeeName -replace " ", ""
$targetEmployeeRepoName = "renevanosnabrugge/employee-$employeePascalCase"

New-Repository -targetRepoName $targetEmployeeRepoName
New-Labels -sourceRepoName $sourceRepoName -targetRepoName $targetEmployeeRepoName
New-Issues -sourceRepoName $sourceRepoName -targetRepoName $targetEmployeeRepoName -label "Template Employee"
New-Issues -sourceRepoName $sourceRepoName -targetRepoName $backofficeRepoName -label "Template Office Support"

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
        [string] $label,
        [string] $prefixIssues
    )
    $issuesJson = gh issue list --repo $($sourceRepoName) -l $($label) --json "body","title","labels"
    $issues = $issuesJson | ConvertFrom-Json 
    
    #read skiplabels.json file from the same directory as the runnin script
    $skipLabels = Get-Content -Path "./scripts/skiplabels.json" | ConvertFrom-Json



    # for each issue create a new issue with the same title and body
    foreach ($issue in $issues) {
        Write-Host $issue.title
        $labels = $issue.labels

        #clean all values in the labelArray by creating a new array
        $labelArray = @()

        #for loop to add all the labels to the labelArray
        for($i = 0; $i -lt $labels.Count; $i++)
        {
    
            # if the label does not exist in the skipLabels array, add it to the labelArray
            if ($skipLabels -notcontains $labels[$i].name) {
                $labelArray += $labels[$i].name
            }
        }

   
        $labelCommaList = $labelArray -join ","

        #if the prefixIssues is not empty, add the prefix to the title
        $issueTitle = $issue.title
        if ($prefixIssues -ne "") {

            $issueTitle = $prefixIssues + $issue.title
        }
        gh issue create -t $issueTitle -b $issue.body -l $labelCommaList --repo $targetRepoName
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
New-Issues -sourceRepoName $sourceRepoName -targetRepoName $backofficeRepoName -label "Template Office Support"  -prefixIssues "$employeeName - "

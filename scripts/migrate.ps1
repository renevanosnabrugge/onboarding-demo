. ./secrets.ps1

$issues = Get-Content -Path issues.json | ConvertFrom-Json
$labels= Get-Content -Path labels.json | ConvertFrom-Json




foreach ($issue in $issues) {
    $labels = $issue.labels
    $labelArray = @()
    foreach ($label in $labels) {
        #build an array of label names that are in $label.name 
        $labelArray += $label.name

    }

    $labelCommaList = $labelArray -join ","

    gh issue create --repo renevanosnabrugge/onboarding-demo -t $issue.title -b $issue.body -l $labelCommaList
}
$allGroupsMembers = ForEach ($allGroupsMembers in $(Get-Content SCCMGroupList.txt)) {
    Get-ADGroupMember -Identity $allGroupsMembers
    " "
}
$allGroupsMembers | Select-Object Name, SamAccountName | Export-CSV -Path allUsers.csv -NoTypeInformation
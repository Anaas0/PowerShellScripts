##Queries AD for the Name and Email Address of the payroll number provided in the users.txt
##Output is in a .csv file named "output.csv"

$users = ForEach ($users in $(Get-Content GetUserEmail\users.txt)) { Get-ADUser -Properties GivenName, Surname, UserPrincipalName $users}
$users | Select-Object GivenName, Surname, UserPrincipalName |
    Export-CSV -Path GetUserEmail\output.csv -NoTypeInformation
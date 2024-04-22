# LocalBrute Script

This PowerShell script, `localbrute.ps1`, is a derived version of the script available at [InfosecMatter/Minimalistic-offensive-security-tools](https://github.com/InfosecMatter/Minimalistic-offensive-security-tools/blob/master/localbrute.ps1) with enhanced performance.

## Usage

To use the script, follow these steps:

1. Open a PowerShell terminal.
2. Navigate to the directory containing the script.
3. Execute the script with the following parameters:

    ```powershell
    localbrute -u "<username>" -dct "<dictionary_file>" -debug $true
    ```

    - `<username>`: The username of the local account to brute-force.
    - `<dictionary_file>`: The path to the dictionary file containing passwords.
    - `$true` (optional): Enables debug mode for additional output.

## Script Functionality

The script performs the following steps:

1. **Check User Existence**: 
    - It checks if the specified username exists among the local user accounts on the machine.

2. **Load Dictionary**:
    - It reads the dictionary file containing potential passwords.

3. **Brute-force Passwords**:
    - It iterates through each password in the dictionary and attempts to authenticate with the user account.
    - If debug mode is enabled, it provides additional information about the password being tried.
    - If a password is found that successfully authenticates the user, the script stops execution and reports the password.

4. **Logging**:
    - It logs the progress and results in a file named `localbrute.state`.
    - If a password is found, it logs the username, domain, authentication status, and the password.

## Parameters

- `-u`: Specifies the username of the local account to brute-force.
- `-dct`: Specifies the path to the dictionary file containing passwords.
- `-debug`: (Optional) Enables debug mode for additional output.

## Dependencies

- This script relies on the `System.DirectoryServices.AccountManagement` assembly for user authentication.

## Notes

- Ensure that PowerShell execution policy allows running scripts on the system.
- Use this script responsibly and only on systems where you have proper authorization.
- For improved performance, enhancements have been made to the original script available at [InfosecMatter/Minimalistic-offensive-security-tools](https://github.com/InfosecMatter/Minimalistic-offensive-security-tools/blob/master/localbrute.ps1).


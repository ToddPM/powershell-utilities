function Create-Config
    {
    Write-Output "======================================" > $script:config_path_file
    Write-Output "***  $script:program_name configuration  ***" >> $script:config_path_file
    Write-Output "======================================" >> $script:config_path_file
    }  #Create-Config


function Get-Config-Setting
    {
    param([string]$setting_name)

    $setting_value = ""

    if (-Not (Test-Path -LiteralPath $script:config_path_file))
        {
        Create-Config
        }
    else
        {
        # Return a collection where each object = one line of content.
        $config_contents = Get-Content $script:config_path_file

        ForEach ($config_line in $config_contents)
            {
            $first_three = $config_line.Substring(0, 3)
            $is_comment = $false

            if ($first_three -eq "***" -or $first_three -eq "---" -or $first_three -eq "===")
                {
                $is_comment = $true
                }

            if (-Not $is_comment)
                {
                $config_variable = ""
                $config_value = ""
                $config_delimiter = $config_line.IndexOf(":")

                if ($config_delimiter -gt -1)
                    {
                    $config_variable = $config_line.Substring(0, $config_delimiter).Trim()
                    $config_value = $config_line.Substring($config_delimiter + 1, $config_line.Length - $config_delimiter - 1).Trim()
                    }

                if ($config_variable -eq $setting_name)
                    {
                    #For now, this means only the final value of settings duplciated in the config file will be returned.
                    $setting_value = $config_value.Trim()
                    }
                }
            }  #ForEach
        }
    $setting_value
    }  #Get-Config-Setting


function Initialize-Variables
    {
    $script:program_name = "Sample Program"

    $documents_path = [Environment]::GetFolderPath("MyDocuments")
    $local_path = "$documents_path\$script:program_name"

    $script:input_path = "$local_path\Input"

    $script:config_file = "config.txt"
    $script:config_path_file = "$script:input_path\$config_file"

    #Create "Libraries\Documents\$script:program_name" folder if it doesn't exist.
    if (-Not (Test-Path -LiteralPath $local_path -PathType Container))
        {
        New-Item -ItemType Directory -Path $local_path | Out-Null
        }

    #Create "Libraries\Documents\$script:program_name\Input" folder if it doesn't exist.
    if (-Not (Test-Path -LiteralPath $script:input_path -PathType Container))
        {
        New-Item -ItemType Directory -Path $script:input_path | Out-Null
        }

    #Create a configuration file if it doesn't exist.
    if (-Not (Test-Path -LiteralPath $script:config_path_file))
        {
        Create-Config
        }
    }  #Initialize-Variables


function Prompt-and-Enter-Parameter
    {
    Write-Host ""
    Write-Host "Enter a configuration parameter name: " -NoNewline

    $entered_parameter_name = Read-Host
    $entered_parameter_name = $entered_parameter_name.Trim()

    if ($entered_parameter_name -ne "")
        {
        Write-Host "Enter the parameter value: " -NoNewline
        $entered_parameter_value = Read-Host
        $entered_parameter_value = $entered_parameter_value.Trim()

        Set-Config-Setting -setting_name $entered_parameter_name -setting_value $entered_parameter_value
        }
    }  #Prompt-and-Enter-Parameter


function Set-Config-Setting
    {
    param([string]$setting_name, [string]$setting_value)
    
    $setting_value = $setting_value.Trim()
    $temp_path_file = "$script:input_path\temp config.txt"
    $setting_found = $false

    if (Test-Path -LiteralPath $temp_path_file)
        {
        Remove-Item $temp_path_file
        }

    if (-Not (Test-Path -LiteralPath $script:config_path_file))
        {
        Create-Config
        }

    if (Test-Path -LiteralPath $script:config_path_file)
        {
        # Return a collection where each object = one line of content.
        $config_contents = Get-Content $script:config_path_file

        ForEach ($config_line in $config_contents)
            {
            $new_config_line = ""

            $first_three = $config_line.Substring(0, 3)
            $is_comment = $false

            if ($first_three -eq "***" -or $first_three -eq "---" -or $first_three -eq "===")
                {
                $is_comment = $true
                }

            if (-Not $is_comment)
                {
                $config_variable = ""
                $config_value = ""
                $config_delimiter = $config_line.IndexOf(":")

                if ($config_delimiter -gt -1)
                    {
                    $config_variable = $config_line.Substring(0, $config_delimiter).Trim()
                    $config_value = $config_line.Substring($config_delimiter + 1, $config_line.Length - $config_delimiter - 1).Trim()
                    }

                if ($config_variable -eq $setting_name)
                    {
                    $setting_found = $true
                    $new_config_line = "${config_variable}: $setting_value"
                    }
                else
                    {
                    $new_config_line = $config_line
                    }
                }
            else
                {
                $new_config_line = $config_line
                }

            Write-Output $new_config_line >> $temp_path_file
            }  #ForEach

        if (-Not $setting_found)
            {
            Write-Output "${setting_name}: $setting_value" >> $temp_path_file
            }

        if (Test-Path -LiteralPath $script:config_path_file)
            {
            Remove-Item $script:config_path_file
            }

        if (Test-Path -LiteralPath $temp_path_file)
            {
            Rename-Item $temp_path_file $script:config_path_file
            }
        }
    }  #Set-Config-Setting


Initialize-Variables

for($loopCounter = 1; $loopCounter -le 3; $loopCounter++)
    {
    Prompt-and-Enter-Parameter
    }

$returned_value = Get-Config-Setting -setting_name "logEmailAddress"
Write-Host ""
Write-Host "logEmailAddress = $returned_value" 

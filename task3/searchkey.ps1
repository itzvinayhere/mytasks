<#
users = %{"john" => %{age: 27}, "meg" => %{age: 23}}
get_in(users, ["john", :age])
27
# Equivalent to:
users["john"][:age]
27
#>

function get_in {
    param (
        [psobject]$obj,
        [string[]]$key
    )
    if (($obj -eq "") -or ($obj -eq $null)) {
        Write-Output "Object is empty"
    }
    else {
        switch ($key.count) { 
            0 { $output = $obj }
            1 { $output = $obj.$($key[0]) }
            2 { $output = $obj.$($key[0]).$($key[1]) }
            3 { $output = $obj.$($key[0]).$($key[1]).$($key[2]) }
        }
    }
    Write-Output $output
}

cd C:\
$users = Get-Content -Path .\test.json | ConvertFrom-Json

#[string[]]$key = "joy", "languageproficiency","english"
#[string[]]$key = "joy","sex"
[string[]]$key = "joy"
get_in -obj $users -key $key
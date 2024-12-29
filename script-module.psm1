
function loadEnv {
    param (
        [String]$envPath = ".env"
    )

    get-content $envPath | foreach {
        $name, $value = $_.split('=')
        set-content env:\$name $value
    }

}

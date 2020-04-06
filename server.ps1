Start-PodeServer {
    Add-PodeEndpoint -Address * -Port 8080 -Protocol Http
    
    # create the shared variable
    Set-PodeState -Name 'hash' -Value @{ 'values' = @(); } | Out-Null

    # attempt to re-initialise the state (will do nothing if the file doesn't exist)
    Restore-PodeState -Path './state.json'

    # timer to add a random number to the shared state
    Add-PodeSchedule -Name 'forever' -Cron '@minutely' -ScriptBlock {
        param($Event)
    
        # ensure we're thread safe
        Lock-PodeObject -Object $Event.Lockable {
    
            # attempt to get the hashtable from the state
            $hash = (Get-PodeState -Name 'hash')
    
            # add a random number
            $hash.values += (Get-Random -Minimum 0 -Maximum 10)
    
            # save the state to file
            Save-PodeState -Path './state.json'
        }
    }

    # route to return the value of the hashtable from shared state
    Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
        param($e)

        # again, ensure we're thread safe
        Lock-PodeObject -Object $e.Lockable {

            # get the hashtable from the state and return it
            $hash = (Get-PodeState -Name 'hash')
            Write-PodeJsonResponse -Value $hash
        }
    }

    # route to remove the hashtable from shared state
    Add-PodeRoute -Method Delete -Path '/' -ScriptBlock {
        param($e)

        # ensure we're thread safe
        Lock-PodeObject -Object $e.Lockable {

            # remove the hashtable from the state
            Remove-PodeState -Name 'hash' | Out-Null
        }
    }
    }
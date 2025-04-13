# Importer le module Pode
Import-Module Pode

# Démarrer le serveur Pode
Start-PodeServer {

    # Ajouter un endpoint HTTP
    Add-PodeEndpoint -Address * -Port 8080 -Protocol Http

    # Route GET sur "/"
    Add-PodeRoute -Method Get -Path '/' -ScriptBlock {

        # Infos système
        $serverName = $env:COMPUTERNAME
        $serverUser = $env:USERNAME

        # Utilisation mémoire (en Mo)
        $memory = Get-CimInstance Win32_OperatingSystem
        $totalRAM = [math]::Round($memory.TotalVisibleMemorySize / 1KB, 2)
        $freeRAM = [math]::Round($memory.FreePhysicalMemory / 1KB, 2)
        $usedRAM = [math]::Round($totalRAM - $freeRAM, 2)
        $ramUsagePercent = [math]::Round(($usedRAM / $totalRAM) * 100, 2)

        # Uptime
        $uptime = (Get-Date) - $memory.LastBootUpTime
        $uptimeText = "{0:%d} jours {0:%h}h {0:%m}m" -f $uptime

        # Utilisation CPU moyenne
        $cpuLoad = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average

        # Espace disque principal (C:)
        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
        $diskTotal = [math]::Round($disk.Size / 1GB, 2)
        $diskFree = [math]::Round($disk.FreeSpace / 1GB, 2)
        $diskUsed = [math]::Round($diskTotal - $diskFree, 2)
        $diskUsagePercent = [math]::Round(($diskUsed / $diskTotal) * 100, 2)

        # HTML à renvoyer
        $html = @"
        <html>
            <head>
                <meta charset="UTF-8">
                <title>Infos Serveur</title>
                <link href='https://fonts.googleapis.com/css2?family=Roboto:wght@400;500&display=swap' rel='stylesheet'>
                <style>
                    body {
                        font-family: 'Roboto', sans-serif;
                        background-color: #f4f7fb;
                        margin: 0;
                        padding: 20px;
                        color: #333;
                    }
                    h1 {
                        color: #005A9E;
                        font-weight: 500;
                    }
                    h2 {
                        margin-top: 30px;
                        color: #444;
                        border-bottom: 2px solid #ccc;
                        padding-bottom: 5px;
                    }
                    p {
                        margin: 8px 0;
                        font-size: 1rem;
                    }
                    strong {
                        color: #000;
                    }
                    .container {
                        max-width: 800px;
                        margin: auto;
                        background: white;
                        padding: 30px;
                        border-radius: 8px;
                        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
                    }
                    .info {
                        margin-bottom: 20px;
                        background-color: #fafafa;
                        padding: 15px;
                        border-radius: 6px;
                        box-shadow: 0 1px 6px rgba(0,0,0,0.1);
                    }
                    .info p {
                        margin-bottom: 10px;
                    }
                </style>
            </head>
            <body>
                <h1>Bienvenue sur le serveur Pode</h1>
                <h2>Informations Generales</h2>
                <p><strong>Nom du poste :</strong> $serverName</p>
                <p><strong>Utilisateur connecte :</strong> $serverUser</p>

                <h2>Utilisation Systeme</h2>
                <p><strong>RAM utilisee :</strong> $usedRAM Mo / $totalRAM Mo ($ramUsagePercent %)</p>
                <p><strong>CPU :</strong> $cpuLoad %</p>
                <p><strong>Espace disque (C:):</strong> $diskUsed Go / $diskTotal Go ($diskUsagePercent %)</p>
                <p><strong>Uptime :</strong> $uptimeText</p>
            </body>
        </html>
"@

        Write-PodeHtmlResponse -Value $html
    }

}

# Importer le module Pode
Import-Module Pode

# Démarrer le serveur Pode
Start-PodeServer {

    # Ajouter un endpoint HTTP
    Add-PodeEndpoint -Address * -Port 8080 -Protocol Http

    # Route GET sur "/"
    Add-PodeRoute -Method Get -Path '/' -ScriptBlock {

        # Infos du serveur
        $serverName = $env:COMPUTERNAME
        $serverUser = $env:USERNAME

        # Contenu HTML
        $html = @"
        <html>
            <head>
                <title>Infos Serveur</title>
            </head>
            <body>
                <h1>voici les données du serveur</h1>
                <p><strong>Nom du poste (serveur) :</strong> $serverName</p>
                <p><strong>Utilisateur connecté :</strong> $serverUser</p>
            </body>
        </html>
"@

        # Envoyer la réponse au client
        Write-PodeHtmlResponse -Value $html
    }

}

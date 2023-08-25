# Função para obter a data de expiração do certificado SSL de um host
function Get-SSLCertificateExpiryDate {
    param (
        [string]$hostname,
        [int]$port = 443
    )

 

    try {
        # Cria um cliente TCP para se conectar ao host e porta especificados
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($hostname, $port)

        # Inicializa um fluxo SSL a partir do fluxo do cliente TCP e autentica o host
        $sslStream = [System.Net.Security.SslStream]::new($tcpClient.GetStream(), $false, { $true })
        $sslStream.AuthenticateAsClient($hostname)

        # Obtém o certificado remoto e sua data de expiração
        $cert = $sslStream.RemoteCertificate
        $expiry_date = $cert.GetExpirationDateString()

        # Libera os recursos do fluxo SSL e do cliente TCP
        $sslStream.Dispose()
        $tcpClient.Close()

        return [datetime]::Parse($expiry_date)
    } catch {
        throw "Erro ao verificar o certificado SSL de $hostname : $_"
    }
}

 

# Função para enviar e-mails
function Send-Email {
    param (
        [string]$subject,
        [string]$message
    )

 

    $sender_email = "EMAIL@gmail.com"
    $sender_password = ConvertTo-SecureString "SENHA" -AsPlainText -Force
    $receiver_email = "destinatario"
    $smtp_server = "smtp.gmail.com"
    $smtp_port = 587

 

    # Cria uma mensagem de e-mail
    $msg = [System.Net.Mail.MailMessage]::new()
    $msg.From = $sender_email
    $msg.To.Add($receiver_email)
    $msg.Subject = $subject
    $msg.Body = $message

 

    # Configura o cliente SMTP
    $smtp = [System.Net.Mail.SmtpClient]::new($smtp_server, $smtp_port)
    $smtp.EnableSsl = $true
    $smtp.Credentials = [System.Net.NetworkCredential]::new($sender_email, $sender_password)

    try {
        # Envia o e-mail
        $smtp.Send($msg)
        $smtp.Dispose()
        Write-Host "E-mail enviado com sucesso!"
    } catch {
        Write-Host "Erro ao enviar o e-mail: $_"
    }
}

 

try {
    # Lê a lista de websites a partir do arquivo
    $websites = Get-Content "check-urls.txt"

    # Itera sobre cada website na lista
    foreach ($website in $websites) {
        try {
            # Obtém a data de expiração do certificado SSL
            $expiry_date = Get-SSLCertificateExpiryDate $website
            $current_date = Get-Date

 

            # Verifica se o certificado está prestes a expirar
            if ($expiry_date -gt $current_date) {
                $days_remaining = ($expiry_date - $current_date).Days
                if ($days_remaining -le 15) {
                    $alert_message = "ALERTA: O certificado SSL de $website expira em $days_remaining dias, em $expiry_date."
                    Send-Email "Aviso de Certificado Expirando $website" $alert_message
                }
            } else {
                Write-Host "O certificado SSL de $website já expirou em $expiry_date."
            }
        } catch {
            Write-Host $_
        }
    }
} catch {
    Write-Host "Erro ao ler o arquivo de sites: $_"
}
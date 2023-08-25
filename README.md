# Chaca-SSL-em-PowerShell
Script para checar um certificado SSL de uma lista de sites gerando um alerta via e-mail caso algum esteja próximo a vencer
Existe e coisas importantes neste Script: 
1 - sender_email = "seu email" sender_password = "chave para acesso de aplicação externa do seu email" Esse password não é o seu password do e-mail, dentro do gerenciamento da sua conta google você cria password para serem utilizados em aplicações terceiras, ele é gerado automaticamente quando você manda criar. Ao tentar usar a 1º vez você deverá autentivar o fator de 2 etapas (MFA) e assim mandará e-mail normalmente.
2 - with open("check-urls.txt", "r") as file: Este é o arquivo que possui os sites que serão verificados ele deve estar presente na mesma pasta onde o script python está. O arquivo é lido linha por linha

# Corrige as vulnerabilidades apontadas pelo FortiClient (Apps de terceiros):
#   - OpenSSL 3.5.7.0  -> vem embutido no Git for Windows (C:\Program Files\Git)
#   - Java JDK 8.0.202 -> C:\Program Files\Java\jdk1.8.0_202
#   - MySQL Server 8.0.32 -> C:\Program Files\MySQL\MySQL Server 8.0
#
# Como usar: abra o PowerShell como Administrador e rode
#   Set-ExecutionPolicy -Scope Process Bypass
#   .\atualizar-apps.ps1
#
# O MySQL NAO e atualizado automaticamente (envolve dados); veja o README.

$ErrorActionPreference = "Stop"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Execute este script em um PowerShell aberto como Administrador."
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget nao encontrado. Instale o 'Instalador de Aplicativo' pela Microsoft Store e tente de novo."
}

# 1) OpenSSL: atualizar o Git for Windows traz o OpenSSL corrigido
Write-Host "`n=== [1/2] Atualizando Git for Windows (OpenSSL embutido) ===" -ForegroundColor Cyan
Get-Process git, bash, mintty -ErrorAction SilentlyContinue | Stop-Process -Force
winget upgrade --id Git.Git -e --silent --accept-source-agreements --accept-package-agreements
if ($LASTEXITCODE -ne 0) {
    # Codigo diferente de zero tambem ocorre quando ja esta na ultima versao
    Write-Host "winget upgrade retornou $LASTEXITCODE (pode ja estar atualizado)." -ForegroundColor Yellow
}
& "C:\Program Files\Git\mingw64\bin\openssl.exe" version
& "C:\Program Files\Git\usr\bin\openssl.exe" version

# 2) Java JDK 8u202: ultima versao gratuita da Oracle, nao recebe mais correcoes.
#    Substitui pelo Eclipse Temurin 8 (OpenJDK gratuito e atualizado) e remove o JDK antigo.
Write-Host "`n=== [2/2] Instalando Eclipse Temurin JDK 8 e removendo Oracle JDK 8u202 ===" -ForegroundColor Cyan
winget install --id EclipseAdoptium.Temurin.8.JDK -e --silent --accept-source-agreements --accept-package-agreements

$jdkAntigo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                               "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "Java SE Development Kit 8 Update 202*" -or $_.DisplayName -like "Java 8 Update 202*" }

foreach ($app in $jdkAntigo) {
    Write-Host "Removendo $($app.DisplayName)..."
    if ($app.PSChildName -match '^\{.+\}$') {
        Start-Process msiexec.exe -ArgumentList "/x $($app.PSChildName) /qn /norestart" -Wait
    } else {
        Write-Host "Remova manualmente em Configuracoes > Aplicativos: $($app.DisplayName)" -ForegroundColor Yellow
    }
}

if (Test-Path "C:\Program Files\Java\jdk1.8.0_202") {
    Write-Host "A pasta C:\Program Files\Java\jdk1.8.0_202 ainda existe; apague-a se nada mais a usar." -ForegroundColor Yellow
}

Write-Host "`nNovo Java:" -ForegroundColor Cyan
& javac -version

Write-Host "`nPronto. Atualize o MySQL seguindo o README e depois clique em 'Varredura' no FortiClient." -ForegroundColor Green

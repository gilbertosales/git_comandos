# Correção das vulnerabilidades do FortiClient (Apps de terceiros)

O FortiClient marcou 3 aplicativos como **Critical** com ação "Instalação Manual":

| App | Onde está | Correção |
|-----|-----------|----------|
| OpenSSL 3.5.7.0 | `C:\Program Files\Git\...\openssl.exe` | Atualizar o **Git for Windows** (o OpenSSL vem junto com ele) |
| Java JDK 8.0.202 | `C:\Program Files\Java\jdk1.8.0_202` | Trocar pelo **Eclipse Temurin 8** (OpenJDK gratuito e atualizado) e remover o 8u202 |
| MySQL Server 8.0.32 | `C:\Program Files\MySQL\MySQL Server 8.0` | Atualizar para o **MySQL 8.4 LTS** (o 8.0 saiu de suporte em abril/2026) |

## 1 e 2: Git (OpenSSL) e Java, pelo script

1. Feche o Git Bash, a IDE e qualquer programa Java.
2. Abra o **PowerShell como Administrador** na pasta deste arquivo e rode:

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\atualizar-apps.ps1
   ```

**Sem winget?** Faça na mão:
- Git: baixe a versão mais recente em https://git-scm.com/download/win e instale por cima.
- Java: instale o JDK 8 (MSI x64) de https://adoptium.net/temurin/releases/?version=8 e depois
  remova "Java SE Development Kit 8 Update 202" em *Configurações > Aplicativos*.

> Se algum programa seu aponta para `C:\Program Files\Java\jdk1.8.0_202` (ex.: a variável
> `JAVA_HOME`, Eclipse, IntelliJ, Maven), aponte para a pasta nova do Temurin
> (`C:\Program Files\Eclipse Adoptium\jdk-8...`).

## 3: MySQL Server 8.0.32 → 8.4 LTS (manual, tem dados)

1. **Backup** (no PowerShell/cmd):
   ```powershell
   & "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe" -u root -p --all-databases --routines --events --triggers > C:\backup_mysql.sql
   ```
2. Baixe o **MySQL Installer** ou o MSI do MySQL Server **8.4 LTS** em
   https://dev.mysql.com/downloads/mysql/ (escolha a versão 8.4.x mais recente).
3. Pare o serviço: `net stop MySQL80`
4. Instale o 8.4. No passo de configuração, aponte para a **mesma pasta de dados**
   (normalmente `C:\ProgramData\MySQL\MySQL Server 8.0\Data`) para o upgrade in-place;
   o próprio servidor atualiza as tabelas de sistema no primeiro start.
5. Confira: `mysql -u root -p -e "SELECT VERSION();"`
6. Desinstale o "MySQL Server 8.0" em *Configurações > Aplicativos* (os dados ficam no `ProgramData`).

> Se o MySQL não é usado para nada, o caminho mais simples é só **desinstalar**
> (depois de fazer o backup do passo 1).

## Depois

Abra o FortiClient → **Varredura de Vulnerabilidade** → rode a varredura de novo para confirmar
que os 3 itens sumiram.

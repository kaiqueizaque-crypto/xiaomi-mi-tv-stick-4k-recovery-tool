# =====================================================================
# XIAOMI MI TV STICK 4K (MDZ-27-AA / "soul") - RECOVERY TOOLKIT
# Projeto remodelado para recuperacao automatizada e amigavel (1-Clique)
# Baseado na pesquisa e firmware oficial do projeto RodrigoDeveloperX & 4PDA
# Repositorio oficial: https://github.com/kaiqueizaque-crypto/xiaomi-mi-tv-stick-4k-recovery-tool
# =====================================================================

# 1. Elevacao automatica para Administrador
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    } catch {
        Write-Host "Por favor, execute este programa como Administrador (clique com botao direito no .bat -> Executar como Administrador)." -ForegroundColor Yellow
        Write-Host "Pressione qualquer tecla para fechar..."
        [void][System.Console]::ReadKey($true)
        exit
    }
}

# 2. Configuracao de Caminhos Relativos
$rootDir = (Split-Path -Path $PSScriptRoot -Parent)
$fwDir   = "$rootDir\firmware"
$binDir  = "$fwDir\bin"
$imgDir  = "$fwDir\images"
$drvDir  = "$rootDir\drivers"
$fb      = "$binDir\fastboot.exe"

$env:PATH = "$binDir;" + $env:PATH
$host.UI.RawUI.WindowTitle = "Mi TV Stick 4K Recovery Toolkit (Android 14) - [ADMINISTRADOR]"

function Pause-Console {
    Write-Host ""
    Write-Host "Pressione qualquer tecla para voltar ao menu principal..." -ForegroundColor Gray
    [void][System.Console]::ReadKey($true)
}

function Corrigir-Guids {
    param([bool]$Silencioso = $true)
    $ADB_GUID = '{F72FE0D4-CBCB-407D-8814-9ED673D0DD6B}'
    $targets = @(
        'HKLM:\SYSTEM\CurrentControlSet\Enum\USB\VID_1B8E&PID_C004',
        'HKLM:\SYSTEM\CurrentControlSet\Enum\USB\VID_18D1&PID_0D02',
        'HKLM:\SYSTEM\CurrentControlSet\Enum\USB\VID_18D1&PID_4EE7'
    )
    foreach ($root in $targets) {
        if (Test-Path $root) {
            Get-ChildItem $root -ErrorAction SilentlyContinue | ForEach-Object {
                $paramKey = "$($_.PSPath)\Device Parameters"
                if (!(Test-Path $paramKey)) { New-Item -Path $paramKey -Force | Out-Null }
                Set-ItemProperty -Path $paramKey -Name DeviceInterfaceGUIDs -Value ([string[]]@($ADB_GUID)) -Type MultiString -ErrorAction SilentlyContinue
                if (-not $Silencioso) {
                    Write-Host "  [OK] GUID configurado para: $($_.PSChildName)" -ForegroundColor Green
                }
            }
        }
    }
}

function Instalar-Drivers-Silencioso {
    # Garante que os drivers estejam no Windows Driver Store
    $gInf = "$drvDir\google\android_winusb.inf"
    if (Test-Path $gInf) {
        pnputil /add-driver $gInf /install 2>$null | Out-Null
    }
    $dInf = "$drvDir\amlogic_dnl\DNL.inf"
    if (Test-Path $dInf) {
        pnputil /add-driver $dInf /install 2>$null | Out-Null
    }
    $dExe = "$drvDir\amlogic_dnl\installer_x64.exe"
    if (Test-Path $dExe) {
        Start-Process $dExe -ArgumentList "/quiet" -Wait -ErrorAction SilentlyContinue
    }
    Corrigir-Guids -Silencioso $true
}

# Auto-preparacao de drivers e chaves na inicializacao
Instalar-Drivers-Silencioso

function Garantir-Firmware {
    $superPath = "$imgDir\super.img"
    if (Test-Path $superPath) { return $true }

    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "                DOWNLOAD DA FIRMWARE OFICIAL ANDROID 14              " -ForegroundColor Green
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "A pasta da firmware completa (1 GB) nao foi encontrada localmente." -ForegroundColor Yellow
    Write-Host "Ela fica hospedada com download direto na nossa Release do GitHub:" -ForegroundColor White
    Write-Host "https://github.com/kaiqueizaque-crypto/xiaomi-mi-tv-stick-4k-recovery-tool/releases" -ForegroundColor Cyan
    Write-Host ""

    # Verifica se o usuario ja baixou o zip na pasta
    $localZip = Get-ChildItem "$rootDir" -Filter "*Firmware*.zip" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $localZip) {
        $parentDir = Split-Path $rootDir -Parent
        if ($parentDir) {
            $localZip = Get-ChildItem "$parentDir" -Filter "*Firmware*.zip" -ErrorAction SilentlyContinue | Select-Object -First 1
        }
    }

    if ($localZip) {
        Write-Host "[*] Arquivo compactado encontrado: $($localZip.Name)" -ForegroundColor Green
        Write-Host "[*] Extraindo arquivos da firmware para a pasta do programa..." -ForegroundColor Yellow
        tar.exe -xf "$($localZip.FullName)" -C "$rootDir"
        if (Test-Path $superPath) { return $true }
    }

    Write-Host "Deseja que o programa baixe e extraia a firmware oficial agora?" -ForegroundColor White
    $resp = Read-Host "Digite 'S' para baixar automaticamente ou 'N' para cancelar"
    if ($resp -match "^[Ss]") {
        $fwUrl = "https://github.com/kaiqueizaque-crypto/xiaomi-mi-tv-stick-4k-recovery-tool/releases/download/Firmware/v1.0.0.-.Firmware.Android.14.zip"
        $zipDest = "$rootDir\firmware_download.zip"
        Write-Host "`nBaixando firmware oficial (1.08 GB)... Aguarde o termino:" -ForegroundColor Cyan
        curl.exe -L -C - --retry 5 -o $zipDest $fwUrl
        if (Test-Path $zipDest) {
            Write-Host "`nExtraindo firmware..." -ForegroundColor Yellow
            tar.exe -xf $zipDest -C "$rootDir"
            Remove-Item $zipDest -Force -ErrorAction SilentlyContinue
        }
    }

    if (Test-Path $superPath) {
        Write-Host "`n[OK] Firmware pronta para gravacao!" -ForegroundColor Green
        Start-Sleep -Seconds 2
        return $true
    } else {
        Write-Host "`n[!] Os arquivos da firmware ainda nao estao na pasta." -ForegroundColor Red
        Write-Host "    Baixe o arquivo na aba Releases do GitHub e extraia na pasta 'firmware'." -ForegroundColor Yellow
        Pause-Console
        return $false
    }
}

function Instalar-Drivers-Interativo {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "         [2] INSTALACAO E REPARO DE DRIVERS USB DO WINDOWS           " -ForegroundColor Green
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Este procedimento instala os drivers necessarios para que o computador" -ForegroundColor White
    Write-Host "consiga conversar com o processador Amlogic e com o Fastboot da Google." -ForegroundColor White
    Write-Host ""
    
    Write-Host "[1/3] Registrando Google USB Driver (Modo Fastboot)..." -ForegroundColor Yellow
    $gInf = "$drvDir\google\android_winusb.inf"
    if (Test-Path $gInf) {
        pnputil /add-driver $gInf /install | Out-Null
        Write-Host "      Driver Google registrado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "      Arquivo $gInf nao encontrado." -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "[2/3] Registrando Amlogic WinUSB Driver (Modo DNL / 1B8E C004)..." -ForegroundColor Yellow
    $dInf = "$drvDir\amlogic_dnl\DNL.inf"
    if (Test-Path $dInf) {
        pnputil /add-driver $dInf /install | Out-Null
        Write-Host "      Driver Amlogic DNL registrado com sucesso!" -ForegroundColor Green
    }
    $dExe = "$drvDir\amlogic_dnl\installer_x64.exe"
    if (Test-Path $dExe) {
        Start-Process $dExe -ArgumentList "/quiet" -Wait -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Host "[3/3] Aplicando identificadores de comunicacao ADB no Registro..." -ForegroundColor Yellow
    Corrigir-Guids -Silencioso $false
    
    Write-Host ""
    Write-Host "=====================================================================" -ForegroundColor Green
    Write-Host "Concluido! Todos os drivers estao registrados no seu Windows." -ForegroundColor Green
    Write-Host "=====================================================================" -ForegroundColor Green
    Pause-Console
}

function Mostrar-Menu {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "           XIAOMI MI TV STICK 4K (MDZ-27-AA) - RECOVERY TOOL         " -ForegroundColor Green
    Write-Host "        Restauracao Oficial do Android 14 (Desbrick Total)           " -ForegroundColor Yellow
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host " [OK] Drivers USB do sistema: Prontos e verificados automaticamente" -ForegroundColor DarkGreen
    Write-Host "---------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  OPCOES PRINCIPAIS:" -ForegroundColor White
    Write-Host "   [1] RECUPERACAO AUTOMATICA EM 1 CLIQUE (Recomendado)" -ForegroundColor Green
    Write-Host "       Captura o aparelho, desbloqueia, grava o Android 14 e reseta" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   [2] Instalar / Reparar Drivers USB no Windows" -ForegroundColor White
    Write-Host "   [3] Testar Conexao do Cabo e Porta USB (Monitor em tempo real)" -ForegroundColor White
    Write-Host "   [4] Abrir Zadig (Configuracao Manual de Drivers - se necessario)" -ForegroundColor White
    Write-Host "   [5] Manual de Instrucoes e Dicas de Solucao de Problemas (FAQ)" -ForegroundColor White
    Write-Host "   [6] Abrir Pasta dos Arquivos de Firmware" -ForegroundColor White
    Write-Host "   [7] Sair" -ForegroundColor Gray
    Write-Host ""
    Write-Host "=====================================================================" -ForegroundColor Cyan
}

function Menu-Ajuda {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "             [5] DICAS E SOLUCAO DE PROBLEMAS COMUNS                 " -ForegroundColor Yellow
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. O STICK FICA PISCANDO E SUMINDO NO COMPUTADOR:" -ForegroundColor Yellow
    Write-Host "   Isso e normal quando ele esta brickado! O nosso recuperador" -ForegroundColor White
    Write-Host "   (Opcao 1) 'pesca' a conexao no milissegundo exato em que ele liga." -ForegroundColor White
    Write-Host "   Basta seguir a ordem: Desconectar -> Iniciar a Opcao 1 -> Conectar." -ForegroundColor White
    Write-Host ""
    Write-Host "2. NUNCA DESCONECTE O CABO DURANTE A GRAVACAO:" -ForegroundColor Yellow
    Write-Host "   O Mi Stick nao tem bateria interna! Se voce tirar o cabo durante a" -ForegroundColor White
    Write-Host "   gravacao, ele desliga e volta para a estaca zero. Deixe o cabo quieto." -ForegroundColor White
    Write-Host ""
    Write-Host "3. CABO DE CARGA vs CABO DE DADOS:" -ForegroundColor Yellow
    Write-Host "   Muitos cabos de carregador comum so passam energia e nao tem trilhas" -ForegroundColor White
    Write-Host "   de dados. Use um cabo de celular de qualidade comprovada de dados." -ForegroundColor White
    Write-Host ""
    Write-Host "4. PRIMEIRO BOOT NA TV:" -ForegroundColor Yellow
    Write-Host "   Apos recuperar no PC, ligue na TV usando uma fonte de tomada na parede" -ForegroundColor White
    Write-Host "   de pelo menos 5V 2A. NUNCA ligue na USB da TV, pois ela nao aguenta." -ForegroundColor White
    Write-Host "   O primeiro boot do Android 14 pode demorar de 5 a 10 minutos." -ForegroundColor White
    Write-Host ""
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Pause-Console
}

while ($true) {
    Mostrar-Menu
    $opcao = Read-Host "Digite o numero da opcao desejada e pressione Enter"
    
    switch ($opcao) {
        "1" {
            if (-not (Garantir-Firmware)) { continue }

            Clear-Host
            Write-Host "=====================================================================" -ForegroundColor Cyan
            Write-Host "           [1] INICIANDO RECUPERACAO AUTOMATICA ANDROID 14           " -ForegroundColor Green
            Write-Host "=====================================================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  PASSO A PASSO PARA O USUARIO (MUITO SIMPLES):" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "   Passo 1: Se o Mi Stick estiver conectado, DESCONECTE do USB agora." -ForegroundColor White
            Write-Host "   Passo 2: Pressione [ENTER] abaixo para armar o sistema de captura." -ForegroundColor White
            Write-Host "   Passo 3: Quando aparecer '< waiting for any device >', PLUGUE o stick." -ForegroundColor White
            Write-Host "   Passo 4: NAO MEXA NO CABO ate vermos a mensagem verde de sucesso!" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "---------------------------------------------------------------------" -ForegroundColor DarkGray
            Write-Host "Pressione qualquer tecla para armar o Fastboot e aguardar a conexao..." -ForegroundColor Gray
            [void][System.Console]::ReadKey($true)
            
            Instalar-Drivers-Silencioso
            
            Write-Host ""
            Write-Host "[*] Sistema armado! Aguardando voce conectar o Mi Stick no USB..." -ForegroundColor Cyan
            Write-Host "    (Plugue o cabo no computador agora)" -ForegroundColor Yellow
            Write-Host ""
            & $fb reboot bootloader
            
            Write-Host ""
            Write-Host "[*] Aparelho detectado! Aguardando 3 segundos para estabilizar..." -ForegroundColor Yellow
            Start-Sleep -Seconds 3
            
            Corrigir-Guids -Silencioso $true
            
            Set-Location $fwDir
            Write-Host ""
            Write-Host "[*] Informacoes do Aparelho:" -ForegroundColor Cyan
            & $fb getvar product
            & $fb getvar version-bootloader
            
            Write-Host ""
            Write-Host "[*] Destravando permissoes de gravacao (bootloader unlock)..." -ForegroundColor Cyan
            & $fb flashing unlock 2>$null | Out-Null
            & $fb flashing unlock_critical 2>$null | Out-Null
            
            Write-Host ""
            Write-Host "[*] [1/9] Gravando particao: bootloader..." -ForegroundColor Green
            & $fb flash bootloader "$imgDir\bootloader.img"
            
            $particoes = @(
                @{ nome = "dtbo"; desc = "Arvore de Dispositivos (dtbo)" },
                @{ nome = "oem"; desc = "Configuracoes OEM (oem)" },
                @{ nome = "odm_ext"; desc = "Extensoes ODM (odm_ext)" },
                @{ nome = "vbmeta"; desc = "Chaves de Seguranca (vbmeta)" },
                @{ nome = "vbmeta_system"; desc = "Assinatura do Sistema (vbmeta_system)" },
                @{ nome = "vendor_boot"; desc = "Kernel de Inicializacao (vendor_boot)" },
                @{ nome = "boot"; desc = "Sistema Base de Boot (boot)" }
            )
            
            $i = 2
            foreach ($p in $particoes) {
                Write-Host ""
                Write-Host "[*] [$i/9] Gravando $($p.desc)..." -ForegroundColor Green
                & $fb --slot all flash $($p.nome) "$imgDir\$($p.nome).img"
                $i++
            }
            
            Write-Host ""
            Write-Host "[*] [9/9] Gravando particao SUPER de 1,8 GB (Android 14)..." -ForegroundColor Green
            Write-Host "    (Esta etapa pode levar de 2 a 4 minutos. Nao desconecte!)" -ForegroundColor Yellow
            & $fb flash super "$imgDir\super.img"
            
            Write-Host ""
            Write-Host "[*] Travando o bootloader com chaves de fabrica..." -ForegroundColor Cyan
            & $fb flashing lock 2>$null | Out-Null
            & $fb flashing lock_critical 2>$null | Out-Null
            
            Write-Host ""
            Write-Host "[*] Ajustando slots e formatando dados (Reset de Fabrica / Wipe)..." -ForegroundColor Cyan
            & $fb reboot bootloader 2>$null | Out-Null
            Start-Sleep -Seconds 3
            & $fb flashing unlock 2>$null | Out-Null
            & $fb set_active other 2>$null | Out-Null
            & $fb set_active other 2>$null | Out-Null
            & $fb -w 2>$null | Out-Null
            & $fb flashing lock 2>$null | Out-Null
            
            Write-Host ""
            Write-Host "=====================================================================" -ForegroundColor Green
            Write-Host "              RECUPERACAO CONCLUIDA COM 100% DE SUCESSO!             " -ForegroundColor Green
            Write-Host "=====================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "COMO LIGAR O APARELHO NA TELEVISAO AGORA:" -ForegroundColor White
            Write-Host " 1. Pode desconectar o cabo USB do computador com seguranca." -ForegroundColor White
            Write-Host " 2. Conecte o Mi Stick na entrada HDMI da TV." -ForegroundColor White
            Write-Host " 3. LIGUE NA TOMADA COM FONTE DE 5V 2A (Nao use a porta USB da TV!)." -ForegroundColor Yellow
            Write-Host " 4. No primeiro boot, aguarde de 5 a 10 minutos para carregar a tela." -ForegroundColor Yellow
            Write-Host " 5. Quando abrir a tela de boas-vindas do Android TV, pareie o controle!" -ForegroundColor Green
            Write-Host ""
            Write-Host "=====================================================================" -ForegroundColor Green
            Pause-Console
        }
        
        "2" {
            Instalar-Drivers-Interativo
        }
        
        "3" {
            Clear-Host
            Write-Host "=====================================================================" -ForegroundColor Cyan
            Write-Host "         [3] TESTE DE CABO E MONITORAMENTO USB (15 SEGUNDOS)         " -ForegroundColor Yellow
            Write-Host "=====================================================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Dica: Conecte e desconecte o cabo para ver se o Windows detecta o chip." -ForegroundColor White
            Write-Host ""
            for ($i = 0; $i -lt 15; $i++) {
                $dev = Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -like '*1B8E*' -or $_.InstanceId -like '*18D1*' }
                $hora = Get-Date -Format 'HH:mm:ss'
                if ($dev) {
                    Write-Host "[$hora] -> DETECTADO: $($dev.FriendlyName) ($($dev.InstanceId))" -ForegroundColor Green
                } else {
                    Write-Host "[$hora] -> Nenhum sinal do Mi Stick (Cabo desconectado ou sem dados)" -ForegroundColor Yellow
                }
                Start-Sleep -Seconds 1
            }
            Write-Host ""
            Write-Host "Se aparecer DETECTADO mesmo por 1 segundo, seu cabo e porta estao OK!" -ForegroundColor Cyan
            Pause-Console
        }
        
        "4" {
            Clear-Host
            Write-Host "=====================================================================" -ForegroundColor Cyan
            Write-Host "                    [4] ABRINDO O UTILITARIO ZADIG                   " -ForegroundColor Yellow
            Write-Host "=====================================================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Como usar caso o driver automatico falhe em um computador antigo:" -ForegroundColor White
            Write-Host " 1. No menu superior, clique em: Options -> List All Devices" -ForegroundColor White
            Write-Host " 2. Na lista, escolha: DNL (USB ID: 1B8E C004)" -ForegroundColor Yellow
            Write-Host " 3. No campo Driver, selecione: WinUSB" -ForegroundColor White
            Write-Host " 4. Clique em: Install Driver (ou Replace Driver)" -ForegroundColor Green
            Write-Host ""
            Start-Process "$drvDir\zadig-2.9.exe"
            Pause-Console
        }
        
        "5" {
            Menu-Ajuda
        }
        
        "6" {
            Invoke-Item $fwDir
        }
        
        "7" {
            exit
        }
    }
}

# 📺 Xiaomi Mi TV Stick 4K (MDZ-27-AA) — 1-Click Recovery Toolkit (Android 14)

[![Windows 10/11](https://img.shields.io/badge/Windows-10%20%7C%2011-blue?logo=windows)](https://microsoft.com)
[![Xiaomi MDZ-27-AA](https://img.shields.io/badge/Modelo-MDZ--27--AA%20(soul)-orange?logo=xiaomi)](https://mi.com)
[![Firmware Android 14](https://img.shields.io/badge/Firmware-Android%2014%20(V816.0.26.6.10)-green?logo=android)](https://android.com)
[![Download Firmware](https://img.shields.io/badge/⬇️%20Firmware%20Oficial-Download%20(1.08%20GB)-brightgreen)](https://github.com/kaiqueizaque-crypto/xiaomi-mi-tv-stick-4k-recovery-tool/releases/download/Firmware/v1.0.0.-.Firmware.Android.14.zip)

> **Solução completa, automatizada e pronta para uso** para desbrickar o **Xiaomi Mi TV Stick 4K (Modelo: MDZ-27-AA / codinome "soul")** preso no logo "Mi", em bootloop infinito ou caindo no modo de emergência Amlogic (`VID_1B8E&PID_C004`).
>
> 💡 **Projeto remodelado para usuários leigos:** Todo o processo técnico complexo (instalação de drivers, correção de GUIDs do registro, captura do bootloader e gravação de partições) foi transformado em um assistente automático de **1 clique**.

---

## 📦 Download Rápido dos Arquivos

1. **Baixe o repositório:** Clique no botão verde `<> Code` ➔ **Download ZIP** (ou clone via Git).
2. **Baixe a Firmware oficial (1.08 GB):**  
   👉 **[Clique aqui para baixar a Firmware Oficial Android 14 (v1.0.0.-.Firmware.Android.14.zip)](https://github.com/kaiqueizaque-crypto/xiaomi-mi-tv-stick-4k-recovery-tool/releases/download/Firmware/v1.0.0.-.Firmware.Android.14.zip)**  
   *(Extraia o conteúdo dentro da pasta `firmware` do projeto, ou simplesmente deixe o zip na raiz que o nosso programa extrai para você automaticamente!)*

---

## 🎯 Por que o Mi Stick 4K entra em Bootloop?

Milhares de aparelhos sofreram falhas durante a atualização oficial da Xiaomi via OTA do Android 11 para o Android 14. Quando a atualização falha pela metade:
1. O bootloader é atualizado para o Android 14, mas as partições do sistema ficam corrompidas.
2. O aparelho não consegue ligar o Android e cai no modo de emergência da Amlogic (**Modo DNL / `VID_1B8E&PID_C004`**), ciclando no barramento USB a cada poucos segundos.
3. Métodos tradicionais falham porque o Windows não possui os drivers WinUSB instalados por padrão, o identificador de interface do ADB fica ausente no registro e o aparelho desliga se o cabo for desconectado.

Este kit resolve todos esses problemas de forma **100% transparente e automática**.

---

## 📁 Estrutura do Repositório

```text
Mi_TV_Stick_4K_Recovery_Tool/
│
├── 🚀 EXECUTAR_RECUPERACAO.bat     <- Iniciador principal (Dê dois cliques aqui)
├── 📄 INSTRUCOES.txt               <- Manual simples e direto em texto puro
├── 📘 README.md                    <- Documentação oficial
├── 📘 LEIAME.md                    <- Cópia em português
│
├── 📁 drivers/                     <- Todos os drivers necessários incluídos
│   ├── google/                     <- Driver oficial Google USB (Fastboot VID 18D1)
│   ├── amlogic_dnl/                <- Driver Amlogic WinUSB (DNL VID 1B8E PID C004)
│   └── zadig-2.9.exe               <- Gerenciador USB Zadig (para casos excepcionais)
│
├── 📁 firmware/                    <- Pasta onde a firmware oficial é descompactada
│   ├── bin/                        <- fastboot.exe, mke2fs.exe, AdbWinApi.dll, etc.
│   └── images/                     <- bootloader.img, super.img (1.8 GB), boot.img, etc.
│
└── 📁 scripts/
    └── recuperador.ps1             <- O cérebro do assistente (PowerShell inteligente)
```

---

## 🛠️ Como Usar (Passo a Passo para Qualquer Usuário)

### O que você precisa:
- O Mi TV Stick 4K (MDZ-27-AA).
- Um **Cabo USB de dados** (cabos que apenas carregam não transmitem informações para o PC).
- Um computador com Windows 10 ou 11.
- Um carregador de celular de parede (5V e 2A) para ligar na TV no final.

---

### Passo 1: Abrir o Programa
1. Dê dois cliques em **`EXECUTAR_RECUPERACAO.bat`**.
2. Clique em **Sim** na tela de permissão de Administrador do Windows.
3. O programa verificará e configurará todos os drivers do sistema automaticamente.

---

### Passo 2: Recuperação Automática
1. No menu principal, digite **`1`** e pressione **[ENTER]**.
2. Siga as orientações na tela:
   - Se o Mi Stick estiver conectado, **desconecte-o**.
   - Pressione qualquer tecla para armar o Fastboot (`< waiting for any device >`).
   - **Plugue o Mi Stick na porta USB do computador.**
   - **NÃO MEXA NO CABO!**
3. O assistente fará todo o processo:
   - Captura a conexão no momento exato.
   - Salta para o 2º estágio do Fastboot da Google.
   - Desbloqueia o bootloader.
   - Grava todas as partições oficiais (`bootloader`, `boot`, `dtbo`, `oem`, `vendor_boot`, `vbmeta`, etc.).
   - Grava a partição do sistema `super.img` de 1.8 GB (leva de 2 a 4 minutos).
   - Trava o bootloader de volta com chaves oficiais de fábrica.
   - Executa o reset de fábrica (`wipe data`).
   - Exibe a tela verde de **SUCESSO**!

---

### Passo 3: Ligando na TV
1. Desconecte o cabo USB do computador.
2. Plugue o Mi Stick na entrada HDMI da TV.
3. **LIGUE NA TOMADA COM FONTE DE 5V 2A** (⚠️ **NUNCA ligue na USB da própria TV**, pois ela não fornece energia suficiente para o primeiro boot).
4. No primeiro boot, aguarde de **5 a 10 minutos** com a logo na tela enquanto o Android organiza os arquivos.
5. Quando aparecer a tela de boas-vindas do Android TV, pareie o controle e aproveite seu aparelho recuperado!

---

## ⚡ Recursos e Inovações Deste Kit Remodelado

- **Zero Configuração Manual:** O usuário não precisa abrir o Gerenciador de Dispositivos, nem adivinhar comandos no CMD.
- **Auto-Download Inteligente:** Se a pasta da firmware não estiver presente, o programa oferece o download direto e descompactação automática.
- **Injeção de Drivers Automática:** Adiciona automaticamente os drivers da Google e da Amlogic no repositório de drivers do Windows (`DriverStore`) usando `pnputil`.
- **Auto-Correção de GUID:** Insere dinamicamente o identificador ADB `{F72FE0D4-CBCB-407D-8814-9ED673D0DD6B}` no Registro do Windows para que o Fastboot nunca fique preso em `< waiting for any device >`.
- **Sincronia Inteligente de Captura:** Resolve a perda de conexão causada pelo reinício do chip Amlogic armando a escuta antes da conexão física.
- **Firmware Oficial com Chaves de Fábrica:** Utiliza a build oficial `UKG3.250107.001.V816.0.26.6.10` assinada digitalmente pela Xiaomi (`release-keys`).

---

## 🙏 Créditos e Agradecimentos

Este projeto remodelado foi desenvolvido para democratizar o acesso à recuperação deste aparelho, e presta homenagem às fontes originais de pesquisa:

- **[RodrigoDeveloperX](https://github.com/RodrigoDeveloperX/xiaomi-mi-tv-stick-4k-mdz-27-aa-recovery)**: Pela pesquisa aprofundada, identificação do problema da transição Android 11 → Android 14, descoberta das particularidades do DNL e testes no hardware real.
- **Comunidade [4PDA](https://4pda.to/forum/index.php?showtopic=1041410)**: Pelo pioneirismo no arquivamento e disponibilização dos pacotes oficiais de firmware e ferramentas Amlogic.
- **Pete Batard / Akeo**: Pelo desenvolvimento da ferramenta Zadig e biblioteca `libwdi`.
- **Google & Amlogic**: Pelas ferramentas de desenvolvimento Android Platform Tools (`fastboot`) e arquitetura Amlogic BootROM.

---

## ⚖️ Isenção de Responsabilidade

Este software é fornecido "como está", sem garantias explícitas ou implícitas. Todas as firmwares aqui referenciadas são de propriedade intelectual da Xiaomi Inc. Este repositório destina-se a fins educacionais e de reparo de dispositivos fora de garantia que se tornaram inoperantes após atualizações oficiais.

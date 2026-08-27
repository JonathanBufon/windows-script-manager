<a id="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![GPL-3.0 License][license-shield]][license-url]

<br />
<div align="center">
  <h1 align="center">🧹 Windows Script Manager</h1>

  <p align="center">
    Um único <code>.bat</code> que deixa o Windows 10/11 pronto para uso depois de formatar:
    limpa, remove bloatware e telemetria, instala seus programas e define os padrões de arquivo.
    <br />
    <a href="#uso"><strong>Ver a documentação »</strong></a>
    <br />
    <br />
    <a href="https://github.com/JonathanBufon/windows-script-manager/raw/main/windows-setup.bat">Baixar o script</a>
    &middot;
    <a href="https://github.com/JonathanBufon/windows-script-manager/issues/new?labels=bug">Reportar bug</a>
    &middot;
    <a href="https://github.com/JonathanBufon/windows-script-manager/issues/new?labels=enhancement">Sugerir função</a>
  </p>
</div>

<details>
  <summary>Sumário</summary>
  <ol>
    <li>
      <a href="#sobre-o-projeto">Sobre o projeto</a>
      <ul>
        <li><a href="#o-que-ele-faz">O que ele faz</a></li>
        <li><a href="#construído-com">Construído com</a></li>
      </ul>
    </li>
    <li>
      <a href="#começando">Começando</a>
      <ul>
        <li><a href="#pré-requisitos">Pré-requisitos</a></li>
        <li><a href="#instalação">Instalação</a></li>
      </ul>
    </li>
    <li>
      <a href="#uso">Uso</a>
      <ul>
        <li><a href="#menu">Menu</a></li>
        <li><a href="#configuração">Configuração</a></li>
        <li><a href="#adicionando-e-removendo-programas">Adicionando e removendo programas</a></li>
        <li><a href="#programas-padrão">Programas padrão</a></li>
        <li><a href="#log">Log</a></li>
      </ul>
    </li>
    <li><a href="#como-funciona">Como funciona</a></li>
    <li><a href="#avisos">Avisos</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contribuindo">Contribuindo</a></li>
    <li><a href="#licença">Licença</a></li>
    <li><a href="#contato">Contato</a></li>
    <li><a href="#agradecimentos">Agradecimentos</a></li>
  </ol>
</details>

## Sobre o projeto

Formatar um PC é sempre a mesma sequência de tarefas chatas: tirar o bloatware,
desligar a telemetria, arrancar o OneDrive, limpar o que a instalação deixou pra
trás, instalar os programas de sempre e reassociar os tipos de arquivo. Cada uma
dessas coisas tem um script pronto por aí — e aí você acaba executando cinco
arquivos diferentes, na ordem certa, torcendo pra não esquecer nenhum.

Este projeto junta tudo isso em **um arquivo só**, sem instalador e sem
dependência nenhuma. Duplo clique, ele pede elevação sozinho e faz o resto.

Nasceu da unificação de dois repositórios que resolviam metades diferentes do
problema (veja [Agradecimentos](#agradecimentos)), com a deduplicação das partes
que se sobrepunham e três módulos novos.

### O que ele faz

| Módulo | O que faz | Padrão |
|---|---|:---:|
| **Ponto de restauração** | Habilita a proteção do sistema e cria um checkpoint antes de qualquer alteração | ✅ |
| **Telemetria** | `AllowTelemetry=0`, desativa os serviços DiagTrack e dmwappushservice, as notificações do Feedback e 8 tarefas agendadas de diagnóstico | ✅ |
| **OneDrive** | Desinstala (x64 e x86), apaga as pastas residuais, remove do painel do Explorer e bloqueia a sincronização por policy | ✅ |
| **Debloat** | Remove 17 apps de consumo (Xbox, Skype, Bing, Clipchamp, Zune…), desliga os widgets da barra de tarefas e as sugestões do menu Iniciar | ✅ |
| **Instalação** | Instala seus programas via `winget`, em modo silencioso | ✅ |
| **Programas padrão** | Associa WinRAR aos formatos compactados e o VLC aos de vídeo e áudio | ✅ |
| **Privacidade** | Limpa itens recentes, jump lists, cache de miniaturas, relatórios de erro (WER) e o cache DNS | ✅ |
| **Cache dos navegadores** | Chrome, Edge, Brave e Firefox — **fecha os navegadores abertos**, por isso vem desligado | ❌ |
| **Limpeza de disco** | Temporários do usuário e do sistema, lixeira, cache do Windows Update e do Delivery Optimization, `Windows.old` e limpeza de componentes via DISM | ✅ |
| **Otimização** | `defrag /O` — TRIM em SSD, desfragmentação em HDD | ✅ |

Nada aqui quebra o Windows Update nem a Microsoft Store.

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

### Construído com

[![Batch][batch-shield]][batch-url]
[![PowerShell][powershell-shield]][powershell-url]
[![Windows][windows-shield]][windows-url]

Batch puro para o fluxo e a interface; PowerShell só onde o `cmd` não dá conta
(remoção de pacotes Appx, ponto de restauração, lixeira); `winget`, `DISM`,
`reg` e `schtasks` para o trabalho pesado. Sem binários de terceiros, sem
download de nada além dos programas que você mesmo listar.

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

## Começando

### Pré-requisitos

* Windows 10 ou Windows 11
* Conta com privilégios de administrador (o script pede elevação sozinho)
* `winget` — já vem no Windows 11 e no 10 atualizado. Para conferir:
  ```sh
  winget --version
  ```
  Se não existir, instale o **Instalador de Aplicativo** pela Microsoft Store.
  O script funciona sem ele: só pula o módulo de instalação e avisa.

### Instalação

1. Baixe o [`windows-setup.bat`][download-url] — é o único arquivo necessário.
   Ou clone o repositório:
   ```sh
   git clone https://github.com/JonathanBufon/windows-script-manager.git
   ```
2. Abra o arquivo num editor de texto e ajuste o bloco de configuração no topo
   (quais módulos rodar, quais programas instalar). Veja [Uso](#uso).
3. Duplo clique no `windows-setup.bat`.

> [!TIP]
> Não precisa clicar com o botão direito em "Executar como administrador".
> O script detecta que não está elevado e se relança pelo UAC sozinho.

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

## Uso

```bat
windows-setup.bat          :: abre o menu interativo
windows-setup.bat /auto    :: executa tudo, sem perguntar nada
windows-setup.bat /clean   :: só limpeza de disco + privacidade
```

### Menu

```
[1]  Executar TUDO                 (recomendado em PC recém-formatado)
[2]  Escolher módulos um a um
[3]  Somente limpeza de disco      (temp, lixeira, cache, Windows.old)
[4]  Somente privacidade + debloat (telemetria, OneDrive, apps)
[5]  Somente instalar programas + definir padrões
[6]  Ver configuração atual
[0]  Sair
```

### Configuração

No topo do arquivo há um bloco de flags. Trocar `1` por `0` desliga o módulo,
sem precisar mexer em mais nada:

```bat
set "DO_RESTOREPOINT=1"      && rem Cria ponto de restauracao antes de tudo
set "DO_TELEMETRY=1"         && rem Desativa telemetria, DiagTrack e tarefas
set "DO_ONEDRIVE=1"          && rem Desinstala o OneDrive por completo
set "DO_DEBLOAT=1"           && rem Remove apps de consumo (Xbox, Skype, etc)
set "DO_INSTALL=1"           && rem Instala meus programas via winget
set "DO_DEFAULTS=1"          && rem Define WinRAR e VLC como programa padrao
set "DO_PRIVACY=1"           && rem Recentes, thumbcache, relatorios de erro
set "DO_BROWSERCACHE=0"      && rem Cache dos navegadores (FECHA os navegadores)
set "DO_DISKCLEAN=1"         && rem Temp, lixeira, cache do Update, Windows.old
set "DO_DISM_RESETBASE=0"    && rem DISM /ResetBase (irreversivel, ver aviso)
set "DO_OPTIMIZE=1"          && rem Otimiza / TRIM do disco do sistema
set "ASK_REBOOT=1"           && rem Pergunta se quer reiniciar no final
```

A opção `[2]` do menu permite escolher módulo a módulo na hora, sem editar o
arquivo.

### Adicionando e removendo programas

A lista de programas fica numa variável, separada por espaços, com os **IDs
exatos** do winget:

```bat
set "WINGET_APPS=Discord.Discord Valve.Steam Mozilla.Firefox RARLab.WinRAR VideoLAN.VLC"
```

| Programa | ID do winget |
|---|---|
| Discord | `Discord.Discord` |
| Steam | `Valve.Steam` |
| Firefox | `Mozilla.Firefox` |
| WinRAR | `RARLab.WinRAR` |
| VLC | `VideoLAN.VLC` |

**Para adicionar**, descubra o ID e emende na mesma linha:

```sh
winget search "obs studio"

Nome        Id                    Versão   Origem
-------------------------------------------------
OBS Studio  OBSProject.OBSStudio  31.0.1   winget
            ^^^^^^^^^^^^^^^^^^^^
            é essa coluna que vai na lista
```

```bat
set "WINGET_APPS=Discord.Discord Valve.Steam Mozilla.Firefox RARLab.WinRAR VideoLAN.VLC OBSProject.OBSStudio"
```

Alguns IDs comuns para começar — confirme com `winget search` antes, porque os
mantenedores às vezes renomeiam:

| Programa | ID | Programa | ID |
|---|---|---|---|
| 7-Zip | `7zip.7zip` | OBS Studio | `OBSProject.OBSStudio` |
| Google Chrome | `Google.Chrome` | Spotify | `Spotify.Spotify` |
| Notepad++ | `Notepad++.Notepad++` | qBittorrent | `qBittorrent.qBittorrent` |
| VS Code | `Microsoft.VisualStudioCode` | Epic Games | `EpicGames.EpicGamesLauncher` |
| Git | `Git.Git` | PowerToys | `Microsoft.PowerToys` |

**Para remover**, apague o item da linha:

```bat
:: sem o Discord
set "WINGET_APPS=Valve.Steam Mozilla.Firefox RARLab.WinRAR VideoLAN.VLC"
```

> [!WARNING]
> Tirar da lista **não desinstala** nada que já esteja no PC — só faz o script
> parar de instalar aquilo nas próximas execuções. Para desinstalar de verdade:
> ```bat
> winget uninstall --id Discord.Discord
> ```

Para desligar a instalação por completo sem mexer na lista, use
`set "DO_INSTALL=0"` ou a opção `[2]` do menu.

**Regras da lista:**

* Tudo em **uma única linha**, entre as aspas do `set "WINGET_APPS=..."`.
* Separador é **espaço**, sem vírgula e sem aspas nos itens.
* Use o **Id**, não o nome: `Mozilla.Firefox`, não `Firefox`.
* Como o script usa `--exact`, um ID errado faz falhar **só aquele** pacote —
  os outros continuam, e o código do erro vai para o log.

> A lista de apps que o módulo de **debloat remove** é outra, e fica dentro da
> sub-rotina `:MOD_DEBLOAT`, nas linhas `set "APPS=..."`. Mesma ideia.

Cada pacote é instalado com `--exact --id --silent --accept-package-agreements
--accept-source-agreements --disable-interactivity`, ou seja, zero clique. Os
retornos de "já instalado" e "já atualizado" contam como sucesso.

> [!NOTE]
> Esse é o único módulo que depende de rede. Num PC recém-formatado ainda sem
> driver de rede, ele falha e todos os outros rodam normalmente; é só executar a
> opção `[5]` mais tarde.

### Programas padrão

O módulo localiza os executáveis instalados, cria os ProgIDs `WinRAR.Archive`,
`VLC.Video` e `VLC.Audio` em `HKCR` (com ícone e comando de abertura), aponta
cada extensão para eles, registra em `OpenWithProgids`, apaga o `UserChoice`
anterior daquela extensão e reinicia o Explorer.

As listas de extensões também são editáveis no topo do `.bat`:

```bat
set "EXT_WINRAR=.rar .zip .7z .tar .gz .tgz .bz2 .xz .cab .arj .lzh .ace .z .iso"
set "EXT_VLC_VIDEO=.mp4 .mkv .avi .mov .wmv .flv .webm .mpg .mpeg .m4v .3gp .ts .m2ts .vob .ogv .divx"
set "EXT_VLC_AUDIO=.mp3 .flac .wav .aac .ogg .oga .m4a .wma .opus .mka .aiff"
```

> [!IMPORTANT]
> **Limitação sem contorno por script.** Desde o Windows 8 a escolha final do
> usuário fica em `HKCU\...\FileExts\<ext>\UserChoice`, protegida por um hash que
> combina extensão + ProgID + SID + timestamp. O algoritmo não é público e a
> chave tem ACL negando escrita — gravar ali diretamente faz o Windows detectar
> a adulteração e **resetar** a associação.
>
> Na prática: num PC recém-formatado, onde ainda não existe `UserChoice` para
> `.mkv` ou `.7z`, o que o script faz **é** suficiente. Onde o Windows já fincou
> um padrão próprio (caso do `.zip`, e do `.rar` no Windows 11 24H2), vai faltar
> um clique em **Configurações › Aplicativos › Aplicativos padrão**. O script
> oferece abrir essa tela no fim do módulo.

### Log

Toda execução gera um log carimbado com data e hora em `logs/`, ao lado do
script. A saída de cada comando vai para lá; a tela mostra só o progresso. O
módulo de limpeza registra o espaço livre em disco antes e depois, para você ver
quanto foi recuperado.

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

## Como funciona

O script é um único `.bat` organizado em módulos independentes, cada um numa
sub-rotina própria. A ordem não é arbitrária:

```
elevação (UAC)
   └─ ponto de restauração
        └─ telemetria → OneDrive → debloat
             └─ instalação (winget) → programas padrão
                  └─ privacidade → cache dos navegadores
                       └─ limpeza de disco → otimização
```

A limpeza vem **depois** do debloat e da instalação de propósito: assim tanto os
resíduos dos apps removidos quanto os instaladores baixados pelo winget já
entram na faxina. O DISM, que é o passo mais lento, roda por último.

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

## Avisos

> [!CAUTION]
> **Não há desfazer automático.** Deixe o ponto de restauração ligado na
> primeira execução.

* `DO_DISM_RESETBASE=1` libera mais espaço, mas **impede desinstalar
  atualizações antigas** depois. Por isso vem desligado.
* `DO_BROWSERCACHE=1` **fecha** Chrome, Edge, Brave, Firefox e Opera antes de
  limpar. Vem desligado para não matar navegadores no meio do seu trabalho.
* A remoção do OneDrive apaga arquivos que ainda não tenham sido sincronizados.
* `Windows.old` às vezes resiste ao `rd` mesmo com `takeown` e `icacls`; nesse
  caso use a Limpeza de Disco do Windows (`cleanmgr`) e marque "Instalações
  anteriores do Windows".
* O script **não** faz ativação do Windows e não toca em nada relacionado a
  licenciamento.

Testado em Windows 11. Deve funcionar no Windows 10, mas alguns nomes de app do
módulo de debloat são específicos do 11.

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

## Roadmap

- [x] Unificar os scripts de limpeza e debloat num arquivo só
- [x] Elevação automática por UAC
- [x] Menu interativo + modo desatendido (`/auto`)
- [x] Log carimbado por execução, com espaço livre antes/depois
- [x] Instalação de programas via `winget`
- [x] Associação de programas padrão (WinRAR e VLC)
- [ ] Modo `/dry` para simular sem alterar nada
- [ ] Perfis de configuração (gamer, trabalho, mínimo)
- [ ] Ajustes de aparência do Explorer (extensões visíveis, arquivos ocultos)

Veja as [issues abertas][issues-url] para a lista completa de ideias e bugs
conhecidos.

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

## Contribuindo

Contribuições são o que torna a comunidade open source um lugar incrível para
aprender e criar. Qualquer contribuição é **muito bem-vinda**.

Se tiver uma sugestão que melhore o projeto, faça um fork e abra um pull
request. Você também pode simplesmente abrir uma issue com a tag `enhancement`.

1. Faça um fork do projeto
2. Crie sua branch (`git checkout -b feature/MinhaFuncao`)
3. Commit das mudanças (`git commit -m 'Adiciona MinhaFuncao'`)
4. Push para a branch (`git push origin feature/MinhaFuncao`)
5. Abra um Pull Request

Ao mexer no `.bat`, mantenha o padrão do arquivo: **sem acentos** (o console do
`cmd` os quebra), todo comando redirecionado para o log, e cada módulo numa
sub-rotina própria com sua flag `DO_*`.

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

## Licença

Distribuído sob a licença GPL-3.0, herdada do `clean-windows`. Veja
[`LICENSE`](LICENSE) para mais informações.

O código vindo do `debloat` está sob MIT, compatível com a incorporação em uma
obra GPL.

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

## Contato

Jonathan Bufon — [@JonathanBufon](https://github.com/JonathanBufon)

Link do projeto: [https://github.com/JonathanBufon/windows-script-manager](https://github.com/JonathanBufon/windows-script-manager)

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

## Agradecimentos

Este projeto é a unificação de dois repositórios, com a deduplicação das partes
que se sobrepunham (temporários, cache do Windows Update, DISM e lixeira
apareciam nos dois):

| Origem | Autor | Licença | O que veio de lá |
|---|---|---|---|
| [yanpenalva/clean-windows](https://github.com/yanpenalva/clean-windows) | Yan Penalva | GPL-3.0 | `clean.bat` — privacidade, cache dos navegadores, limpeza de disco, otimização |
| [micheg/debloat](https://github.com/micheg/debloat) | Michelangelo Giacomelli | MIT | `stop_telemetry.bat`, `remove_onedrive.bat`, `debloat_soft.bat`, `clean_disk_safe.bat` |

Os módulos de ponto de restauração, instalação via winget e programas padrão são
novos.

* [Raphire/Win11Debloat](https://github.com/Raphire/Win11Debloat) — inspiração do `micheg/debloat`
* [othneildrew/Best-README-Template](https://github.com/othneildrew/Best-README-Template) — modelo deste README
* [Shields.io](https://shields.io) — badges

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

[contributors-shield]: https://img.shields.io/github/contributors/JonathanBufon/windows-script-manager.svg?style=for-the-badge
[contributors-url]: https://github.com/JonathanBufon/windows-script-manager/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/JonathanBufon/windows-script-manager.svg?style=for-the-badge
[forks-url]: https://github.com/JonathanBufon/windows-script-manager/network/members
[stars-shield]: https://img.shields.io/github/stars/JonathanBufon/windows-script-manager.svg?style=for-the-badge
[stars-url]: https://github.com/JonathanBufon/windows-script-manager/stargazers
[issues-shield]: https://img.shields.io/github/issues/JonathanBufon/windows-script-manager.svg?style=for-the-badge
[issues-url]: https://github.com/JonathanBufon/windows-script-manager/issues
[license-shield]: https://img.shields.io/github/license/JonathanBufon/windows-script-manager.svg?style=for-the-badge
[license-url]: https://github.com/JonathanBufon/windows-script-manager/blob/main/LICENSE
[download-url]: https://github.com/JonathanBufon/windows-script-manager/raw/main/windows-setup.bat
[batch-shield]: https://img.shields.io/badge/Batch-4D4D4D?style=for-the-badge&logo=windowsterminal&logoColor=white
[batch-url]: https://learn.microsoft.com/windows-server/administration/windows-commands/windows-commands
[powershell-shield]: https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white
[powershell-url]: https://learn.microsoft.com/powershell/
[windows-shield]: https://img.shields.io/badge/Windows%2010%20%2F%2011-0078D6?style=for-the-badge&logo=windows&logoColor=white
[windows-url]: https://www.microsoft.com/windows

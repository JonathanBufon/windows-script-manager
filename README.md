# Windows Script Manager

Script único de pós-formatação para Windows 10/11. Um arquivo `.bat`, sem
dependências, sem instalador: limpa o sistema, remove telemetria e bloatware,
instala seus programas e define os padrões de arquivo — tudo em uma execução.

Nasceu da unificação de dois projetos que faziam isso em pedaços separados
(veja [Créditos](#créditos)).

```bat
windows-setup.bat          :: menu interativo
windows-setup.bat /auto    :: executa tudo, sem perguntas
windows-setup.bat /clean   :: só limpeza de disco + privacidade
```

Baixe apenas o `windows-setup.bat`, dê um duplo clique e pronto — ele pede
elevação sozinho pelo UAC. Cada execução grava um log em
`logs/wsm-AAAAMMDD-HHMMSS.log`, ao lado do script.

---

## O que ele faz

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

---

## Como funciona

### Fluxo

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

A opção `[2]` do menu permite escolher módulo a módulo na hora da execução, sem
editar o arquivo.

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

### Log

Toda execução gera um log carimbado com data e hora em `logs/`. A saída de cada
comando vai para lá; a tela mostra só o progresso. O módulo de limpeza registra
o espaço livre em disco antes e depois, para você ver quanto foi recuperado.

---

## Programas instalados

A lista fica numa variável, separada por espaços, com os **IDs exatos** do
winget:

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

### Adicionando um programa

Descubra o ID exato com `winget search` e emende na mesma linha, separado por
espaço:

```bat
winget search "obs studio"

Nome        Id                    Versão   Origem
-------------------------------------------------
OBS Studio  OBSProject.OBSStudio  31.0.1   winget
            ^^^^^^^^^^^^^^^^^^^^
            é essa coluna que vai na lista
```

```bat
:: antes
set "WINGET_APPS=Discord.Discord Valve.Steam Mozilla.Firefox RARLab.WinRAR VideoLAN.VLC"

:: depois
set "WINGET_APPS=Discord.Discord Valve.Steam Mozilla.Firefox RARLab.WinRAR VideoLAN.VLC OBSProject.OBSStudio"
```

Alguns IDs comuns para começar — sempre confirme com `winget search` antes,
porque os mantenedores às vezes renomeiam:

| Programa | ID |
|---|---|
| 7-Zip | `7zip.7zip` |
| Google Chrome | `Google.Chrome` |
| Notepad++ | `Notepad++.Notepad++` |
| Visual Studio Code | `Microsoft.VisualStudioCode` |
| OBS Studio | `OBSProject.OBSStudio` |
| Spotify | `Spotify.Spotify` |
| qBittorrent | `qBittorrent.qBittorrent` |
| Epic Games Launcher | `EpicGames.EpicGamesLauncher` |
| PowerToys | `Microsoft.PowerToys` |
| Git | `Git.Git` |

### Removendo um programa

Apague o item da linha. Só isso:

```bat
:: sem o Discord
set "WINGET_APPS=Valve.Steam Mozilla.Firefox RARLab.WinRAR VideoLAN.VLC"
```

> ⚠️ Tirar da lista **não desinstala** nada que já esteja no PC — só faz o
> script parar de instalar aquilo nas próximas execuções. Para desinstalar de
> verdade:
>
> ```bat
> winget uninstall --id Discord.Discord
> ```

Para desligar a instalação por completo, sem mexer na lista, use
`set "DO_INSTALL=0"` ou a opção `[2]` do menu.

### Regras da lista

- Tudo em **uma única linha**, entre as aspas do `set "WINGET_APPS=..."`.
- Separador é **espaço**, sem vírgula e sem aspas nos itens.
- Use o **Id**, não o nome do programa: `Mozilla.Firefox`, não `Firefox`.
- Como o script usa `--exact`, um ID errado faz falhar **só aquele** pacote —
  os outros continuam. O código do erro aparece no log.
- Se você adicionar um programa que deva virar padrão de algum tipo de arquivo,
  veja também [Programas padrão](#programas-padrão).

> A lista de apps que o módulo de **debloat remove** é outra, e fica dentro da
> sub-rotina `:MOD_DEBLOAT`, nas linhas `set "APPS=..."`. Mesma ideia: itens
> separados por espaço.

### Como a instalação roda

Cada pacote é instalado com `--exact --id --silent --accept-package-agreements
--accept-source-agreements --disable-interactivity`, ou seja, zero clique. Os
códigos de retorno de "já instalado" e "já atualizado" são tratados como
sucesso, e a falha de um pacote não interrompe os demais.

Se o `winget` não existir no sistema, o módulo avisa e o script segue em frente
— basta instalar o **Instalador de Aplicativo** pela Microsoft Store e rodar a
opção `[5]` depois.

> Esse é o único módulo que depende de rede. Num PC recém-formatado sem driver
> de rede ainda, ele falha e todos os outros rodam normalmente; é só executar a
> opção `[5]` mais tarde.

---

## Programas padrão

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

**Limitação conhecida, sem contorno por script:** desde o Windows 8 a escolha
final do usuário fica em `HKCU\...\FileExts\<ext>\UserChoice`, protegida por um
hash que combina extensão + ProgID + SID + timestamp. O algoritmo não é público
e a chave tem ACL negando escrita — gravar ali diretamente faz o Windows
detectar a adulteração e **resetar** a associação.

Na prática: num PC recém-formatado, onde ainda não existe `UserChoice` para
`.mkv` ou `.7z`, o que o script faz **é** suficiente. Onde o Windows já fincou
um padrão próprio (caso do `.zip`, e do `.rar` no Windows 11 24H2), vai faltar
um clique de confirmação em **Configurações › Aplicativos › Aplicativos
padrão**. O script oferece abrir essa tela no fim do módulo.

---

## Avisos

- **Não há desfazer automático.** Deixe o ponto de restauração ligado na
  primeira execução.
- `DO_DISM_RESETBASE=1` libera mais espaço, mas **impede desinstalar
  atualizações antigas** depois. Por isso vem desligado.
- `DO_BROWSERCACHE=1` **fecha** Chrome, Edge, Brave, Firefox e Opera antes de
  limpar. Vem desligado para não matar navegadores no meio do seu trabalho.
- A remoção do OneDrive apaga arquivos que ainda não tenham sido sincronizados.
- `Windows.old` às vezes resiste ao `rd` mesmo com `takeown` e `icacls`; nesse
  caso use a Limpeza de Disco do Windows (`cleanmgr`) e marque "Instalações
  anteriores do Windows".
- O script **não** faz ativação do Windows e não tem nada a ver com licenciamento.

Testado em Windows 11. Deve funcionar no Windows 10, mas alguns nomes de app do
módulo de debloat são específicos do 11.

---

## Créditos

Este projeto é a unificação de dois repositórios, com a deduplicação das partes
que se sobrepunham (temporários, cache do Windows Update, DISM e lixeira
apareciam nos dois):

| Origem | Autor | Licença | O que veio de lá |
|---|---|---|---|
| [yanpenalva/clean-windows](https://github.com/yanpenalva/clean-windows) | Yan Penalva | GPL-3.0 | `clean.bat` — privacidade, cache dos navegadores, limpeza de disco, otimização |
| [micheg/debloat](https://github.com/micheg/debloat) | Michelangelo Giacomelli | MIT | `stop_telemetry.bat`, `remove_onedrive.bat`, `debloat_soft.bat`, `clean_disk_safe.bat` |

O `micheg/debloat`, por sua vez, se inspira no
[Raphire/Win11Debloat](https://github.com/Raphire/Win11Debloat).

Os módulos de ponto de restauração, instalação via winget e programas padrão
são novos.

## Licença

[GPL-3.0](LICENSE), herdada do `clean-windows`. O código vindo do `debloat` está
sob MIT, compatível com a incorporação em uma obra GPL.

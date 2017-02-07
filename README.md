# Sysplace-Patterns

Dokumentation der Pattern im Projekt SysPlace. Aus den LaTeX-Dateien können per Buildscript PDF-Dateien sowie eine vollstände Website generiert werden.

# Aufbau der Patternbeschreibungen
Alle Patternbeschreibungen sowie Resourcen (Grafiken, Hilfsdateien etc.) befinden sich als `.tex` Dateien im Ordner `patterns/` (beispielsweise `swipe_to_give.tex`). Änderungen an konkreten Pattern werden am jeweiligen Patterndokument vorgenommen, während Änderungen, die alle Pattern betreffen, in den entsprechenden Meta-Dateien vorgenommen werden. Jedes Patterndokument hat folgenden Aufbau (per LaTeX-includes):

```LaTeX
─<pattern>.tex      (konkrete Definition der Platzhalter-Variablen aus template.tex)
  ├──header.tex     (verwendete Packages, globale Variablen, Definition von Bibliographie und Glossar)
  │   ├──lit.bib    (Literaturverzeichnis für alle Pattern)
  │   └──glossary   (Glossareinträge für alle Pattern)
  └──template.tex   (Allgemeine Struktur des Patterndokuments mit Platzhalter-Variablen)
```

Ein Patterndokument kann in einer IDE wie z.B. Texmaker manuell geändert und übersetzt werden, alle Dokumente können auch automatisiert per Buildscript übersetzt werden (s. nächster Punkt).

# Patterndokumente (PDF) erstellen
Um alle Patterndokumente automatisch neu zu generieren, kann das Buildscript `build.ps1` verwendet werden. Dazu wird das Script zunächst mit dem `dot source`-Befehl geladen:

```PowerShell
$ . .\build.ps1
```

Danach wird das build target `build-pdf` ausgeführt:

```PowerShell
$ build-pdf
```

Die erstellen PDF-Dokumente befinden sich anschließend in `output/pdf/`.

# Website erstellen
Um eine Website zu erstellen, wird das build target `build-website` analog zu `build-pdf` aufgerufen:

```PowerShell
$ . .\build.ps1
$ build-web
```

*Zu beachten ist*, dass das build target `build-pdf` vor dem Erstellen der Website ausgeführt werden muss, damit die erstellten Hilfsdateien für die Bibliographie, das Glossar sowie die in der Website verlinkten PDF-Dokumente der Patternbeschreibungen in die Website integriert werden können.

Die Website wird in einem mehrschrittigen Verfahren erstellt:
- Generieren aller Pattern als HTML-Dokumente durch htlatex (Übersetzen einer `.tex`-Datei in eine `.html`-Datei)
- Einfügen eines Menüs in alle Patterndokumente (Find and Replace per Powershell)
- Einfügen eines Downloadlinks in alle Patterndokumente (Find and Replace per Powershell)
- Ausführen eines Jekyll Builds, der die restliche Websitestruktur statisch erstellt und die einzelnen HTML-Patterndokumente einbindet
- Integration aller im build target `build-pdf` erstellten PDF-Dokumente in die Website

# Website deployen
Um die Website zu deployen, wird das build target `deploy-external` verwendet:

```PowerShell
$ . .\build.ps1
$ deploy-external
```

Für Testzwecke ist noch weiteres target `deploy-internal` vorgesehen. Die Server, auf die jeweils deployed werden soll, sind im Buildscript konfigurierbar.

# Aufräumen
Mit dem build target `clean` werden alle durch das Buildscript generierten Artefakte (PDF-Dateien, Websiten, Hilfsdateien etc.) entfernt:

```PowerShell
$ . .\build.ps1
$ clean
```

# TL;DR 
## (Pattern ändern -> Dokumente erstellen -> Website erstellen -> deployen)
Änderungen vornehmen an gewünschtem Pattern im Dokument `patterns/<pattern>.tex` für einzelne Pattern oder in `patterns/template.tex` für alle Patterns, danach:

```PowerShell
$ . .\build.ps1
$ clean; build-pdf; build-web
$ deploy-external
```

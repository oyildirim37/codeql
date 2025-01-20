# CodeQL-Datenbankerstellung für Loop (Swift)

## Zweck und Ablauf

Dieses Dokument beschreibt die Schritte, um das Loop-Projekt (konkret: den **LoopWorkspace**) mithilfe von CodeQL zu bauen und eine **CodeQL-Datenbank** zu erzeugen. Anschließend kann diese Datenbank verwendet werden, um Codeabfragen (Queries) durchzuführen, beispielsweise zur Code-Qualität oder Sicherheitsanalyse in Swift.

---

## 1. Ziel und Voraussetzungen

**Ziel**  
- Erstellen einer CodeQL-Datenbank („myDatabase“) für das Swift-Projekt LoopWorkspace.

**Voraussetzungen**  
- macOS-Umgebung (z. B. macOS 12 oder 13).
- Xcode in einer passenden Version, hier: **Xcode 15.4**.
- iOS-Simulator (in diesem Beispiel iOS 17.5).
- Installierte CodeQL-CLI (z. B. Version 2.20.0).
- LoopWorkspace (Swift-basiert) lokal verfügbar.

---

## 2. Typische Probleme beim Build

1. **SwiftSyntax / AppIntentsFehler**  
   - In Xcode 16.x verursachen AppIntents-Schritte wiederholt Fehlermeldungen wie `libSwiftSyntax.dylib not found` oder `AppIntentsSSUTraining`.
   - Lösung: Eine Xcode-Version wählen, die diese Probleme nicht aufweist (hier Xcode 15.4).

2. **Fehler bei -destination**  
   - Im Terminal: `xcodebuild: error: option 'Destination' requires at least one parameter of the form 'key=value'`.
   - Ursache: Falsche oder unvollständige Syntax.  
   - Lösung: Exakte Angaben in der Form `"platform=iOS Simulator,id=...,OS=..."`.

3. **Kompatibilität von Simulator und Xcode**  
   - Es muss eine passende iOS-Runtime (z. B. 17.5) installiert sein.  
   - Sonst erscheinen Meldungen wie `no devices found` oder `ineligible destinations`.

---

## 3. Installation und Konfiguration

### 3.1 Xcode 15.4 bereitstellen

1. Download: Xcode 15.4 als `.xip` von [developer.apple.com/download/all/](https://developer.apple.com/download/all/).
2. Entpacken und nach `/Applications/` verschieben, z. B. `/Applications/Xcode-15.4.app`.
3. Umschalten auf diese Version:

   ```bash
   sudo xcode-select -s /Applications/Xcode-15.4.app
   xcodebuild -version

4. Erwartete Ausgabe
    ```bash
   Xcode 15.4
   Build version 15F31d

### 3.2 Simulator-Runtime installieren
1. In Xcode (15.4) unter “Settings → Platforms” die gewünschte iOS-Version (z. B. 17.2) installieren.
2. Anschließend ist ein Simulator wie „iPhone 15 (17.2)“ verfügbar.

### 3.3 CodeQL-CLI
1. Herunterladen der CodeQL-CLI-Binaries von von ([https://github.com/github/codeql-cli-binaries/releases./](https://github.com/github/codeql-cli-binaries)).
2. Entpacken, z. B. nach ~/codeql.
3. Prüfung:
    ```bash
   Xcode 15.4
   Build version 15F31d

## 4. Erstellung der CodeQL-Datenbank
### 4.1 Projekt bereinigen

1. Im Vorfeld empfiehlt sich das Löschen von alten DerivedData:
   ```bash
      rm -rf ~/Library/Developer/Xcode/DerivedData/LoopWorkspace-*


### 4.2 Datenbank-Build
1. Im LoopWorkspace-Verzeichnis den CodeQL-Befehl ausführen:
      ```bash
   codeql database create myDatabase \
     --language=swift \
     --command "xcodebuild \
    -workspace LoopWorkspace.xcworkspace \
    -scheme LoopWorkspace \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,id=D523B73E-BB82-4E80-AE38-8984ED513004,OS=17.5' \
    -configuration Debug \
    clean build" \
     --overwrite
2. Dabei die richtige id für den Simulator verwenden, ermittelt über:
   ```bash
      xcodebuild -workspace LoopWorkspace.xcworkspace \
           -scheme LoopWorkspace \
           -showdestinations


3. myDatabase ist das Zielverzeichnis der CodeQL-Datenbank.

4. --overwrite überschreibt eine eventuell vorhandene Datenbank gleichen Namens.
5. Ergebnis: Nach Abschluss erscheint:

    ```bash
      ** BUILD SUCCEEDED **
   Finalizing database at /.../myDatabase
   Successfully created database at /.../myDatabase




## 5. Kurzer Test mit einer Beispiel-Query

**Im Folgenden ein minimaler Test, der alle Force-Unwraps (!) in Swift auflistet:**
1. Eine Datei ForceUnwrap.ql anlegen:
    ```bash
     import Swift

   from ForceUnwrapExpression f
   select f, "Force unwrap here."

2. Anschließend im Terminal die Query gegen die Datenbank laufen lassen:
   ```bash
     codeql query run ForceUnwrap.ql \
     --database=myDatabase \
     --output=forceunwrap.bqrs


3. Die Ergebnisse decodebar machen:
     ```bash
        codeql bqrs decode forceunwrap.bqrs
4. Es werden Positionen der !-Verwendung angezeigt.



## 6. Typische Fehlerquellen
1.   ```bash
        libSwiftSyntax.dylib missing:
Tritt in Xcode 16.x und iOS 16/17 auf. Siehe oben, durch Xcode 15.4 gelöst.

2. Destination muss folgende Form haben:
   ```bash
        platform=iOS Simulator,id=...,OS=...'
3. Simulator nicht installiert: iOS 17.5 in Xcode Settings laden.
4. Zeilenumbruch: In Bash kann ein falscher Backslash zum Fehler Unknown build action '\' führen. Besser in einer Zeile oder sauberer Shell-Quote.
5. Konflikte bei alten DerivedData: Vor Neuversuchen DerivedData des Projektes löschen mit:
    ```bash
        rm -rf ~/Library/Developer/Xcode/DerivedData/LoopWorkspace-*













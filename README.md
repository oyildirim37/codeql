#CodeQL-Datenbankerstellung für Loop (Swift)

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

import swift
import codeql.swift.printast.PrintAst

class PrintAstConfigurationOverride extends PrintAstConfiguration {
  override predicate shouldPrint(Locatable e) {
    // Standardverhalten vom PrintAstConfiguration
    super.shouldPrint(e)
    // und zusätzlich: Pfadabgleich mit dem Dateinamen
    and (
      e.getFile().getRelativePath() = "CGMBLEKit/CGMBLEKit/Glucose.swift"
      or
      exists(Locatable parent |
        this.shouldPrint(parent) and
        parent = getImmediateParent(e)
      )
    )
  }
}

 import swift
 import codeql.swift.dataflow.DataFlow
 import codeql.swift.elements.expr.internal.MemberRefExprImpl
 import codeql.swift.dataflow.TaintTracking


 
 module MyConfig implements DataFlow::ConfigSig {
 
   predicate isSource(DataFlow::Node src) {
     // Fall (1)
     exists(CallExpr call1 |
       call1.getStaticTarget().(Method).hasQualifiedName("Data", "init(contentsOf:options:)") and
       src.asExpr() = call1
     )
    or
    // Fall (2)
    exists(CallExpr call2 |
        call2.getStaticTarget().(Method).hasQualifiedName("AVAudioPlayer", "init(contentsOf:)") and
        src.asExpr() = call2
      )

    or 
    //Fall (3)
    exists(MemberRefExpr mre, VarDecl v, NominalType t |
        mre.hasMember() and
        mre.getMember() = v and
        v.getName() = "data" and
        // Basistyp casten und Name prüfen
      //  mre.getBase().getType() = t and
        //t.getName() = "DataResponse" and
        src.asExpr() = mre
      )
    or
    // Fall (4): MemberRefExpr auf .text einer UITextField-Instanz
    exists(MemberRefExpr mre, VarDecl v, NominalType nt |
    // 1) Prüfen, dass dieses MemberRefExpr überhaupt ein Member hat
    mre.hasMember() and
    
    // 2) Das Member ist eine Variable (VarDecl) und heißt "text"
    mre.getMember() = v and
    v.getName() = "text" and

    // 3) Der Basistyp ist ein UITextField
    mre.getBase().getType() = nt and
    nt.getName() = "UITextField" and

    // 4) bestimmen dieses MemberRefExpr als Quelle
    src.asExpr() = mre
    )
}
 
   predicate isSink(DataFlow::Node snk) {
     // Fall (1) cleartext-transmission
     exists(CallExpr call3 |
        // Prüfe, ob der Aufruf URL(string:) ist
        call3.getStaticTarget().(Method)
          .hasQualifiedName("URL", "init(string:)")
        and
        // Definieren des Argument (Index 0) als Senke
        snk.asExpr() = call3.getArgument(0).getExpr()
      )
      or
    // Fall (2) uncontrolled-format-string
      exists(CallExpr call4 |
        // Prüfe, ob wir es hier mit `String.init(format:_:)` zu tun haben
        call4.getStaticTarget().(Method).hasQualifiedName("String", "init(format:_:)") and
        // Das erste Argument ist das Format-String
        snk.asExpr() = call4.getArgument(0).getExpr()
      )
      or
      // Fall (3) cleartext-logging
      exists(CallExpr call5 |
        // Prüfe, ob das statische Target dem "logger.debug" entspricht 
        call5.getStaticTarget().(Method).hasQualifiedName("Logger", "debug(_:metadata:)")
        and
        // Das erste Argument (String) betrachten wir als Senke
        snk.asExpr() = call5.getArgument(0).getExpr()
      )
      or
    // Fall (4) os_log cleartext-storage-preference
    exists(CallExpr call6 |
        // Prüfe, ob das statische Ziel “UserDefaults.set(_:forKey:)” ist
        call6.getStaticTarget().(Method).hasQualifiedName("UserDefaults", "set(_:forKey:)") and
        // Das erste Argument, also c.getArgument(0), ist die eigentliche Senke
        snk.asExpr() = call6.getArgument(0).getExpr()
      )
      or
    // Fall (5) PredicateInjection
      exists(CallExpr call7 |
       (call7.getStaticTarget().(Method).hasQualifiedName("NSPredicate", "init(format:argumentArray:)")
        or
        call7.getStaticTarget().(Method).hasQualifiedName("NSPredicate", "init(format:_:)")
        // oder eben wo immer NSPredicate(format:…) verwendet wird
        )
        and
        snk.asExpr() = call7.getArgument(0).getExpr()
      )
      or
      //Fall (6) Path Injection
        // 6.1) Lesen einer Datei
      exists(CallExpr call8 |
        call8.getStaticTarget().(Method).hasQualifiedName("Data", "init(contentsOf:)") and
        snk.asExpr() = call8.getArgument(0).getExpr()
      )
      or
        // 6.2) Schreiben in eine Datei
      exists(CallExpr call9 |
        call9.getStaticTarget().(Method).hasQualifiedName("Data", "write(to:options:)") and
        snk.asExpr() = call9.getArgument(0).getExpr()
      )
      or
        // 6.3) Entfernen einer Datei
      exists(CallExpr call10 |
        call10.getStaticTarget().(Method).hasQualifiedName("FileManager", "removeItem(at:)") and
        snk.asExpr() = call10.getArgument(0).getExpr()
      )
      or
    // Fall (7) cleartext-storage-database
        // 7.1 Wenn auf NSManagedObjectContext.save() zugegriffen wird etc.
      exists(CallExpr call11 |
        call11.getStaticTarget().(Method).hasQualifiedName("NSManagedObjectContext", "save()") and
        // … und wir den zu speichernden Ausdruck als potenzielle Senke betrachten
        snk.asExpr() = call11
      )
      or
        // 7.2 Wenn auf NSManagedObjectContext.delete() zugegriffen wird etc.
      exists(CallExpr call12 |
        call12.getStaticTarget().(Method).hasQualifiedName("NSManagedObjectContext", "delete(_:)")
        and snk.asExpr() = call12.getArgument(0).getExpr()
      )
     
   }
 }
 
 module MyFlow = DataFlow::Global<MyConfig>;

 // Hier Pfade abfragen
 from DataFlow::Node source, DataFlow::Node sink
 where MyFlow::flow(source, sink)
 select source, "Dataflow to $@.", sink, sink.toString()
 
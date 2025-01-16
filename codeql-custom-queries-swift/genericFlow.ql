import swift
import codeql.swift.dataflow.DataFlow
import codeql.swift.elements.expr.internal.MemberRefExprImpl
import codeql.swift.dataflow.TaintTracking



module MyConfig implements DataFlow::ConfigSig {
    predicate isSource(DataFlow::Node src) {
      // ALLE Funktions-Parameter als Quellen
      // (Oder: alle Member-Variablen, etc.)
      exists(Function fp |
        src.asParameter() = fp.getParam(0)
      )
    }
  
    predicate isSink(DataFlow::Node snk) {
      // ALLES, was in eine Methode reingeht, als Senke
      exists(Function c |
        snk.asParameter() = c.getParam(0)
      )
    }
  }
  

module MyFlow = DataFlow::Global<MyConfig>;

// Hier Pfade abfragen
from DataFlow::Node source, DataFlow::Node sink
where MyFlow::flow(source, sink)
select source, "Dataflow to $@.", sink, sink.toString()

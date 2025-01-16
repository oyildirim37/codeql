    import swift
    import codeql.swift.dataflow.FlowSources
    
    string sourceClass(FlowSource s) {
      s instanceof LocalFlowSource and result = "Local flow source"
      or
      s instanceof RemoteFlowSource and result = "Remote flow source"
    }
    
    from FlowSource s
    select s, sourceClass(s) + ": " + s.getSourceType(),
    s.getLocation().getFile(),
    s.getLocation()
      .getStartLine().toString() + ":" + s.getLocation().getStartColumn().toString() + " - " + s.getLocation().getEndLine().toString() + ":" + s.getLocation().getEndColumn().toString(),
      s.asExpr().getEnclosingCallable().toString()
  
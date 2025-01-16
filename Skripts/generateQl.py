#!/usr/bin/env python3

import re
import sys

# Pfad zur CSV, z. B. "Entitaeten.csv"
INPUT_CSV = "./results/filteredEntitaeten.csv"

# Regex-Heuristik:
# - "did" + (Receive|Discover|Error|Fail|Connect etc.) => QUELLE
# - "log|send|write|store" => SENKE
source_pattern = re.compile(r"did(Error|Fail|Receive|Discover|Connect|Disconnect)|viewDidLoad")
sink_pattern   = re.compile(r"log|send|store|write|upload|notify|completeDelete|completeCreate|completeUpdate")

# Ausgabe: "MyGlobalFlow.ql"
OUTPUT_QL = "./codeql-custom-queries-swift/MyGlobalFlow.ql"


def main():
    # Listen anlegen
    sources = []
    sinks   = []

    try:
        with open(INPUT_CSV, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("//"):
                    continue

                # CSV aufgebaut wie:  methodName,FullyQualifiedName in SomeFile.swift
                # Bsp:   scanForPeripheral(),G7BluetoothManager.scanForPeripheral() in G7SensorKit/...
                parts = line.split(",", 1)  # nur in zwei Teile splitten
                if len(parts) < 2:
                    continue
                
                method_sig = parts[0]       # z. B. "scanForPeripheral()"
                full_desc  = parts[1]       # z. B. "G7BluetoothManager.scanForPeripheral() in G7SensorKit..."

                # Quell-Matching
                if source_pattern.search(method_sig):
                    sources.append(method_sig)

                # Senken-Matching
                if sink_pattern.search(method_sig):
                    sinks.append(method_sig)
        
        # QL-Datei erzeugen
        generate_ql_file(sources, sinks, OUTPUT_QL)
        print(f"[OK] Generierte QL-Datei: {OUTPUT_QL}")
        print(f"[Info] Erkannte {len(sources)} sources und {len(sinks)} sinks.")
    
    except FileNotFoundError:
        print(f"[Fehler] CSV-Datei {INPUT_CSV} nicht gefunden.")
        sys.exit(1)


def generate_ql_file(source_list, sink_list, output_path):
    """
    Erzeugt eine QL-Datei, die ein DataFlow::ConfigSig implementiert,
    und die in isSource / isSink die ermittelten Methoden enthält.
    """
    # Hier ein einfacher OR-Konstrukt (m.getName() = 'X' or m.getName() = 'Y' ...)
    def make_predicate_clause(method_names):
        if not method_names:
            return "false"
        # generiere z. B.  (m.getName() = "xyz" or m.getName() = "abc" ...)
        conditions = []
        for m in sorted(set(method_names)):
            # remove parentheses from method name if present (like "scanForPeripheral()" => "scanForPeripheral")
            # (optional, je nachdem wie du es in CodeQL abfragen willst)
            cleaned = m
            if "(" in m:
                cleaned = m.split("(")[0]
            
            conditions.append(f'm.getName() = "{cleaned}"')
        return " or\n      ".join(conditions)

    source_pred = make_predicate_clause(source_list)
    sink_pred   = make_predicate_clause(sink_list)

    with open(output_path, "w", encoding="utf-8") as ql:
        ql.write(f"""\
import swift
import codeql.swift.dataflow.DataFlow

// Unser DataFlow-Config:
module MyConfig implements DataFlow::ConfigSig {{

  // =======================
  //  1) Quellen
  // =======================
  predicate isSource(DataFlow::Node source) {{
    exists(Method m |
      ({source_pred})
      and
      // hier mappe Node -> method; 
      // VORSICHT: je nachdem, wie du Source = "Parameter" oder "Returnwert" definierst,
      // kann es sein, dass man parameterNode(...) oder exprNode(...) nutzen muss.
      source.asExpr() = m.getAStmt()
    )
  }}

  // =======================
  //  2) Senken
  // =======================
  predicate isSink(DataFlow::Node sink) {{
    exists(Method m |
      ({sink_pred})
      and
      sink.asExpr() = m.getAStmt()
    )
  }}

  // optional
  predicate isAdditionalFlowStep(DataFlow::Node from, DataFlow::Node to) {{ result = false }}
  predicate isBarrier(DataFlow::Node node) {{ result = false }}

}}

// Globale DataFlow-Analyse
module MyGlobalFlow = DataFlow::Global<MyConfig>;

// Pfad-Query, um dataflow zu sammeln
// Erzeugt Pfade von Source -> Sink
from DataFlow::Path p
where MyGlobalFlow::flow(p.getSource(), p.getSink())
select p, "Dataflow: " + p.toString()
""")
    # done


if __name__ == "__main__":
    main()

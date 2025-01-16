#!/usr/bin/env python3

import csv
import re

# Pfade zu den CSV-Dateien (ggf. anpassen)
INPUT_CSV = "./Entitaeten.csv"
OUTPUT_CSV = "filteredEntitaeten.csv"

# Regex, um 'deinit()' zu erkennen (Case-Sensitive)
pattern_deinit = re.compile(r"\.deinit\(\)")

def remove_deinit_methods(input_path, output_path):
    with open(input_path, mode="r", encoding="utf-8") as infile, \
         open(output_path, mode="w", encoding="utf-8", newline="") as outfile:
        
        reader = csv.reader(infile)
        writer = csv.writer(outfile)

        for row in reader:
            # row ist eine Liste der CSV-Spalten in einer Zeile
            # Überprüfen, ob irgendein Spalteneintrag 'deinit()' enthält
            row_string = ",".join(row)
            if pattern_deinit.search(row_string):
                # Wenn 'deinit()' auftaucht, überspringen
                continue
            else:
                # Andernfalls in die Ausgabedatei schreiben
                writer.writerow(row)

if __name__ == "__main__":
    remove_deinit_methods(INPUT_CSV, OUTPUT_CSV)
    print(f"Gefilterte CSV wurde in '{OUTPUT_CSV}' gespeichert.")

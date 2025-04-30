#!/bin/bash

# Calcola MD5, tipo file, dimensione e percorso completo
function compute() {
    find "$1" -type f | while read -r x; do
        # Stampa MD5, tipo file, dimensione e percorso completo
        echo "$(md5sum "$x") ${x##*.} $(du -h "$x" | cut -f1) $x" | gawk '{print $1 "\t" $3 "\t" $4 "\t" $5 }' >> "$outpath.$2"
    done
}

# Inizializzazione
function initialize() {
    inpath=$(readlink -f "$1")
    outpath=$(readlink -f "$2")

    echo "📁 Directory di input: $inpath"
    echo "📄 File di output base: $outpath"

    for dir in "$inpath"/*/; do
        dir=${dir%/}
        name=${dir##*/}

        # Tool detection
        case "$name" in
            recup_dir.*)
                tool="photorec"
                ;;
            scalpel*|scalpel-output*)
                tool="scalpel"
                ;;
            output|foremost*|*.foremost)
                tool="foremost"
                ;;
            *)
                tool="$name"  # fallback, crea nome file generico
                ;;
        esac

        echo "🛠️ Elaborazione $tool -> $dir"
        compute "$dir" "$tool"
        mv "$outpath.$tool" "$tool.txt"
    done

    echo "🔗 Unione risultati..."
    cat *.txt > "$outpath"
    sort -u -k 1,1 "$outpath" -o "$outpath"
    sort -k 2 "$outpath" -o "$outpath"

    echo "📦 Unione in result.txt..."
    cat "$outpath" >> result.txt
    sort -u -k 1,1 result.txt -o result.txt
    sort -k 2 result.txt -o result.txt
}

# Avvio script
if (( $# != 2 )); then
    echo "❌ Nessun argomento fornito."
    echo "👉 Uso: ./script.sh <cartella_con_output> <nome_file_output>"
    exit 1
else
    initialize "$1" "$2"
fi

# Creazione CSV
if [[ -f foremost.txt && -f scalpel.txt && -f photorec.txt ]]; then
    echo -e 'MD5\tFOREMOST\tSCALPEL\tPHOTOREC\tTYPE\tDIMENSION\tPATH' > table.csv

    gawk 'FNR==NR{a[$1]="YES";next}{print $1, a[$1]?a[$1]:"NO", "\t" $2 "\t" $3 "\t" $4 "\t" $5}' foremost.txt result.txt > tmp.txt
    gawk 'FNR==NR{a[$1]="YES";next}{print $1 "\t" $2 "\t" ,a[$1]?a[$1]:"NO", "\t"  $3 "\t"  $4 "\t"  $5}' scalpel.txt tmp.txt > tmp2.txt
    gawk 'FNR==NR{a[$1]="YES";next}{print $1 "\t" $2 "\t" $3 "\t" ,a[$1]?a[$1]:"NO", "\t"  $4 "\t"  $5 "\t" $6}' photorec.txt tmp2.txt >> table.csv

    rm tmp.txt tmp2.txt
    echo "✅ Tabella 'table.csv' generata con successo."
    # Creazione HTML ordinabile con Tablesort.js
if [[ -f table.csv ]]; then
    echo "🧱 Generazione HTML ordinabile da CSV..."

    {
        echo "<!DOCTYPE html>"
        echo "<html lang='en'>"
        echo "<head><meta charset='UTF-8'><title>File Recuperati</title>"
        echo "<script src='https://unpkg.com/tablesort@5.3.0/dist/tablesort.min.js'></script>"
        echo "<style>
            body { font-family: sans-serif; padding: 20px; }
            table { border-collapse: collapse; width: 100%; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background-color: #f2f2f2; cursor: pointer; }
            tr:nth-child(even) { background-color: #f9f9f9; }
        </style>"
        echo "</head><body>"
        echo "<h2>File Recuperati</h2>"
        echo "<table id='myTable'><thead><tr>"

        # Header
        IFS=$'\t' read -ra HEADERS <<< "$(head -1 table.csv)"
        for header in "${HEADERS[@]}"; do
            echo "<th>${header}</th>"
        done

        echo "</tr></thead><tbody>"

        # Data rows
        tail -n +2 table.csv | while IFS=$'\t' read -r line; do
            echo "<tr>"
            IFS=$'\t' read -ra FIELDS <<< "$line"
            for field in "${FIELDS[@]}"; do
                echo "<td>${field}</td>"
            done
            echo "</tr>"
        done

        echo "</tbody></table>"
        echo "<script>new Tablesort(document.getElementById('myTable'));</script>"
        echo "</body></html>"
    } > table.html

    echo "✅ HTML ordinabile generato con successo: table.html"
fi

    
else
    echo "⚠️ Mancano uno o più file tra: foremost.txt, scalpel.txt, photorec.txt"
    echo "❌ Impossibile generare table.csv"
fi

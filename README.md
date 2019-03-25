Script created for Digital forensics course 's exercises.

Generate a table for check which tool have restored the file

# Usage
. start.sh directory file.txt

directory = directory generate by foremost(output)/scalpel(scalpel-output)/photorec(recup_dir.1)
file = file where save the information generate from the single tool foremost.txt/scalpel.txt/photorec.txt

output = result.txt and table.txt


# Example 
table.csv

|MD5|Foremost|Scalpel|Photorec|Type|Dimension|
|---|--------|-------|--------|----|---------|
5c487ec5fad70bae67130bb5e11164be |       NO|      NO|       YES|    docx|    12K|
63750f2a7e54d39ae45b94252e29044c |       NO|      NO|       YES|    docx|    12K|
ef3aa429f4c03c712b65711f3834b03e |       NO|     YES|        NO|     fws|   3,9M|    
5750594f5966839665346b17b556a134 |       NO|     YES|       YES|     gif|   4,0K|
8ffbaea260c0a8b616106baba2e402f9 |      YES|      NO|        NO|     gif|    44M|
...                              |      ...|     ...|       ...|     ...|    ...|
d964e0076f9ecf21da8bc2dab585b531 |      YES|      NO|       NO |     gif|    44M|   

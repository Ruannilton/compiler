nim compile src/main.nim
.\src\main.exe input/main.c -o:out/main.dot -d:out/main.txt
dot -Tpng ./out/main.dot -o ./out/graph.png
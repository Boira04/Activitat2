# Pràctica 2: Exercici 3 - Traductor DIMACS a Notacio Clausal

Aquest projecte consisteix en un traductor automàtic que converteix fitxers en format **CNF DIMACS** (habitualment utilitzats en soluciors SAT) a una **notació clausal** llegible per humans.

La implementació s'ha realitzat utilitzant les eines d'anàlisi lèxica i sintàctica **Flex** (Lex) i **Bison** (Yacc) en llenguatge C.

## Descripció del Funcionament

El traductor llegeix un fitxer d'entrada que segueix l'especificació DIMACS:
1.  Ignora els comentaris (línies que comencen amb el caràcter `c`).
2.  Processa la capçalera `p cnf <num_variables> <num_clausules>`.
3.  Llegeix les clàusules formades per enters (on `0` indica el final de la clàusula).
4.  Genera una sortida amb el format: `(p1 v !p2) ^ (p3 v p4) ...`

## Requisits

Cal tenir instal·lades les següents eines en un entorn Linux/Unix:
*   **Flex** (Generador d'analitzadors lèxics)
*   **Bison** (Generador d'analitzadors sintàctics)
*   **GCC** (Compilador de C)
*   **Make** (Gestor de compilació)

## Instruccions d'Execució

### 1. Compilació
Per generar l'executable, simplement executa la comanda `make` a la carpeta arrel del projecte:

Per compilar el projecte:
```bash
make
```

Per executar el projecte amb l'exemple:
```bash
./traductor < entrada.cnf
```
# Exercici 1 - Calculadora amb Flex i Bison

Calculadora d'expressions aritmètiques i de bits implementada amb **Flex** (anàlisi lèxica) i **Bison** (anàlisi sintàctica).

## Fitxers

| Fitxer | Descripció |
|--------|------------|
| `calc.l` | Especificació del lexer (Flex) |
| `calc.y` | Gramàtica i semàntica (Bison) |
| `Makefile` | Regles de compilació |
| `exemple.txt` | Exemples d'entrada |



## Operadors suportats

| Operador | Descripció |
|----------|------------|
| `+` `-` `*` `/` | Aritmètica bàsica (reals) |
| `div` `mod` | Divisió entera i mòdul |
| `<<` `>>` | Desplaçament de bits |
| `&` `\|` `^` `~` | AND, OR, XOR, NOT bit a bit |
| `(real)` | Conversió enter → real |
| `=` | Assignació a registre |


## Exemple

```
a = 2;
b = -3;
c = a + b;
A = (real)a + 2.1;
5 & 3;
10 div 3;
```

## Compilació i Execució

```bash
make
./calc < exemple.txt
```
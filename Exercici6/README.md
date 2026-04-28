# Exercici 6 - Càlcul de FIRST per a Gramàtiques

Eina que llegeix una gramàtica independent del context i calcula el conjunt **FIRST** de cada no terminal, implementada amb **Flex** i **Bison**.


## Compilació i Execució

```bash
make
```
```bash
./primers test.gr

./primers < test.gr
```

## Format d'entrada

Cada regla té la forma:

```
NomTerminal : produccio1 | produccio2 | ... ;
```

- **No terminals:** lletres majúscules (`A`–`Z`)
- **Terminals:** lletres minúscules (`a`–`z`)
- Les alternatives se separen amb `|` i la regla acaba amb `;`
- Es suporten comentaris de línia amb `//`

### Exemple (`test.gr`)

```
S : aAc | fA | Bdef ;
B : Ab | Ad | k ;
A : ilm | ml ;
```

## Sortida

Per cada no terminal, els terminals que pertanyen al seu conjunt FIRST:

```
S= a f i k m
B= i k m
A= i m
```

## Neteja

```bash
make clean
```

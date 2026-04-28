# Exercici 5 – Llenguatge de descripció d'AFD

## Descripció

Analitzador lèxic i sintàctic per a la descripció d'un Autòmat Finit Determinista (AFD).
Implementat amb **flex** (analitzador lèxic) i **bison** (analitzador sintàctic) generant codi C.

## Compilació i execució

```bash
make
./afd fitxer.afd
```

## Format del fitxer d'entrada

El fitxer d'entrada descriu un AFD amb les seccions següents, **en ordre**:

```
// comentari de línia
alfabet { simbol1, simbol2, ... }
estats { estat1, estat2, ... }
inicial { estat_inicial }
finals { final1, final2, ... }
transicions {
    estat, simbol -> estat_desti;
    ...
}
```

### Característiques lèxiques

| Element         | Format                                 |
|-----------------|----------------------------------------|
| Comentaris      | `//` fins a final de línia             |
| Identificadors  | Lletra seguida de lletres, dígits o `_`|
| Paraules clau   | `alfabet`, `estats`, `inicial`, `finals`, `transicions` |
| Símbols         | `{` `}` `,` `;` `->`                  |
| Ignorats        | espais, tabuladors, nova línia         |

### Característiques sintàctiques

Gramàtica (en notació BNF):

```
afd         → sec_alfabet sec_estats sec_inicial sec_finals sec_transicions
sec_alfabet → 'alfabet' '{' llista_simbols '}'
sec_estats  → 'estats' '{' llista_ids '}'
sec_inicial → 'inicial' '{' ID '}'
sec_finals  → 'finals' '{' llista_ids '}'
sec_transicions → 'transicions' '{' llista_trans '}'
llista_simbols  → ID | llista_simbols ',' ID
llista_ids      → ID | llista_ids ',' ID
llista_trans    → ε | llista_trans transicio
transicio       → ID ',' ID '->' ID ';'
```

### Tractament d'errors

- **Errors lèxics**: detectats al lexer, reportats per stderr amb número de línia.
- **Errors sintàctics**: mode pànic, recuperació a nivell de `transicio` (sincronització amb `;`).
- **Errors semàntics**: estats o símbols no definits, transicions duplicades, estat inicial o finals invàlids.

## Validació de l'AFD

L'eina comprova les 4 condicions de correcció:

1. **Estat inicial únic**: s'especifica exactament un estat inicial, i ha d'existir a la llista d'estats.
2. **Assolibilitat**: tots els estats s'assoleixen des de l'estat inicial (BFS sobre la taula de transicions).
3. **Co-assolibilitat**: des de tots els estats es pot arribar a algun estat final (punt fix enrere).
4. **Estat final**: hi ha almenys un estat final definit.

## Sortida

- **AFD correcte**: imprimeix `AFD Correcte!` i la taula de transicions.
  - `->` marca l'estat inicial
  - `*` marca els estats finals
  - `-` indica transició no definida

- **AFD incorrecte**: imprimeix el/s error/s i `ERROR: AFD incorrecte.`

## Fitxers de test

| Fitxer                  | Resultat esperat |
|-------------------------|------------------|
| `test.afd`              | AFD Correcte     |
| `test_incorrecte1.afd`  | Error: estat no assolible |
| `test_incorrecte2.afd`  | Error: estat trampa (no pot arribar a final) |

## Limitacions

- Màxim 100 estats (`MAX_STATES`)
- Màxim 50 símbols en l'alfabet (`MAX_ALPHA`)
- Noms d'estats i símbols de màxim 63 caràcters
- Les seccions han d'aparèixer en l'ordre definit

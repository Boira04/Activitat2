# Exercici 5 – Llenguatge de descripció d'AFD

## Descripció

Analitzador lèxic i sintàctic per a la descripció d'un Autòmat Finit Determinista (AFD).
Implementat amb **flex** (analitzador lèxic) i **bison** (analitzador sintàctic) generant codi C.


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

## Sortida

- **AFD correcte**: imprimeix `AFD Correcte!` i la taula de transicions.
  - `->` marca l'estat inicial
  - `*` marca els estats finals
  - `-` indica transició no definida

- **AFD incorrecte**: imprimeix el/s error/s i `ERROR: AFD incorrecte.`


## Compilació i execució

```bash
make
./afd test.afd
```
```bash
make
./afd test_incorrecte1.afd
```
```bash
make
./afd test_incorrecte2.afd
```


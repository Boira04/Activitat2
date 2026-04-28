# Exercici 2 - Validador de Fórmules de Lògica de Primer Ordre

Analitzador sintàctic de fórmules CP1 (Càlcul de Predicats de Primer Ordre) implementat amb **Flex** i **Bison**.


## Sintaxi suportada

**Quantificadors:** `forall`, `exists`

**Connectors lògics** (de menor a major prioritat):

| Operador | Símbols |
|----------|---------|
| Bicondicional | `<->` |
| Implicació | `->` |
| Disjunció | `or`, `v` |
| Conjunció | `and`, `^` |
| Negació | `not`, `!` |

**Símbols:**
- Variables: `x0`, `x1`, `x2`, ...
- Predicats: identificadors que comencen per majúscula (`P1`, `Igual`, ...)
- Funcions/constants: identificadors que comencen per minúscula (`f1`, `a2`, ...)

## Exemple

```
forall x1 forall x2 (P1(x1, x2) -> P2(x2));
exists x1 (P(x1) and Q(f(x1)));
```

Cada fórmula acaba amb `;`. La sortida indica si és correcta o incorrecta i en quina línia.

## Compilació i Execució

```bash
make
./cp1 < test.txt
```

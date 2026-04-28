# Pràctica 2: Exercici 4 - Construcció de Thompson

Aquest programa implementa l'algorisme de **Ken Thompson** per convertir expressions regulars en un **Autòmat Finit No Determinista amb λ-transicions (AFN-λ)**.

## Característiques del Llenguatge

*   **Alfabet:** Suporta els caràcters `{a, b, c, d}`.
*   **Paraula buida:** Es representa amb el token `BUIDA` o `buida` (λ).
*   **Operadors suportats:**
    *   `|` : Alternativa (OR)
    *   `.` : Concatenació
    *   `*` : Tancament de Kleene (zero o més)
    *   `+` : Tancament positiu (un o més)
    *   `?` : Opcionalitat (zero o un)
    *   `()` : Agrupament per parèntesis
*   **Final d'expressió:** Cada expressió ha d'acabar en punt i coma `;`.

## Compilació i Execució

Per compilar el projecte:
```bash
make clean
make
```

Per executar el projecte amb l'exemple:
```bash
./thompson < test.txt
```
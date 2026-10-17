# Guía de estudio – Racket y la práctica de pedidos

Esta guía cubre todo lo necesario para entender `practica_solucion.rkt` y preparar el examen. Léela en orden.

---

## 1. Conceptos clave

### 1.1 Todo es una expresión en notación prefija
En Racket el operador va **primero**, dentro de paréntesis:

```racket
(+ 2 3)          ; 5      (no 2 + 3)
(* (+ 1 2) 4)    ; 12     primero se evalúa lo de adentro
```
Cada par de paréntesis es una **llamada**: `(función arg1 arg2 ...)`.

### 1.2 Valores básicos
| Tipo | Ejemplos |
|---|---|
| Números | `5`, `-3`, `2.5`, `5/100` (fracción exacta) |
| Textos (strings) | `"Medellin"`, `""` (vacío) |
| Booleanos | `#t` (verdadero), `#f` (falso) |
| Listas | `'(1 2 3)`, `(list "a" "b")`, `'()` (vacía) |

> **Ojo:** en Racket **todo lo que no sea `#f` cuenta como verdadero**. Por eso `member` puede devolver una lista y usarse como condición.

### 1.3 Inmutabilidad
En programación funcional **no se modifican datos**: se crean datos nuevos. `filter`, `map`, `cons`, `reverse` nunca cambian la lista original; devuelven otra. El enunciado lo exige: *"toda la información inicial permanece sin modificaciones"*.

### 1.4 Listas: la estructura central
Una lista es una cadena de "cajas": cada una tiene un primer elemento (`car`/`first`) y el resto (`cdr`), que a su vez es una lista. La última caja apunta a `'()`.

```
(list 1 2 3)  =  (cons 1 (cons 2 (cons 3 '())))
car  -> 1
cdr  -> '(2 3)
```

### 1.5 Recursión
Como no hay ciclos con variables que cambian, se repite trabajo llamando a la misma función con un problema **más pequeño**. Toda función recursiva tiene:

1. **Caso base**: la situación más simple, donde se responde sin volver a llamar (normalmente la lista vacía `'()`).
2. **Caso recursivo**: se hace algo con el primer elemento y se llama a la función con el resto (`cdr`).

```racket
(define (contar lista)
  (if (null? lista)
      0                              ; caso base
      (+ 1 (contar (cdr lista)))))   ; caso recursivo
```
Traza de `(contar '(a b c))`:
```
(contar '(a b c)) = 1 + (contar '(b c))
                  = 1 + 1 + (contar '(c))
                  = 1 + 1 + 1 + (contar '())
                  = 1 + 1 + 1 + 0 = 3
```

### 1.6 Acumuladores
Una variante: llevar el resultado parcial en un parámetro extra. Se usa en `eliminar-duplicados-aux` (el parámetro `vistos`). Como `cons` agrega al **inicio**, al final se hace `reverse` para recuperar el orden.

### 1.7 Funciones de orden superior y lambda
Una función de **orden superior** recibe o devuelve funciones. `map`, `filter`, `for-each`, `apply` y nuestra `agrupar-por` lo son. `lambda` crea funciones sin nombre en el lugar donde se necesitan:

```racket
(filter (lambda (x) (> x 2)) '(1 2 3 4))   ; '(3 4)
```

### 1.8 Condicionales
- `if` → dos caminos: `(if condición si-verdadero si-falso)`.
- `cond` → varios caminos; se detiene en la **primera** condición verdadera; `else` atrapa el resto.
- `and` / `or` → evalúan en **cortocircuito**: `and` se detiene en el primer `#f`, `or` en el primer verdadero. Por eso `(and (number? x) (> x 0))` es seguro: si `x` no es número, nunca se ejecuta `(> x 0)`.

### 1.9 Variables locales con `let*`
```racket
(let* ([a 2]
       [b (+ a 3)])   ; b puede usar a
  (* a b))            ; 10
```
`let*` crea variables **en secuencia**: cada una puede usar las anteriores. También fuerza el **orden** de evaluación, lo que importa al leer del teclado.

---

## 2. Glosario de funciones permitidas

### Definición y listas
| Función | Qué hace | Ejemplo |
|---|---|---|
| `define` | Crea una variable o función | `(define edad 20)`, `(define (doble x) (* 2 x))` |
| `list` | Construye una lista | `(list 1 2 3)` → `'(1 2 3)` |
| `first` / `car` | Primer elemento | `(first '(10 20))` → `10` |
| `second` | Segundo elemento | `(second '(10 20 30))` → `20` |
| `third` | Tercer elemento | `(third '(10 20 30))` → `30` |
| `cdr` | La lista sin el primero | `(cdr '(1 2 3))` → `'(2 3)` |
| `cons` | Agrega al inicio | `(cons 1 '(2 3))` → `'(1 2 3)` |
| `list-ref` | Elemento en una posición (desde 0) | `(list-ref '(10 20 30) 1)` → `20` |
| `length` | Cantidad de elementos | `(length '(a b c))` → `3` |
| `reverse` | Invierte | `(reverse '(1 2 3))` → `'(3 2 1)` |
| `append` | Une listas | `(append '(1 2) '(3))` → `'(1 2 3)` |
| `null?` | ¿Lista vacía? | `(null? '())` → `#t` |
| `member` | Busca; devuelve la sublista desde el elemento o `#f` | `(member 2 '(1 2 3))` → `'(2 3)` |
| `assoc` | Busca un par por su clave | `(assoc 'b '((a 1) (b 2)))` → `'(b 2)` |

### Orden superior
| Función | Qué hace | Ejemplo |
|---|---|---|
| `map` | Aplica una función a cada elemento → lista nueva | `(map add1 '(1 2))` → `'(2 3)` |
| `filter` | Conserva los que cumplen la condición | `(filter even? '(1 2 3 4))` → `'(2 4)` |
| `apply` | Usa una lista como argumentos | `(apply + '(1 2 3))` → `6` |
| `for-each` | Como `map` pero solo para efectos (imprimir); no construye lista | `(for-each displayln '(a b))` |
| `lambda` | Función anónima | `((lambda (x) (+ x 1)) 5)` → `6` |

### Comparaciones y lógica
| Función | Qué hace | Ejemplo |
|---|---|---|
| `equal?` | Igualdad estructural de cualquier cosa | `(equal? '(1 2) '(1 2))` → `#t` |
| `string=?` | Igualdad de textos (error si no son textos) | `(string=? "a" "a")` → `#t` |
| `= < > <= >=` | Comparan números (autorizados) | `(>= 5 3)` → `#t` |
| `not` | Negación | `(not #t)` → `#f` |
| `and` / `or` | Conjunción / disyunción | `(and #t #f)` → `#f` |
| `number?` | ¿Es número? | `(number? 42)` → `#t` |
| `zero?` `even?` `odd?` | ¿Cero? ¿par? ¿impar? | `(zero? 0)` → `#t` |

### Aritmética
| Función | Ejemplo |
|---|---|
| `+ - * /` | `(/ 12 3)` → `4`; ojo: `(/ 1 3)` → `1/3` (fracción exacta) |
| `modulo` | `(modulo 10 3)` → `1` |
| `expt` | `(expt 2 3)` → `8` |
| `sqrt` | `(sqrt 9)` → `3` |
| `abs` | `(abs -5)` → `5` |
| `max` / `min` | `(max 4 10 7)` → `10` |
| `round` | `(round 3.6)` → `4` (con .5 redondea al par) |
| `exact->inexact` | `(exact->inexact 1/4)` → `0.25` |

### Textos y entrada/salida
| Función | Qué hace | Ejemplo |
|---|---|---|
| `string-append` | Concatena textos | `(string-append "Hola, " "Mundo")` |
| `string->number` | Texto a número (`#f` si no se puede) | `(string->number "123")` → `123` |
| `display` | Imprime sin salto de línea | `(display "Hola")` |
| `displayln` | Imprime con salto de línea | `(displayln "Hola")` |
| `printf` | Imprime con formato; `~a` se reemplaza por el valor | `(printf "Total: ~a\n" 5)` |
| `read-line` | Lee una línea del teclado (texto) | `(define n (read-line))` |
| `error` | Lanza un error con mensaje | `(error "Algo falló")` |

### Hash (diccionarios)
| Función | Ejemplo |
|---|---|
| `make-hash` | `(make-hash '((a . 1) (b . 2)))` |
| `hash-ref` | `(hash-ref h 'a)` → `1` |

### Ciclos, condicionales y estructuras (general.png)
| Forma | Qué hace | Ejemplo |
|---|---|---|
| `for-each` | Recorre una lista con efectos | `(for-each displayln '(a b c))` |
| `for` | Repite sobre una secuencia | `(for ([i (in-range 3)]) (displayln i))` |
| `while` (let loop) | Repetir mientras una condición | `(let loop ([x 0]) (when (< x 3) (displayln x) (loop (add1 x))))` |
| `if` | Dos caminos | `(if (> 3 2) 'mayor 'menor)` |
| `cond` | Varios caminos | `(cond [(> 5 10) 'g] [else 'otro])` |
| `case` | Compara un valor con casos | `(case 2 [(1) 'uno] [(2) 'dos] [else 'otro])` |
| `let*` | Variables locales secuenciales | `(let* ([x 2] [y (+ x 3)]) y)` |
| `begin` | Ejecuta varias expresiones; devuelve la última | `(begin (displayln 1) (displayln 2))` |
| `match` | Compara contra patrones | `(match '(1 2) [(list a b) (+ a b)])` → `3` |

---

## 3. Anatomía de un programa en Racket

```racket
#lang racket                         ; 1. Lenguaje (siempre la primera línea)

(define IVA 19/100)                  ; 2. Constantes

(define (precio-con-iva p)           ; 3. Funciones pequeñas, una tarea cada una
  (+ p (* p IVA)))

(define (sumar-lista lista)          ; 4. Funciones recursivas sobre listas
  (if (null? lista)                  ;    caso base
      0
      (+ (car lista)                 ;    trabajo con el primero
         (sumar-lista (cdr lista))))) ;   recursión con el resto

(displayln (sumar-lista '(1 2 3)))   ; 5. Programa principal / llamadas
```

**Plantilla mental para recorrer una lista:**
```racket
(define (procesar lista)
  (cond
    [(null? lista) <respuesta-para-vacía>]
    [else (<combinar> (car lista) (procesar (cdr lista)))]))
```

**Buenas prácticas usadas en la solución:**
- Accesores con nombre (`ped-ciudad`) en vez de `list-ref` con números sueltos.
- Una función = una responsabilidad (validar, calcular despacho, sumar...).
- Funciones genéricas reutilizables (`sumar-campo`, `agrupar-por`).
- Funciones "envoltorio" que inician el acumulador (`registros-unicos`).

---

### 3.1 Programas en varios archivos (módulos)
Cada archivo `.rkt` con `#lang racket` es un **módulo**. Para compartir funciones:
```racket
(provide (all-defined-out))   ; en el módulo: "exporto todo lo que defino"
(require "datos.rkt")         ; en otro archivo: "cargo lo que datos.rkt exporta"
```
> `require`/`provide` no están en la lista de funciones: son la sintaxis de módulos de Racket y solo se usan para dividir el proyecto en archivos, no en la lógica.

Estructura de la práctica:
```
practica_solucion.rkt            ← punto de entrada: menú (main)
modulos/
  datos.rkt                      ← representación, accesores, constantes, datos de prueba
  parte1_validacion.rkt          ← PARTE 1   (requiere datos)
  parte2_calculos.rkt            ← PARTE 2   (requiere datos, parte1)
  parte3_conciliacion.rkt        ← PARTE 3   (requiere datos, parte2)
  entrada.rkt                    ← lectura por teclado
  informe.rkt                    ← imprime todo (requiere las tres partes)
```
Las dependencias van en un solo sentido (datos → parte1 → parte2 → parte3 → informe → main). Racket no permite que dos módulos se requieran entre sí.

Ejecutar: `racket practica_solucion.rkt` (o abrirlo en DrRacket y pulsar *Run*).

## 4. Desglose de pies a cabeza del código

### 4.0 Flujo general (cómo se conectan las partes)

```
pedidos originales
   │  Parte 1
   ├── registros-invalidos ──────────────► INCONSISTENCIAS
   └── registros-validos
          └── registros-unicos ──(cantidad-duplicados)► DUPLICADOS
                 ├── rechazados-por-inventario ─────► RECHAZADOS
                 └── pedidos-facturables
                        │  Parte 2
                        └── facturar-todos ► facturados
                               ├── totales, ordenar, mayor/menor
                               ├── agrupar-por (ciudad, categoría, ...)
                               └── métricas (promedio, top 5, ...)
                                      │  Parte 3
pagos ────────────────────────────────┴── conciliar-todos ► CONCILIACIÓN
                                              │
                                          informe (imprime todo)
```
Cada flecha es una **lista nueva**. La función `informe` encadena todo con `let*`.

### 4.1 Sección 0 – Representación de datos
**Decisión:** un pedido es una lista de 15 campos. Es lo más simple con las funciones permitidas (no hay `struct`). Para no recordar posiciones se definen accesores:
```racket
(define (ped-ciudad p) (list-ref p 3))
```
Igual con pagos `(list numero valor)` y con el **pedido facturado**: `(list pedido subtotal desc-cliente desc-volumen despacho impuesto total)`. Guardar el pedido original dentro del facturado permite luego agrupar por ciudad, cliente, etc.

Las listas `TIPOS-CLIENTE`, `MEDIOS-PAGO`, ... son constantes con los valores permitidos.

### 4.2 Parte 1 – Validación, duplicados e inventario
- **`valor-permitido?`**: `member` devuelve sublista o `#f`; `(not (not x))` lo convierte a `#t/#f`.
- **`numero-positivo?`**: `(and (number? x) (> x 0))`. Gracias al cortocircuito, si alguien escribió "abc" como cantidad (`string->number` da `#f`) no hay error.
- **`pedido-valido?`**: un gran `and` con cada regla del enunciado. Si una falla, todo es `#f`.
- **`registros-validos` / `registros-invalidos`**: dos `filter`, uno con el predicado y otro con su negación (`lambda` + `not`).
- **Duplicados**: `mismo-registro?` compara número **y** código. `ya-registrado?` usa `filter` + `null?` para saber si hay alguno igual en una lista. `eliminar-duplicados-aux` recorre con acumulador:
  - caso base: no quedan → `(reverse vistos)`;
  - si ya está en `vistos` → se salta;
  - si no → `(cons primero vistos)`.

  Traza con `(A B A')` donde A' duplica A:
  ```
  pendientes (A B A')  vistos ()
  pendientes (B A')    vistos (A)
  pendientes (A')      vistos (B A)
  pendientes ()        vistos (B A)   ; A' se descartó
  → (reverse '(B A)) = (A B)
  ```
  `cantidad-duplicados` = largo original − largo sin duplicados.
- **Inventario**: `pedidos-facturables` = Aprobado **y** disponible ≥ cantidad (no hay despachos parciales). `rechazados-por-inventario` = Aprobado **y no** suficiente.

**¿Por qué duplicados se calculan sobre los válidos?** Porque el enunciado primero separa válidos/inválidos y solo los válidos siguen al procesamiento.

### 4.3 Parte 2 – Cálculos económicos
Funciones pequeñas, una por regla:

| Función | Regla |
|---|---|
| `subtotal` | cantidad × precio |
| `porcentaje-cliente` | Normal 0, Frecuente 5%, Premium 10% (`cond` + `string=?`) |
| `descuento-volumen` | 3% si subtotal ≥ 1.000.000 |
| `costo-base-despacho` | ≤10 km: 8.000; ≤30: 15.000; >30: 25.000 + 1.000·(km−30) |
| `costo-despacho` | ×1,4 si es Express |
| `tasa-impuesto` | 5% Alimentos, 19% resto |

**Decisión: fracciones exactas** (`5/100`, `14/10`) + `round`. Así no hay errores de decimales (0.1 + 0.2 ≠ 0.3 en flotantes) y la conciliación puede comparar con `=` exactamente.

`facturar-pedido` usa `let*` porque cada valor depende del anterior:
```
comercial = subtotal − desc-cliente − desc-volumen
base-imp  = comercial + despacho
impuesto  = base-imp × tasa
total     = base-imp + impuesto
```

**Ejemplo completo – pedido 1 de prueba** (Premium, Express, 40 km, 1 × 2.500.000, Tecnología):
```
subtotal        = 2.500.000
desc. Premium   =   250.000  (10%)
desc. volumen   =    75.000  (3%, porque ≥ 1.000.000)
comercial       = 2.175.000
despacho base   = 25.000 + 1.000·(40−30) = 35.000
Express (+40%)  =    49.000
antes impuesto  = 2.224.000
IVA 19%         =   422.560
TOTAL           = 2.646.560   → por eso el pago de prueba #1 es 2.646.560 (conciliado)
```

**Agregaciones:**
- `sumar-campo campo lista` = `(apply + (map campo lista))`. Con ella salen los totales bruto, descontado, despachos, impuestos y definitivo.
- **Ordenamiento**: no existe `sort` en la lista permitida, así que se implementa **inserción**:
  - `insertar-desc` mete un elemento en una lista ya ordenada;
  - `ordenar-desc` ordena el resto y luego inserta el primero.
  ```
  ordenar (3 1 2) = insertar 3 en (ordenar (1 2))
                  = insertar 3 en (insertar 1 en (ordenar (2)))
                  = insertar 3 en (insertar 1 en (2)) = insertar 3 en (2 1) = (3 2 1)
  ```
  Mayor = primero de la ordenada; menor = primero de su `reverse`.
- **`agrupar-por`** (la pieza más importante): recibe *qué clave usar* y *qué valor sumar* como funciones. Construye pares `(clave total)` con `sumar-en-grupo`, que busca la clave recursivamente: si la encuentra suma, si no la crea. Con la misma función se resuelven: por ciudad, por categoría, por tipo de cliente, por medio de pago (valor = 1 para **contar**), por cédula y unidades por código. Esto es la ventaja del orden superior: **una función, seis usos**.
- `grupo-maximo` → categoría top y cliente top (luego `assoc` busca el nombre por cédula).
- Métricas: `todos-consistentes?` (no hay ninguno inconsistente → `filter` + `null?`), `existe-premium-express?` (existe al menos uno → `not null?`), `superiores-al-promedio`, `top-cinco` (usa `tomar`, recursiva) y `porcentaje-conversion` (facturados / originales × 100).

### 4.4 Parte 3 – Conciliación, lectura e informe
- `buscar-facturado` encuentra el pedido facturado por número.
- `conciliar-pago` devuelve `(numero estado diferencia)` con un `cond`:
  - no existe → "Sin pedido" (todo cuenta como excedente);
  - igual → "Conciliado";
  - menor → "Pendiente" (falta dinero);
  - mayor → "Excedente".
- `total-pendiente`, `total-excedente`, `numeros-con-diferencia` filtran por estado y suman con `apply +`.
- **Lectura**: `preguntar` = `display` + `read-line`. `preguntar-numero` añade `string->number`. `leer-pedidos i n` es recursiva: caso base `i > n`. Se usa `let*` para que el pedido actual se lea **antes** que los siguientes (orden correcto de preguntas). Así la cantidad de pedidos solo se conoce en ejecución, como pide el enunciado.
- **`informe`**: un `let*` que encadena todas las etapas y un `begin` que imprime cada sección: registros recibidos, inconsistencias, duplicados, rechazados por inventario, facturados, valores económicos, resúmenes, conciliación y métricas.
- **`main`**: menú; opción 1 usa `PEDIDOS-PRUEBA`/`PAGOS-PRUEBA`, opción 2 lee del teclado.

### 4.5 Qué muestran los datos de prueba
| Pedido | Resultado esperado | Motivo |
|---|---|---|
| 1 | Facturado, 2.646.560 | Premium + Express > 2.000.000 → métrica "Sí" |
| 2 | Facturado, 218.400 | Alimentos (IVA 5%) |
| 3 | Facturado, 379.610 | El segundo #3 es **duplicado** |
| 4 | Rechazado por inventario | pide 2, hay 1 |
| 5 | Facturado, 1.995.630 | Frecuente con descuento por volumen |
| 6 | No facturado | Pago Pendiente |
| -7, 8, 9 | Inconsistencias | número negativo, cédula vacía, medio "Bitcoin" |
| 10 | Facturado, 489.328 | Express a 9 km |

Pagos: #1 conciliado, #2 pendiente (118.400), #3 excedente (20.390), #99 sin pedido. Conversión: 5 de 11 = 45,45%. Hay 5 facturados, así que se muestra el Top 5.

---

## 5. Preguntas tipo examen

1. ¿Qué diferencia hay entre `map`, `filter` y `for-each`?
2. Escribe una función recursiva que cuente cuántos números pares hay en una lista. Identifica caso base y caso recursivo.
3. ¿Por qué `(and (number? x) (> x 0))` no da error si `x` es `"hola"`?
4. ¿Qué devuelve `(member 3 '(1 2 3 4))`? ¿Por qué puede usarse como condición?
5. ¿Por qué se necesita `reverse` al final de una función con acumulador que usa `cons`?
6. Calcula a mano el total de un pedido Frecuente, envío Normal, 35 km, 3 × 100.000, categoría Ropa. *(Resp.: sub 300.000; desc 15.000; comercial 285.000; despacho 30.000; base 315.000; IVA 59.850; total 374.850)*
7. Diferencia entre `let*` y `define` dentro de una función.
8. ¿Cómo usarías `agrupar-por` para contar pedidos por ciudad?
   *(Resp.: `(agrupar-por (lambda (f) (ped-ciudad (fac-pedido f))) (lambda (f) 1) facturados)`)*
9. ¿Qué hace `(apply + (map second '((a 1) (b 2))))`? *(Resp.: 3)*
10. ¿Por qué se usaron fracciones exactas (`19/100`) en vez de `0.19`?

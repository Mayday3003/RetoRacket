#lang racket
;; parte1_validacion.rkt -> PARTE 1: validación, duplicados e inventario
;; Parte de la práctica "Sistema de gestión de pedidos". Ver practica_solucion.rkt.

(require "datos.rkt")
;; provide: exporta todas las definiciones para que otros archivos las usen.
(provide (all-defined-out))

;; =============================================================================
;;  SECCIÓN 1 (PARTE 1). VALIDACIÓN, DUPLICADOS E INVENTARIO
;; =============================================================================

;; -----------------------------------------------------------------------------
;;  (texto-vacio? x)
;;  Qué hace : indica si x NO es un texto útil (es "" o no es texto).
;;  Parámetro: x -> cualquier valor.
;;  Retorna  : #t si x es "" ; #f en otro caso.
;;  Nota     : se usa equal? (y no string=?) porque string=? lanza error si
;;             recibe algo que no es texto; equal? compara cualquier cosa.
;; -----------------------------------------------------------------------------
(define (texto-vacio? x)
  (equal? x ""))

;; -----------------------------------------------------------------------------
;;  (valor-permitido? valor opciones)
;;  Qué hace : verifica si un valor pertenece a una lista de opciones válidas.
;;  Parámetros: valor -> el texto a revisar; opciones -> lista de textos válidos.
;;  Retorna  : #t si está, #f si no.
;;  Cómo     : member retorna la sublista desde el elemento (valor "verdadero")
;;             o #f. Con (not (not ...)) lo convertimos a un booleano limpio.
;; -----------------------------------------------------------------------------
(define (valor-permitido? valor opciones)
  (not (not (member valor opciones))))

;; -----------------------------------------------------------------------------
;;  (numero-positivo? x)
;;  Retorna #t si x es un número estrictamente mayor que cero.
;;  El (number? x) va primero: si x no es número, and se detiene y NO evalúa
;;  (> x 0), evitando un error (evaluación en cortocircuito).
;; -----------------------------------------------------------------------------
(define (numero-positivo? x)
  (and (number? x) (> x 0)))

;; -----------------------------------------------------------------------------
;;  (pedido-valido? p)
;;  Qué hace : aplica TODAS las reglas de consistencia del enunciado.
;;  Parámetro: p -> un pedido.
;;  Retorna  : #t si el pedido es consistente, #f si tiene alguna inconsistencia.
;;  Reglas (un pedido es INVÁLIDO si):
;;    - número de pedido no positivo
;;    - cédula vacía
;;    - cantidad solicitada <= 0
;;    - precio unitario <= 0
;;    - cantidad disponible negativa
;;    - categoría vacía
;;    - medio de pago / tipo cliente / tipo envío / estado fuera de lo permitido
;;  Se usa and: TODAS las condiciones deben cumplirse para ser válido.
;; -----------------------------------------------------------------------------
(define (pedido-valido? p)
  (and (numero-positivo? (ped-numero p))                 ; número > 0
       (not (texto-vacio? (ped-cedula p)))               ; cédula no vacía
       (numero-positivo? (ped-cantidad p))               ; cantidad > 0
       (numero-positivo? (ped-precio p))                 ; precio > 0
       (number? (ped-disponible p))                      ; disponible es número...
       (>= (ped-disponible p) 0)                         ; ...y no negativo
       (not (texto-vacio? (ped-categoria p)))            ; categoría no vacía
       (number? (ped-distancia p))                       ; distancia numérica
       (>= (ped-distancia p) 0)                          ; distancia no negativa
       (valor-permitido? (ped-medio p)  MEDIOS-PAGO)     ; medio de pago válido
       (valor-permitido? (ped-tipo p)   TIPOS-CLIENTE)   ; tipo cliente válido
       (valor-permitido? (ped-envio p)  TIPOS-ENVIO)     ; tipo envío válido
       (valor-permitido? (ped-estado p) ESTADOS-PAGO)))  ; estado pago válido

;; -----------------------------------------------------------------------------
;;  (registros-validos pedidos) / (registros-invalidos pedidos)
;;  Separan la lista original en dos NUEVAS listas usando filter.
;;  filter recorre la lista y conserva solo los elementos donde el predicado
;;  retorna #t. Para los inválidos usamos una lambda que niega el predicado.
;; -----------------------------------------------------------------------------
(define (registros-validos pedidos)
  (filter pedido-valido? pedidos))

(define (registros-invalidos pedidos)
  (filter (lambda (p) (not (pedido-valido? p))) pedidos))

;; -----------------------------------------------------------------------------
;;  (mismo-registro? a b)
;;  Dos registros son DUPLICADOS si tienen el mismo número de pedido Y el mismo
;;  código de producto. Retorna #t o #f.
;; -----------------------------------------------------------------------------
(define (mismo-registro? a b)
  (and (equal? (ped-numero a) (ped-numero b))
       (equal? (ped-codigo a) (ped-codigo b))))

;; -----------------------------------------------------------------------------
;;  (ya-registrado? p lista)
;;  Retorna #t si en 'lista' existe algún registro duplicado de p.
;;  Cómo: filtramos los que son iguales a p; si el resultado NO es vacío,
;;  entonces p ya estaba.
;; -----------------------------------------------------------------------------
(define (ya-registrado? p lista)
  (not (null? (filter (lambda (q) (mismo-registro? p q)) lista))))

;; -----------------------------------------------------------------------------
;;  (eliminar-duplicados-aux pendientes vistos)
;;  Qué hace : recorre 'pendientes' y construye 'vistos' con la PRIMERA
;;             ocurrencia de cada registro.
;;  Parámetros:
;;    pendientes -> registros que faltan por revisar.
;;    vistos     -> acumulador con los registros únicos encontrados (al revés).
;;  Retorna  : la lista de registros únicos en el orden original.
;;  CASO BASE: si no quedan pendientes, retornamos 'vistos' invertido
;;             (porque cons agrega al inicio y el orden quedó al revés).
;;  CASO RECURSIVO:
;;    - si el primero ya está en vistos  -> se descarta y seguimos.
;;    - si no                            -> se agrega a vistos y seguimos.
;; -----------------------------------------------------------------------------
(define (eliminar-duplicados-aux pendientes vistos)
  (cond
    [(null? pendientes) (reverse vistos)]                    ; caso base
    [(ya-registrado? (car pendientes) vistos)                ; ¿duplicado?
     (eliminar-duplicados-aux (cdr pendientes) vistos)]      ; lo ignoramos
    [else
     (eliminar-duplicados-aux (cdr pendientes)               ; avanzamos
                              (cons (car pendientes) vistos))])) ; y lo guardamos

;; -----------------------------------------------------------------------------
;;  (registros-unicos pedidos)
;;  Función "envoltorio": arranca el auxiliar con el acumulador vacío '().
;; -----------------------------------------------------------------------------
(define (registros-unicos pedidos)
  (eliminar-duplicados-aux pedidos '()))

;; -----------------------------------------------------------------------------
;;  (cantidad-duplicados pedidos)
;;  Cuántos registros repetidos se encontraron = total - únicos.
;; -----------------------------------------------------------------------------
(define (cantidad-duplicados pedidos)
  (- (length pedidos) (length (registros-unicos pedidos))))

;; -----------------------------------------------------------------------------
;;  (pago-aprobado? p)      -> #t si el estado de pago es "Aprobado".
;;  (inventario-suficiente? p) -> #t si disponible >= cantidad (no hay
;;                             despachos parciales).
;; -----------------------------------------------------------------------------
(define (pago-aprobado? p)
  (string=? (ped-estado p) "Aprobado"))

(define (inventario-suficiente? p)
  (>= (ped-disponible p) (ped-cantidad p)))

;; -----------------------------------------------------------------------------
;;  (rechazados-por-inventario unicos)
;;  Pedidos con pago APROBADO pero SIN inventario suficiente.
;; -----------------------------------------------------------------------------
(define (rechazados-por-inventario unicos)
  (filter (lambda (p) (and (pago-aprobado? p)
                           (not (inventario-suficiente? p))))
          unicos))

;; -----------------------------------------------------------------------------
;;  (pedidos-facturables unicos)
;;  Pedidos que SÍ continúan el proceso: pago aprobado E inventario suficiente.
;; -----------------------------------------------------------------------------
(define (pedidos-facturables unicos)
  (filter (lambda (p) (and (pago-aprobado? p)
                           (inventario-suficiente? p)))
          unicos))



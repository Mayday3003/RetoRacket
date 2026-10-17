#lang racket
;; parte2_calculos.rkt -> PARTE 2: cálculos económicos y análisis de la jornada
;; Parte de la práctica "Sistema de gestión de pedidos". Ver practica_solucion.rkt.

(require "datos.rkt")
(require "parte1_validacion.rkt")
;; provide: exporta todas las definiciones para que otros archivos las usen.
(provide (all-defined-out))

;; =============================================================================
;;  SECCIÓN 2 (PARTE 2). CÁLCULOS ECONÓMICOS Y ANÁLISIS DE LA JORNADA
;; =============================================================================

;; -----------------------------------------------------------------------------
;;  (subtotal p) = cantidad * precio unitario.
;; -----------------------------------------------------------------------------
(define (subtotal p)
  (* (ped-cantidad p) (ped-precio p)))

;; -----------------------------------------------------------------------------
;;  (porcentaje-cliente tipo)
;;  Qué hace : retorna el porcentaje de descuento según el tipo de cliente.
;;  Usa cond con string=?: Normal 0, Frecuente 5/100, Premium 10/100.
;;  Nota: se usan fracciones exactas (5/100) para no perder precisión.
;; -----------------------------------------------------------------------------
(define (porcentaje-cliente tipo)
  (cond
    [(string=? tipo "Frecuente") 5/100]
    [(string=? tipo "Premium")   10/100]
    [else 0]))                              ; Normal: sin descuento

;; -----------------------------------------------------------------------------
;;  (descuento-cliente p) = subtotal * porcentaje según tipo (redondeado).
;; -----------------------------------------------------------------------------
(define (descuento-cliente p)
  (round (* (subtotal p) (porcentaje-cliente (ped-tipo p)))))

;; -----------------------------------------------------------------------------
;;  (descuento-volumen p)
;;  3% adicional si el subtotal (ANTES de descuentos) es >= 1.000.000.
;;  Ambos descuentos se calculan sobre el subtotal original.
;; -----------------------------------------------------------------------------
(define (descuento-volumen p)
  (if (>= (subtotal p) 1000000)
      (round (* (subtotal p) 3/100))        ; aplica 3%
      0))                                   ; no aplica

;; -----------------------------------------------------------------------------
;;  (valor-comercial p) = subtotal - descuento cliente - descuento volumen.
;; -----------------------------------------------------------------------------
(define (valor-comercial p)
  (- (subtotal p) (descuento-cliente p) (descuento-volumen p)))

;; -----------------------------------------------------------------------------
;;  (costo-base-despacho km)
;;  Tarifa por distancia:
;;    km <= 10        -> 8.000
;;    11 <= km <= 30  -> 15.000
;;    km > 30         -> 25.000 + 1.000 por cada km adicional a 30
;;  cond evalúa en orden y se detiene en la primera condición verdadera, por
;;  eso basta preguntar "<= 10" y luego "<= 30".
;; -----------------------------------------------------------------------------
(define (costo-base-despacho km)
  (cond
    [(<= km 10) 8000]
    [(<= km 30) 15000]
    [else (+ 25000 (* 1000 (- km 30)))]))

;; -----------------------------------------------------------------------------
;;  (costo-despacho p)
;;  Si el envío es Express, el costo base recibe un recargo del 40% (* 14/10).
;; -----------------------------------------------------------------------------
(define (costo-despacho p)
  (let* ([base (costo-base-despacho (ped-distancia p))])  ; tarifa por km
    (if (string=? (ped-envio p) "Express")
        (round (* base 14/10))                             ; +40%
        base)))

;; -----------------------------------------------------------------------------
;;  (tasa-impuesto p): 5% para "Alimentos", 19% para el resto.
;; -----------------------------------------------------------------------------
(define (tasa-impuesto p)
  (if (string=? (ped-categoria p) "Alimentos") 5/100 19/100))

;; -----------------------------------------------------------------------------
;;  (facturar-pedido p)
;;  Qué hace : construye el PEDIDO FACTURADO con todos los valores económicos.
;;  Usa let* porque cada variable depende de las anteriores:
;;    comercial -> antes-impuesto -> impuesto -> total
;;  Retorna  : (list p subtotal desc-cliente desc-volumen despacho impuesto total)
;; -----------------------------------------------------------------------------
(define (facturar-pedido p)
  (let* ([sub        (subtotal p)]                          ; cantidad*precio
         [d-cli      (descuento-cliente p)]                 ; desc. por tipo
         [d-vol      (descuento-volumen p)]                 ; desc. por volumen
         [despacho   (costo-despacho p)]                    ; envío
         [comercial  (- sub d-cli d-vol)]                   ; valor comercial
         [base-imp   (+ comercial despacho)]                ; antes de impuesto
         [impuesto   (round (* base-imp (tasa-impuesto p)))] ; impuesto
         [total      (+ base-imp impuesto)])                ; valor definitivo
    (list p sub d-cli d-vol despacho impuesto total)))

;; -----------------------------------------------------------------------------
;;  (facturar-todos facturables)
;;  map aplica facturar-pedido a cada pedido y retorna la NUEVA lista.
;; -----------------------------------------------------------------------------
(define (facturar-todos facturables)
  (map facturar-pedido facturables))

;; -----------------------------------------------------------------------------
;;  (sumar-campo campo facturados)
;;  Qué hace : suma un campo de todos los pedidos facturados.
;;  Parámetros: campo -> función accesora (ej. fac-total); facturados -> lista.
;;  Cómo     : map extrae el campo de cada uno y (apply + lista) suma todos.
;;             (apply + '()) da 0, así que funciona con listas vacías.
;; -----------------------------------------------------------------------------
(define (sumar-campo campo facturados)
  (apply + (map campo facturados)))

;; Totales generales de la jornada.
(define (total-bruto fs)      (sumar-campo fac-subtotal fs))
(define (total-descontado fs) (+ (sumar-campo fac-desc-cliente fs)
                                 (sumar-campo fac-desc-volumen fs)))
(define (total-despachos fs)  (sumar-campo fac-despacho fs))
(define (total-impuestos fs)  (sumar-campo fac-impuesto fs))
(define (total-definitivo fs) (sumar-campo fac-total fs))

;; -----------------------------------------------------------------------------
;;  ORDENAMIENTO POR INSERCIÓN (no existe 'sort' en la lista permitida)
;;
;;  (insertar-desc f ordenada)
;;  Inserta el facturado f en la lista 'ordenada' (de mayor a menor total)
;;  en la posición correcta.
;;  CASO BASE 1: lista vacía -> (list f).
;;  CASO BASE 2: f es >= que el primero -> f va al frente.
;;  CASO RECURSIVO: se conserva el primero y se inserta f en el resto.
;; -----------------------------------------------------------------------------
(define (insertar-desc f ordenada)
  (cond
    [(null? ordenada) (list f)]
    [(>= (fac-total f) (fac-total (car ordenada))) (cons f ordenada)]
    [else (cons (car ordenada) (insertar-desc f (cdr ordenada)))]))

;; -----------------------------------------------------------------------------
;;  (ordenar-desc facturados)
;;  CASO BASE: lista vacía ya está ordenada.
;;  CASO RECURSIVO: ordenamos el resto y luego insertamos el primero.
;; -----------------------------------------------------------------------------
(define (ordenar-desc facturados)
  (if (null? facturados)
      '()
      (insertar-desc (car facturados) (ordenar-desc (cdr facturados)))))

;; Mayor valor = primero de la lista ordenada; menor = último (primero del
;; reverso). Retornan #f si no hay facturados.
(define (pedido-mayor fs)
  (if (null? fs) #f (first (ordenar-desc fs))))

(define (pedido-menor fs)
  (if (null? fs) #f (first (reverse (ordenar-desc fs)))))

;; -----------------------------------------------------------------------------
;;  AGRUPACIÓN GENÉRICA
;;  Un resumen agrupado es una lista de pares (list clave acumulado),
;;  ej: (("Medellin" 500000) ("Cali" 300000)).
;;
;;  (sumar-en-grupo clave valor grupos)
;;  Retorna una NUEVA lista de grupos donde a la clave se le suma 'valor'.
;;  CASO BASE: no hay grupos -> se crea el grupo nuevo (list (list clave valor)).
;;  CASO RECURSIVO:
;;    - si el primer grupo tiene esa clave -> se reemplaza con la suma.
;;    - si no -> se conserva y se busca en el resto.
;; -----------------------------------------------------------------------------
(define (sumar-en-grupo clave valor grupos)
  (cond
    [(null? grupos) (list (list clave valor))]
    [(equal? (first (car grupos)) clave)
     (cons (list clave (+ (second (car grupos)) valor)) (cdr grupos))]
    [else (cons (car grupos) (sumar-en-grupo clave valor (cdr grupos)))]))

;; -----------------------------------------------------------------------------
;;  (agrupar-por obtener-clave obtener-valor elementos)
;;  Qué hace : agrupa una lista cualquiera por una clave y suma un valor.
;;  Parámetros:
;;    obtener-clave -> función que da la clave de un elemento (ej. ciudad).
;;    obtener-valor -> función que da el número a sumar (ej. total, o 1 para
;;                     contar).
;;    elementos     -> la lista a agrupar.
;;  CASO BASE: lista vacía -> no hay grupos '().
;;  CASO RECURSIVO: agrupamos el resto y luego sumamos el primer elemento.
;;  Es una función de ORDEN SUPERIOR: recibe funciones como parámetros.
;; -----------------------------------------------------------------------------
(define (agrupar-por obtener-clave obtener-valor elementos)
  (if (null? elementos)
      '()
      (sumar-en-grupo (obtener-clave (car elementos))
                      (obtener-valor (car elementos))
                      (agrupar-por obtener-clave obtener-valor (cdr elementos)))))

;; Resúmenes de facturación pedidos por el enunciado.
(define (facturacion-por-ciudad fs)
  (agrupar-por (lambda (f) (ped-ciudad (fac-pedido f))) fac-total fs))

(define (facturacion-por-categoria fs)
  (agrupar-por (lambda (f) (ped-categoria (fac-pedido f))) fac-total fs))

(define (facturacion-por-tipo-cliente fs)
  (agrupar-por (lambda (f) (ped-tipo (fac-pedido f))) fac-total fs))

;; Conteo de pedidos procesados por medio de pago: el "valor" es siempre 1.
(define (pedidos-por-medio-pago fs)
  (agrupar-por (lambda (f) (ped-medio (fac-pedido f))) (lambda (f) 1) fs))

;; Valor comprado por cada cédula (el cliente puede aparecer varias veces).
(define (compras-por-cliente fs)
  (agrupar-por (lambda (f) (ped-cedula (fac-pedido f))) fac-total fs))

;; Unidades a descontar del inventario por código de producto.
(define (unidades-por-codigo fs)
  (agrupar-por (lambda (f) (ped-codigo (fac-pedido f)))
               (lambda (f) (ped-cantidad (fac-pedido f)))
               fs))

;; -----------------------------------------------------------------------------
;;  (grupo-maximo grupos)
;;  Retorna el par (clave valor) con el mayor valor; #f si no hay grupos.
;;  CASO BASE: un solo grupo -> ese es el máximo.
;;  CASO RECURSIVO: comparamos el primero con el máximo del resto.
;; -----------------------------------------------------------------------------
(define (grupo-maximo grupos)
  (cond
    [(null? grupos) #f]
    [(null? (cdr grupos)) (car grupos)]
    [else
     (let* ([max-resto (grupo-maximo (cdr grupos))])
       (if (>= (second (car grupos)) (second max-resto))
           (car grupos)
           max-resto))]))

(define (categoria-mayor-facturacion fs)
  (grupo-maximo (facturacion-por-categoria fs)))

;; -----------------------------------------------------------------------------
;;  (cliente-mayor-compra fs)
;;  Retorna (list cedula nombre valor) del cliente con mayor valor acumulado.
;;  Busca el nombre con assoc sobre pares (cedula nombre).
;; -----------------------------------------------------------------------------
(define (cliente-mayor-compra fs)
  (let* ([mejor (grupo-maximo (compras-por-cliente fs))])
    (if (not mejor)
        #f
        (let* ([nombres (map (lambda (f) (list (ped-cedula (fac-pedido f))
                                               (ped-nombre (fac-pedido f))))
                             fs)]                       ; pares cédula-nombre
               [par (assoc (first mejor) nombres)])      ; buscamos la cédula
          (list (first mejor) (second par) (second mejor))))))

;; -----------------------------------------------------------------------------
;;  (facturado-consistente? f)
;;  Todos los valores económicos deben ser positivos (descuentos >= 0) y los
;;  datos del pedido deben seguir siendo válidos.
;; -----------------------------------------------------------------------------
(define (facturado-consistente? f)
  (and (pedido-valido? (fac-pedido f))
       (> (fac-subtotal f) 0)
       (>= (fac-desc-cliente f) 0)
       (>= (fac-desc-volumen f) 0)
       (> (fac-despacho f) 0)
       (> (fac-impuesto f) 0)
       (> (fac-total f) 0)))

;; ¿Todos consistentes? = no existe ninguno inconsistente.
(define (todos-consistentes? fs)
  (null? (filter (lambda (f) (not (facturado-consistente? f))) fs)))

;; ¿Existe al menos un Premium con envío Express cuyo total supere 2.000.000?
(define (existe-premium-express? fs)
  (not (null? (filter (lambda (f)
                        (and (string=? (ped-tipo (fac-pedido f)) "Premium")
                             (string=? (ped-envio (fac-pedido f)) "Express")
                             (> (fac-total f) 2000000)))
                      fs))))

;; Promedio del valor definitivo (0 si no hay facturados).
(define (promedio-facturado fs)
  (if (null? fs) 0 (/ (total-definitivo fs) (length fs))))

;; Pedidos cuyo valor final es superior al promedio general.
(define (superiores-al-promedio fs)
  (let* ([prom (promedio-facturado fs)])
    (filter (lambda (f) (> (fac-total f) prom)) fs)))

;; -----------------------------------------------------------------------------
;;  (tomar n lista): primeros n elementos de una lista.
;;  CASO BASE: n = 0 o lista vacía -> '().
;;  CASO RECURSIVO: primero + (tomar (n-1) resto).
;; -----------------------------------------------------------------------------
(define (tomar n lista)
  (if (or (zero? n) (null? lista))
      '()
      (cons (car lista) (tomar (- n 1) (cdr lista)))))

;; Top 5 solo si existen al menos cinco operaciones válidas; si no, '().
(define (top-cinco fs)
  (if (>= (length fs) 5)
      (tomar 5 (ordenar-desc fs))
      '()))

;; Porcentaje de registros originales que terminaron en venta facturada.
(define (porcentaje-conversion originales fs)
  (if (null? originales)
      0
      (exact->inexact (/ (round (* 10000 (/ (length fs) (length originales))))
                         100))))



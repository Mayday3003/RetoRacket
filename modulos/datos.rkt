#lang racket
;; datos.rkt -> representación de los datos, accesores, constantes y datos de prueba
;; Parte de la práctica "Sistema de gestión de pedidos". Ver practica_solucion.rkt.

;; provide: exporta todas las definiciones para que otros archivos las usen.
(provide (all-defined-out))

;; =============================================================================
;;  SECCIÓN 0. REPRESENTACIÓN DE LOS DATOS
;; =============================================================================
;;  Un PEDIDO es una lista de 15 campos en este orden exacto:
;;    posición 0  -> número de pedido            (número)
;;    posición 1  -> cédula del cliente          (texto)
;;    posición 2  -> nombre del cliente          (texto)
;;    posición 3  -> ciudad                      (texto)
;;    posición 4  -> categoría del producto      (texto)
;;    posición 5  -> código del producto         (texto)
;;    posición 6  -> nombre del producto         (texto)
;;    posición 7  -> cantidad solicitada         (número)
;;    posición 8  -> precio unitario             (número)
;;    posición 9  -> cantidad disponible         (número)
;;    posición 10 -> medio de pago               (texto)
;;    posición 11 -> tipo de cliente             (texto)
;;    posición 12 -> tipo de envío               (texto)
;;    posición 13 -> distancia en km             (número)
;;    posición 14 -> estado del pago             (texto)
;;
;;  Un PAGO es una lista de 2 campos: (list numero-pedido valor-recibido)
;;
;;  Un PEDIDO FACTURADO es una lista de 7 campos:
;;    (list pedido subtotal desc-cliente desc-volumen despacho impuesto total)
;; =============================================================================

;; -----------------------------------------------------------------------------
;;  ACCESORES DEL PEDIDO
;;  Cada función recibe un pedido (lista) y retorna UN campo usando list-ref.
;;  Ventaja: el resto del programa usa nombres claros (ped-ciudad p) en vez de
;;  números mágicos (list-ref p 3). Si el orden cambiara, solo se edita aquí.
;; -----------------------------------------------------------------------------
(define (ped-numero p)     (list-ref p 0))
(define (ped-cedula p)     (list-ref p 1))
(define (ped-nombre p)     (list-ref p 2))
(define (ped-ciudad p)     (list-ref p 3))
(define (ped-categoria p)  (list-ref p 4))
(define (ped-codigo p)     (list-ref p 5))
(define (ped-producto p)   (list-ref p 6))
(define (ped-cantidad p)   (list-ref p 7))
(define (ped-precio p)     (list-ref p 8))
(define (ped-disponible p) (list-ref p 9))
(define (ped-medio p)      (list-ref p 10))
(define (ped-tipo p)       (list-ref p 11))
(define (ped-envio p)      (list-ref p 12))
(define (ped-distancia p)  (list-ref p 13))
(define (ped-estado p)     (list-ref p 14))

;; -----------------------------------------------------------------------------
;;  ACCESORES DEL PAGO: (list numero valor)
;; -----------------------------------------------------------------------------
(define (pago-numero pg) (first pg))   ; primer elemento: número de pedido
(define (pago-valor pg)  (second pg))  ; segundo elemento: valor recibido

;; -----------------------------------------------------------------------------
;;  ACCESORES DEL PEDIDO FACTURADO
;;  (list pedido subtotal desc-cliente desc-volumen despacho impuesto total)
;; -----------------------------------------------------------------------------
(define (fac-pedido f)       (list-ref f 0))
(define (fac-subtotal f)     (list-ref f 1))
(define (fac-desc-cliente f) (list-ref f 2))
(define (fac-desc-volumen f) (list-ref f 3))
(define (fac-despacho f)     (list-ref f 4))
(define (fac-impuesto f)     (list-ref f 5))
(define (fac-total f)        (list-ref f 6))

;; -----------------------------------------------------------------------------
;;  VALORES PERMITIDOS POR LA EMPRESA (constantes)
;; -----------------------------------------------------------------------------
(define TIPOS-CLIENTE  (list "Normal" "Frecuente" "Premium"))
(define MEDIOS-PAGO    (list "Efectivo" "Tarjeta" "PSE" "Transferencia"))
(define TIPOS-ENVIO    (list "Normal" "Express"))
(define ESTADOS-PAGO   (list "Aprobado" "Pendiente" "Rechazado"))



;; =============================================================================
;;  DATOS DE PRUEBA (cubren todos los casos del enunciado)
;; =============================================================================
(define PEDIDOS-PRUEBA
  (list
   ;; num ced    nombre   ciudad      categ        cod    prod       cant precio   disp medio          tipo        envio     km  estado
   (list 1 "100" "Ana"    "Medellin"  "Tecnologia" "T01" "Portatil"  1   2500000  5  "Tarjeta"       "Premium"   "Express" 40 "Aprobado")
   (list 2 "200" "Luis"   "Bogota"    "Alimentos"  "A01" "Cafe"      10  20000    50 "Efectivo"      "Normal"    "Normal"  5  "Aprobado")
   (list 3 "300" "Marta"  "Cali"      "Hogar"      "H01" "Lampara"   4   80000    10 "PSE"           "Frecuente" "Normal"  20 "Aprobado")
   (list 3 "300" "Marta"  "Cali"      "Hogar"      "H01" "Lampara"   4   80000    10 "PSE"           "Frecuente" "Normal"  20 "Aprobado") ; duplicado
   (list 4 "100" "Ana"    "Medellin"  "Hogar"      "H02" "Silla"     2   150000   1  "Tarjeta"       "Premium"   "Normal"  8  "Aprobado") ; sin inventario
   (list 5 "400" "Pedro"  "Bogota"    "Tecnologia" "T02" "Celular"   2   900000   3  "Transferencia" "Frecuente" "Express" 12 "Aprobado")
   (list 6 "500" "Sofia"  "Medellin"  "Alimentos"  "A02" "Arroz"     30  4000     100 "Efectivo"     "Normal"    "Normal"  3  "Pendiente") ; no aprobado
   (list -7 "600" "Juan"  "Cali"      "Hogar"      "H03" "Mesa"      1   300000   2  "PSE"           "Normal"    "Normal"  5  "Aprobado") ; número negativo
   (list 8 ""    "Nadie"  "Cali"      "Hogar"      "H04" "Cama"      1   900000   2  "PSE"           "Normal"    "Normal"  5  "Aprobado") ; cédula vacía
   (list 9 "700" "Rosa"   "Bogota"    "Ropa"       "R01" "Camisa"    3   60000    9  "Bitcoin"       "Normal"    "Normal"  15 "Aprobado") ; medio inválido
   (list 10 "200" "Luis"  "Bogota"    "Ropa"       "R02" "Chaqueta"  2   200000   4  "Tarjeta"       "Normal"    "Express" 9  "Aprobado")))

(define PAGOS-PRUEBA
  (list
   (list 1 2646560)  ; exacto -> conciliado (cálculo en la guía)
   (list 2 100000)   ; menor -> pendiente
   (list 3 400000)   ; mayor -> excedente
   (list 99 50000))) ; no existe pedido facturado


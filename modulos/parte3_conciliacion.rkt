#lang racket
;; parte3_conciliacion.rkt -> PARTE 3: conciliación de pagos
;; Parte de la práctica "Sistema de gestión de pedidos". Ver practica_solucion.rkt.

(require "datos.rkt")
(require "parte2_calculos.rkt")
;; provide: exporta todas las definiciones para que otros archivos las usen.
(provide (all-defined-out))

;; =============================================================================
;;  SECCIÓN 3 (PARTE 3). CONCILIACIÓN DE PAGOS, LECTURA E INFORME
;; =============================================================================

;; -----------------------------------------------------------------------------
;;  (buscar-facturado numero fs)
;;  Retorna el pedido facturado con ese número o #f si no existe.
;; -----------------------------------------------------------------------------
(define (buscar-facturado numero fs)
  (let* ([encontrados (filter (lambda (f) (equal? (ped-numero (fac-pedido f))
                                                  numero))
                              fs)])
    (if (null? encontrados) #f (car encontrados))))

;; -----------------------------------------------------------------------------
;;  (conciliar-pago pg fs)
;;  Qué hace : compara un pago con su pedido facturado.
;;  Retorna  : (list numero estado diferencia) donde estado es:
;;    "Conciliado"  -> valor recibido = valor definitivo (diferencia 0)
;;    "Pendiente"   -> recibido < definitivo (diferencia = lo que falta)
;;    "Excedente"   -> recibido > definitivo (diferencia = lo que sobra)
;;    "Sin pedido"  -> no hay pedido facturado con ese número; todo el dinero
;;                     recibido se considera excedente.
;; -----------------------------------------------------------------------------
(define (conciliar-pago pg fs)
  (let* ([f (buscar-facturado (pago-numero pg) fs)])
    (cond
      [(not f) (list (pago-numero pg) "Sin pedido" (pago-valor pg))]
      [(= (pago-valor pg) (fac-total f)) (list (pago-numero pg) "Conciliado" 0)]
      [(< (pago-valor pg) (fac-total f))
       (list (pago-numero pg) "Pendiente" (- (fac-total f) (pago-valor pg)))]
      [else
       (list (pago-numero pg) "Excedente" (- (pago-valor pg) (fac-total f)))])))

;; Concilia todos los pagos (nueva lista de resultados).
(define (conciliar-todos pagos fs)
  (map (lambda (pg) (conciliar-pago pg fs)) pagos))

;; Filtra los resultados de conciliación por estado.
(define (resultados-con-estado estado resultados)
  (filter (lambda (r) (string=? (second r) estado)) resultados))

(define (total-conciliados rs) (length (resultados-con-estado "Conciliado" rs)))

(define (total-pendiente rs)
  (apply + (map third (resultados-con-estado "Pendiente" rs))))

(define (total-excedente rs)
  (+ (apply + (map third (resultados-con-estado "Excedente" rs)))
     (apply + (map third (resultados-con-estado "Sin pedido" rs)))))

;; Números de pedido con diferencias (todo lo que no está conciliado).
(define (numeros-con-diferencia rs)
  (map first (filter (lambda (r) (not (string=? (second r) "Conciliado"))) rs)))


#lang racket
;; =============================================================================
;;  SISTEMA INTEGRAL DE GESTIÓN, CONCILIACIÓN Y LIQUIDACIÓN DE PEDIDOS
;; =============================================================================
;;  Solución de la práctica (partes 1, 2 y 3).
;;
;;  RESTRICCIÓN: solo se usan las funciones de "funciones.png" y "general.png"
;;  (define, list, first, second, third, cons, map, filter, apply, null?,
;;  number?, string=?, string->number, string-append, car, cdr, length,
;;  reverse, append, member, assoc, equal?, not, lambda, + - * /, round,
;;  exact->inexact, list-ref, for-each, if, cond, and, or, case, let*, begin,
;;  read-line, printf, display, displayln, max, min ...) más los operadores de
;;  comparación < > <= >= = (autorizados explícitamente).
;;
;;  PRINCIPIO FUNCIONAL: los datos originales NUNCA se modifican. Cada etapa
;;  (validar, filtrar, calcular, agrupar, ordenar, conciliar) produce una
;;  NUEVA lista a partir de la anterior.
;; =============================================================================

;;  ESTRUCTURA DEL PROYECTO (este archivo es el punto de entrada):
;;    modulos/datos.rkt               -> representación, accesores, datos de prueba
;;    modulos/parte1_validacion.rkt   -> PARTE 1: validación, duplicados, inventario
;;    modulos/parte2_calculos.rkt     -> PARTE 2: cálculos, agrupaciones, métricas
;;    modulos/parte3_conciliacion.rkt -> PARTE 3: conciliación de pagos
;;    modulos/entrada.rkt             -> lectura por teclado
;;    modulos/informe.rkt             -> informe consolidado
;;  'require' carga las funciones que cada módulo exporta con 'provide'.
;; =============================================================================
(require "modulos/datos.rkt"
         "modulos/entrada.rkt"
         "modulos/informe.rkt")

;; =============================================================================
;;  PROGRAMA PRINCIPAL
;; =============================================================================
;;  (main): menú inicial. 1 = datos de prueba, 2 = ingreso por teclado.
;;  La cantidad de pedidos y pagos solo se conoce durante la ejecución.
(define (main)
  (begin
    (displayln "SISTEMA DE GESTION DE PEDIDOS")
    (displayln "1. Usar datos de prueba")
    (displayln "2. Ingresar datos por teclado")
    (let* ([opcion (preguntar "Opcion: ")])
      (cond
        [(equal? opcion "1") (informe PEDIDOS-PRUEBA PAGOS-PRUEBA)]
        [(equal? opcion "2")
         (let* ([n-ped   (preguntar-numero "Cuantos pedidos va a ingresar? ")]
                [pedidos (leer-pedidos 1 n-ped)]
                [n-pag   (preguntar-numero "Cuantos pagos va a ingresar? ")]
                [pagos   (leer-pagos 1 n-pag)])
           (informe pedidos pagos))]
        [else (displayln "Opcion no valida.")]))))

(main)

#lang racket
;; informe.rkt -> impresión del informe consolidado (une las partes 1, 2 y 3)
;; Parte de la práctica "Sistema de gestión de pedidos". Ver practica_solucion.rkt.

(require "datos.rkt")
(require "parte1_validacion.rkt")
(require "parte2_calculos.rkt")
(require "parte3_conciliacion.rkt")
;; provide: exporta todas las definiciones para que otros archivos las usen.
(provide (all-defined-out))

;; -----------------------------------------------------------------------------
;;  FUNCIONES DE IMPRESIÓN
;; -----------------------------------------------------------------------------
;; Título de sección.
(define (titulo texto)
  (printf "\n==================== ~a ====================\n" texto))

;; Imprime un pedido en una línea corta.
(define (mostrar-pedido p)
  (printf "  #~a | ~a | ~a | ~a | cant ~a | estado ~a\n"
          (ped-numero p) (ped-nombre p) (ped-ciudad p)
          (ped-codigo p) (ped-cantidad p) (ped-estado p)))

;; Imprime un pedido facturado con su detalle económico.
(define (mostrar-facturado f)
  (printf "  #~a ~a (~a) | sub ~a | desc ~a | desp ~a | imp ~a | TOTAL ~a\n"
          (ped-numero (fac-pedido f)) (ped-nombre (fac-pedido f))
          (ped-tipo (fac-pedido f)) (fac-subtotal f)
          (+ (fac-desc-cliente f) (fac-desc-volumen f))
          (fac-despacho f) (fac-impuesto f) (fac-total f)))

;; Imprime una lista de grupos (clave valor).
(define (mostrar-grupos grupos)
  (for-each (lambda (g) (printf "  ~a: ~a\n" (first g) (second g))) grupos))

;; Imprime una lista de elementos con una función dada, o "(ninguno)".
(define (mostrar-lista mostrar lista)
  (if (null? lista)
      (displayln "  (ninguno)")
      (for-each mostrar lista)))

;; -----------------------------------------------------------------------------
;;  (informe pedidos pagos)
;;  Encadena TODAS las etapas (parte 1 -> parte 2 -> parte 3) y muestra el
;;  informe consolidado. let* deja claro el "flujo" de datos: cada lista nueva
;;  se construye a partir de la anterior; 'pedidos' nunca se modifica.
;; -----------------------------------------------------------------------------
(define (informe pedidos pagos)
  (let* ([invalidos   (registros-invalidos pedidos)]          ; Parte 1
         [validos     (registros-validos pedidos)]
         [unicos      (registros-unicos validos)]
         [duplicados  (cantidad-duplicados validos)]
         [sin-inv     (rechazados-por-inventario unicos)]
         [facturables (pedidos-facturables unicos)]
         [facturados  (facturar-todos facturables)]           ; Parte 2
         [ordenados   (ordenar-desc facturados)]
         [mayor       (pedido-mayor facturados)]
         [menor       (pedido-menor facturados)]
         [cat-top     (categoria-mayor-facturacion facturados)]
         [cli-top     (cliente-mayor-compra facturados)]
         [concil      (conciliar-todos pagos facturados)])     ; Parte 3
    (begin
      (titulo "REGISTROS RECIBIDOS")
      (printf "  Total registros: ~a\n" (length pedidos))
      (mostrar-lista mostrar-pedido pedidos)

      (titulo "INCONSISTENCIAS")
      (printf "  Registros invalidos: ~a\n" (length invalidos))
      (mostrar-lista mostrar-pedido invalidos)

      (titulo "DUPLICADOS")
      (printf "  Registros duplicados encontrados: ~a\n" duplicados)
      (printf "  Registros unicos para procesar: ~a\n" (length unicos))

      (titulo "RECHAZADOS POR INVENTARIO")
      (mostrar-lista mostrar-pedido sin-inv)

      (titulo "PEDIDOS FACTURADOS (mayor a menor)")
      (mostrar-lista mostrar-facturado ordenados)

      (titulo "VALORES ECONOMICOS")
      (printf "  Total bruto (antes de descuentos): ~a\n" (total-bruto facturados))
      (printf "  Total descontado: ~a\n" (total-descontado facturados))
      (printf "  Total cobrado por despachos: ~a\n" (total-despachos facturados))
      (printf "  Total impuestos: ~a\n" (total-impuestos facturados))
      (printf "  Total definitivo facturado: ~a\n" (total-definitivo facturados))
      (if mayor
          (printf "  Pedido de mayor valor: #~a (~a)\n"
                  (ped-numero (fac-pedido mayor)) (fac-total mayor))
          (displayln "  Pedido de mayor valor: (ninguno)"))
      (if menor
          (printf "  Pedido de menor valor: #~a (~a)\n"
                  (ped-numero (fac-pedido menor)) (fac-total menor))
          (displayln "  Pedido de menor valor: (ninguno)"))

      (titulo "RESUMENES POR AGRUPACION")
      (displayln " Por ciudad:")         (mostrar-grupos (facturacion-por-ciudad facturados))
      (displayln " Por categoria:")      (mostrar-grupos (facturacion-por-categoria facturados))
      (displayln " Por tipo de cliente:") (mostrar-grupos (facturacion-por-tipo-cliente facturados))
      (displayln " Pedidos por medio de pago:") (mostrar-grupos (pedidos-por-medio-pago facturados))
      (displayln " Unidades a descontar por codigo:") (mostrar-grupos (unidades-por-codigo facturados))
      (if cat-top
          (printf " Categoria con mayor facturacion: ~a (~a)\n" (first cat-top) (second cat-top))
          (displayln " Categoria con mayor facturacion: (ninguna)"))
      (if cli-top
          (printf " Cliente con mayor compra: ~a - ~a (~a)\n"
                  (first cli-top) (second cli-top) (third cli-top))
          (displayln " Cliente con mayor compra: (ninguno)"))

      (titulo "CONCILIACION DE PAGOS")
      (for-each (lambda (r) (printf "  Pedido ~a: ~a (diferencia ~a)\n"
                                    (first r) (second r) (third r)))
                concil)
      (printf "  Pedidos conciliados: ~a\n" (total-conciliados concil))
      (printf "  Total pendiente: ~a\n" (total-pendiente concil))
      (printf "  Total excedentes: ~a\n" (total-excedente concil))
      (printf "  Pedidos con diferencias: ~a\n" (numeros-con-diferencia concil))

      (titulo "METRICAS GENERALES")
      (printf "  Todos los facturados son consistentes: ~a\n"
              (if (todos-consistentes? facturados) "Si" "No"))
      (printf "  Existe Premium + Express > 2.000.000: ~a\n"
              (if (existe-premium-express? facturados) "Si" "No"))
      (printf "  Promedio facturado: ~a\n"
              (exact->inexact (promedio-facturado facturados)))
      (displayln "  Pedidos superiores al promedio:")
      (mostrar-lista mostrar-facturado (superiores-al-promedio facturados))
      (displayln "  Top 5 pedidos de la jornada:")
      (if (>= (length facturados) 5)
          (mostrar-lista mostrar-facturado (top-cinco facturados))
          (displayln "  (no hay al menos cinco operaciones validas)"))
      (printf "  Porcentaje de conversion a venta: ~a%\n"
              (porcentaje-conversion pedidos facturados)))))



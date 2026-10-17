#lang racket
;; entrada.rkt -> lectura de pedidos y pagos por teclado (read-line)
;; Parte de la práctica "Sistema de gestión de pedidos". Ver practica_solucion.rkt.

;; provide: exporta todas las definiciones para que otros archivos las usen.
(provide (all-defined-out))

;; -----------------------------------------------------------------------------
;;  LECTURA POR TECLADO
;; -----------------------------------------------------------------------------
;;  (preguntar mensaje): muestra el mensaje y retorna el texto escrito.
(define (preguntar mensaje)
  (begin (display mensaje)
         (read-line)))

;;  (preguntar-numero mensaje): igual, pero convierte a número.
;;  string->number retorna #f si el texto no es un número; la validación
;;  posterior (number?) marcará ese pedido como inconsistente.
(define (preguntar-numero mensaje)
  (string->number (preguntar mensaje)))

;; -----------------------------------------------------------------------------
;;  (leer-pedido i): pide los 15 campos del pedido i y retorna la lista.
;;  let* garantiza que las preguntas se hacen en orden.
;; -----------------------------------------------------------------------------
(define (leer-pedido i)
  (begin
    (printf "\n--- Pedido ~a ---\n" i)
    (let* ([numero     (preguntar-numero "Numero de pedido: ")]
           [cedula     (preguntar "Cedula del cliente: ")]
           [nombre     (preguntar "Nombre del cliente: ")]
           [ciudad     (preguntar "Ciudad: ")]
           [categoria  (preguntar "Categoria del producto: ")]
           [codigo     (preguntar "Codigo del producto: ")]
           [producto   (preguntar "Nombre del producto: ")]
           [cantidad   (preguntar-numero "Cantidad solicitada: ")]
           [precio     (preguntar-numero "Precio unitario: ")]
           [disponible (preguntar-numero "Cantidad disponible: ")]
           [medio      (preguntar "Medio de pago (Efectivo/Tarjeta/PSE/Transferencia): ")]
           [tipo       (preguntar "Tipo de cliente (Normal/Frecuente/Premium): ")]
           [envio      (preguntar "Tipo de envio (Normal/Express): ")]
           [distancia  (preguntar-numero "Distancia en km: ")]
           [estado     (preguntar "Estado del pago (Aprobado/Pendiente/Rechazado): ")])
      (list numero cedula nombre ciudad categoria codigo producto
            cantidad precio disponible medio tipo envio distancia estado))))

;; -----------------------------------------------------------------------------
;;  (leer-pedidos i n): lee pedidos desde el i hasta el n.
;;  CASO BASE: i > n -> '() (ya se leyeron todos).
;;  CASO RECURSIVO: se lee el pedido i y se pone delante de los siguientes.
;;  Se usa let* para forzar que el pedido i se lea ANTES que los demás.
;; -----------------------------------------------------------------------------
(define (leer-pedidos i n)
  (if (> i n)
      '()
      (let* ([actual (leer-pedido i)])
        (cons actual (leer-pedidos (+ i 1) n)))))

;; Igual que leer-pedidos, pero para pagos (numero valor).
(define (leer-pagos i n)
  (if (> i n)
      '()
      (let* ([numero (begin (printf "\n--- Pago ~a ---\n" i)
                            (preguntar-numero "Numero de pedido: "))]
             [valor  (preguntar-numero "Valor recibido: ")]
             [actual (list numero valor)])
        (cons actual (leer-pagos (+ i 1) n)))))


;; Virtual Land
;; Own and trade virtual land parcels

(define-data-var next-parcel-id uint u1)

(define-map parcels
  uint
  {
    owner: principal,
    x: int,
    y: int,
    price: uint,
    for-sale: bool
  }
)

(define-read-only (get-parcel (parcel-id uint))
  (map-get? parcels parcel-id)
)

(define-public (mint-parcel (x int) (y int))
  (let ((parcel-id (var-get next-parcel-id)))
    (map-set parcels parcel-id {
      owner: tx-sender,
      x: x,
      y: y,
      price: u0,
      for-sale: false
    })
    (var-set next-parcel-id (+ parcel-id u1))
    (ok parcel-id)
  )
)

(define-public (list-for-sale (parcel-id uint) (price uint))
  (let ((parcel (unwrap! (map-get? parcels parcel-id) (err u100))))
    (asserts! (is-eq tx-sender (get owner parcel)) (err u101))
    (map-set parcels parcel-id (merge parcel { price: price, for-sale: true }))
    (ok true)
  )
)

(define-public (buy-parcel (parcel-id uint))
  (let ((parcel (unwrap! (map-get? parcels parcel-id) (err u100))))
    (asserts! (get for-sale parcel) (err u102))
    (try! (stx-transfer? (get price parcel) tx-sender (get owner parcel)))
    (map-set parcels parcel-id (merge parcel { owner: tx-sender, for-sale: false }))
    (ok true)
  )
)

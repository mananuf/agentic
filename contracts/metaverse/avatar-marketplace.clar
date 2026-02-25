;; Avatar Marketplace
;; Trade avatar items and accessories

(define-data-var next-item-id uint u1)

(define-map items
  uint
  {
    owner: principal,
    item-type: (string-ascii 32),
    rarity: (string-ascii 16),
    price: uint
  }
)

(define-read-only (get-item (item-id uint))
  (map-get? items item-id)
)

(define-public (mint-item (item-type (string-ascii 32)) (rarity (string-ascii 16)))
  (let ((item-id (var-get next-item-id)))
    (map-set items item-id {
      owner: tx-sender,
      item-type: item-type,
      rarity: rarity,
      price: u0
    })
    (var-set next-item-id (+ item-id u1))
    (ok item-id)
  )
)

(define-public (sell-item (item-id uint) (price uint))
  (let ((item (unwrap! (map-get? items item-id) (err u100))))
    (asserts! (is-eq tx-sender (get owner item)) (err u101))
    (map-set items item-id (merge item { price: price }))
    (ok true)
  )
)

(define-public (buy-item (item-id uint))
  (let ((item (unwrap! (map-get? items item-id) (err u100))))
    (asserts! (> (get price item) u0) (err u102))
    (try! (stx-transfer? (get price item) tx-sender (get owner item)))
    (map-set items item-id (merge item { owner: tx-sender, price: u0 }))
    (ok true)
  )
)

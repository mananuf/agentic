;; Virtual Goods
;; Trade virtual items and collectibles

(define-data-var next-good-id uint u1)

(define-map goods
  uint
  {
    owner: principal,
    name: (string-ascii 64),
    category: (string-ascii 32),
    tradeable: bool
  }
)

(define-read-only (get-good (good-id uint))
  (map-get? goods good-id)
)

(define-public (create-good (name (string-ascii 64)) (category (string-ascii 32)))
  (let ((good-id (var-get next-good-id)))
    (map-set goods good-id {
      owner: tx-sender,
      name: name,
      category: category,
      tradeable: true
    })
    (var-set next-good-id (+ good-id u1))
    (ok good-id)
  )
)

(define-public (transfer-good (good-id uint) (recipient principal))
  (let ((good (unwrap! (map-get? goods good-id) (err u100))))
    (asserts! (is-eq tx-sender (get owner good)) (err u101))
    (asserts! (get tradeable good) (err u102))
    (map-set goods good-id (merge good { owner: recipient }))
    (ok true)
  )
)

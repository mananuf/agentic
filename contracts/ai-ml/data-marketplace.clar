;; AI Data Marketplace
;; Buy and sell training datasets

(define-data-var next-dataset-id uint u1)

(define-map datasets
  uint
  {
    seller: principal,
    name: (string-ascii 64),
    price: uint,
    samples: uint,
    sold: uint
  }
)

(define-read-only (get-dataset (dataset-id uint))
  (map-get? datasets dataset-id)
)

(define-public (list-dataset (name (string-ascii 64)) (price uint) (samples uint))
  (let ((dataset-id (var-get next-dataset-id)))
    (map-set datasets dataset-id {
      seller: tx-sender,
      name: name,
      price: price,
      samples: samples,
      sold: u0
    })
    (var-set next-dataset-id (+ dataset-id u1))
    (ok dataset-id)
  )
)

(define-public (purchase-dataset (dataset-id uint))
  (let ((dataset (unwrap! (map-get? datasets dataset-id) (err u100))))
    (try! (stx-transfer? (get price dataset) tx-sender (get seller dataset)))
    (map-set datasets dataset-id (merge dataset { sold: (+ (get sold dataset) u1) }))
    (ok true)
  )
)

;; Content Monetization
;; Monetize streaming content

(define-data-var next-content-id uint u1)

(define-map content
  uint
  {
    creator: principal,
    title: (string-ascii 64),
    price: uint,
    views: uint,
    revenue: uint
  }
)

(define-read-only (get-content (content-id uint))
  (map-get? content content-id)
)

(define-public (publish-content (title (string-ascii 64)) (price uint))
  (let ((content-id (var-get next-content-id)))
    (map-set content content-id {
      creator: tx-sender,
      title: title,
      price: price,
      views: u0,
      revenue: u0
    })
    (var-set next-content-id (+ content-id u1))
    (ok content-id)
  )
)

(define-public (purchase-access (content-id uint))
  (let ((content-data (unwrap! (map-get? content content-id) (err u100))))
    (try! (stx-transfer? (get price content-data) tx-sender (get creator content-data)))
    (map-set content content-id (merge content-data {
      views: (+ (get views content-data) u1),
      revenue: (+ (get revenue content-data) (get price content-data))
    }))
    (ok true)
  )
)

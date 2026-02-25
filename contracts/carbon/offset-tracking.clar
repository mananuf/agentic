;; Offset Tracking
;; Track carbon offset activities

(define-map offsets
  principal
  {
    total-offset: uint,
    activities: uint,
    last-offset: uint
  }
)

(define-read-only (get-offset (account principal))
  (map-get? offsets account)
)

(define-public (record-offset (amount uint))
  (let ((existing (default-to { total-offset: u0, activities: u0, last-offset: u0 }
                               (map-get? offsets tx-sender))))
    (ok (map-set offsets tx-sender {
      total-offset: (+ (get total-offset existing) amount),
      activities: (+ (get activities existing) u1),
      last-offset: block-height
    }))
  )
)

(define-read-only (get-total-offset (account principal))
  (let ((offset (default-to { total-offset: u0, activities: u0, last-offset: u0 }
                            (map-get? offsets account))))
    (ok (get total-offset offset))
  )
)

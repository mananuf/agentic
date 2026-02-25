;; Emissions Registry
;; Track and report carbon emissions

(define-map emissions
  principal
  {
    total-emissions: uint,
    reports: uint,
    last-report: uint
  }
)

(define-read-only (get-emissions (entity principal))
  (map-get? emissions entity)
)

(define-public (report-emissions (amount uint))
  (let ((existing (default-to { total-emissions: u0, reports: u0, last-report: u0 }
                               (map-get? emissions tx-sender))))
    (ok (map-set emissions tx-sender {
      total-emissions: (+ (get total-emissions existing) amount),
      reports: (+ (get reports existing) u1),
      last-report: block-height
    }))
  )
)

(define-read-only (get-total-emissions (entity principal))
  (let ((emission (default-to { total-emissions: u0, reports: u0, last-report: u0 }
                              (map-get? emissions entity))))
    (ok (get total-emissions emission))
  )
)

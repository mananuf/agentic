;; Impact Verification
;; Verify charitable impact and outcomes

(define-data-var next-impact-id uint u1)

(define-map impacts
  uint
  {
    charity: principal,
    project: (string-ascii 64),
    beneficiaries: uint,
    verified: bool,
    verifier: (optional principal)
  }
)

(define-read-only (get-impact (impact-id uint))
  (map-get? impacts impact-id)
)

(define-public (report-impact (project (string-ascii 64)) (beneficiaries uint))
  (let ((impact-id (var-get next-impact-id)))
    (map-set impacts impact-id {
      charity: tx-sender,
      project: project,
      beneficiaries: beneficiaries,
      verified: false,
      verifier: none
    })
    (var-set next-impact-id (+ impact-id u1))
    (ok impact-id)
  )
)

(define-public (verify-impact (impact-id uint))
  (let ((impact (unwrap! (map-get? impacts impact-id) (err u100))))
    (map-set impacts impact-id (merge impact { 
      verified: true,
      verifier: (some tx-sender)
    }))
    (ok true)
  )
)

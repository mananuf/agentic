;; Insurance Claims
;; Process healthcare insurance claims

(define-data-var next-claim-id uint u1)

(define-map claims
  uint
  {
    patient: principal,
    provider: principal,
    amount: uint,
    status: (string-ascii 16),
    approved-amount: uint
  }
)

(define-read-only (get-claim (claim-id uint))
  (map-get? claims claim-id)
)

(define-public (submit-claim (provider principal) (amount uint))
  (let ((claim-id (var-get next-claim-id)))
    (map-set claims claim-id {
      patient: tx-sender,
      provider: provider,
      amount: amount,
      status: "pending",
      approved-amount: u0
    })
    (var-set next-claim-id (+ claim-id u1))
    (ok claim-id)
  )
)

(define-public (approve-claim (claim-id uint) (approved-amount uint))
  (let ((claim (unwrap! (map-get? claims claim-id) (err u100))))
    (map-set claims claim-id (merge claim { 
      status: "approved",
      approved-amount: approved-amount
    }))
    (ok true)
  )
)

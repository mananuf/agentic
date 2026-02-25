;; Fund Distribution
;; Distribute funds to beneficiaries

(define-constant contract-owner tx-sender)
(define-data-var fund-balance uint u0)

(define-map distributions
  uint
  {
    beneficiary: principal,
    amount: uint,
    purpose: (string-ascii 64),
    distributed: bool
  }
)

(define-data-var next-distribution-id uint u1)

(define-read-only (get-distribution (distribution-id uint))
  (map-get? distributions distribution-id)
)

(define-public (add-funds (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set fund-balance (+ (var-get fund-balance) amount))
    (ok true)
  )
)

(define-public (schedule-distribution (beneficiary principal) (amount uint) (purpose (string-ascii 64)))
  (let ((distribution-id (var-get next-distribution-id)))
    (asserts! (is-eq tx-sender contract-owner) (err u100))
    (map-set distributions distribution-id {
      beneficiary: beneficiary,
      amount: amount,
      purpose: purpose,
      distributed: false
    })
    (var-set next-distribution-id (+ distribution-id u1))
    (ok distribution-id)
  )
)

(define-public (execute-distribution (distribution-id uint))
  (let ((distribution (unwrap! (map-get? distributions distribution-id) (err u101))))
    (asserts! (is-eq tx-sender contract-owner) (err u100))
    (asserts! (not (get distributed distribution)) (err u102))
    (try! (as-contract (stx-transfer? (get amount distribution) tx-sender (get beneficiary distribution))))
    (var-set fund-balance (- (var-get fund-balance) (get amount distribution)))
    (map-set distributions distribution-id (merge distribution { distributed: true }))
    (ok true)
  )
)

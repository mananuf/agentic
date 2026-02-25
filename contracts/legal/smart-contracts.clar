;; Legal Smart Contracts
;; Create and execute legal agreements

(define-data-var next-contract-id uint u1)

(define-map legal-contracts
  uint
  {
    party-a: principal,
    party-b: principal,
    terms-hash: (buff 32),
    signed-a: bool,
    signed-b: bool,
    executed: bool
  }
)

(define-read-only (get-contract (contract-id uint))
  (map-get? legal-contracts contract-id)
)

(define-public (create-contract (party-b principal) (terms-hash (buff 32)))
  (let ((contract-id (var-get next-contract-id)))
    (map-set legal-contracts contract-id {
      party-a: tx-sender,
      party-b: party-b,
      terms-hash: terms-hash,
      signed-a: true,
      signed-b: false,
      executed: false
    })
    (var-set next-contract-id (+ contract-id u1))
    (ok contract-id)
  )
)

(define-public (sign-contract (contract-id uint))
  (let ((contract (unwrap! (map-get? legal-contracts contract-id) (err u100))))
    (asserts! (is-eq tx-sender (get party-b contract)) (err u101))
    (map-set legal-contracts contract-id (merge contract { signed-b: true }))
    (ok true)
  )
)

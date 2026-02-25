;; Micropayments
;; Process small payments for content

(define-map balances principal uint)

(define-read-only (get-balance (account principal))
  (default-to u0 (map-get? balances account))
)

(define-public (deposit (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (ok (map-set balances tx-sender (+ (get-balance tx-sender) amount)))
  )
)

(define-public (pay-creator (creator principal) (amount uint))
  (let ((sender-balance (get-balance tx-sender)))
    (asserts! (>= sender-balance amount) (err u100))
    (map-set balances tx-sender (- sender-balance amount))
    (ok (map-set balances creator (+ (get-balance creator) amount)))
  )
)

(define-public (withdraw (amount uint))
  (let ((balance (get-balance tx-sender)))
    (asserts! (>= balance amount) (err u100))
    (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
    (ok (map-set balances tx-sender (- balance amount)))
  )
)

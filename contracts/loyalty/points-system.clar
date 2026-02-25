;; Loyalty Points System
;; Earn and manage loyalty points

(define-map balances principal uint)

(define-read-only (get-balance (account principal))
  (default-to u0 (map-get? balances account))
)

(define-public (earn-points (amount uint))
  (let ((current-balance (get-balance tx-sender)))
    (ok (map-set balances tx-sender (+ current-balance amount)))
  )
)

(define-public (spend-points (amount uint))
  (let ((current-balance (get-balance tx-sender)))
    (asserts! (>= current-balance amount) (err u100))
    (ok (map-set balances tx-sender (- current-balance amount)))
  )
)

(define-public (transfer-points (recipient principal) (amount uint))
  (let ((sender-balance (get-balance tx-sender)))
    (asserts! (>= sender-balance amount) (err u100))
    (map-set balances tx-sender (- sender-balance amount))
    (ok (map-set balances recipient (+ (get-balance recipient) amount)))
  )
)

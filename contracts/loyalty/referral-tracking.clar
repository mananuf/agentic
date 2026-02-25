;; Referral Tracking
;; Track and reward referrals

(define-map referrals
  principal
  {
    referrer: (optional principal),
    referrals-made: uint,
    rewards-earned: uint
  }
)

(define-read-only (get-referral (user principal))
  (map-get? referrals user)
)

(define-public (register-referral (referrer principal))
  (ok (map-set referrals tx-sender {
    referrer: (some referrer),
    referrals-made: u0,
    rewards-earned: u0
  }))
)

(define-public (record-referral-success)
  (let ((referral (unwrap! (map-get? referrals tx-sender) (err u100)))
        (referrer-principal (unwrap! (get referrer referral) (err u101))))
    (let ((referrer-data (unwrap! (map-get? referrals referrer-principal) (err u102))))
      (map-set referrals referrer-principal (merge referrer-data {
        referrals-made: (+ (get referrals-made referrer-data) u1),
        rewards-earned: (+ (get rewards-earned referrer-data) u100)
      }))
      (ok true)
    )
  )
)

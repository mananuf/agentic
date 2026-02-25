;; Subscription Management
;; Manage streaming subscriptions

(define-map subscriptions
  principal
  {
    tier: (string-ascii 16),
    expires: uint,
    auto-renew: bool
  }
)

(define-constant tier-prices {
  basic: u1000,
  premium: u2000,
  ultimate: u5000
})

(define-read-only (get-subscription (subscriber principal))
  (map-get? subscriptions subscriber)
)

(define-public (subscribe (tier (string-ascii 16)))
  (let ((price (if (is-eq tier "basic")
                   u1000
                   (if (is-eq tier "premium")
                       u2000
                       u5000))))
    (try! (stx-transfer? price tx-sender (as-contract tx-sender)))
    (ok (map-set subscriptions tx-sender {
      tier: tier,
      expires: (+ block-height u4320),
      auto-renew: false
    }))
  )
)

(define-public (cancel-subscription)
  (let ((subscription (unwrap! (map-get? subscriptions tx-sender) (err u100))))
    (ok (map-set subscriptions tx-sender (merge subscription { auto-renew: false })))
  )
)

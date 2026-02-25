;; Tier Management
;; Manage customer loyalty tiers

(define-map member-tiers
  principal
  {
    tier: (string-ascii 16),
    points: uint,
    benefits: uint
  }
)

(define-read-only (get-tier (member principal))
  (map-get? member-tiers member)
)

(define-public (update-tier (points uint))
  (let ((tier-name (if (>= points u10000)
                       "platinum"
                       (if (>= points u5000)
                           "gold"
                           (if (>= points u1000)
                               "silver"
                               "bronze")))))
    (ok (map-set member-tiers tx-sender {
      tier: tier-name,
      points: points,
      benefits: (/ points u100)
    }))
  )
)

;; Vote Delegation
;; Delegate voting power

(define-map delegations
  principal
  {
    delegate: principal,
    power: uint,
    active: bool
  }
)

(define-read-only (get-delegation (delegator principal))
  (map-get? delegations delegator)
)

(define-public (delegate-votes (delegate principal) (power uint))
  (ok (map-set delegations tx-sender {
    delegate: delegate,
    power: power,
    active: true
  }))
)

(define-public (revoke-delegation)
  (let ((delegation (unwrap! (map-get? delegations tx-sender) (err u100))))
    (ok (map-set delegations tx-sender (merge delegation { active: false })))
  )
)

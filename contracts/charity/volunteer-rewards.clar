;; Volunteer Rewards
;; Reward volunteers for their contributions

(define-map volunteers
  principal
  {
    hours: uint,
    rewards: uint,
    projects: uint
  }
)

(define-read-only (get-volunteer (volunteer principal))
  (map-get? volunteers volunteer)
)

(define-public (log-hours (hours uint))
  (let ((existing (default-to { hours: u0, rewards: u0, projects: u0 } 
                               (map-get? volunteers tx-sender))))
    (map-set volunteers tx-sender {
      hours: (+ (get hours existing) hours),
      rewards: (get rewards existing),
      projects: (+ (get projects existing) u1)
    })
    (ok true)
  )
)

(define-public (claim-reward)
  (let ((volunteer (unwrap! (map-get? volunteers tx-sender) (err u100))))
    (let ((reward-amount (* (get hours volunteer) u100)))
      (asserts! (> reward-amount u0) (err u101))
      (try! (as-contract (stx-transfer? reward-amount tx-sender tx-sender)))
      (map-set volunteers tx-sender (merge volunteer { 
        rewards: (+ (get rewards volunteer) reward-amount),
        hours: u0
      }))
      (ok reward-amount)
    )
  )
)

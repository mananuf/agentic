;; AI Training Rewards
;; Reward contributors for model training

(define-constant contract-owner tx-sender)
(define-data-var reward-pool uint u0)

(define-map contributions
  principal
  {
    compute-hours: uint,
    rewards-earned: uint,
    last-claim: uint
  }
)

(define-read-only (get-contribution (contributor principal))
  (map-get? contributions contributor)
)

(define-public (add-contribution (compute-hours uint))
  (let ((existing (default-to { compute-hours: u0, rewards-earned: u0, last-claim: u0 } 
                               (map-get? contributions tx-sender))))
    (map-set contributions tx-sender {
      compute-hours: (+ (get compute-hours existing) compute-hours),
      rewards-earned: (get rewards-earned existing),
      last-claim: (get last-claim existing)
    })
    (ok true)
  )
)

(define-public (claim-rewards)
  (let ((contribution (unwrap! (map-get? contributions tx-sender) (err u100))))
    (let ((reward-amount (* (get compute-hours contribution) u1000)))
      (asserts! (>= (var-get reward-pool) reward-amount) (err u101))
      (try! (as-contract (stx-transfer? reward-amount tx-sender tx-sender)))
      (var-set reward-pool (- (var-get reward-pool) reward-amount))
      (map-set contributions tx-sender (merge contribution { 
        rewards-earned: (+ (get rewards-earned contribution) reward-amount),
        last-claim: block-height
      }))
      (ok reward-amount)
    )
  )
)

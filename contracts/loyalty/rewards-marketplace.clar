;; Rewards Marketplace
;; Redeem points for rewards

(define-data-var next-reward-id uint u1)

(define-map rewards
  uint
  {
    name: (string-ascii 64),
    cost: uint,
    available: uint,
    redeemed: uint
  }
)

(define-read-only (get-reward (reward-id uint))
  (map-get? rewards reward-id)
)

(define-public (add-reward (name (string-ascii 64)) (cost uint) (available uint))
  (let ((reward-id (var-get next-reward-id)))
    (map-set rewards reward-id {
      name: name,
      cost: cost,
      available: available,
      redeemed: u0
    })
    (var-set next-reward-id (+ reward-id u1))
    (ok reward-id)
  )
)

(define-public (redeem-reward (reward-id uint))
  (let ((reward (unwrap! (map-get? rewards reward-id) (err u100))))
    (asserts! (> (get available reward) u0) (err u101))
    (map-set rewards reward-id (merge reward {
      available: (- (get available reward) u1),
      redeemed: (+ (get redeemed reward) u1)
    }))
    (ok true)
  )
)

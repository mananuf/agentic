;; Governance System
;; Decentralized governance voting

(define-data-var next-proposal-id uint u1)

(define-map proposals
  uint
  {
    proposer: principal,
    title: (string-ascii 64),
    votes-for: uint,
    votes-against: uint,
    executed: bool
  }
)

(define-map votes
  { proposal-id: uint, voter: principal }
  { vote: bool, weight: uint }
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

(define-public (create-proposal (title (string-ascii 64)))
  (let ((proposal-id (var-get next-proposal-id)))
    (map-set proposals proposal-id {
      proposer: tx-sender,
      title: title,
      votes-for: u0,
      votes-against: u0,
      executed: false
    })
    (var-set next-proposal-id (+ proposal-id u1))
    (ok proposal-id)
  )
)

(define-public (cast-vote (proposal-id uint) (vote bool) (weight uint))
  (let ((proposal (unwrap! (map-get? proposals proposal-id) (err u100))))
    (map-set votes { proposal-id: proposal-id, voter: tx-sender } { vote: vote, weight: weight })
    (if vote
      (map-set proposals proposal-id (merge proposal { votes-for: (+ (get votes-for proposal) weight) }))
      (map-set proposals proposal-id (merge proposal { votes-against: (+ (get votes-against proposal) weight) }))
    )
    (ok true)
  )
)

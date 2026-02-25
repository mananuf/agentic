;; Quadratic Voting
;; Quadratic voting mechanism

(define-data-var next-poll-id uint u1)

(define-map polls
  uint
  {
    creator: principal,
    question: (string-ascii 128),
    total-votes: uint,
    active: bool
  }
)

(define-map poll-votes
  { poll-id: uint, voter: principal }
  { credits-spent: uint, vote-power: uint }
)

(define-read-only (get-poll (poll-id uint))
  (map-get? polls poll-id)
)

(define-public (create-poll (question (string-ascii 128)))
  (let ((poll-id (var-get next-poll-id)))
    (map-set polls poll-id {
      creator: tx-sender,
      question: question,
      total-votes: u0,
      active: true
    })
    (var-set next-poll-id (+ poll-id u1))
    (ok poll-id)
  )
)

(define-public (vote-quadratic (poll-id uint) (credits uint))
  (let ((poll (unwrap! (map-get? polls poll-id) (err u100)))
        (vote-power (sqrti credits)))
    (map-set poll-votes { poll-id: poll-id, voter: tx-sender } {
      credits-spent: credits,
      vote-power: vote-power
    })
    (map-set polls poll-id (merge poll { total-votes: (+ (get total-votes poll) vote-power) }))
    (ok vote-power)
  )
)

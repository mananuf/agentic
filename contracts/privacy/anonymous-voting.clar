;; Anonymous Voting
;; Vote without revealing identity

(define-data-var next-ballot-id uint u1)

(define-map ballots
  uint
  {
    title: (string-ascii 64),
    votes-for: uint,
    votes-against: uint,
    active: bool
  }
)

(define-map vote-commitments
  { ballot-id: uint, commitment: (buff 32) }
  bool
)

(define-read-only (get-ballot (ballot-id uint))
  (map-get? ballots ballot-id)
)

(define-public (create-ballot (title (string-ascii 64)))
  (let ((ballot-id (var-get next-ballot-id)))
    (map-set ballots ballot-id {
      title: title,
      votes-for: u0,
      votes-against: u0,
      active: true
    })
    (var-set next-ballot-id (+ ballot-id u1))
    (ok ballot-id)
  )
)

(define-public (cast-anonymous-vote (ballot-id uint) (commitment (buff 32)) (vote bool))
  (let ((ballot (unwrap! (map-get? ballots ballot-id) (err u100))))
    (asserts! (get active ballot) (err u101))
    (asserts! (is-none (map-get? vote-commitments { ballot-id: ballot-id, commitment: commitment })) (err u102))
    (map-set vote-commitments { ballot-id: ballot-id, commitment: commitment } true)
    (if vote
      (map-set ballots ballot-id (merge ballot { votes-for: (+ (get votes-for ballot) u1) }))
      (map-set ballots ballot-id (merge ballot { votes-against: (+ (get votes-against ballot) u1) }))
    )
    (ok true)
  )
)

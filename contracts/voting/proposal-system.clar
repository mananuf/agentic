;; Proposal System
;; Submit and manage proposals

(define-data-var next-proposal-id uint u1)
(define-data-var min-stake uint u1000)

(define-map proposals
  uint
  {
    creator: principal,
    description: (string-ascii 128),
    stake: uint,
    status: (string-ascii 16)
  }
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

(define-public (submit-proposal (description (string-ascii 128)))
  (let ((proposal-id (var-get next-proposal-id))
        (stake (var-get min-stake)))
    (try! (stx-transfer? stake tx-sender (as-contract tx-sender)))
    (map-set proposals proposal-id {
      creator: tx-sender,
      description: description,
      stake: stake,
      status: "pending"
    })
    (var-set next-proposal-id (+ proposal-id u1))
    (ok proposal-id)
  )
)

(define-public (approve-proposal (proposal-id uint))
  (let ((proposal (unwrap! (map-get? proposals proposal-id) (err u100))))
    (map-set proposals proposal-id (merge proposal { status: "approved" }))
    (ok true)
  )
)

;; Royalty Distribution
;; Distribute royalties to creators

(define-map royalty-splits
  uint
  {
    content-id: uint,
    creator: principal,
    percentage: uint,
    total-earned: uint
  }
)

(define-data-var next-split-id uint u1)

(define-read-only (get-split (split-id uint))
  (map-get? royalty-splits split-id)
)

(define-public (register-split (content-id uint) (creator principal) (percentage uint))
  (let ((split-id (var-get next-split-id)))
    (asserts! (<= percentage u100) (err u100))
    (map-set royalty-splits split-id {
      content-id: content-id,
      creator: creator,
      percentage: percentage,
      total-earned: u0
    })
    (var-set next-split-id (+ split-id u1))
    (ok split-id)
  )
)

(define-public (distribute-royalty (split-id uint) (total-amount uint))
  (let ((split (unwrap! (map-get? royalty-splits split-id) (err u101)))
        (creator-amount (/ (* total-amount (get percentage split)) u100)))
    (try! (as-contract (stx-transfer? creator-amount tx-sender (get creator split))))
    (map-set royalty-splits split-id (merge split {
      total-earned: (+ (get total-earned split) creator-amount)
    }))
    (ok creator-amount)
  )
)

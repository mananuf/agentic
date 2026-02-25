;; Donation Tracker
;; Track charitable donations

(define-data-var next-donation-id uint u1)
(define-data-var total-donations uint u0)

(define-map donations
  uint
  {
    donor: principal,
    charity: principal,
    amount: uint,
    timestamp: uint,
    category: (string-ascii 32)
  }
)

(define-read-only (get-donation (donation-id uint))
  (map-get? donations donation-id)
)

(define-read-only (get-total-donations)
  (ok (var-get total-donations))
)

(define-public (make-donation (charity principal) (amount uint) (category (string-ascii 32)))
  (let ((donation-id (var-get next-donation-id)))
    (try! (stx-transfer? amount tx-sender charity))
    (map-set donations donation-id {
      donor: tx-sender,
      charity: charity,
      amount: amount,
      timestamp: block-height,
      category: category
    })
    (var-set next-donation-id (+ donation-id u1))
    (var-set total-donations (+ (var-get total-donations) amount))
    (ok donation-id)
  )
)

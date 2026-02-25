;; Carbon Credits
;; Trade carbon offset credits

(define-data-var next-credit-id uint u1)

(define-map credits
  uint
  {
    owner: principal,
    tons: uint,
    project: (string-ascii 64),
    verified: bool
  }
)

(define-read-only (get-credit (credit-id uint))
  (map-get? credits credit-id)
)

(define-public (issue-credit (tons uint) (project (string-ascii 64)))
  (let ((credit-id (var-get next-credit-id)))
    (map-set credits credit-id {
      owner: tx-sender,
      tons: tons,
      project: project,
      verified: false
    })
    (var-set next-credit-id (+ credit-id u1))
    (ok credit-id)
  )
)

(define-public (transfer-credit (credit-id uint) (recipient principal))
  (let ((credit (unwrap! (map-get? credits credit-id) (err u100))))
    (asserts! (is-eq tx-sender (get owner credit)) (err u101))
    (asserts! (get verified credit) (err u102))
    (map-set credits credit-id (merge credit { owner: recipient }))
    (ok true)
  )
)

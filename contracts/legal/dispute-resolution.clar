;; Dispute Resolution
;; Arbitration and dispute handling

(define-data-var next-dispute-id uint u1)

(define-map disputes
  uint
  {
    plaintiff: principal,
    defendant: principal,
    arbitrator: principal,
    stake: uint,
    resolved: bool,
    winner: (optional principal)
  }
)

(define-read-only (get-dispute (dispute-id uint))
  (map-get? disputes dispute-id)
)

(define-public (file-dispute (defendant principal) (arbitrator principal) (stake uint))
  (let ((dispute-id (var-get next-dispute-id)))
    (try! (stx-transfer? stake tx-sender (as-contract tx-sender)))
    (map-set disputes dispute-id {
      plaintiff: tx-sender,
      defendant: defendant,
      arbitrator: arbitrator,
      stake: stake,
      resolved: false,
      winner: none
    })
    (var-set next-dispute-id (+ dispute-id u1))
    (ok dispute-id)
  )
)

(define-public (resolve-dispute (dispute-id uint) (winner principal))
  (let ((dispute (unwrap! (map-get? disputes dispute-id) (err u100))))
    (asserts! (is-eq tx-sender (get arbitrator dispute)) (err u101))
    (try! (as-contract (stx-transfer? (get stake dispute) tx-sender winner)))
    (map-set disputes dispute-id (merge dispute { resolved: true, winner: (some winner) }))
    (ok true)
  )
)

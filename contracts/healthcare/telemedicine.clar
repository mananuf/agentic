;; Telemedicine Platform
;; Schedule and manage virtual appointments

(define-data-var next-appointment-id uint u1)

(define-map appointments
  uint
  {
    patient: principal,
    doctor: principal,
    scheduled-time: uint,
    fee: uint,
    completed: bool
  }
)

(define-read-only (get-appointment (appointment-id uint))
  (map-get? appointments appointment-id)
)

(define-public (book-appointment (doctor principal) (scheduled-time uint) (fee uint))
  (let ((appointment-id (var-get next-appointment-id)))
    (try! (stx-transfer? fee tx-sender (as-contract tx-sender)))
    (map-set appointments appointment-id {
      patient: tx-sender,
      doctor: doctor,
      scheduled-time: scheduled-time,
      fee: fee,
      completed: false
    })
    (var-set next-appointment-id (+ appointment-id u1))
    (ok appointment-id)
  )
)

(define-public (complete-appointment (appointment-id uint))
  (let ((appointment (unwrap! (map-get? appointments appointment-id) (err u100))))
    (asserts! (is-eq tx-sender (get doctor appointment)) (err u101))
    (try! (as-contract (stx-transfer? (get fee appointment) tx-sender (get doctor appointment))))
    (map-set appointments appointment-id (merge appointment { completed: true }))
    (ok true)
  )
)

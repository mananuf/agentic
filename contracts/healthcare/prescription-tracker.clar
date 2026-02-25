;; Prescription Tracker
;; Track and verify prescriptions

(define-data-var next-prescription-id uint u1)

(define-map prescriptions
  uint
  {
    patient: principal,
    doctor: principal,
    medication: (string-ascii 64),
    dosage: (string-ascii 32),
    filled: bool
  }
)

(define-read-only (get-prescription (prescription-id uint))
  (map-get? prescriptions prescription-id)
)

(define-public (issue-prescription (patient principal) (medication (string-ascii 64)) (dosage (string-ascii 32)))
  (let ((prescription-id (var-get next-prescription-id)))
    (map-set prescriptions prescription-id {
      patient: patient,
      doctor: tx-sender,
      medication: medication,
      dosage: dosage,
      filled: false
    })
    (var-set next-prescription-id (+ prescription-id u1))
    (ok prescription-id)
  )
)

(define-public (fill-prescription (prescription-id uint))
  (let ((prescription (unwrap! (map-get? prescriptions prescription-id) (err u100))))
    (asserts! (not (get filled prescription)) (err u101))
    (map-set prescriptions prescription-id (merge prescription { filled: true }))
    (ok true)
  )
)

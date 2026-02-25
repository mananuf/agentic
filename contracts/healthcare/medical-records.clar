;; Medical Records System
;; Secure patient medical records

(define-map records
  principal
  {
    record-hash: (buff 32),
    provider: principal,
    timestamp: uint,
    access-granted: (list 10 principal)
  }
)

(define-read-only (get-record (patient principal))
  (map-get? records patient)
)

(define-public (create-record (record-hash (buff 32)))
  (ok (map-set records tx-sender {
    record-hash: record-hash,
    provider: tx-sender,
    timestamp: block-height,
    access-granted: (list)
  }))
)

(define-public (grant-access (accessor principal))
  (let ((record (unwrap! (map-get? records tx-sender) (err u100))))
    (ok (map-set records tx-sender (merge record {
      access-granted: (unwrap! (as-max-len? (append (get access-granted record) accessor) u10) (err u101))
    })))
  )
)

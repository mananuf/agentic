;; Green Energy Certificates
;; Certify renewable energy production

(define-data-var next-certificate-id uint u1)

(define-map certificates
  uint
  {
    producer: principal,
    energy-type: (string-ascii 32),
    mwh: uint,
    timestamp: uint,
    retired: bool
  }
)

(define-read-only (get-certificate (certificate-id uint))
  (map-get? certificates certificate-id)
)

(define-public (issue-certificate (energy-type (string-ascii 32)) (mwh uint))
  (let ((certificate-id (var-get next-certificate-id)))
    (map-set certificates certificate-id {
      producer: tx-sender,
      energy-type: energy-type,
      mwh: mwh,
      timestamp: block-height,
      retired: false
    })
    (var-set next-certificate-id (+ certificate-id u1))
    (ok certificate-id)
  )
)

(define-public (retire-certificate (certificate-id uint))
  (let ((certificate (unwrap! (map-get? certificates certificate-id) (err u100))))
    (asserts! (is-eq tx-sender (get producer certificate)) (err u101))
    (asserts! (not (get retired certificate)) (err u102))
    (map-set certificates certificate-id (merge certificate { retired: true }))
    (ok true)
  )
)

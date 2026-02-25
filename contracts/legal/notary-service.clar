;; Notary Service
;; Digital notarization of documents

(define-data-var next-notarization-id uint u1)

(define-map notarizations
  uint
  {
    document-hash: (buff 32),
    owner: principal,
    notary: principal,
    timestamp: uint,
    verified: bool
  }
)

(define-read-only (get-notarization (notarization-id uint))
  (map-get? notarizations notarization-id)
)

(define-public (request-notarization (document-hash (buff 32)) (notary principal))
  (let ((notarization-id (var-get next-notarization-id)))
    (map-set notarizations notarization-id {
      document-hash: document-hash,
      owner: tx-sender,
      notary: notary,
      timestamp: block-height,
      verified: false
    })
    (var-set next-notarization-id (+ notarization-id u1))
    (ok notarization-id)
  )
)

(define-public (verify-notarization (notarization-id uint))
  (let ((notarization (unwrap! (map-get? notarizations notarization-id) (err u100))))
    (asserts! (is-eq tx-sender (get notary notarization)) (err u101))
    (map-set notarizations notarization-id (merge notarization { verified: true }))
    (ok true)
  )
)

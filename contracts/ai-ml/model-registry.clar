;; AI Model Registry
;; Register and manage AI/ML models

(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-not-found (err u101))

(define-data-var next-model-id uint u1)

(define-map models
  uint
  {
    owner: principal,
    name: (string-ascii 64),
    version: (string-ascii 16),
    accuracy: uint,
    verified: bool
  }
)

(define-read-only (get-model (model-id uint))
  (map-get? models model-id)
)

(define-public (register-model (name (string-ascii 64)) (version (string-ascii 16)) (accuracy uint))
  (let ((model-id (var-get next-model-id)))
    (map-set models model-id {
      owner: tx-sender,
      name: name,
      version: version,
      accuracy: accuracy,
      verified: false
    })
    (var-set next-model-id (+ model-id u1))
    (ok model-id)
  )
)

(define-public (verify-model (model-id uint))
  (let ((model (unwrap! (map-get? models model-id) err-not-found)))
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (map-set models model-id (merge model { verified: true }))
    (ok true)
  )
)

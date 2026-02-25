;; Encrypted Storage
;; Store encrypted data on-chain

(define-map storage
  principal
  {
    data-hash: (buff 32),
    encryption-key-hash: (buff 32),
    timestamp: uint,
    size: uint
  }
)

(define-read-only (get-storage (owner principal))
  (map-get? storage owner)
)

(define-public (store-data (data-hash (buff 32)) (encryption-key-hash (buff 32)) (size uint))
  (ok (map-set storage tx-sender {
    data-hash: data-hash,
    encryption-key-hash: encryption-key-hash,
    timestamp: block-height,
    size: size
  }))
)

(define-public (update-data (data-hash (buff 32)) (encryption-key-hash (buff 32)) (size uint))
  (let ((existing (unwrap! (map-get? storage tx-sender) (err u100))))
    (ok (map-set storage tx-sender {
      data-hash: data-hash,
      encryption-key-hash: encryption-key-hash,
      timestamp: block-height,
      size: size
    }))
  )
)

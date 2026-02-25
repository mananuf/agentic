;; Intellectual Property Registry
;; Register and manage IP rights

(define-data-var next-ip-id uint u1)

(define-map ip-rights
  uint
  {
    owner: principal,
    ip-type: (string-ascii 16),
    title: (string-ascii 64),
    content-hash: (buff 32),
    registration-date: uint
  }
)

(define-read-only (get-ip (ip-id uint))
  (map-get? ip-rights ip-id)
)

(define-public (register-ip (ip-type (string-ascii 16)) (title (string-ascii 64)) (content-hash (buff 32)))
  (let ((ip-id (var-get next-ip-id)))
    (map-set ip-rights ip-id {
      owner: tx-sender,
      ip-type: ip-type,
      title: title,
      content-hash: content-hash,
      registration-date: block-height
    })
    (var-set next-ip-id (+ ip-id u1))
    (ok ip-id)
  )
)

(define-public (transfer-ip (ip-id uint) (new-owner principal))
  (let ((ip (unwrap! (map-get? ip-rights ip-id) (err u100))))
    (asserts! (is-eq tx-sender (get owner ip)) (err u101))
    (map-set ip-rights ip-id (merge ip { owner: new-owner }))
    (ok true)
  )
)

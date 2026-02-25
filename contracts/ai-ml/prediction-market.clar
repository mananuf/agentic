;; AI Prediction Market
;; Market for AI predictions and outcomes

(define-constant contract-owner tx-sender)
(define-data-var next-prediction-id uint u1)

(define-map predictions
  uint
  {
    creator: principal,
    question: (string-ascii 128),
    stake: uint,
    resolved: bool,
    outcome: bool
  }
)

(define-read-only (get-prediction (prediction-id uint))
  (map-get? predictions prediction-id)
)

(define-public (create-prediction (question (string-ascii 128)) (stake uint))
  (let ((prediction-id (var-get next-prediction-id)))
    (try! (stx-transfer? stake tx-sender (as-contract tx-sender)))
    (map-set predictions prediction-id {
      creator: tx-sender,
      question: question,
      stake: stake,
      resolved: false,
      outcome: false
    })
    (var-set next-prediction-id (+ prediction-id u1))
    (ok prediction-id)
  )
)

(define-public (resolve-prediction (prediction-id uint) (outcome bool))
  (let ((prediction (unwrap! (map-get? predictions prediction-id) (err u100))))
    (asserts! (is-eq tx-sender contract-owner) (err u101))
    (asserts! (not (get resolved prediction)) (err u102))
    (map-set predictions prediction-id (merge prediction { resolved: true, outcome: outcome }))
    (ok true)
  )
)

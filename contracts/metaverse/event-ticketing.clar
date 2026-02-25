;; Event Ticketing
;; Virtual event tickets and access

(define-data-var next-event-id uint u1)
(define-data-var next-ticket-id uint u1)

(define-map events
  uint
  {
    organizer: principal,
    name: (string-ascii 64),
    capacity: uint,
    sold: uint,
    price: uint
  }
)

(define-map tickets
  uint
  {
    event-id: uint,
    owner: principal,
    used: bool
  }
)

(define-read-only (get-event (event-id uint))
  (map-get? events event-id)
)

(define-public (create-event (name (string-ascii 64)) (capacity uint) (price uint))
  (let ((event-id (var-get next-event-id)))
    (map-set events event-id {
      organizer: tx-sender,
      name: name,
      capacity: capacity,
      sold: u0,
      price: price
    })
    (var-set next-event-id (+ event-id u1))
    (ok event-id)
  )
)

(define-public (buy-ticket (event-id uint))
  (let ((event (unwrap! (map-get? events event-id) (err u100)))
        (ticket-id (var-get next-ticket-id)))
    (asserts! (< (get sold event) (get capacity event)) (err u101))
    (try! (stx-transfer? (get price event) tx-sender (get organizer event)))
    (map-set tickets ticket-id {
      event-id: event-id,
      owner: tx-sender,
      used: false
    })
    (map-set events event-id (merge event { sold: (+ (get sold event) u1) }))
    (var-set next-ticket-id (+ ticket-id u1))
    (ok ticket-id)
  )
)

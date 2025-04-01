;; Farm Registration Contract
;; This contract records details of insured agricultural operations

(define-data-var last-farm-id uint u0)

(define-map farms
  { farm-id: uint }
  {
    owner: principal,
    location: (string-utf8 100),
    crop-type: (string-utf8 50),
    area: uint,
    active: bool
  }
)

(define-public (register-farm (location (string-utf8 100)) (crop-type (string-utf8 50)) (area uint))
  (let
    (
      (new-id (+ (var-get last-farm-id) u1))
    )
    (var-set last-farm-id new-id)
    (map-set farms
      { farm-id: new-id }
      {
        owner: tx-sender,
        location: location,
        crop-type: crop-type,
        area: area,
        active: true
      }
    )
    (ok new-id)
  )
)

(define-public (update-farm (farm-id uint) (crop-type (string-utf8 50)) (area uint))
  (let
    (
      (farm-data (unwrap! (map-get? farms { farm-id: farm-id }) (err u1)))
    )
    ;; Check if caller is the farm owner
    (asserts! (is-eq tx-sender (get owner farm-data)) (err u2))

    (map-set farms
      { farm-id: farm-id }
      (merge farm-data {
        crop-type: crop-type,
        area: area
      })
    )
    (ok true)
  )
)

(define-public (deactivate-farm (farm-id uint))
  (let
    (
      (farm-data (unwrap! (map-get? farms { farm-id: farm-id }) (err u1)))
    )
    ;; Check if caller is the farm owner
    (asserts! (is-eq tx-sender (get owner farm-data)) (err u2))

    (map-set farms
      { farm-id: farm-id }
      (merge farm-data {
        active: false
      })
    )
    (ok true)
  )
)

(define-read-only (get-farm (farm-id uint))
  (map-get? farms { farm-id: farm-id })
)

(define-read-only (is-farm-active (farm-id uint))
  (default-to false (get active (map-get? farms { farm-id: farm-id })))
)


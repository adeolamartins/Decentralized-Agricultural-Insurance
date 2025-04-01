;; Weather Data Oracle Contract
;; This contract provides verified climate information

(define-constant ORACLE_MANAGER tx-sender)

(define-map weather-data-providers
  { provider: principal }
  { authorized: bool }
)

(define-map weather-data
  { location: (string-utf8 100), timestamp: uint }
  {
    temperature: int,
    rainfall: uint,
    humidity: uint,
    wind-speed: uint,
    verified: bool
  }
)

(define-public (register-provider (provider principal))
  (begin
    ;; Only contract creator can register providers
    (asserts! (is-eq tx-sender ORACLE_MANAGER) (err u1))
    (map-set weather-data-providers
      { provider: provider }
      { authorized: true }
    )
    (ok true)
  )
)

(define-public (revoke-provider (provider principal))
  (begin
    ;; Only contract creator can revoke providers
    (asserts! (is-eq tx-sender ORACLE_MANAGER) (err u1))
    (map-set weather-data-providers
      { provider: provider }
      { authorized: false }
    )
    (ok true)
  )
)

(define-public (submit-weather-data
    (location (string-utf8 100))
    (timestamp uint)
    (temperature int)
    (rainfall uint)
    (humidity uint)
    (wind-speed uint))
  (begin
    ;; Check if provider is authorized
    (asserts! (default-to false (get authorized (map-get? weather-data-providers { provider: tx-sender }))) (err u2))

    (map-set weather-data
      { location: location, timestamp: timestamp }
      {
        temperature: temperature,
        rainfall: rainfall,
        humidity: humidity,
        wind-speed: wind-speed,
        verified: true
      }
    )
    (ok true)
  )
)

(define-read-only (get-weather-data (location (string-utf8 100)) (timestamp uint))
  (map-get? weather-data { location: location, timestamp: timestamp })
)

(define-read-only (is-weather-extreme
    (location (string-utf8 100))
    (timestamp uint)
    (rainfall-threshold uint)
    (temp-high-threshold int)
    (temp-low-threshold int)
    (wind-threshold uint))
  (let
    (
      (data (unwrap! (map-get? weather-data { location: location, timestamp: timestamp }) (err u3)))
    )
    (asserts! (get verified data) (err u4))
    (ok (or
      (> (get rainfall data) rainfall-threshold)
      (> (get temperature data) temp-high-threshold)
      (< (get temperature data) temp-low-threshold)
      (> (get wind-speed data) wind-threshold)
    ))
  )
)


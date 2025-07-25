;; CoachChain - Professional coaching session tracking and recognition platform
;; Version: 1.0.0

(define-data-var program-coordinator principal tx-sender)
(define-data-var total-coaching-hours uint u0)
(define-data-var recognition-multiplier uint u25) ;; recognition points per hour
(define-data-var last-recognition-cycle uint u0)

(define-map coach-contributions principal uint)
(define-map coach-disciplines principal (string-utf8 64))
(define-map discipline-approvals (string-utf8 64) bool)

;; Error codes
(define-constant err-unauthorized-coordinator (err u1200))
(define-constant err-coordinator-already-exists (err u1201))
(define-constant err-invalid-hours (err u1202))
(define-constant err-no-recognition-due (err u1203))
(define-constant err-no-contributions (err u1204))
(define-constant err-invalid-discipline (err u1205))
(define-constant err-discipline-not-approved (err u1206))

;; Verify coordinator authorization
(define-private (is-program-coordinator (caller principal))
  (begin
    (asserts! (is-eq caller (var-get program-coordinator)) err-unauthorized-coordinator)
    (ok true)))

;; Initialize coaching tracking program
(define-public (launch-coaching-program (coordinator principal))
  (begin
    (asserts! (is-none (map-get? coach-contributions coordinator)) err-coordinator-already-exists)
    (var-set program-coordinator coordinator)
    (ok "CoachChain program launched successfully")))

;; Approve discipline for coaching tracking
(define-public (approve-discipline (discipline-name (string-utf8 64)))
  (begin
    (try! (is-program-coordinator tx-sender))
    (asserts! (> (len discipline-name) u0) err-invalid-discipline)
    (map-set discipline-approvals discipline-name true)
    (ok "Discipline approved for coaching tracking")))

;; Register coaching hours
(define-public (log-coaching-hours (hours uint) (discipline (string-utf8 64)))
  (begin
    (asserts! (> hours u0) err-invalid-hours)
    (asserts! (default-to false (map-get? discipline-approvals discipline)) err-discipline-not-approved)
    
    (let ((current-hours (default-to u0 (map-get? coach-contributions tx-sender))))
      (map-set coach-contributions tx-sender (+ current-hours hours))
      (map-set coach-disciplines tx-sender discipline)
      (var-set total-coaching-hours (+ (var-get total-coaching-hours) hours))
      (ok (+ current-hours hours)))))

;; Calculate recognition points
(define-public (calculate-recognition-points)
  (begin
    (try! (is-program-coordinator tx-sender))
    (let ((current-cycle (+ (var-get last-recognition-cycle) u1))
          (total-hours (var-get total-coaching-hours)))
      (asserts! (> total-hours (var-get last-recognition-cycle)) err-no-recognition-due)
      
      (let ((new-recognition-points (* (var-get recognition-multiplier) total-hours)))
        (var-set last-recognition-cycle current-cycle)
        (ok new-recognition-points)))))

;; Claim coaching recognition rewards
(define-public (claim-coaching-recognition)
  (begin
    (let ((coach-hours (default-to u0 (map-get? coach-contributions tx-sender))))
      (asserts! (> coach-hours u0) err-no-contributions)
      
      (let ((total-hours (var-get total-coaching-hours))
            (recognition-points (* (var-get recognition-multiplier) coach-hours))
            (contribution-percentage (/ (* coach-hours u100000) total-hours)))
        
        (let ((final-recognition (/ (* contribution-percentage recognition-points) u100000)))
          (map-delete coach-contributions tx-sender)
          (map-delete coach-disciplines tx-sender)
          (var-set total-coaching-hours (- (var-get total-coaching-hours) coach-hours))
          (ok (+ coach-hours final-recognition)))))))

;; Read-only functions
(define-read-only (get-coaching-hours (coach principal))
  (default-to u0 (map-get? coach-contributions coach)))

(define-read-only (get-coach-discipline (coach principal))
  (map-get? coach-disciplines coach))

(define-read-only (get-total-coaching-hours)
  (var-get total-coaching-hours))

(define-read-only (is-discipline-approved (discipline-name (string-utf8 64)))
  (default-to false (map-get? discipline-approvals discipline-name)))

(define-read-only (get-program-stats)
  {
    coordinator: (var-get program-coordinator),
    total-hours: (var-get total-coaching-hours),
    recognition-multiplier: (var-get recognition-multiplier)
  })
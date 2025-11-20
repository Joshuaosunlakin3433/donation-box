;; error constants definition
(define-constant ERR-UNAUTHORIZED (err u401))

;; defining data variable
(define-data-var total-donations-collected uint u0)
(define-data-var contract-owner principal tx-sender)

;; maps
(define-map donor-contributions
    principal
    uint
)

;; public functions
(define-public (donate (amount uint))
    (let (
            (current-amount (default-to u0 (map-get? donor-contributions tx-sender)))
            (updated-amount (+ current-amount amount))
        )
        (begin
            (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
            (map-set donor-contributions tx-sender updated-amount)
            (var-set total-donations-collected
                (+ (var-get total-donations-collected) amount)
            )
            (ok true)
        )
    )
)

;; read-only functions
;; check how much a specific donor has contributed
(define-read-only (get-donor-total (donor principal))
    (default-to u0 (map-get? donor-contributions donor))
)

;; get the overall donation total
(define-read-only (get-total-donations)
    (var-get total-donations-collected)
)

;; check how much STX is in the vault
(define-read-only (get-contract-balance)
    (stx-get-balance (as-contract tx-sender))
)

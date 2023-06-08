;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname miner) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "batch-io.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "batch-io.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
; "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDEkHwEK3GhQj1JHhkGQuuYWV4yBQIqmL4eSCkD8UwUHb0oZQ43n/mdeWBqFB5U52EdHrqq7pAi7AVN+eXkSimv"
(require "requirements/crypto-extras.rkt")
(require "requirements/hashtable-extras.rkt")
(require "requirements/http-extras.rkt")
(require racket/string)

(define MY-SECRET-KEY
  (string-append
   "MIIBOwIBAAJBAMSQfAQrcaFCPUkeGQZC65hZXjIFAiqYvh5IKQPxTBQdvShlDjef+Z15YGoUHlTnYR0euqrukCLsBU355"
   "eRKKa8CAwEAAQJBAKu0CqEZ0girdB2KzRFLI8HRTxciiOHsyyZoomtvPKXUTFxlvsSLDimxEW/a5l6WQaP0a1L/UcZYNgl+"
   "u7sWnwECIQDotUPC3ZUKvSlzu7WqyOr3WMTFYMR65/eyrLawdh+WHQIhANg9GgSdrvs7nIDINtt20qC99N0SvQWbgABXeY/"
   "lJAU7AiEAtX66jL8ZQTjrnZInTD5L1AJt5atlUp6c98Pw8IwQcpkCIFp6ho5z5CmfMcb4/2so9sznbrOqCYl1HUQHVggNmt"
   "rNAiAZrDlFBKo3zs4Kis4mrkLNVcnSmmizwfkkAQsDxRKNxA=="))

(define MY-PUBLIC-KEY (secret->public MY-SECRET-KEY))
;; An [Optional X] is one of:
;; - X
;; - #false
;;
;; Interpretation: Either a value of type X or #false

(define-struct transaction [serial unique-string sender-sig sender-key receiver-key amount])
;; A Transaction is a (make-transaction Nat String Signature PublicKey PublicKey Nat)
;;
;; (make-transaction serial unique-string sender-sig sender-key receiver-key amount) represents a
;; single transaction that moves amount accelcoin from sender-key to receiver-key.
;; Moreover:
;;
;; 1. The amount must be positive;
;; 2. The unique-string must be globally unique;
;; 2. The signature signs the string
;;      (string-append unique-string receiver-key ":" (number->string amount))
;;    with the private key corresponding to sender-key.
;; 3. the unique-string is a string that is unique to this transaction.

(define-struct block [transactions nonce miner-key])
;; A Block is a (make-block [List-of Transaction] Nat PublicKey)
;;
;; (make-block transactions nonce miner-key) represents a block of transactions mined by miner-key.
;; The transactions are processed left-to-right. Thus (first transactions) occurs before
;; (second transactions).

;; A Blockchain is a [NE-List-of Block]
;;
;; The first element of a Blockchain is the latest block and the last element is the first
;; block or the *genesis block*. The genesis block has zero transactions and all other blocks have
;; three or more transactions.

(define ALICE-PRIVATE-KEY
  (string-append "MIIBOgIBAAJBAMrPOfefdvowOwAplxY/NLkJFymyedikvwvsyhtQ98CawNXeKydg+WYD9YzQW1tI"
                 "Y5Ta1bqZhk5hpWGM4eusKxkCAwEAAQJAMtQW2hmsLu3xi4vg4uF6bDl8BaZGZWZ8vxdcW9ZCEZIEt"
                 "nYGlkpwoG5YcUp3a39YRP+Nt2fA6bmPbvjmWAspkQIhAPodYjlh0p7P4QodsvQinMRp9Z8knfBmYe"
                 "Qpg/0otBMVAiEAz5Tjyw0Yanh6CCIvDRKQ+SvdTMvrJykIMyzmsWgYSPUCIEwGvIG2w3/0rnIVvvz"
                 "IvKBTmQ7L4ZpedKkXGYDNa5dVAiAfRL5Lh911rFA1iXCs927/Gaxs"
                 "NQtnCrdBfjIB5zxBQQIhAO0Z"
                 "N+PGdjJfbhivUdgfx+DbrHkClSWT8SidILAbgQkd"))

(define BOB-PRIVATE-KEY
  (string-append "MIIBOwIBAAJBAKy4zO2w1HfXMNHSCYKuheD+5ZkAlHubePYNOVvi3gA/AQ1S0HcRFmTkzFz/SCp+0c"
                 "Z3wErzHhKXmvgIrjLbdYMCAwEAAQJACBwBGyPTRfEnjKJk6erRxFeTZhSd5BPPoRXL3KGRNMesv5qc"
                 "t9QNbHA2ghjY4Z1gokwLgCViG88FvG0qMKGNSQIhANduvtUGGvqeb+c6khwi60sf/3KMa082IjC3fe"
                 "4RosJPAiEAzT8eusKDsL3q38i1o6E4pzUuW4oK0ta1BCGEdZn2kI0CIDb6bz8ECNyOlHZJL0J48t1A"
                 "NDuydCxJ313ZZgzceVHnAiEApVA7vg1B6K9vaIPO2VbXvMW26wAKq7tH3WXpvJcf41kCIQCTv8zWOp"
                 "8Dq3NKTdFZD28NCohpiEOAP3yMng9HhXcAqg=="))
(define CAROL-PRIVATE-KEY (make-secret))
(define DAVID-PRIVATE-KEY (make-secret))
(define ALICE-PUBLIC-KEY (secret->public ALICE-PRIVATE-KEY))
(define BOB-PUBLIC-KEY (secret->public BOB-PRIVATE-KEY))
(define CAROL-PUBLIC-KEY (secret->public CAROL-PRIVATE-KEY))
(define DAVID-PUBLIC-KEY (secret->public DAVID-PRIVATE-KEY))

(define EX-UNIQUE-STRING (unique-string))

;; Sends 100 accelcoins from Alice to Bob
(define EX-TRANSACTION-0
  (make-transaction
   0
   EX-UNIQUE-STRING
   (make-signature (string-append EX-UNIQUE-STRING BOB-PUBLIC-KEY ":" (number->string 100))
                   ALICE-PRIVATE-KEY)
   ALICE-PUBLIC-KEY
   BOB-PUBLIC-KEY
   100))

;; build-transaction: Nat PrivateKey PublicKey Nat -> Transaction
;; (build-transaction serial sender-private-key receiver-public-key amount) builds a transaction
;; that sends amount from the sender to the receiver.

(define (build-transaction serial sender-private-key receiver-public-key amount)
  (local [(define us (unique-string))]
         (make-transaction
          serial
          us
          (make-signature (string-append us receiver-public-key ":" (number->string amount))
                          sender-private-key)
          (secret->public sender-private-key)
          receiver-public-key
          amount)))

(define EX-TRANSACTION-1 (build-transaction 1 BOB-PRIVATE-KEY ALICE-PUBLIC-KEY 50))
(define EX-TRANSACTION-2 (build-transaction 2 BOB-PRIVATE-KEY CAROL-PUBLIC-KEY 30))
(define EX-TRANSACTION-3 (build-transaction 3 DAVID-PRIVATE-KEY BOB-PUBLIC-KEY 100))
(define EX-TRANSACTION-4 (build-transaction 4 CAROL-PRIVATE-KEY ALICE-PUBLIC-KEY 60))

;; transaction->string : Transaction -> String
;; Serializes a transaction into a string with the format
;; "transaction:sender-sig:sender-key:receiver-key,amount"

(define (transaction->string t)
  (string-append (number->string (transaction-serial t))
                 ":"
                 "transaction:"
                 (transaction-unique-string t)
                 ":"
                 (transaction-sender-sig t)
                 ":"
                 (transaction-sender-key t)
                 ":"
                 (transaction-receiver-key t)
                 ","
                 (number->string (transaction-amount t))))

#|
(check-expect (transaction->string EX-TRANSACTION-0)
              (string-append "0:"
                             "transaction:"
                             (transaction-unique-string EX-TRANSACTION-0)
                             ":"
                             (transaction-sender-sig EX-TRANSACTION-0)
                             ":"
                             ALICE-PUBLIC-KEY
                             ":"
                             BOB-PUBLIC-KEY
                             ","
                             "100"))
(check-expect (transaction->string EX-TRANSACTION-1)
              (string-append "1:"
                             "transaction:"
                             (transaction-unique-string EX-TRANSACTION-1)
                             ":"
                             (transaction-sender-sig EX-TRANSACTION-1)
                             ":"
                             BOB-PUBLIC-KEY
                             ":"
                             ALICE-PUBLIC-KEY
                             ","
                             "50"))
(check-expect (transaction->string EX-TRANSACTION-4)
              (string-append "4:"
                             "transaction:"
                             (transaction-unique-string EX-TRANSACTION-4)
                             ":"
                             (transaction-sender-sig EX-TRANSACTION-4)
                             ":"
                             CAROL-PUBLIC-KEY
                             ":"
                             ALICE-PUBLIC-KEY
                             ","
                             "60"))

|#

;; A genesis block where Alice starts the blockchain and receives the first mining reward.
(define EX-BLOCK-0
  (make-block '()
              8631727707325622792404128232286945630015639849891523695238049493932286431978
              ALICE-PUBLIC-KEY))

;; A block with five transactions

(define EX-BLOCK-1
  (make-block
   (list EX-TRANSACTION-0 EX-TRANSACTION-1 EX-TRANSACTION-2 EX-TRANSACTION-3 EX-TRANSACTION-4)
   0
   BOB-PUBLIC-KEY))
(define EX-BLOCK-2
  (make-block
   (list EX-TRANSACTION-4 EX-TRANSACTION-2 EX-TRANSACTION-0 EX-TRANSACTION-3 EX-TRANSACTION-1)
   0
   CAROL-PUBLIC-KEY))

;; block-digest: Digest Block -> Digest
;; (block-digest prev-digest block) computes the digest of block, given the digest
;; of the previous block.
;;
;; The digest must be the digest of the following strings concatenated in order:
;;
;; 1. prev-digest as a string
;; 2. The transactions as strings (using transaction->string) concatenated in order
;; 3. The nonce as a string

(define (block-digest prev-digest block)
  (digest (string-append (number->string prev-digest)
                         (foldr string-append "" (map transaction->string (block-transactions block)))
                         (number->string (block-nonce block)))))

(define DIGEST-0 0)
(define DIGEST-1 (block-digest DIGEST-0 EX-BLOCK-1))
(define DIGEST-2 (block-digest DIGEST-1 EX-BLOCK-2))

#|

(check-expect (block-digest DIGEST-0 EX-BLOCK-2)
              (digest (string-append "0"
                                     (transaction->string EX-TRANSACTION-4)
                                     (transaction->string EX-TRANSACTION-2)
                                     (transaction->string EX-TRANSACTION-0)
                                     (transaction->string EX-TRANSACTION-3)
                                     (transaction->string EX-TRANSACTION-1)
                                     "0")))
(check-expect (block-digest DIGEST-1 EX-BLOCK-2)
              (digest (string-append (number->string DIGEST-1)
                                     (transaction->string EX-TRANSACTION-4)
                                     (transaction->string EX-TRANSACTION-2)
                                     (transaction->string EX-TRANSACTION-0)
                                     (transaction->string EX-TRANSACTION-3)
                                     (transaction->string EX-TRANSACTION-1)
                                     "0")))
(check-expect (block-digest DIGEST-0 EX-BLOCK-1)
              (digest (string-append "0"
                                     (transaction->string EX-TRANSACTION-0)
                                     (transaction->string EX-TRANSACTION-1)
                                     (transaction->string EX-TRANSACTION-2)
                                     (transaction->string EX-TRANSACTION-3)
                                     (transaction->string EX-TRANSACTION-4)
                                     "0")))


|#
;; Copy this definition to your solution
(define DIGEST-LIMIT (expt 2 (* 8 30)))

#|
(check-expect (<= DIGEST-0 DIGEST-LIMIT) #true)
(check-expect (<= DIGEST-1 DIGEST-LIMIT) #false)
(check-expect (<= DIGEST-2 DIGEST-LIMIT) #false)
|#

;; Obviously the genesis block's digest is within the limit, but the other two are not.

;; mine-block : Digest PublicKey [List-of Transaction] Nat -> [Optional Block]
;; (mine-block prev-digest miner-public-key transactions trials)
;; tries to mine a block, but gives up after trials attempts.
;;
;; The produced block has a digest that is less than DIGEST-LIMIT.

(define (mine-block prev-digest miner-public-key transactions trials)
  ;; generate-and-check : Int Block -> [Optional Block]
  ;; attempts to generate a valid block by creating random nonce values
  ;; and testing whether they yield a digest under the limit,
  ;; but gives up after trials attempts
  (local
   [(define (generate-and-check count current)
      (cond
        [(= count 0) #false]
        [else
         (if (<= (block-digest prev-digest current) DIGEST-LIMIT)
             current
             (generate-and-check (- count 1)
                                 (make-block transactions (random 4294967087) miner-public-key)))]))]
   (generate-and-check trials (make-block transactions (random 4294967087) miner-public-key))))

#|
(check-expect (mine-block 0 ALICE-PUBLIC-KEY (list EX-TRANSACTION-0) 100) #false)

(define EX-MINED-BLOCK-1
  (mine-block 0 ALICE-PUBLIC-KEY (list EX-TRANSACTION-0 EX-TRANSACTION-1 EX-TRANSACTION-2) 1000000))
(check-expect (< (block-digest 0 EX-MINED-BLOCK-1) DIGEST-LIMIT) #true)

(define EX-MINED-BLOCK-2
  (mine-block (block-digest 0 EX-MINED-BLOCK-1)
              CAROL-PUBLIC-KEY
              (block-transactions EX-BLOCK-2)
              1000000))
(check-expect (< (block-digest (block-digest 0 EX-MINED-BLOCK-1) EX-MINED-BLOCK-2) DIGEST-LIMIT)
              #true)


;; Example blockchains that we can use for testing
(define EX-BLOCKCHAIN-1 (list EX-BLOCK-1 EX-BLOCK-0))
(define EX-BLOCKCHAIN-2 (list EX-BLOCK-0))
(define EX-BLOCKCHAIN-3 (list EX-MINED-BLOCK-1 EX-BLOCK-0))
(define EX-BLOCKCHAIN-4 (list EX-BLOCK-2 EX-BLOCK-1 EX-BLOCK-0))
|#

;; A Ledger is a [Hash-Table-of PublicKey Nat]
;; A ledger maps wallet IDs (public keys) to the number of accelcoins they have.

(define EX-EMPTY-LEDGER (make-hash '()))
(define EX-LEDGER-1 (make-hash (list (list ALICE-PUBLIC-KEY 100) (list BOB-PUBLIC-KEY 200))))
(define EX-LEDGER-2 (make-hash (list (list ALICE-PUBLIC-KEY 100))))

;; hash-update : [Hash-table-of X Y] X (Y -> Y) Y
;; updates entry using function if present, else default

(define (hash-update h k upd def)
  (hash-set h k (if (hash-has-key? h k) (upd (hash-ref h k)) def)))

(check-expect (hash-update (make-hash (list)) "foo" add1 0) (make-hash (list (list "foo" 0))))
(check-expect (hash-update (make-hash (list (list "foo" 0) (list "bar" 0))) "foo" add1 0)
              (make-hash (list (list "foo" 1) (list "bar" 0))))

;; reward : PublicKey Ledger -> Ledger
;; Grants the miner the reward for mining a block.

(define (reward public-key ledger)
  (hash-update ledger public-key (lambda (x) (+ 100 x)) 100))

(check-expect (reward BOB-PUBLIC-KEY EX-LEDGER-1)
              (make-hash (list (list ALICE-PUBLIC-KEY 100) (list BOB-PUBLIC-KEY 300))))
(check-expect (reward BOB-PUBLIC-KEY EX-LEDGER-2)
              (make-hash (list (list ALICE-PUBLIC-KEY 100) (list BOB-PUBLIC-KEY 100))))
(check-expect (reward ALICE-PUBLIC-KEY EX-EMPTY-LEDGER) EX-LEDGER-2)

;; update-ledger/transaction: Transaction Ledger -> [Optional Ledger]
;; Updates the ledger with a single transaction. Produces #false if
;; the sender does not have enough accelcoin to send.

(define (update-ledger/transaction t l)
  (cond
    [(not (hash-has-key? l (transaction-sender-key t))) #false]
    [(or (> (transaction-amount t) (hash-ref l (transaction-sender-key t)))
         (< (transaction-amount t) 1))
     #false]
    [else
     (hash-update (hash-update l
                               (transaction-sender-key t)
                               (lambda (x) (- x (transaction-amount t)))
                               (hash-ref l (transaction-sender-key t)))
                  (transaction-receiver-key t)
                  (lambda (x) (+ x (transaction-amount t)))
                  (transaction-amount t))]))

#|

(check-expect
 (update-ledger/transaction EX-TRANSACTION-0
                            (make-hash (list (list ALICE-PUBLIC-KEY 300) (list BOB-PUBLIC-KEY 200))))
 (make-hash (list (list ALICE-PUBLIC-KEY 200) (list BOB-PUBLIC-KEY 300))))

(check-expect
 (update-ledger/transaction EX-TRANSACTION-0 (make-hash (list (list BOB-PUBLIC-KEY 2000))))
 #false)
(check-expect
 (update-ledger/transaction EX-TRANSACTION-3 (make-hash (list (list DAVID-PUBLIC-KEY 400))))
 (make-hash (list (list DAVID-PUBLIC-KEY 300) (list BOB-PUBLIC-KEY 100))))

(check-expect (update-ledger/transaction (build-transaction 5 DAVID-PRIVATE-KEY BOB-PRIVATE-KEY 0)
                                         (make-hash (list (list DAVID-PUBLIC-KEY 400))))
              #false)

|#

;; update-ledger/block : Block Ledger -> [Optional Ledger]
;; Updates the ledger with the transactions in a block, and rewards the miner.
(define (update-ledger/block ablock aledger)
  (if (boolean? (foldr (lambda (transaction ledger)
                         (if (boolean? ledger) #false (update-ledger/transaction transaction ledger)))
                       aledger
                       (reverse (block-transactions ablock))))
      #false
      (reward (block-miner-key ablock)
              (foldr (lambda (transaction ledger) (update-ledger/transaction transaction ledger))
                     aledger
                     (reverse (block-transactions ablock))))))

#|
(check-expect (update-ledger/block EX-BLOCK-0 (make-hash (list (list ALICE-PUBLIC-KEY 0))))
              EX-LEDGER-2)

(check-expect (update-ledger/block EX-BLOCK-1 EX-EMPTY-LEDGER) #false)

(check-expect (update-ledger/block EX-BLOCK-0 EX-EMPTY-LEDGER) EX-LEDGER-2)
(check-expect (update-ledger/block EX-BLOCK-1
                                   (make-hash (list (list ALICE-PUBLIC-KEY 200)
                                                    (list BOB-PUBLIC-KEY 300)
                                                    (list CAROL-PUBLIC-KEY 350)
                                                    (list DAVID-PUBLIC-KEY 400))))
              (make-hash (list (list ALICE-PUBLIC-KEY 210)
                               (list BOB-PUBLIC-KEY 520)
                               (list CAROL-PUBLIC-KEY 320)
                               (list DAVID-PUBLIC-KEY 300))))

|#

;; send-transaction: PrivateKey PublicKey Nat -> Boolean
;; (send-transaction sender-private-key receiver-public-key amount) sends a
;; transactions to the Accelchain broadcaster.
(define (send-transaction sender-private-key receiver-public-key amount)
  (post-data "broadcaster.federico.codes"
             "/"
             (create-transaction-str
              (build-transaction 0 sender-private-key receiver-public-key amount))))

;; create-transaction-str : Transaction -> String
;; Creates a string with format "transaction:unique-string:signature:your-public-key:receiver-public-key,amount"
;; given a transaction.

(define (create-transaction-str t)
  (string-append "transaction:"
                 (transaction-unique-string t)
                 ":"
                 (transaction-sender-sig t)
                 ":"
                 (transaction-sender-key t)
                 ":"
                 (transaction-receiver-key t)
                 ","
                 (number->string (transaction-amount t))))

#|

(check-expect (create-transaction-str EX-TRANSACTION-0)
              (string-append "transaction:"
                             (transaction-unique-string EX-TRANSACTION-0)
                             ":"
                             (transaction-sender-sig EX-TRANSACTION-0)
                             ":"
                             ALICE-PUBLIC-KEY
                             ":"
                             BOB-PUBLIC-KEY
                             ","
                             "100"))
(check-expect (create-transaction-str EX-TRANSACTION-1)
              (string-append "transaction:"
                             (transaction-unique-string EX-TRANSACTION-1)
                             ":"
                             (transaction-sender-sig EX-TRANSACTION-1)
                             ":"
                             BOB-PUBLIC-KEY
                             ":"
                             ALICE-PUBLIC-KEY
                             ","
                             "50"))
(check-expect (create-transaction-str EX-TRANSACTION-4)
              (string-append "transaction:"
                             (transaction-unique-string EX-TRANSACTION-4)
                             ":"
                             (transaction-sender-sig EX-TRANSACTION-4)
                             ":"
                             CAROL-PUBLIC-KEY
                             ":"
                             ALICE-PUBLIC-KEY
                             ","
                             "60"))

|#

(define-struct validator-state [ledger pending-transactions received-transactions prev-digest])
;; A ValidatorState is a
;; (make-validator-state Ledger [Hash-Table-of Nat Transaction] [Hash-Table-of String Boolean] Digest)
;;
;; (make-validator-state Ledger [Hash-Table-of Nat Transaction] [Hash-Table-of String Boolean] Digest) represents a
;; single ValidatorState that contains the specified ledger, hash table of pending transactions,
;; hash table of unique strings of pending and existing transactions, and digest of the latest block
;; This way, the ValidatorState can store and update a functional blockchain in real time while
;; validating all transactions and blocks being added without needing to store the blockchain itself.

(define (validator-state-template vs)
  (... (validator-state-ledger vs) ...
       (validator-state-pending-transactions vs) ...
       (validator-state-received-transactions vs) ...
       (validator-state-prev-digest vs) ...))

(define INITIAL-LEDGER
  (make-hash
   (list (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpxhxqx"
                              "gKeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
               100))))

(define INITIAL-VALIDATOR-STATE
  (make-validator-state INITIAL-LEDGER (make-hash '()) (make-hash '()) 0))

(define LEGAL-TRANSACTION-1
  (make-transaction
   1
   "L85uJZ66mPX5UdP/2RKwhrVDy8Chf/Gi6/B5kSaGSTc="
   "EzJeFbFWNfQr9+N+HMAqBJvQP+LokP2l6ZbUGJVxJsQo788hZPQPPobNHUCZnzpC3qhlU3EHGCS46nAOArmX0g=="
   (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpxhxqxgKeneVF4"
                  "eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
   (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQD482hkZnSwjUJrmlSZ75Jshk5Xf4U"
                  "0Y0qQjDlEcEYieKHlu+2bJRviqkoONYwX38mjMO3EPiOpYY72MEUJymV5")
   20))

(define LEGAL-TRANSACTION-2
  (make-transaction
   2
   "eEmCb7QfYFW1WBBQqIC8e5R/e6wINNvB1Hj4njhTSvA="
   "l7SSPqyatoQCDZ5JFgfXnboxeyX924jGie0qMPsRJt/mh3dhpyHsLO9GnNX26v47oc5oHZGUd1S6OXxoRO7o4A=="
   (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpxhxqxgKen"
                  "eVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
   (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQD482hkZnSwjUJrmlSZ75Jshk5Xf4U"
                  "0Y0qQjDlEcEYieKHlu+2bJRviqkoONYwX38mjMO3EPiOpYY72MEUJymV5")
   15))
(define LEGAL-TRANSACTION-3
  (make-transaction
   3
   "pdQJqUZNR4UcOaL9Z8zLTeac4vJCZJRBlUQscIk6qkQ="
   "pH2H4JrbDfUdvzT7m76am1LOAMPeWVDoz/Vk1K14cfCR1CwPMAjNG7d7TdX9nphrlk6KK03gudoY+/2wBibn0Q=="
   (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpxhxqxg"
                  "KeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
   (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQD482hkZnSwjUJrmlSZ75Jshk5Xf4U0Y0"
                  "qQjDlEcEYieKHlu+2bJRviqkoONYwX38mjMO3EPiOpYY72MEUJymV5")
   15))
(define LEGAL-TRANSACTION-4
  (make-transaction
   4
   "jUc72ub/Qw5IJNDxdYVfeebXN7I+nj9t8jgzXZa0Q3s="
   "BY1zexA7Ei/hvtCDSoW/kYE19AXVpT6I3JmWximvltwIDz5o2gltgySmW5FUXOAcvaDs5LUB8ooZAAwd6MwySQ=="
   (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpxhxqxgK"
                  "eneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
   (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDMZy0CtUcgZDnQ1H8FuCiDI8ETWYy1SCGFme"
                  "gA24C39O2utfAH2RS+CD87noWmpK6qhe2pk3LgO1UWGc3uZS7t")
   10))

(define INVALID-SIGNATURE-TRANSACTION
  (make-transaction
   1
   "L85uJZ66mPX5UdP/2RKwhrVDy8Chf/Gi6/B5kSaGSTc="
   "l7SSPqyatoQCDZ5JFgfXnboxeyX924jGie0qMPsRJt/mh3dhpyHsLO9GnNX26v47oc5oHZGUd1S6OXxoRO7o4A=="
   (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpx"
                  "hxqxgKeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
   (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQD482hkZnSwjUJrmlSZ75Jshk5Xf4U0Y0qQjDl"
                  "EcEYieKHlu+2bJRviqkoONYwX38mjMO3EPiOpYY72MEUJymV5")
   20))

(define DUPLICATE-UNIQUE-STR-TRANSACTION
  (make-transaction
   2
   "L85uJZ66mPX5UdP/2RKwhrVDy8Chf/Gi6/B5kSaGSTc="
   "l7SSPqyatoQCDZ5JFgfXnboxeyX924jGie0qMPsRJt/mh3dhpyHsLO9GnNX26v47oc5oHZGUd1S6OXxoRO7o4A=="
   (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRp"
                  "xhxqxgKeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
   (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQD482hkZnSwjUJrmlSZ75Jshk5Xf4"
                  "U0Y0qQjDlEcEYieKHlu+2bJRviqkoONYwX38mjMO3EPiOpYY72MEUJymV5")
   15))

(define VALID-BLOCK-1
  (mine-block 0
              (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIs"
                             "ccHRpxhxqxgKeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
              (list LEGAL-TRANSACTION-1 LEGAL-TRANSACTION-2 LEGAL-TRANSACTION-3)
              1000000))

(define VALID-BLOCK-2
  (mine-block 0
              (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDMZy0CtUcgZDnQ1H8FuCiDI8ETWYy1S"
                             "CGFmegA24C39O2utfAH2RS+CD87noWmpK6qhe2pk3LgO1UWGc3uZS7t")
              (list LEGAL-TRANSACTION-1 LEGAL-TRANSACTION-2 LEGAL-TRANSACTION-3 LEGAL-TRANSACTION-4)
              1000000))

(define INVALID-BLOCK-1
  (mine-block 0
              (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccH"
                             "RpxhxqxgKeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
              (list LEGAL-TRANSACTION-1 LEGAL-TRANSACTION-2)
              1000000))

;; handle-transaction : ValidatorState Transaction -> [Optional ValidatorState]
;; This function receives a ValidatorState and a new transaction. It produces #false if:
;; The transaction signature is invalid; or the transaction is a duplicate (based on unique-string).
;; Otherwise, it produces a new ValidatorState that records the new transaction.
;; However, note that the new transaction is not processed until it appears in a block.

(define (handle-transaction vs t)
  (if (and (check-transaction-signature t)
           (not (hash-has-key? (validator-state-received-transactions vs)
                               (transaction-unique-string t)))
           (not (boolean? (update-ledger/transaction t (validator-state-ledger vs)))))
      (make-validator-state
       (validator-state-ledger vs)
       (hash-set (validator-state-pending-transactions vs) (transaction-serial t) t)
       (hash-set (validator-state-received-transactions vs) (transaction-unique-string t) #true)
       (validator-state-prev-digest vs))
      #false))

(check-expect (handle-transaction INITIAL-VALIDATOR-STATE LEGAL-TRANSACTION-1)
              (make-validator-state
               INITIAL-LEDGER
               (make-hash (list (list (transaction-serial LEGAL-TRANSACTION-1) LEGAL-TRANSACTION-1)))
               (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)))
               0))

(check-expect (handle-transaction
               (make-validator-state
                INITIAL-LEDGER
                (make-hash (list (list (transaction-serial LEGAL-TRANSACTION-1) LEGAL-TRANSACTION-1)))
                (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)))
                0)
               LEGAL-TRANSACTION-2)
              (make-validator-state
               INITIAL-LEDGER
               (make-hash (list (list (transaction-serial LEGAL-TRANSACTION-1) LEGAL-TRANSACTION-1)
                                (list (transaction-serial LEGAL-TRANSACTION-2) LEGAL-TRANSACTION-2)))
               (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)
                                (list (transaction-unique-string LEGAL-TRANSACTION-2) #true)))
               0))

(check-expect (handle-transaction INITIAL-VALIDATOR-STATE INVALID-SIGNATURE-TRANSACTION) #false)
(check-expect (handle-transaction
               (make-validator-state
                INITIAL-LEDGER
                (make-hash (list (list (transaction-serial LEGAL-TRANSACTION-1) transaction-serial)))
                (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)))
                0)
               DUPLICATE-UNIQUE-STR-TRANSACTION)
              #false)
(check-expect (handle-transaction
               (make-validator-state
                INITIAL-LEDGER
                (make-hash (list (list (transaction-serial LEGAL-TRANSACTION-1) LEGAL-TRANSACTION-1)
                                 (list (transaction-serial LEGAL-TRANSACTION-2) LEGAL-TRANSACTION-2)))
                (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)
                                 (list (transaction-unique-string LEGAL-TRANSACTION-2) #true)))
                0)
               LEGAL-TRANSACTION-3)
              (make-validator-state
               INITIAL-LEDGER
               (make-hash (list (list (transaction-serial LEGAL-TRANSACTION-1) LEGAL-TRANSACTION-1)
                                (list (transaction-serial LEGAL-TRANSACTION-2) LEGAL-TRANSACTION-2)
                                (list (transaction-serial LEGAL-TRANSACTION-3) LEGAL-TRANSACTION-3)))
               (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)
                                (list (transaction-unique-string LEGAL-TRANSACTION-2) #true)
                                (list (transaction-unique-string LEGAL-TRANSACTION-3) #true)))
               0))

;; check-transaction-signature : Transaction -> Boolean
;; Returns whether or not a transaction's signature is valid
;; using check-signature with the transaction's attributes as arguments

(define (check-transaction-signature t)
  (check-signature (transaction-sender-key t)
                   (string-append (transaction-unique-string t)
                                  (transaction-receiver-key t)
                                  ":"
                                  (number->string (transaction-amount t)))
                   (transaction-sender-sig t)))

(check-expect (check-transaction-signature EX-TRANSACTION-0) #true)
(check-expect (check-transaction-signature EX-TRANSACTION-1) #true)
(check-expect (check-transaction-signature EX-TRANSACTION-2) #true)
(check-expect (check-transaction-signature
               (make-transaction 5 (unique-string) "ajnfasioje" BOB-PUBLIC-KEY ALICE-PUBLIC-KEY 30))
              #false)

;; handle-block : ValidatorState Block -> [Optional ValidatorState]
;; This function receives a ValidatorState and a new block. It produces #false if:
;; a. The block digest is invalid
;; b. The block has fewer than three transactions
;; c. update-ledger/block produces #false
;; d. If any of the transactions in the block are duplicated or altered.
;; Must receive a transaction on handle-transaction before it appears in handle-block
;; Otherwise, it produces a new ValidatorState that adds the new block to the blockchain.

(define (handle-block vs b)
  (if (and (< (block-digest (validator-state-prev-digest vs) b) DIGEST-LIMIT)
           (>= (length (block-transactions b)) 3)
           (not (boolean? (update-ledger/block b (validator-state-ledger vs))))
           (no-duplicates? (map transaction-serial (block-transactions b)))
           (andmap (lambda (t)
                     (hash-has-key? (validator-state-pending-transactions vs) (transaction-serial t)))
                   (block-transactions b)))
      (make-validator-state (update-ledger/block b (validator-state-ledger vs))
                            (foldr (lambda (t tm) (hash-remove tm (transaction-serial t)))
                                   (validator-state-pending-transactions vs)
                                   (block-transactions b))
                            (validator-state-received-transactions vs)
                            (block-digest (validator-state-prev-digest vs) b))
      #false))

(check-expect
 (handle-block (make-validator-state
                INITIAL-LEDGER
                (make-hash (list (list (transaction-serial LEGAL-TRANSACTION-1) LEGAL-TRANSACTION-1)
                                 (list (transaction-serial LEGAL-TRANSACTION-2) LEGAL-TRANSACTION-2)
                                 (list (transaction-serial LEGAL-TRANSACTION-3) LEGAL-TRANSACTION-3)))
                (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)
                                 (list (transaction-unique-string LEGAL-TRANSACTION-2) #true)
                                 (list (transaction-unique-string LEGAL-TRANSACTION-3) #true)))
                0)
               VALID-BLOCK-1)
 (make-validator-state
  (make-hash
   (list (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpxhxqx"
                              "gKeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
               150)
         (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQD482hkZnSwjUJrmlSZ75Jshk5Xf4U0Y0"
                              "qQjDlEcEYieKHlu+2bJRviqkoONYwX38mjMO3EPiOpYY72MEUJymV5")
               50)))
  (make-hash '())
  (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)
                   (list (transaction-unique-string LEGAL-TRANSACTION-2) #true)
                   (list (transaction-unique-string LEGAL-TRANSACTION-3) #true)))
  (block-digest 0 VALID-BLOCK-1)))

(check-expect
 (handle-block (make-validator-state
                INITIAL-LEDGER
                (make-hash (list (list (transaction-serial LEGAL-TRANSACTION-2) LEGAL-TRANSACTION-2)
                                 (list (transaction-serial LEGAL-TRANSACTION-3) LEGAL-TRANSACTION-3)))
                (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-2) #true)
                                 (list (transaction-unique-string LEGAL-TRANSACTION-3) #true)))
                0)
               VALID-BLOCK-1)
 #false)

(check-expect
 (handle-block (make-validator-state
                INITIAL-LEDGER
                (make-hash (list (list (transaction-serial LEGAL-TRANSACTION-1) LEGAL-TRANSACTION-1)
                                 (list (transaction-serial LEGAL-TRANSACTION-2) LEGAL-TRANSACTION-2)))
                (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)
                                 (list (transaction-unique-string LEGAL-TRANSACTION-2) #true)))
                0)
               INVALID-BLOCK-1)
 #false)

(check-expect
 (handle-block (make-validator-state
                INITIAL-LEDGER
                (make-hash (list (list (transaction-serial LEGAL-TRANSACTION-1) LEGAL-TRANSACTION-1)
                                 (list (transaction-serial LEGAL-TRANSACTION-2) LEGAL-TRANSACTION-2)
                                 (list (transaction-serial LEGAL-TRANSACTION-3) LEGAL-TRANSACTION-3)
                                 (list (transaction-serial LEGAL-TRANSACTION-4) LEGAL-TRANSACTION-4)))
                (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)
                                 (list (transaction-unique-string LEGAL-TRANSACTION-2) #true)
                                 (list (transaction-unique-string LEGAL-TRANSACTION-3) #true)
                                 (list (transaction-unique-string LEGAL-TRANSACTION-4) #true)))
                0)
               VALID-BLOCK-1)
 (make-validator-state
  (make-hash
   (list (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpxhxqx"
                              "gKeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
               150)
         (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQD482hkZnSwjUJrmlSZ75Jshk5Xf4U0Y0"
                              "qQjDlEcEYieKHlu+2bJRviqkoONYwX38mjMO3EPiOpYY72MEUJymV5")
               50)))
  (make-hash (list (list (transaction-serial LEGAL-TRANSACTION-4) LEGAL-TRANSACTION-4)))
  (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)
                   (list (transaction-unique-string LEGAL-TRANSACTION-2) #true)
                   (list (transaction-unique-string LEGAL-TRANSACTION-3) #true)
                   (list (transaction-unique-string LEGAL-TRANSACTION-4) #true)))
  (block-digest 0 VALID-BLOCK-1)))

(check-expect
 (handle-block (make-validator-state
                INITIAL-LEDGER
                (make-hash (list (list (transaction-serial LEGAL-TRANSACTION-1) LEGAL-TRANSACTION-1)
                                 (list (transaction-serial LEGAL-TRANSACTION-2) LEGAL-TRANSACTION-2)
                                 (list (transaction-serial LEGAL-TRANSACTION-3) LEGAL-TRANSACTION-3)
                                 (list (transaction-serial LEGAL-TRANSACTION-4) LEGAL-TRANSACTION-4)))
                (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)
                                 (list (transaction-unique-string LEGAL-TRANSACTION-2) #true)
                                 (list (transaction-unique-string LEGAL-TRANSACTION-3) #true)
                                 (list (transaction-unique-string LEGAL-TRANSACTION-4) #true)))
                0)
               VALID-BLOCK-2)
 (make-validator-state
  (make-hash
   (list (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpxhxqx"
                              "gKeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
               40)
         (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQD482hkZnSwjUJrmlSZ75Jshk5Xf4U0Y0"
                              "qQjDlEcEYieKHlu+2bJRviqkoONYwX38mjMO3EPiOpYY72MEUJymV5")
               50)
         (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDMZy0CtUcgZDnQ1H8FuCiDI8ETWYy"
                              "1SCGFmegA24C39O2utfAH2RS+CD87noWmpK6qhe2pk3LgO1UWGc3uZS7t")
               110)))
  (make-hash '())
  (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)
                   (list (transaction-unique-string LEGAL-TRANSACTION-2) #true)
                   (list (transaction-unique-string LEGAL-TRANSACTION-3) #true)
                   (list (transaction-unique-string LEGAL-TRANSACTION-4) #true)))
  (block-digest 0 VALID-BLOCK-2)))

(check-expect
 (handle-block
  (make-validator-state
   (make-hash
    (list (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpxhxqx"
                               "gKeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
                40)
          (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQD482hkZnSwjUJrmlSZ75Jshk5Xf4U0Y0"
                               "qQjDlEcEYieKHlu+2bJRviqkoONYwX38mjMO3EPiOpYY72MEUJymV5")
                50)
          (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDMZy0CtUcgZDnQ1H8FuCiDI8ETWYy"
                               "1SCGFmegA24C39O2utfAH2RS+CD87noWmpK6qhe2pk3LgO1UWGc3uZS7t")
                110)))
   (make-hash (list (list (transaction-serial LEGAL-TRANSACTION-1) LEGAL-TRANSACTION-1)
                    (list (transaction-serial LEGAL-TRANSACTION-2) LEGAL-TRANSACTION-2)
                    (list (transaction-serial LEGAL-TRANSACTION-3) LEGAL-TRANSACTION-3)))
   (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)
                    (list (transaction-unique-string LEGAL-TRANSACTION-2) #true)
                    (list (transaction-unique-string LEGAL-TRANSACTION-3) #true)))
   (block-digest 0 VALID-BLOCK-2))
  VALID-BLOCK-1)
 #false)

;; no-duplicates? : [List-of Nat] -> Boolean
;; Returns whether or not there are any duplicates in a list of numbers
;; Practical application is to check for duplicate serials in a list of serial numbers

(define (no-duplicates? serial-list)
  (cond
    [(empty? serial-list) #true]
    [(cons? serial-list)
     (if (member? (first serial-list) (rest serial-list))
         #false
         (no-duplicates? (rest serial-list)))]))

(check-expect (no-duplicates? (list 1 2 3 4 5 6)) #true)
(check-expect (no-duplicates? (list 1 2 3 5 6 7 1)) #false)
(check-expect (no-duplicates? (list 1)) #true)

;; show-state-handler : ValidatorState -> String
;; Consumes a validator state and outputs a string with its ledger displayed

(define (show-state-handler vs)
  (foldr string-append
         ""
         (map (lambda (key value) (string-append key "    " (number->string value) "    "))
              (hash-keys (validator-state-ledger vs))
              (hash-values (validator-state-ledger vs)))))

(check-expect (show-state-handler INITIAL-VALIDATOR-STATE)
              (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpxhxqxgKeneV"
                             "F4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF    100    "))
(check-expect
 (show-state-handler
  (make-validator-state
   (make-hash
    (list (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpxhxqx"
                               "gKeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
                40)
          (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQD482hkZnSwjUJrmlSZ75Jshk5Xf4U0Y0"
                               "qQjDlEcEYieKHlu+2bJRviqkoONYwX38mjMO3EPiOpYY72MEUJymV5")
                50)
          (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDMZy0CtUcgZDnQ1H8FuCiDI8ETWYy"
                               "1SCGFmegA24C39O2utfAH2RS+CD87noWmpK6qhe2pk3LgO1UWGc3uZS7t")
                110)))
   (make-hash '())
   (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-1) #true)
                    (list (transaction-unique-string LEGAL-TRANSACTION-2) #true)
                    (list (transaction-unique-string LEGAL-TRANSACTION-3) #true)))
   (block-digest 0 VALID-BLOCK-2)))
 (string-append
  "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDMZy0CtUcgZDnQ1H8FuCiDI8ETWYy1SCGFmegA24C39O2utfAH2RS+"
  "CD87noWmpK6qhe2pk3LgO1UWGc3uZS7t    110    AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrX"
  "YQJbwuCkIyIsccHRpxhxqxgKeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF    40    AA"
  "AAB3NzaC1yc2EAAAADAQABAAAAQQD482hkZnSwjUJrmlSZ75Jshk5Xf4U0Y0qQjDlEcEYieKHlu+2bJRviqkoO"
  "NYwX38mjMO3EPiOpYY72MEUJymV5    50    "))

(check-expect
 (show-state-handler
  (make-validator-state
   (make-hash
    (list (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpxhxqx"
                               "gKeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6N7qKxasVTR/2s1N2OBWF")
                150)
          (list (string-append "AAAAB3NzaC1yc2EAAAADAQABAAAAQQD482hkZnSwjUJrmlSZ75Jshk5Xf4U0Y0"
                               "qQjDlEcEYieKHlu+2bJRviqkoONYwX38mjMO3EPiOpYY72MEUJymV5")
                50)))
   (make-hash '())
   (make-hash (list (list (transaction-unique-string LEGAL-TRANSACTION-4) #true)))
   (block-digest 0 VALID-BLOCK-1)))
 (string-append
  "AAAAB3NzaC1yc2EAAAADAQABAAAAQQDbXz4rfbrRrXYQJbwuCkIyIsccHRpxhxqxgKeneVF4eUXof6e2nLvdXkGA0Y6uBAQ6"
  "N7qKxasVTR/2s1N2OBWF    150    AAAAB3NzaC1yc2EAAAADAQABAAAAQQD482hkZnSwjUJrmlSZ75Jshk5Xf4U0Y0qQ"
  "jDlEcEYieKHlu+2bJRviqkoONYwX38mjMO3EPiOpYY72MEUJymV5    50    "))
(define (go init-state)
  (blockchain-big-bang init-state
                       [on-transaction handle-transaction]
                       [on-block handle-block]
                       [show-state show-state-handler]))

;; block->string : Block -> String
;; Serializes a block into a string with the format.
(define (block->string blk)
  (local [(define transactions (block-transactions blk))
          (define transaction-strings
            (map (lambda (t) (string-replace (transaction->string t) ":" ";")) transactions))
          (define transaction-string (string-join transaction-strings ":"))]
         (format "block:~a:~a:~a" (block-nonce blk) (block-miner-key blk) transaction-string)))

;; mine+validate : ValidatorState PublicKey Number -> Boolean
;;
;; (mine+validate state miner-key retries)
;;
;; Uses mine-block (from Part 1) to mine the pending transactions in
;; the validator state.
;;
;; Produces #false if the retries are exhausted or if the number of pending
;; transactions is less than three.
;;
;; If mining succeeds, sends the serialized block using post-data and produces
;; #true.

(define (mine+validate state miner-key retries)
  ;; post-or-false? : [Optional Block] -> Boolean
  ;; Takes in either a mined block or #false (depending on what mine-block did)
  ;; If given a block, it posts the block and returns true.
  ;; If given #false, it returns #false

  (local
   [(define (post-or-false? result)
      (if (boolean? result) #false (post-data "accelchain.api.breq.dev" "/" (block->string result))))]
   (if (< (length (hash-keys (validator-state-pending-transactions state))) 3)
       #false
       (post-or-false? (mine-block (validator-state-prev-digest state)
                                   miner-key
                                   (hash-values (validator-state-pending-transactions state))
                                   retries)))))

;; go-miner : ValidatorState PublicId Number -> ValidatorState
;;
;; (go-miner state miner-key retries) mines the pending transactions in state
;; uses `go` to validate the current blockchain, and then recurs indefinitely.

(define (go-miner state miner-key retries)
  (local [(define FROM-MINE (mine+validate state miner-key retries))]
         (go-miner (go state) miner-key retries)))

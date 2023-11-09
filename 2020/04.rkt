#lang racket

(define LINES (file->lines "inputs/04.txt"))


(eprintf "Part 1~n")

(define (get-records sl)
  (cond
    [(empty? sl) '()]
    [(not (non-empty-string? (first sl))) (get-records (rest sl))]
    [else (cons
           (string-join (takef sl non-empty-string?) " ")
           (get-records (dropf sl non-empty-string?)))]))

(define (split-field s) (string-split s ":"))

(define (split-fields s) (map split-field (string-split s)))

(define expected-fields (list->set '("byr" "iyr" "eyr" "hgt" "hcl" "ecl" "pid")))

(define (get-key-set h) (list->set (hash-keys h)))

(define (has-all-fields? h) (equal? (set-intersect (get-key-set (make-hash (split-fields h))) expected-fields) expected-fields))

(count has-all-fields? (get-records LINES))


(eprintf "Part 2~n")

(define functions
  (make-hash
   (list
    (cons "byr" (λ (x) (<= 1920 (string->number x) 2002)))
    (cons "iyr" (λ (x) (<= 2010 (string->number x) 2020)))
    (cons "eyr" (λ (x) (<= 2020 (string->number x) 2030)))
    (cons "hgt" (λ (x)
                  (if (string-suffix? x "cm")
                      (<= 150 (string->number (string-trim x #rx"[A-Za-z]+")) 193)
                      (<= 59 (string->number (string-trim x #px"[A-Za-z]+")) 76))))
    (cons "hcl" (λ (x) (regexp-match-exact? #px"^#[0-9a-f]{6}$" x)))
    (cons "ecl" (λ (x) (set-member? (list->set '("amb" "blu" "brn" "gry" "grn" "hzl" "oth")) x)))
    (cons "pid" (λ (x) (regexp-match-exact? #px"^[0-9]{9}$" x)))
    (cons "cid" (λ (x) #t)))))

(define (fields-meet-constraints? record)
  (andmap
   (λ (x) ((hash-ref functions (first x)) (second x)))
   (split-fields record)))

(count
 (λ (x) (and (fields-meet-constraints? x) (has-all-fields? x)))
 (get-records LINES))

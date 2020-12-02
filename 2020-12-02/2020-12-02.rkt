#lang racket

(define LINES (file->lines "2020-12-02.txt"))


(eprintf "Part 1~n")

; Split string and format into correct types
(define (split s)
  (define parts (string-split s #rx"[- :]+"))
  (list
   (string->number (first parts))
   (string->number (second parts))
   (string-ref (third parts) 0)
   (fourth parts)))

; Count occurrences of given letter
(define (valid-num-occurrences? min max char str)
  (<= min (count (λ (x) (equal? x char)) (string->list str)) max))

(count
 (λ (x) x)
 (map (λ (x) (apply valid-num-occurrences? (split x))) LINES))


(eprintf "Part 2~n")

(define (is-valid? p1 p2 char string)
  (xor
    (equal? char (string-ref string (sub1 p1)))
    (equal? char (string-ref string (sub1 p2)))))

(count
 (λ (x) x)
 (map (λ (x) (apply is-valid? (split x))) LINES))

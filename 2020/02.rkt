#lang racket

(define LINES (file->lines "inputs/02.txt"))

; Split string and convert to correct types
(define (split str)
  (define parts (string-split str #rx"[- :]+"))
  (list
   (string->number (first parts))
   (string->number (second parts))
   (string-ref (third parts) 0)
   (fourth parts)))


(eprintf "Part 1~n")

; Are the occurrences of the given letter, in the given range?
(define (is-valid-1? min max char str)
  (<= min (count (λ (x) (equal? x char)) (string->list str)) max))

(count identity (map (λ (x) (apply is-valid-1? (split x))) LINES))


(eprintf "Part 2~n")

; Does only one of the first and second position contain the given character?
(define (is-valid-2? p1 p2 char string)
  (xor
    (equal? char (string-ref string (sub1 p1)))
    (equal? char (string-ref string (sub1 p2)))))

(count identity (map (λ (x) (apply is-valid-2? (split x))) LINES))

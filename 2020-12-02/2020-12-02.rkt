#lang racket

(define LINES (file->lines "2020-12-02.txt"))


(eprintf "Part 1~n")

; Split string and convert to correct types
(define (split s)
  (define parts (string-split s #rx"[- :]+"))
  (list
   (string->number (first parts))
   (string->number (second parts))
   (string-ref (third parts) 0)
   (fourth parts)))

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

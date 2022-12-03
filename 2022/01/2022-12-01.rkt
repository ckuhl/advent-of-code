#lang racket

(define INPUT (file->lines "2022-12-01.txt"))

; Input is a list of strings, with sublists separated by 
(define (take-first-sublist lst)
  (cond
    [(empty? lst) empty]
    [(equal? (first lst) "") empty]
    [else (cons (string->number (first lst)) (take-first-sublist (rest lst)))]))

(define (skip-first-sublist lst)
  (cond
    [(empty? lst) empty]
    [(equal? (first lst) "") (rest lst)]
    [else (skip-first-sublist (rest lst))]))

(define (sublist-ify lst)
  (if
   (empty? lst) empty
  (cons
   (take-first-sublist lst)
   (sublist-ify (skip-first-sublist lst)))))

(define SUBLISTS (sublist-ify INPUT))

(define CALORIES (map (lambda (x) (apply + x)) SUBLISTS))

(printf "Part 1~n")


(apply max CALORIES)


(printf "Part 2~n")

(apply + (take (sort CALORIES >) 3))

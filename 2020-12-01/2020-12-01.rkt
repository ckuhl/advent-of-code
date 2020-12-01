#lang racket

(define TARGET 2020)
(define NUMBERS (file->list "2020-12-01.txt"))

(printf "Part 1~n")
(apply
 *
 (set->list
  (set-intersect
   (list->set NUMBERS)
   (list->set (map (λ (x) (- TARGET x)) NUMBERS)))))

(printf "Part 2~n")
(define duals (list->set (map (λ (x) (- TARGET x)) NUMBERS)))
(define found-tuples
   (filter
    (lambda (x) (set-member? duals (apply + x)))
    (combinations NUMBERS 2)))

; Print out the solution
(*
 (caar found-tuples)
 (cadar found-tuples)
 (- TARGET (caar found-tuples) (cadar found-tuples)))

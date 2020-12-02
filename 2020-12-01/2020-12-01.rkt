#lang racket

(define TARGET 2020)
(define NUMBERS (file->list "2020-12-01.txt"))

; The complement that each number will need to sum to TARGET
(define DUALS (list->set (map (λ (x) (- TARGET x)) NUMBERS)))


(eprintf "Part 1~n")

(apply * (set->list (set-intersect (list->set NUMBERS) DUALS)))


(eprintf "Part 2~n")

(define found-tuples
  (filter
   (λ (x) (set-member? DUALS (apply + x)))
   (combinations NUMBERS 2)))

; Calculate the third digit of the first tuple, and mupltiply all together
(*
 (caar found-tuples)
 (cadar found-tuples)
 (- TARGET (caar found-tuples) (cadar found-tuples)))

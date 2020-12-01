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
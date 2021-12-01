#lang racket

(define NUMBERS (file->list "2021-12-01.txt"))

(define (count-sequential-increases lst)
  (count
   positive?
   (map - (append (rest lst) (list 0)) lst)))

(printf "Part 1~n")
(count-sequential-increases NUMBERS)


(printf "Part 2~n")
(count-sequential-increases
 (map
   +
   (append (list-tail NUMBERS 0) (build-list 0 (lambda (x) 0)))
   (append (list-tail NUMBERS 1) (build-list 1 (lambda (x) 0)))
   (append (list-tail NUMBERS 2) (build-list 2 (lambda (x) 0)))))

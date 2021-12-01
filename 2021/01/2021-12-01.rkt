#lang racket

(define NUMBERS (file->list "2021-12-01.txt"))

(printf "Part 1~n")

(count
 positive?
 (map
  -
  (append (rest NUMBERS) (list 0))
  NUMBERS))

(printf "Part 2~n")
(define three-window
  (map
   +
   NUMBERS
   (append (rest NUMBERS) (list 0))
   (append (rest (rest NUMBERS)) (list 0 0))))

(count
 positive?
 (map - (append (rest three-window) (list 0)) three-window))
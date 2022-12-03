#lang racket

(require rackunit)

(define TEST-INPUT (file->lines "2022-12-04-example.txt"))
(define INPUT (file->lines "2022-12-04.txt"))

; ==============================================================================
(printf "Part 1~n")


(define (solve-part-1 x)
  ...)

(test-equal? "Example input should be correct" (solve-part-1 TEST-INPUT) ...)
(solve-part-1 INPUT)

; ==============================================================================
(printf "Part 2~n")

(define (solve-part-2 x)
  ...)

(test-equal? "Example input should be correct" (solve-part-2 TEST-INPUT) ...)
(solve-part-2 INPUT)

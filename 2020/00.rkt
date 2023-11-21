#lang racket

(require rackunit)

(define LINES (file->lines "inputs/00.txt"))
(define EXAMPLE1 (file->lines "inputs/00-example1.txt"))


; =============================================================================
(eprintf "Part 1~n")


(define (solve-part-1 problem-input) -1)

(test-equal? "Part 1 example 1 should be correct" (solve-part-1 EXAMPLE1) 1)
(test-equal? "Part 1 solution should be correct" (solve-part-1 LINES) 1)


; =============================================================================
(eprintf "Part 2~n")

(define (solve-part-2 problem-input) -1)

(test-equal? "Part 2 example 1 should be correct" (solve-part-2 EXAMPLE1) 1)
(test-equal? "Part 2 solution should be correct" (solve-part-2 LINES) 1)

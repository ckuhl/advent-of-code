#lang racket

(require rackunit)

(define LINES (file->lines "inputs/18.txt"))
(define EXAMPLE1 '("1 + 2 * 3 + 4 * 5 + 6"))
(define EXAMPLE2 '("1 + (2 * 3) + (4 * (5 + 6))"))
(define EXAMPLE3 '("2 * 3 + (4 * 5)"))
(define EXAMPLE4 '("5 + (8 * 3 + 9 + 3 * 4 * 3)"))
(define EXAMPLE5 '("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"))
(define EXAMPLE6 '("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"))


; =============================================================================
(eprintf "Part 1~n")

; Hmm... we could definitely do some clever "read in and parse" sort of thinking
; At the same time, that sounds like a lot of work. Let's just do a simple parser
(define l (string->list (first EXAMPLE2)))
l

(define (solve-part-1 problem-input) -1)

;(test-equal? "Part 1 example 1 should be correct" (solve-part-1 EXAMPLE1) 71)
;(test-equal? "Part 1 example 2 should be correct" (solve-part-1 EXAMPLE2) 51)
;(test-equal? "Part 1 example 3 should be correct" (solve-part-1 EXAMPLE3) 26)
;(test-equal? "Part 1 example 4 should be correct" (solve-part-1 EXAMPLE4) 437)
;(test-equal? "Part 1 example 5 should be correct" (solve-part-1 EXAMPLE5) 12240)
;(test-equal? "Part 1 example 6 should be correct" (solve-part-1 EXAMPLE6) 13632)
;(test-equal? "Part 1 solution should be correct" (solve-part-1 LINES) 1)


; =============================================================================
(eprintf "Part 2~n")

(define (solve-part-2 problem-input) -1)

;(test-equal? "Part 2 example 1 should be correct" (solve-part-2 EXAMPLE1) 1)
;(test-equal? "Part 2 solution should be correct" (solve-part-2 LINES) 1)

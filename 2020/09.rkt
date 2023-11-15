#lang racket

(require rackunit)

(define LINES (file->list "inputs/09.txt"))
(define EXAMPLE1 (file->list "inputs/09-example1.txt"))

(define (in-past-multiples? lst last-n index)
  (if (<= index last-n) #t
      (let* ([idx (list-ref lst index)]
             [lookback (take (drop lst (- index last-n 1)) (add1 last-n))]
             [multiples (map (lambda (x) (apply + x)) (combinations lookback 2))])
        (if (member idx multiples) #t #f))))

; =============================================================================
(eprintf "Part 1~n")

(define (solve-part-1 problem-input [lookback 25])
  (for/first ([idx (in-naturals)]
              #:when (not (in-past-multiples? problem-input lookback idx)))
    (list-ref problem-input idx)))


; Is it efficient? Ehh... Does it look nice? IMO yes :)
(test-equal? "Example 1 input should be correct" (solve-part-1 EXAMPLE1 5) 127)
(test-equal? "Part 1 solution should be correct" (solve-part-1 LINES) 85848519)


; =============================================================================
(eprintf "Part 2~n")

; Initially it is tempting to imagine running this with two list references,
; left and right, however this has a flaw regarding how we "shrink" a range
; So instead we will think about the left bound and the _width_ and reset
; the width to one when we go over.
(define (chase-range lst target [left 0] [width 1])
  (let* ([subrange (take (drop lst left) width)]
         [range-value (apply + subrange)])
    (cond
      [(> range-value target) (chase-range lst target (add1 left))]
      [(< range-value target) (chase-range lst target left (add1 width))]
      [else subrange])))

(define (solve-part-2 problem-input target-value)
  (let ([subrange (chase-range problem-input target-value)])
    (+ (apply min subrange) (apply max subrange))))

(test-equal? "Part 2 example should be correct" (solve-part-2 EXAMPLE1 (solve-part-1 EXAMPLE1 5)) 62)
(test-equal? "Part 2 solution should be correct" (solve-part-2 LINES (solve-part-1 LINES)) 13414198)

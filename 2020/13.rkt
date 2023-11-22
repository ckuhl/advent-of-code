#lang racket

(require rackunit)

(define LINES (file->lines "inputs/13.txt"))
(define EXAMPLE1 (file->lines "inputs/13-example1.txt"))

(define (waiting-time problem-input)
  (string->number (first problem-input)))

(define (in-service-buses problem-input)
  (map string->number (filter (lambda (x) (not (string=? "x" x))) (string-split (second problem-input) ","))))

(define (next-bus-after-time after route)
  (- (* route (ceiling (/ after route))) after))


; =============================================================================
(eprintf "Part 1~n")

(define (solve-part-1 problem-input)
  (let* ([after-time (waiting-time problem-input)]
         [route-list (in-service-buses problem-input)]
         [wait-list (map (lambda (x) (list x (next-bus-after-time after-time x))) route-list)]
         [shortest-wait (first (sort wait-list (lambda (x y) (< (second x) (second y)))))])
    (apply * shortest-wait)))

(test-equal? "Part 1 example 1 should be correct" (solve-part-1 EXAMPLE1) 295)
(test-equal? "Part 1 solution should be correct" (solve-part-1 LINES) 104)


; =============================================================================
(eprintf "Part 2~n")

; Observe: All bus routes are prime numbers. This means that the first recurrence is somewhere near the LCM.
; Further observe: We are looking for values a, b, c, etc. such that a*x_0 + 2 = b*x_1 + 1 = c*x_2
; Through the power of search engines and university flashbacks, we're working with... The Chinese Remainder Theorem
; https://en.wikipedia.org/wiki/Chinese_remainder_theorem
; FIXME: Maybe? I started implementing it, then realized Racket provides it.

(define (buses-by-offset str)
  (filter
   identity
   (for/list ([i (in-naturals)]
              [item (reverse (string-split str ","))])
     (let ([maybe-number (string->number item)])
       (if maybe-number (cons maybe-number i) #f)))))

; This feels like cheating...
(require math/number-theory)

(define (solve-part-2 problem-input)
  (let* ([bus-list (buses-by-offset (second problem-input))]
         [as (map cdr bus-list)]
         [ns (map car bus-list)]
         [first-bus-offset (apply max as)])
    (- (solve-chinese as ns) first-bus-offset)))

(test-equal? "Part 2 example 1 should be correct" (solve-part-2 EXAMPLE1) 1068781)
(test-equal? "Part 2 example 2 should be correct" (solve-part-2 (list "" "17,x,13,19")) 3417)
(test-equal? "Part 2 example 3 should be correct" (solve-part-2 (list "" "67,7,59,61")) 754018)
(test-equal? "Part 2 example 4 should be correct" (solve-part-2 (list "" "67,x,7,59,61")) 779210)
(test-equal? "Part 2 example 5 should be correct" (solve-part-2 (list "" "67,7,x,59,61")) 1261476)
(test-equal? "Part 2 example 6 should be correct" (solve-part-2 (list "" "1789,37,47,1889")) 1202161486)
(test-equal? "Part 2 solution should be correct" (solve-part-2 LINES) 842186186521918)

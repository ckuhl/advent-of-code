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


(define (parse lst [op +] [acc 0])
  (if (empty? lst) acc
      (match (first lst)
        [#\* (parse (rest lst) * acc)]
        [#\+ (parse (rest lst) + acc)]
        [#\( (let* ([endpoint (recurse lst)]
                    [subexpr (take (rest lst) (sub1 endpoint))])
               (parse (drop lst (add1 endpoint)) op (op acc (parse subexpr))))]
        [N (parse (rest lst) op (op acc (- (char->integer N) (char->integer #\0))))])))

(define (recurse lst [depth 0] [length 0])
  (cond
    [(equal? (first lst) #\() (recurse (rest lst) (add1 depth) (add1 length))]
    [(and (equal? (first lst) #\))
          (equal? depth 1)) length]
    [(equal? (first lst) #\)) (recurse (rest lst) (sub1 depth) (add1 length))]
    [else (recurse (rest lst) depth (add1 length))]))

(define (solve-equation-string s)
  (parse (string->list (string-replace s " " ""))))


(define (solve-part-1 problem-input)
  (apply + (map solve-equation-string problem-input)))

(test-equal? "Part 1 example 1 should be correct" (solve-part-1 EXAMPLE1) 71)
(test-equal? "Part 1 example 2 should be correct" (solve-part-1 EXAMPLE2) 51)
(test-equal? "Part 1 example 3 should be correct" (solve-part-1 EXAMPLE3) 26)
(test-equal? "Part 1 example 4 should be correct" (solve-part-1 EXAMPLE4) 437)
(test-equal? "Part 1 example 5 should be correct" (solve-part-1 EXAMPLE5) 12240)
(test-equal? "Part 1 example 6 should be correct" (solve-part-1 EXAMPLE6) 13632)
(test-equal? "Part 1 solution should be correct" (solve-part-1 LINES) 654686398176)


; =============================================================================
(eprintf "Part 2~n")

; TODO: Now it is time to learn: https://en.wikipedia.org/wiki/Shunting_yard_algorithm


(evaluate (solve-equation-string2 (first EXAMPLE1)))

(define (solve-part-2 problem-input) -1)

;(test-equal? "Part 2 example 1 should be correct" (solve-part-2 EXAMPLE1) 231)
;(test-equal? "Part 2 example 2 should be correct" (solve-part-2 EXAMPLE2) 51)
;(test-equal? "Part 2 example 3 should be correct" (solve-part-2 EXAMPLE3) 46)
;(test-equal? "Part 2 example 4 should be correct" (solve-part-2 EXAMPLE4) 1445)
;(test-equal? "Part 2 example 5 should be correct" (solve-part-2 EXAMPLE5) 669060)
;(test-equal? "Part 2 example 6 should be correct" (solve-part-2 EXAMPLE6) 23340)
;(test-equal? "Part 2 solution should be correct" (solve-part-2 LINES) -1)

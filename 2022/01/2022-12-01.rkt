#lang racket

(require rackunit)

(define TEST-INPUT (file->lines "2022-12-01-example.txt"))
(define INPUT (file->lines "2022-12-01.txt"))

; ==============================================================================
; Input is a list of strings, with sublists separated by a blank line
(define (take-first-sublist lst)
  (cond
    [(empty? lst) empty]
    [(equal? (first lst) "") empty]
    [else (cons (string->number (first lst)) (take-first-sublist (rest lst)))]))

; To iterate through the list, we want to:
; 1. Take the first sublist
; 2. Skip the first sublist, and do the above
(define (skip-first-sublist lst)
  (cond
    [(empty? lst) empty]
    [(equal? (first lst) "") (rest lst)]
    [else (skip-first-sublist (rest lst))]))

; Apply the above two functions, repeatedly
(define (sublist-ify lst)
  (if
   (empty? lst) empty
   (cons
    (take-first-sublist lst)
    (sublist-ify (skip-first-sublist lst)))))

; ==============================================================================
(printf "Part 1~n")
(define (solve-part-1 x)
  (define SUBLISTS (sublist-ify x))
  (define CALORIES (map (lambda (x) (apply + x)) SUBLISTS))
  (apply max CALORIES))

(test-equal? "Test input should be correct" (solve-part-1 TEST-INPUT) 24000)
(solve-part-1 INPUT)


; ==============================================================================
(printf "Part 2~n")
(define (solve-part-2 x)
  (define SUBLISTS (sublist-ify x))
  (define CALORIES (map (lambda (x) (apply + x)) SUBLISTS))
  (apply + (take (sort CALORIES >) 3)))


(test-equal? "Test input should be correct" (solve-part-2 TEST-INPUT) 45000)
(solve-part-2 INPUT)
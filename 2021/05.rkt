#lang racket

(define LINES (file->lines "input/05.txt"))

; Helper: Convert a string of the form "1,2 -> 3,4" to a list of the form
;  (list (list 1 2) (list 3 4))
(define (line->pairs str)
  (map (lambda (x) (map string->number (string-split x ","))) (string-split str " -> ")))

; Convert all input lines into a consumable format
(define LINE-SEGMENTS (map line->pairs LINES))

; Given a line segment (a list of two points), compute all points between the two.
;  Assumption: All lines are horizontal, vertical, or a 45 degree angle
(define (segment->points lst)
  (define x0 (first (first lst)))
  (define y0 (second (first lst)))
  (define x1 (first (second lst)))
  (define y1 (second (second lst)))
  (cond
    [(= x0 x1) (map (lambda (z) (cons x0 z)) (inclusive-range y0 y1 (if (> y0 y1) -1 1)))]
    [(= y0 y1) (map (lambda (z) (cons z y0)) (inclusive-range x0 x1 (if (> x0 x1) -1 1)))]
    [else
     (map
      cons
      (inclusive-range x0 x1 (if (> x0 x1) -1 1))
      (inclusive-range y0 y1 (if (> y0 y1) -1 1)))]))

; Helper: Determine if a list of two points are in a horizontal line.
(define (is-horizontal? lst)
  (define x0 (first (first lst)))
  (define x1 (first (second lst)))
  (= x0 x1))

; Helper: Determine if a list of two points are in a vertical line.
(define (is-vertical? lst)
  (define y0 (second (first lst)))
  (define y1 (second (second lst)))
  (= y0 y1))

; Helper: Determine if a list of two points are in a horizonal or vertical line.
(define (is-either? lst)
  (or
   (is-vertical? lst)
   (is-horizontal? lst)))

(define STRAIGHT-SEGMENTS (filter is-either? LINE-SEGMENTS))

; Given a list of items, insert each into the hash as a key, with the value
;  being the number of times it has been counted.
(define (list->counted-hash lst)
  (foldr
   (lambda (x acc) (hash-update acc x add1 0))
   (hash)
   lst))

; Given a counting hash (i.e. k = any, v = number), return the number of items
;  that occur more than once.
(define (non-unique-count h)
  (length (filter (lambda (x) (> x 1)) (hash-values h))))

; ==============================================================================
(printf "Part 1~n")

(define straight-points (apply append (map segment->points STRAIGHT-SEGMENTS)))
(define straight-occurrences (list->counted-hash straight-points))
(non-unique-count straight-occurrences)


; ==============================================================================
(printf "Part 2~n")

(define all-points (apply append (map segment->points LINE-SEGMENTS)))
(define all-occurrences (list->counted-hash all-points))
(non-unique-count all-occurrences)

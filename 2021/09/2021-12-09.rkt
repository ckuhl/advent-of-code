#lang racket

(define LINES (file->lines "2021-12-09.txt"))

(define EXAMPLE
  (list
   "2199943210"
   "3987894921"
   "9856789892"
   "8767896789"
   "9899965678"))

; Convert an integer character (i.e. #\0 to #\9) to it's numberic value
(define (char->number c)
  (- (char->integer c) 48))

; Get the value at the location of a point, or return 10 otherwise, as 10 is
;  larger than all possible values, and so functions as a sentinel value.
(define (get-location lst x y)
  (cond
    [(or
      (> (add1 y) (length lst))
      (> 0 y))
     10]
    [(or
      (> (add1 x) (string-length (list-ref lst y)))
      (> 0 x))
     10]
    [else (char->number (string-ref (list-ref lst y) x))]))

; Get all neighbours of a point
(define (get-neighbours lst x y)
  (list
   (get-location lst (add1 x) y)
   (get-location lst (sub1 x) y)
   (get-location lst x (add1 y))
   (get-location lst x (sub1 y))))

; Return if the point is lower than all neighbouring points
(define (is-low-point? lst x y)
  (define point (get-location lst x y))
  (for/and ([n (get-neighbours lst x y)])
    (< point n)))

; Create a list of (list x y) where (x, y) forms a valid point
(define (grid-points x-size y-size)
  (cartesian-product
   (sequence->list (in-range x-size))
   (sequence->list (in-range y-size))))

; ==============================================================================
(printf "Part 1~n")

; Helper: Sum the value of all low points + 1 in a given "cave map"
(define (sum-low-points lst)
  (apply
   +
   (map
    (lambda (p)
      (define x (first p))
      (define y (second p))
      (if (is-low-point? lst x y)
          (add1 (get-location lst x y))
          0))
    (grid-points (string-length (first lst)) (length lst)))))

(sum-low-points LINES)

; ==============================================================================
(printf "Part 2~n")

; Gosh this looks like a lot of work...

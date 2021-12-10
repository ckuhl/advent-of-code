#lang racket

(define LINES (file->lines "2021-12-09.txt"))

(define EXAMPLE
  (list
   "2199943210"
   "3987894921"
   "9856789892"
   "8767896789"
   "9899965678"))


(define (char->number c)
  (- (char->integer c) 48))

(define (is-valid? x y)
  (define max-x (string-length (first LINES)))
  (define max-y (length LINES))

  (and
   (<= 0 x)
   (>= max-x x)
   (<= 0 y)
   (>= max-y y)))

(define (get-location x y)
  (string-ref (list-ref EXAMPLE y) x))

(define (get-adjacent-values x y)
  (filter
   (lambda (x) (not (empty? x)))
   (list
    (if (is-valid? (add1 x) (add1 y)) (get-location  (add1 x) (add1 y)) '())
    (if (is-valid? (sub1 x) (add1 y)) (get-location  (sub1 x) (add1 y)) '())
    (if (is-valid? (add1 x) (sub1 y)) (get-location  (add1 x) (sub1 y)) '())
    (if (is-valid? (sub1 x) (sub1 y)) (get-location  (sub1 x) (sub1 y)) '()))))

(define (low-point? x y)
  (define loc (get-location x y))
  (define v (get-adjacent-values x y))
  (printf "~v~n" v)
  (for/and
      ([i v])
    (< (char->number loc) (char->number i))))

(low-point? 4 )

; ==============================================================================
(printf "Part 1~n")


; ==============================================================================
(printf "Part 2~n")

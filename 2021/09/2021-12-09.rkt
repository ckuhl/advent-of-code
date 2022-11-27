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

; Get the indices of the neighbouring points
(define (get-neighbouring-points x y)
  (list
   (list (add1 x) y)
   (list (sub1 x) y)
   (list x (add1 y))
   (list x (sub1 y))))

; Get all neighbours of a point
(define (get-neighbours lst x y)
  (list
   (get-location lst (add1 x) y)
   (get-location lst (sub1 x) y)
   (get-location lst x (add1 y))
   (get-location lst x (sub1 y))))

; Return if the point is lower than all neighbouring points
(define (is-low-point? heightmap x y)
  (define point (get-location heightmap x y))
  (for/and ([n (get-neighbours heightmap x y)])
    (< point n)))

; Create a list of (list x y) where (x, y) forms a valid point
(define (grid-points x-size y-size)
  (cartesian-product
   (sequence->list (in-range x-size))
   (sequence->list (in-range y-size))))

; ==============================================================================
(printf "Part 1~n")

(define (get-low-points heightmap)
  (filter
   (lambda (p)
     (define x (first p))
     (define y (second p))
     (is-low-point? heightmap x y))
   (grid-points (string-length (first heightmap)) (length heightmap))))

; Helper: Sum the value of all low points + 1 in a given "cave map"
(define (sum-low-points heightmap)
  (apply
   +
   (map
    (lambda (p)
      (define x (first p))
      (define y (second p))
      (if (is-low-point? heightmap x y)
          (add1 (get-location heightmap x y))
          0))
    (grid-points (string-length (first heightmap)) (length heightmap)))))

(sum-low-points LINES)

; ==============================================================================
(printf "Part 2~n")

; Basin discovery algorithm:
; 1. Select a point
; 2. If the point < 9, this is in a basin.
;    a. Given a set of points in a basin, select all neighbours of those points
;    b. Those neighbours form the frontier. Remove all points that are 9.
;    c. If the frontier is empty, you've exhausted the basin.

(define points (grid-points (string-length (first EXAMPLE)) (length EXAMPLE)))

; Remove invalid points from a list of points
;  i.e. those outside of the given range
(define (remove-invalid heightmap max-x max-y)
  (filter
   (lambda (p)
     (cond
       [(< (first p) 0) #f]
       [(< (second p) 0) #f]
       [(>= (first p) max-x) #f]
       [(>= (second p) max-y) #f]
       [else #t]))
   heightmap))

; Given a list of all points, and a set of points already in the group.
(define (frontier heightmap st in-set)
  (define all-neighbours
    (list->set
     (apply
      append
      (map
       (lambda (x) (remove-invalid (get-neighbouring-points (first x) (second x)) (string-length (first heightmap)) (length heightmap)))
       (set->list in-set)))))
  (set-subtract all-neighbours in-set))


(define (remove-maxima heightmap pts)
  (list->set
   (filter
    (lambda (p) (not (= 9 (get-location heightmap (first p) (second p)))))
    (set->list pts))))

; Starting from a single point, return the basin around it
(define (find-basin heightmap points acc)
  (define front (remove-maxima EXAMPLE (frontier heightmap points acc)))
  
  (if (set-empty? front) acc (find-basin heightmap points (set-union acc front))))


; Return a basin given an input point to start growing it around.
;  If the initial point is high point, return an empty set.
(define (get-basin heightmap pts pt)
  (if (= 9 (get-location heightmap (first pt) (second pt)))
      (set)
      (find-basin heightmap pts (list->set (list pt)))))

; FIXME: This doesn't handle the case of multiple low points within one basin
; TO fix that, we will need to remove all points in each basin from the list of low points
(define (get-all-basins heightmap)
  (map (lambda (x) (get-basin heightmap points x))
       (get-low-points heightmap)))

; Algorithm for calculating answer to part two:
;  Multiply together the size of the largest three basins
(define (multiply-top3-basin-sizes heightmap)
  (apply
   *
   (map
    (lambda (x) (length (set->list x)))
    (take
     (sort
      (get-all-basins heightmap)
      (lambda (x y) (> (length (set->list x)) (length (set->list y)))))
     3))))

(get-all-basins LINES)

(multiply-top3-basin-sizes LINES)

#lang racket

(require rackunit)

(define LINES (file->lines "input/09.txt"))

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

(check-equal? (sum-low-points EXAMPLE) 15)
(check-equal? (sum-low-points LINES) 518)

; ==============================================================================
(printf "Part 2~n")

; Shortcut: We don't care about height _unless_ it's a basin wall, in which case
; we exclude it. So we can filter here and operate on a set of just points,
; simplifying the problem we deal with
; (list str) -> (set (number . number))
(define (input->point-set input)
  (for*/set ([x (in-range (string-length (first input)))]
             [y (in-range (length input))]
             #:unless (equal? (string-ref (list-ref input y) x) #\9))
    (cons x y)))

; Given a point and our list of points, return any cardinal neighbours (i.e.
; NSEW) of the point that are in the set of points.
(define (neighbours valid-points pt)
  (filter
   (lambda (x) (set-member? valid-points x))
   (list
    (cons (+ (car pt) 1) (cdr pt))
    (cons (- (car pt) 1) (cdr pt))
    (cons (car pt) (+ (cdr pt) 1))
    (cons (car pt) (- (cdr pt) 1)))))

; Simple breadth-first search. Add points to the queue of points to inspect,
; returning a list of all points inspected.
(define (bfs queue rest)
  (if (empty? queue)
      empty
      (let [(neighbour (neighbours rest (first queue)))]
        (cons (first queue)
              (bfs
               (append (cdr queue) neighbour)
               (set-subtract rest (list->set neighbour)))))))

; Given a set of all points to inspect (i.e. our height map), find all pools and
; return a list of sets of points in each pool.
;
; nb. I don't love the list->set here but I don't feel like rewriting bfs above
;     as a fold or something that would avoid needing this here.
(define (largest-pools lava-map)
  (if (set-empty? lava-map)
      empty
      (let ([pool (list->set (bfs (list (set-first lava-map)) lava-map))])
        (cons pool (largest-pools (set-subtract lava-map pool))))))

; Finally, put it all together - get our points that are basins, find the size
; of each pool, then multiple the three largest basin sizes.
(define (solve-part-2 input)
  (let* ([basin-points (input->point-set input)]
         [pool-sizes (map set-count (largest-pools basin-points))])
    (apply * (take (sort pool-sizes >) 3))))

(check-equal? (solve-part-2 EXAMPLE) 1134)
(check-equal? (solve-part-2 LINES) 949905)

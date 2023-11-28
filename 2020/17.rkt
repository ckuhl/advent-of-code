#lang racket

(require racket/hash)

(require rackunit)

(define LINES (file->lines "inputs/17.txt"))
(define EXAMPLE1 (file->lines "inputs/17-example1.txt"))

; Helper: Convert a list of string inputs to '(x y z) : char mappings
(define (strings->mapping problem-input)
  (apply hash-union
         (for/list ([y (in-range 0 (length problem-input))]
                    [l problem-input])
           (for/hash ([x (in-range 0 (string-length l))]
                      [v (string->list l)])
             (values (list x y 0) v)))))

; Generate neighbours of a point (i.e. all points differening in _each_ dimension
;  by no more than +-1, excluding the point itself
(define (neighbours point)
  (let ([x_0 (first point)] [y_0 (second point)] [z_0 (third point)])
    (for*/list ([x (in-range (- x_0 1) (+ x_0 2))]
                [y (in-range (- y_0 1) (+ y_0 2))]
                [z (in-range (- z_0 1) (+ z_0 2))]
                #:when (not (equal? point (list x y z))))
      (list x y z))))


(define (adjacent mapping)
  (let* ([mapping-points (hash-keys mapping)]
         [all-adjacent (apply set-union (map (lambda (x) (list->set (neighbours x))) mapping-points))])
    all-adjacent))

; FIXME: Somehow return a pair, perhaps: the next value of the point, as well as any "new" points
; Maybe: Two functions:
;        1. "Mapping frontier" generate all points neighbours to existing, removing existing.
;        2. "Update mapping" for all existing and neighbouring points.
(define (next-state mapping point)
  (let* ([this (hash-ref mapping point #\.)]
         [neighbour-list (neighbours point)]
         [nearby (map (lambda (x) (hash-ref mapping x #\.)) neighbour-list)]
         [active-neighbours (count (lambda (x) (equal? x #\#)) nearby)])
    (cond
      [(equal? active-neighbours 3) #\#]
      [(and (equal? active-neighbours 2) (char=? this #\#)) #\#]
      [else #\.])))

(define (count-cubes mapping)
  (count (lambda (x) (char=? x #\#)) (hash-values mapping)))

; For each item in the hash, find all neighbours
(define (iterate-mapping mapping)
  (for/hash ([k (adjacent mapping)])
    (values k (next-state mapping k))))

(define (iterate-steps mapping steps)
  (if (zero? steps) mapping
      (iterate-steps (iterate-mapping mapping) (sub1 steps))))


; =============================================================================
(eprintf "Part 1~n")


(define (solve-part-1 problem-input)
  (let ([mapping (strings->mapping problem-input)])
    (count-cubes (iterate-steps mapping 6))))

(test-equal? "Part 1 example 1 should be correct" (solve-part-1 EXAMPLE1) 112)
(test-equal? "Part 1 solution should be correct" (solve-part-1 LINES) 286)


; =============================================================================
(eprintf "Part 2~n")

; You know that saying "if it's stupid and it works, it's not stupid" ?
; I copy-pasted all of my part 1 code and added in a fourth dimension.
; It's slow, it's stupid, but it works. Sometimes stupid is clever.

(define (strings->mapping2 problem-input)
  (apply hash-union
         (for/list ([y (in-range 0 (length problem-input))]
                    [l problem-input])
           (for/hash ([x (in-range 0 (string-length l))]
                      [v (string->list l)])
             (values (list x y 0 0) v)))))

(define (neighbours2 point)
  (let ([x_0 (first point)] [y_0 (second point)] [z_0 (third point)] [w_0 (fourth point)])
    (for*/list ([x (in-range (- x_0 1) (+ x_0 2))]
                [y (in-range (- y_0 1) (+ y_0 2))]
                [z (in-range (- z_0 1) (+ z_0 2))]
                [w (in-range (- w_0 1) (+ w_0 2))]
                #:when (not (equal? point (list x y z w))))
      (list x y z w))))

(define (adjacent2 mapping)
  (let* ([mapping-points (hash-keys mapping)]
         [all-adjacent (apply set-union (map (lambda (x) (list->set (neighbours2 x))) mapping-points))])
    all-adjacent))

(define (next-state2 mapping point)
  (let* ([this (hash-ref mapping point #\.)]
         [neighbour-list (neighbours2 point)]
         [nearby (map (lambda (x) (hash-ref mapping x #\.)) neighbour-list)]
         [active-neighbours (count (lambda (x) (equal? x #\#)) nearby)])
    (cond
      [(equal? active-neighbours 3) #\#]
      [(and (equal? active-neighbours 2) (char=? this #\#)) #\#]
      [else #\.])))

(define (iterate-mapping2 mapping)
  (for/hash ([k (adjacent2 mapping)])
    (values k (next-state2 mapping k))))

(define (iterate-steps2 mapping steps)
  (if (zero? steps) mapping
      (iterate-steps2 (iterate-mapping2 mapping) (sub1 steps))))

(define (solve-part-2 problem-input)
  (let ([mapping (strings->mapping2 problem-input)])
    (count-cubes (iterate-steps2 mapping 6))))

(test-equal? "Part 2 example 1 should be correct" (solve-part-2 EXAMPLE1) 848)
(test-equal? "Part 2 solution should be correct" (solve-part-2 LINES) 960)

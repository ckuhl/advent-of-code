#lang racket

(require rackunit)

(define LINES (file->lines "inputs/11.txt"))
(define EXAMPLE1 (file->lines "inputs/11-example1.txt"))

(define DIRECTIONS '((1 . 1) (1 . 0) (1 . -1) (0 . 1) (0 . -1) (-1 . 1) (-1 . 0) (-1 . -1)))

; FIXME: There's a lot of _rough_ code that can be improved here
;        but that's a scavenger hunt for another day :)

; Hacky conversion of string input to a mapping of (x . y) : value
(define (lines->mapping lst)
  (for*/hash
      ([y (in-range (length lst))]
       [x (in-range (string-length (first lst)))])
    (values (cons x y) (string-ref (list-ref lst y) x))))


; =============================================================================
(eprintf "Part 1~n")

; Since aisles and walls act alike (as empty space) we return an aisle when we hit a wall
(define (direct-neighbours mapping pt)
  (for/list ([disp DIRECTIONS])
    (let ([neighbour (cons (+ (car pt) (car disp)) (+ (cdr pt) (cdr disp)))])
      (hash-ref mapping neighbour #\.))))

; Apply the rules to determine the next state of pt
(define (next-state mapping pt)
  (let ([occupied (count (lambda (x) (equal? x #\#)) (direct-neighbours mapping pt))]
        [seat (hash-ref mapping pt)])
    (cond
      [(and (equal? seat #\L) (zero? occupied)) #\#]
      [(and (equal? seat #\#) (>= occupied 4)) #\L]
      [else seat])))

(define (iterate-seats m)
  (for/hash ([k (hash-keys m)])
    (values k (next-state m k))))

(define (iterate-until-stable m [prev '()])
  (if (equal? m prev) m (iterate-until-stable (iterate-seats m) m)))

(define (solve-part-1 problem-input)
  (count (lambda (x) (equal? #\# x)) (hash-values (iterate-until-stable (lines->mapping problem-input)))))

(test-equal? "Example 1 input should be correct" (solve-part-1 EXAMPLE1) 37)
(test-equal? "Part 1 solution should be correct" (solve-part-1 LINES) 2406)


; =============================================================================
(eprintf "Part 2~n")

; Given a point and a direction, determine if the first visible seat is occupied
(define (sees-occupied-seat? mapping pt disp)
  (let* ([next-pt (cons (+ (car pt) (car disp)) (+ (cdr pt) (cdr disp)))]
         [v (hash-ref mapping next-pt #\L)])
    (cond
      [(equal? v #\#) #t]
      [(equal? v #\L) #f]
      [else (sees-occupied-seat? mapping next-pt disp)])))

; Count number of occupied seats visible in eight basic directions
(define (visible-seat-count mapping pt)
  (count (lambda (x) (sees-occupied-seat? mapping pt x)) DIRECTIONS))

; Apply the rules of our game to a single point
(define (next-state2 mapping pt)
  (let ([occupied (visible-seat-count mapping pt)]
        [seat (hash-ref mapping pt)])
    (cond
      [(and (equal? seat #\L) (zero? occupied)) #\#]
      [(and (equal? seat #\#) (>= occupied 5)) #\L]
      [else seat])))

; FIXME: Generalize this and combine with part1
(define (iterate-seats2 m [apply-rule next-state])
  (for/hash ([k (hash-keys m)])
    (values k (next-state2 m k))))

(define (iterate-until-stable2 m [prev '()])
  (if (equal? m prev) m (iterate-until-stable2 (iterate-seats2 m) m)))

(define (solve-part-2 problem-input)
  (count (lambda (x) (equal? #\# x))
         (hash-values (iterate-until-stable2 (lines->mapping problem-input)))))

(test-equal? "Part 2 example 1 should be correct" (solve-part-2 EXAMPLE1) 26)
(test-equal? "Part 2 solution should be correct" (solve-part-2 LINES) 2149)

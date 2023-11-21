#lang racket

(require rackunit)

(define LINES (file->lines "inputs/12.txt"))
(define EXAMPLE1 (file->lines "inputs/12-example1.txt"))

(define (string->instruction str)
  (cons
   (string-ref str 0)
   (string->number (substring str 1))))


; We start with EW - x axist, with E being positive
; Similarly NS - y axis, with N being positive
; E = 0, S = 1, W = 2, N = 3
; FIXME: This could be done much better
(define OFFSETS (make-hash '((0 . (1 . 0)) (1 . (0 . -1)) (2 . (-1 . 0)) (3 . (0 . 1)))))

; Update our direction integer with degrees
(define (rotate-ship dir deg)
  (modulo (+ (/ deg 90) dir) 4))


; =============================================================================
(eprintf "Part 1~n")

(define (move-ship x y dir instr)
  (match instr
    [(cons #\N z) (list x (+ y z) dir)]
    [(cons #\S z) (list x (- y z) dir)]
    [(cons #\E z) (list (+ x z) y dir)]
    [(cons #\W z) (list (- x z) y dir)]
    [(cons #\L z) (list x y (rotate-ship dir (- z)))]
    [(cons #\R z) (list x y (rotate-ship dir z))]
    [(cons #\F z) (list
                   (+ x (* z (car (hash-ref OFFSETS dir))))
                   (+ y (* z (cdr (hash-ref OFFSETS dir))))
                   dir)]
    [else (error "Not implemented")]))


(define (operate-ship problem-input)
  (foldl (lambda (x acc) (move-ship (first acc) (second acc) (third acc) x))
         '(0 0 0)
         (map string->instruction problem-input)))

(define (solve-part-1 problem-input)
  (let ([result (operate-ship problem-input)])
    (+ (abs (first result))
       (abs (second result)))))

(test-equal? "Example 1 input should be correct" (solve-part-1 EXAMPLE1) 25)
(test-equal? "Part 1 solution should be correct" (solve-part-1 LINES) 1533)


; =============================================================================
(eprintf "Part 2~n")

(define (rotate-point x y deg)
  (match (/ (modulo (+ 360 deg) 360) 90)
    [1 (list y (- x))]
    [2 (list (- x) (- y))]
    [3 (list (- y) x)]
    [else (error "Unknown")]))

(define (move-ship-complex x y wp-x wp-y instr)
  (match instr
    [(cons #\N z) (list x y wp-x (+ wp-y z))]
    [(cons #\S z) (list x y wp-x (- wp-y z))]
    [(cons #\E z) (list x y (+ wp-x z) wp-y)]
    [(cons #\W z) (list x y (- wp-x z) wp-y)]
    [(cons #\L z) (append (list x y) (rotate-point wp-x wp-y (- z)))]
    [(cons #\R z) (append (list x y) (rotate-point wp-x wp-y z))]
    [(cons #\F z) (list (+ x (* z wp-x)) (+ y (* z wp-y)) wp-x wp-y)]
    [else (error "Not implemented")]))

(define (operate-complex-ship problem-input)
  (foldl (lambda (x acc) (move-ship-complex (first acc) (second acc) (third acc) (fourth acc) x))
         '(0 0 10 1)
         (map string->instruction problem-input)))

(define (solve-part-2 problem-input)
  (let ([result (operate-complex-ship problem-input)])
    (+ (abs (first result))
       (abs (second result)))))

(test-equal? "Part 2 example 1 should be correct" (solve-part-2 EXAMPLE1) 286)
(test-equal? "Part 2 solution should be correct" (solve-part-2 LINES) 25235)

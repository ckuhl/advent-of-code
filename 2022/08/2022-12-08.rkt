#lang racket

(require rackunit)

(define INPUT (file->lines "2022-12-08.txt"))
(define TEST-INPUT (file->lines "2022-12-08-example.txt"))

; ==============================================================================
; Helpers

; Convert the input to a 2D array of integers
(define (input->2d-array lst)
  (map
   (lambda (y) (map (compose (lambda (x) (- x (char->integer #\0))) char->integer) y))
   (map string->list lst)))

; Is a character visible viewed from the left?
(define (visible-in-line? lst [must-beat -1])
  (cond
    [(empty? lst) empty]
    [(> (first lst) must-beat)
     (cons #t (visible-in-line? (rest lst) (first lst)))]
    [else (cons #f (visible-in-line? (rest lst) must-beat))]))


; Is a character visible from the right?
(define (visible-in-line-reverse? lst)
  (reverse (visible-in-line? (reverse lst))))

; Combine the two
(define (visible-from-either-end? lst)
  (define forwards (visible-in-line? lst))
  (define backwards (visible-in-line-reverse? lst))

  (map (lambda (a b) (or a b)) forwards backwards))

; If we transpose, left and right become up and down:
;  We can merge the two to get actual visibility!
(define (transpose-2d-array lst)
  (apply map list lst))


(define (merge-horizontal-and-vertical lst)
  (define horizontal (map visible-from-either-end? (input->2d-array lst)))
  (define vertical (transpose-2d-array (map visible-from-either-end? (transpose-2d-array (input->2d-array lst)))))
  (map (lambda (l1 l2) (map (lambda (x y) (or x y)) l1 l2)) horizontal vertical))

(define (count-true-in-2d-array lst)
  (map (lambda (x) (count identity x)) lst))

(check-equal? (apply + (count-true-in-2d-array (merge-horizontal-and-vertical TEST-INPUT))) 21)


; ==============================================================================
(printf "Part 1~n")

(define (solve-part-1 lst)
  (apply + (count-true-in-2d-array (merge-horizontal-and-vertical lst))))

(check-equal? (solve-part-1 TEST-INPUT) 21)
(solve-part-1 INPUT)


; ==============================================================================
(printf "Part 2~n")

(define arr (input->2d-array TEST-INPUT))

(define (get-row 2d pt)
  (list-ref 2d (cdr pt)))

(define (get-col 2d pt)
  (list-ref (transpose-2d-array 2d) (car pt)))

(define (generate-views 2d pt)
  (define row (get-row 2d pt))
  (define col (get-col 2d pt))
  ;(printf "Point: ~v~n" pt)
  (printf "Row, col: ~v, ~v~n" row col)

  (define up (take col (sub1 (cdr pt))))
  (define left (take row (car pt)))
  (define down (drop col (cdr pt)))
  (define right (drop row (add1 (car pt))))
  
  (list up left down right))

(define (get-point 2d pt)
  (list-ref (list-ref 2d (cdr pt)) (car pt)))

; 
(define (count-seen lst init [looking-down #f] [must-beat -1])
  (printf "~v :: ~v :: ~v~n" lst init must-beat)
  (cond
    [(empty? lst) 0]
    [(and looking-down (> init (first lst)))
     (add1 (count-seen (rest lst) init #t))]
    [looking-down
     (add1 (count-seen (rest lst) init #f (first lst)))]
    [(< must-beat (first lst))
     (add1 (count-seen (rest lst) init #f (first lst)))]
    [else (count-seen (rest lst) init #f must-beat)]))

(define (calculate-view 2d pt)
  (define views (generate-views 2d pt))
  (define height (get-point 2d pt))
  (printf "Point height: ~v Views: ~V~n" height views)

  (define (view-counter lst) (count-seen lst height))
  (printf "~v~n" (map view-counter views))
  (apply * (map view-counter views)))

(calculate-view arr '(2 . 3))
(calculate-view arr '(2 . 1))

; TODO: This is a tomorrow problem
(define (solve-part-2 lst)
  -1)

(check-equal? (solve-part-2 TEST-INPUT) 8)
(solve-part-2 INPUT)
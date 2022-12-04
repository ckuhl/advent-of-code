#lang racket

(require rackunit)

(define LINES (file->lines "2021-12-13.txt"))

(define EXAMPLE (file->lines "example.txt"))


; ==============================================================================
; Helpers

(define (get-points lst) (filter (lambda (x) (string-contains? x ",")) lst))
(define (get-folds lst) (filter (lambda (x) (string-contains? x "=")) lst))

(define (str->point s) (map string->number (string-split s ",")))
(define (str->fold s)
  (define parts (string-split (substring s (string-length "fold along ")) "="))
  (cons
   (first parts)
   (string->number (second parts))))

; ==============================================================================
(printf "Part 1~n")

(define (folded-dist magnitude fold)
  (if
   (> magnitude fold)
   (- fold (abs (- fold magnitude)))
   magnitude))

(define (fold-point fold point)
  (define axis (car fold))
  (define magnitude (cdr fold))

  (if
   (equal? axis "x")
   (list
    (folded-dist (first point) magnitude)
    (second point))
   (list
    (first point)
    (folded-dist (second point) magnitude))))

(define (fold-points fold lst)
  (map (lambda (x) (fold-point fold x)) lst))

(define (solve-part-1 lst)
  (define points (map str->point (get-points lst)))
  (define folds (map str->fold (get-folds lst)))
  (define folded (fold-points (first folds) points))
 
  (length (set->list (list->set folded))))

(test-equal? "First example should give 17" (solve-part-1 EXAMPLE) 17)

(solve-part-1 LINES)


; ==============================================================================
(printf "Part 2~n")
(define (fully-fold lst)
  (define points (map str->point (get-points lst)))
  (define folds (map str->fold (get-folds lst)))

  (define fully-folded (foldl fold-points points folds))
  (set->list (list->set fully-folded)))


(define (solve-part-2 lst)
  (define folded (fully-fold lst))

  (define folds (map str->fold (get-folds lst)))

  ; We may have a margin that is within the fold bounds
  ;  To print our dots, we want to know how 
  (define (get-fold-dim folds dim)
    (filter (lambda (x) (equal? (car x) dim)) folds))
    
  (define width (apply min (map cdr (get-fold-dim folds "x"))))
  (define height (apply min (map cdr (get-fold-dim folds "y"))))

  (for/list ([y (in-range height)])
    (list->string
     (for/list ([x (in-range width)])
       (if (member (list x y) folded) #\# #\.)))))

(test-equal?
 "Example should print out O shape"
 (solve-part-2 EXAMPLE)
 '("#####"
   "#...#"
   "#...#"
   "#...#"
   "#####"
   "....."
   "....."))

; HKUJGAJZ
(map (lambda (x) (printf "~v~n" x)) (solve-part-2 LINES))
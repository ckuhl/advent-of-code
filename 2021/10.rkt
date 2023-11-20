#lang racket

(define LINES (file->lines "input/10.txt"))


(define (first-invalid s [acc empty])
  ; (string-ref s 0 0)
  (cond
    [(zero? (string-length s)) acc]
    [(equal? (string-ref s 0) #\{) (first-invalid (substring s 1) (cons (string-ref s 0) acc))]
    [(equal? (string-ref s 0) #\[) (first-invalid (substring s 1) (cons (string-ref s 0) acc))]
    [(equal? (string-ref s 0) #\() (first-invalid (substring s 1) (cons (string-ref s 0) acc))]
    [(equal? (string-ref s 0) #\<) (first-invalid (substring s 1) (cons (string-ref s 0) acc))]
    [(equal? (string-ref s 0) #\}) (if (equal? (first acc) #\{) (first-invalid (substring s 1) (rest acc)) (string-ref s 0))]
    [(equal? (string-ref s 0) #\]) (if (equal? (first acc) #\[) (first-invalid (substring s 1) (rest acc)) (string-ref s 0))]
    [(equal? (string-ref s 0) #\)) (if (equal? (first acc) #\() (first-invalid (substring s 1) (rest acc)) (string-ref s 0))]
    [(equal? (string-ref s 0) #\>) (if (equal? (first acc) #\<) (first-invalid (substring s 1) (rest acc)) (string-ref s 0))]
    [else acc]))


; ==============================================================================
(printf "Part 1~n")
(define (char->p1-score c)
  (cond
    [(equal? c #\}) 1197]
    [(equal? c #\]) 57]
    [(equal? c #\)) 3] 
    [(equal? c #\>) 25137]
    [else 0]))

(apply
 +
 (map
  char->p1-score
  (map first-invalid LINES)))

; ==============================================================================
(printf "Part 2~n")

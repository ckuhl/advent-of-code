#lang racket

(define LINES (file->lines "inputs/05.txt"))

(eprintf "Part 1~n")
; Observe: We're basically just parsing two little-endian binary numbers

(define (row line) 
  (string->number
   (list->string
    (map (lambda (x) (if (equal?  x #\F) #\0 #\1))
         (take (string->list line) 7)))
   2))

(define (col line)
  (string->number
   (list->string
    (map (lambda (x) (if (equal?  x #\L) #\0 #\1))
         (drop (string->list line) 7)))
   2))

(define (seat-id str)
  (let
      ((r (row str))
       (c (col str)))
    (+ c (* r 8))))


; Helper: Calculate all seat IDs, sort, and take last
(define ids (sort (map seat-id LINES) <))

; Part 1 answer: 850
(last ids)


(eprintf "Part 2~n")
(add1
 (foldl
  ; Scan through the sorted list of seats: Is this previous one one-less than the current one?
  ; Take the current seat and continue counting, otherwise take the previous seat (i.e. before the gap)
  (lambda (a acc) (if (equal? a (add1 acc)) a acc))
  (first ids)
  (rest ids)))

; Part 2 answer: 599
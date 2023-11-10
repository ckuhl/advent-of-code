#lang racket

(define LINES (file->lines "inputs/06.txt"))

; Helper: Chunk list of inputed strings by empty lines
(define (chunk lst [acc '()])
  (cond
    [(empty? lst) (list acc)]
    [(equal? (first lst) "") (cons acc (chunk (rest lst)))]
    [else (chunk (rest lst) (cons (first lst) acc))]))


(eprintf "Part 1~n")
(define (unique-questions lst [set-action set-union])
  ; Create a set for the number of questions _anyone_ answered "yes" to
  ; Then sum them and count that sum
  (set-count (apply set-action (map (compose list->set string->list) lst))))

(apply + (map unique-questions (chunk LINES)))
; 6310


(eprintf "Part 2~n")

(apply + (map (lambda (x) (unique-questions x set-intersect)) (chunk LINES)))
; 3193
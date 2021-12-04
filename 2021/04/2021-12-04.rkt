#lang racket

(require racket/hash)

; Did I fix the file by manually appending a newline? Absolutely :)
(define LINES (file->lines "2021-12-04.txt"))

; List of numbers called in sequence
(define NUMBERS (map string->number (string-split (first LINES) ",")))

; Convert a string representing some numbers into a list of numbers
(define (line->numbers str) (map string->number (string-split str " " #:repeat? #t)))

; List of lists of ints: Boards are a list of integers forming a square array
; '() -> (list (list number?))
(define BOARDS
  (foldr
   (lambda (x acc)
     (cond
       ; Base case: Between boards
       [(string=? "" x) (cons empty acc)]
       [(empty? acc) (list (line->numbers x))]
       [else (cons (cons (line->numbers x) (first acc)) (rest acc))]))
   '()
   (rest (rest LINES))))

; Rotate a list of lists 90 degrees (rows->columns
(define (rotate-matrix board)
  (reverse (apply map list board)))

; All winning lines in a single board: horizontal and vertical
(define (lines-in-board board)
  (append
   board
   (rotate-matrix board)))

; Given a list of list of numbers, remove the given number
(define (remove-number lines n)
  (map (lambda (x) (remove n x)) lines))

; Given a set of lines and numbers, remove all numbers from all lines
(define (remove-numbers lines ns)
  (foldr (lambda (x acc) (remove-number acc x)) lines ns))

; Given a list of winning lines, and numbers called in order, return the subset of numbers
;  that need to be called sequentially before one of the lines is cleared
(define (solve-board lines nums)
  (cond [(member empty lines) empty]
        [else
         (cons (first nums)
               (solve-board (remove-number lines (first nums)) (rest nums)))]))


; Given a list of lists, return the shortest list
(define (shortest lsts)
  (foldr
   (lambda (a b) (if (< (length a) (length b)) a b))
   NUMBERS ; hardcoding but hey it works
   lsts))

; Given a list of lists, return the longest list
(define (longest lsts)
  (foldr
   (lambda (a b) (if (> (length a) (length b)) a b))
   '()
   lsts))

; Calculate the score for a board, given a list of numbers drawn
(define (calculate-score numbers board)
  (*
   (last numbers)
   (apply + (apply append (remove-numbers board numbers)))))


; Calculate the winning sequence of numbers called for every board
(define winning-sequences (map (lambda (x) (solve-board (lines-in-board x) NUMBERS)) BOARDS))


; ==============================================================================
(printf "Part 1~n")

(define shortest-winner (shortest winning-sequences))

; Correct answer: 8442
(calculate-score
 shortest-winner
 (list-ref BOARDS (index-of winning-sequences shortest-winner)))


; ==============================================================================
(printf "Part 2~n")

(define longest-winner (longest winning-sequences))

; Correct answer: 4590
(calculate-score
 longest-winner
 (list-ref BOARDS (index-of winning-sequences longest-winner)))

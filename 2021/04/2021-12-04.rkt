#lang racket

(require racket/hash)

; Did I fix the file by manually appending a newline? Absolutely :)
(define LINES (file->lines "2021-12-04.txt"))

; List of numbers called in sequence
(define NUMBERS (map string->number (string-split (first LINES) ",")))

; string? -> (list number?)
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

; Rotate a matrix 90 degrees (make rows columns)
(define (rotate-matrix board)
  (reverse (apply map list board)))

; All winning lines in a single board: horizontal, vertical, and diagonal (x2)
; (list (list number?)) -> (list (list number?))
(define (lines-in-board board)
  (append
   board
   (rotate-matrix board)))

; Given a set of lines, remove a given number from all that match
(define (remove-number lines n)
  (map (lambda (x) (remove n x)) lines))

; Given a set of lines and numbers, remove all numbers from all lines
(define (remove-numbers lines ns)
  (foldr (lambda (x acc) (remove-number acc x)) lines ns))

; Print out a list of all numbers necessary to clear a single line in a board
(define (solve-board lines nums)
  (cond [(member empty lines) empty]
        [else
         (cons (first nums)
               (solve-board (remove-number lines (first nums)) (rest nums)))]))


; Given a list of lists, return the index and sequence of the shortest list
; (list (list any)) -> (number? . list)
(define (shortest lsts)
  (foldr
   (lambda (a b) (if (< (length a) (length b)) a b))
   NUMBERS
   lsts))

; Above, but return the longest list
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

(define winning-sequences (map (lambda (x) (solve-board (lines-in-board x) NUMBERS)) BOARDS))


; ==============================================================================
(printf "Part 1~n")

(define shortest-winner (shortest winning-sequences))

(define winning-board-index (index-of winning-sequences shortest-winner))

(define winning-board (list-ref BOARDS winning-board-index))

; Correct answer: 8442
(calculate-score shortest-winner winning-board)


; ==============================================================================
(printf "Part 2~n")

(define longest-winner (longest winning-sequences))

(define longest-board-index (index-of winning-sequences longest-winner))

(define longest-board (list-ref BOARDS longest-board-index))

; Correct answer: 4590
(calculate-score longest-winner longest-board)

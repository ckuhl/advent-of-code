#lang racket

; Import lines form
(define LINES (file->lines "2020-12-03.txt"))

; Wrap string references in a modulo function, to "wrap around"
(define (string-ref-mod string index)
  (string-ref string (modulo index (string-length string))))

; Recurse through the list of lines, providing each character in the given slope
(define (chars-in-slope stringlist offset rise run)
  (if (> rise (length stringlist)) '()
      (cons
       (string-ref-mod (first stringlist) offset)
       (chars-in-slope (list-tail stringlist rise) (+ offset run) rise run))))

; Count the number of trees (i.e. `#` characters) along a given slope
(define (count-trees lines offset rise run)
  (count (λ (x) (equal? #\# x)) (chars-in-slope lines offset rise run)))


(eprintf "Part 1~n")
(count-trees LINES 0 1 3)


(eprintf "Part 2~n")
(define SLOPES '((1 . 1) (1 . 3) (1 . 5) (1 . 7) (2 . 1)))
(foldl (λ (x result) (* result (count-trees LINES 0 (car x) (cdr x)))) 1 SLOPES)
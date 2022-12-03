#lang racket

(require rackunit)

(define TEST-INPUT (file->lines "2022-12-02-example.txt"))
(define INPUT (file->lines "2022-12-02.txt"))

; ==============================================================================
(printf "Part 1~n")

(define points
  (make-hash
   '(("A X" . 4)
     ("A Y" . 8)
     ("A Z" . 3)
     ("B X" . 1)
     ("B Y" . 5)
     ("B Z" . 9)
     ("C X" . 7)
     ("C Y" . 2)
     ("C Z" . 6))))

(define (solve-part-1 x) (apply + (map (lambda (x) (hash-ref points x)) x)))
(test-equal? "Example input should be correct" (solve-part-1 TEST-INPUT) 15)
(solve-part-1 INPUT)

; ==============================================================================
(printf "Part 2~n")

(define new-points
  (make-hash
   '(("A X" . 3)
     ("A Y" . 4)
     ("A Z" . 8)
     ("B X" . 1)
     ("B Y" . 5)
     ("B Z" . 9)
     ("C X" . 2)
     ("C Y" . 6)
     ("C Z" . 7))))

(define (solve-part-2 x) (apply + (map (lambda (x) (hash-ref new-points x)) x)))
(test-equal? "Example input should be correct" (solve-part-2 TEST-INPUT) 12)
(solve-part-2 INPUT)
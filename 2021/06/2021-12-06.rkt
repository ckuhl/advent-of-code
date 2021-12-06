#lang racket

(define LINES (file->string "2021-12-06.txt"))

(define NUMBERS (map string->number (string-split (string-trim LINES) ",")))


; Given a list of items, insert each into the hash as a key, with the value
;  being the number of times it has been counted.
(define (list->counted-hash lst)
  (foldr
   (lambda (x acc) (hash-update acc x add1 0))
   (hash)
   lst))

(define fish-hash (list->counted-hash NUMBERS))

; Simulate one day of fish life
(define (step-hash h)
  (make-hash
   (list
    (cons 0 (hash-ref h 1 0))
    (cons 1 (hash-ref h 2 0))
    (cons 2 (hash-ref h 3 0))
    (cons 3 (hash-ref h 4 0))
    (cons 4 (hash-ref h 5 0))
    (cons 5 (hash-ref h 6 0))
    (cons 6 (+
             (hash-ref h 7 0)
             (hash-ref h 0 0)))
    (cons 7 (hash-ref h 8 0))
    (cons 8 (hash-ref h 0 0)))))

; Count all of the fish in our fish hash
(define (fish-count h) (apply + (hash-values h)))

; Given a function that takes one parameter, repeatedly apply it.
(define (repeat-apply f x [count 1])
  (if
   (= count 1) (f x)
   (repeat-apply f (f x) (sub1 count))))

; ==============================================================================
(printf "Part 1~n")
(fish-count (repeat-apply step-hash fish-hash 80))


; ==============================================================================
(printf "Part 2~n")
(fish-count (repeat-apply step-hash fish-hash 256))
#lang racket

(require rackunit)

(define TEST-INPUT (file->lines "2022-12-04-example.txt"))
(define INPUT (file->lines "2022-12-04.txt"))

; ==============================================================================
; Helpers
(define (split-input-line s)
  (map
   (lambda (x) (map string->number (string-split x "-")))
   (string-split s ",")))

; ==============================================================================
(printf "Part 1~n")

(define (one-contains-other pairs)
  (define p1 (first pairs))
  (define p2 (second pairs))

  ; Why the `not`? That's a question for when I'm not racing.
  (not
   (or
    (and
     (> (first p1) (first p2))
     (< (second p2) (second p1)))
    (and
     (< (first p1) (first p2))
     (> (second p2) (second p1))))))


(define (solve-part-1 x)
  (define split-input (map split-input-line x))
  (count identity (map one-contains-other split-input)))

(test-equal? "Two pairs in the example fully contain themselves" (solve-part-1 TEST-INPUT) 2)

(solve-part-1 INPUT)

; ==============================================================================
(printf "Part 2~n")

(define (one-overlaps-other pairs)
  (define p1 (first pairs))
  (define p2 (second pairs))

  ; Why the not? That's a question for when I'm not racing
  (not (set-empty?
        (set-intersect
         (list->set (stream->list (in-range (first p1) (add1 (second p1)))))
         (list->set (stream->list (in-range (first p2) (add1 (second p2)))))))))

(define (solve-part-2 x)
  (define split-input (map split-input-line x))
  (count identity (map one-overlaps-other split-input)))


(test-equal? "Four example pairs overlap each other" (solve-part-2 TEST-INPUT) 4)
(solve-part-2 INPUT)

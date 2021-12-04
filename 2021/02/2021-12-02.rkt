#lang racket

(define LINES (file->lines "2021-12-02.txt"))


(define (get-direction str) (first (string-split str)))

(define (get-distance str) (string->number (second (string-split str))))


(printf "Part 1~n")
(define (get-depth str)
  (cond [(string=? "down" (get-direction str)) (get-distance str)]
        [(string=? "up" (get-direction str)) (* -1 (get-distance str))]
        [else 0]))

(define (get-displacement str) (if (string=? "forward" (get-direction str)) (get-distance str) 0))

(define depth (foldl + 0 (map get-depth LINES)))
(define displacement (foldl + 0 (map get-displacement LINES)))

(* depth displacement)


(printf "Part 2~n")

(define (recursive-depth lst [depth 0] [displacement 0] [aim 0])
  (cond [(empty? lst) (* depth displacement)]
       [(string=? "down" (get-direction (first lst)))
        (recursive-depth (rest lst) depth displacement (+ aim (get-distance (first lst))))]
       [(string=? "up" (get-direction (first lst)))
        (recursive-depth (rest lst) depth displacement (- aim (get-distance (first lst))))]
       [else ; forward
        (recursive-depth (rest lst) (+ depth (* (get-distance (first lst)) aim)) (+ displacement (get-distance (first lst))) aim)]))

(recursive-depth LINES)

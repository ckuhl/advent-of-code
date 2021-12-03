#lang racket

(define LINES (file->lines "2021-12-03.txt"))


(printf "Part 1~n")


(define (bit-count lst index [count 0])
  (if (empty? lst) count
      (bit-count (rest lst) index (+ count (string->number (substring (first lst) index (add1 index)))))))

(define bits
  (list
   (bit-count LINES 0)
   (bit-count LINES 1)
   (bit-count LINES 2)
   (bit-count LINES 3)
   (bit-count LINES 4)
   (bit-count LINES 5)
   (bit-count LINES 6)
   (bit-count LINES 7)
   (bit-count LINES 8)
   (bit-count LINES 9)
   (bit-count LINES 10)
   (bit-count LINES 11)))

(define total (length LINES))

(define (most-common-bit lst total)
  (map (lambda (x) (if (>= (* 2 x) total) 1 0)) lst))

(define (least-common-bit lst total)
  (map (lambda (x) (if (>= (* 2 x) total) 0 1)) lst))


(define gamma (foldl string-append "" (reverse (map number->string (most-common-bit bits total)))))
(define epsilon (foldl string-append "" (reverse (map number->string (least-common-bit bits total)))))


(*
 (string->number gamma 2)
 (string->number epsilon 2))

(printf "Part 2~n")

(define (filter-strings-by-index lst index v)
  (filter (lambda (x) (string-ref v index)) lst))



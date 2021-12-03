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

; trie for binary numbers of identical length
; trie := (trie . trie) | (number . number) | empty
; Left = 0, right = 1

; Insert / update a binary number into a trie
(define (trie-insert str trie)
  (cond
    [(string=? "" str) (if (empty? trie) 1 (add1 trie))]
    [(empty? trie) (trie-insert str (cons empty empty))]
    [(eq? #\0 (string-ref str 0)) (cons (trie-insert (substring str 1) (car trie)) (cdr trie))] ; string starts with 0
    [else (cons (car trie) (trie-insert (substring str 1) (cdr trie)))])) ; string starts with 1


(define int-trie (foldl trie-insert empty LINES))

(define (trie-count trie)
  (cond
    [(pair? trie) (+ (trie-count (car trie)) (trie-count (cdr trie)))]
    [(empty? trie) 0]
    [else trie]))

(define (trie-most-popular trie)
  (cond
    ; Base case
    [(number? trie) empty]

    ; Recursive cases
    [(> (trie-count (car trie)) (trie-count (cdr trie)))
     (cons #\0 (trie-most-popular (car trie)))]
    [else (cons #\1 (trie-most-popular (cdr trie)))]))

; Copypasta
(define (trie-least-popular trie)
  (cond
    ; Base case(s)
    [(number? trie) empty]

    ; When there's one left, take that branch
    [(= 1 (trie-count trie)) (if (= 1 (trie-count (car trie))) (cons #\0 (trie-least-popular (car trie))) (cons #\1 (trie-least-popular (cdr trie))))]

    ; Standard recursive cases
    [(> (trie-count (car trie)) (trie-count (cdr trie)))
     (cons #\1 (trie-least-popular (cdr trie)))]
    [else (cons #\0 (trie-least-popular (car trie)))]))


(*
 (string->number (list->string (trie-most-popular int-trie)) 2)
 (string->number (list->string (trie-least-popular int-trie)) 2))

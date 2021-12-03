#lang racket

(define LINES (file->lines "2021-12-03.txt"))


; trie for binary numbers of identical length
; trie := (trie . trie) | number | empty
; left = 0, right = 1

; Insert / update a binary number into a trie
(define (trie-insert str trie)
  (cond
    ; Base case: End of string, update count
    [(string=? "" str) (if (empty? trie) 1 (add1 trie))]

    ; trie branch empty: Insert deeper branch and retry
    [(empty? trie) (trie-insert str (cons '() '()))]
    [(eq? #\0 (string-ref str 0)) (cons (trie-insert (substring str 1) (car trie)) (cdr trie))] ; string starts with 0
    [else (cons (car trie) (trie-insert (substring str 1) (cdr trie)))])) ; string starts with 1


; Count size of trie
(define (trie-count trie)
  (cond
    [(pair? trie) (+ (trie-count (car trie)) (trie-count (cdr trie)))]
    [(empty? trie) 0]
    [else trie]))

; Merge two tries into one
(define (trie-merge trie1 trie2)
  (cond
    ; Base case(s): Take one trie
    [(empty? trie1) trie2]
    [(empty? trie2) trie1]

    ; Base case: At terminal depth so we know both must be numbers here if one is
    [(number? trie1) (+ trie1 trie2)]

    ; Recurse
    [else (cons (trie-merge (car trie1) (car trie2)) (trie-merge (cdr trie1) (cdr trie2)))]))

; Helper: Invert a list of #\0 and #\1 characters
(define (invert-string charlist)
  (cond
   [(empty? charlist) charlist]
   [(eq? (first charlist) #\0) (cons #\1 (invert-string (rest charlist)))]
   [else (cons #\0 (invert-string (rest charlist)))]))

; Helper: Convert a list of #\0 and #\1 into the number they represent
(define (charlist->number lst) (string->number (list->string lst) 2))

; Trie with _all_ of the binary strings inserted
(define BIT-TRIE (foldl trie-insert empty LINES))

; ==============================================================================
(printf "Part 1~n")


; Find the most prominent first bit in a trie
(define (trie-prominent-bit trie)
  (if
   (> (trie-count (car trie)) (trie-count (cdr trie)))
   #\0
   #\1))

; Recursively find the most prominent bit in a trie
(define (trie-prominent-bits trie)
  (if
   ; Base case: We've reached the bottom of the trie
   (number? trie) empty

   ; Otherwise, recurse
   (cons
    (trie-prominent-bit trie)
    (trie-prominent-bits (trie-merge (car trie) (cdr trie))))))


(define gamma-charlist (trie-prominent-bits BIT-TRIE))
(define epsilon-charlist (invert-string gamma-charlist))

; Solution: 1307354
(*
 (charlist->number gamma-charlist)
 (charlist->number epsilon-charlist))


; ==============================================================================
(printf "Part 2~n")

; Follow a trie, taking the most popular branch at each step
;  In the case of ties, take #\1
(define (trie-most-popular trie)
  (cond
    ; Base case
    [(number? trie) empty]

    ; Recursive cases
    [(> (trie-count (car trie)) (trie-count (cdr trie)))
     (cons #\0 (trie-most-popular (car trie)))]
    [else (cons #\1 (trie-most-popular (cdr trie)))]))


; Follow a trie, taking the least popular branch at each step
;  In the case of ties, take #\0
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


; Solution: 482500
(*
 (charlist->number (trie-most-popular BIT-TRIE))
 (charlist->number (trie-least-popular BIT-TRIE)))

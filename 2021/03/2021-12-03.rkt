#lang racket

(define LINES (file->lines "2021-12-03.txt"))

; trie for binary numbers of identical length
; trie := (trie . trie) | number | empty
; car = 0, cdr = 1
; number = a count of results for this path
; empty = no results (used when the other half of the pair contains a number)

; Insert / update a binary number into a trie
(define (trie-insert str trie)
  (cond
    ; Base case: End of string, update count
    [(string=? "" str) (if (empty? trie) 1 (add1 trie))]

    ; trie branch empty: Insert deeper branch and retry
    [(empty? trie) (trie-insert str (cons '() '()))]
    [(eq? #\0 (string-ref str 0)) (cons (trie-insert (substring str 1) (car trie)) (cdr trie))] ; string starts with 0
    [else (cons (car trie) (trie-insert (substring str 1) (cdr trie)))])) ; string starts with 1


; Count the number of items in the trie
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
    [else
     (cons
      (trie-merge (car trie1) (car trie2))
      (trie-merge (cdr trie1) (cdr trie2)))]))

; Helper: Convert a list of #\0 and #\1 into the number they represent
(define (charlist->number lst) (string->number (list->string lst) 2))


; Trie with _all_ of the binary strings inserted
(define BIT-TRIE (foldl trie-insert empty LINES))

; ==============================================================================
(printf "Part 1~n")


; Compare the size of the trie branches using cmp
(define (trie-branch-cmp trie cmp)
  (cmp (trie-count (car trie)) (trie-count (cdr trie))))

; Recursively find the most prominent bit in a trie according to cmp
(define (trie-prominent-bits trie cmp)
  (if
   ; Base case
   (number? trie) empty

   ; Otherwise, recurse
   (cons
    (if (trie-branch-cmp trie cmp) #\0 #\1)
    (trie-prominent-bits (trie-merge (car trie) (cdr trie)) cmp))))

  
; Solution: 1307354
(*
 (charlist->number (trie-prominent-bits BIT-TRIE >)) ; Gamma (most common bits)
 (charlist->number (trie-prominent-bits BIT-TRIE <=))) ; Epsilon (least common bits)


; ==============================================================================
(printf "Part 2~n")

; Follow a trie, taking the branch specified by cmp

(define (trie-branch trie cmp)
  (cond
    ; Base case
    [(number? trie) empty]

    ; Singular case: Take branch with one
    [(empty? (car trie)) (cons #\1 (trie-branch (cdr trie) cmp))]
    [(empty? (cdr trie)) (cons #\0 (trie-branch (car trie) cmp))]

    ; Recursive cases
    [(cmp (trie-count (car trie)) (trie-count (cdr trie)))
     (cons #\0 (trie-branch (car trie) cmp))]
    [else
     (cons #\1 (trie-branch (cdr trie) cmp))]))


; Solution: 482500
(*
 (charlist->number (trie-branch BIT-TRIE >)) ; Oxygen generator rating (most common)
 (charlist->number (trie-branch BIT-TRIE <=))) ; CO2 scrubber rating (least common)

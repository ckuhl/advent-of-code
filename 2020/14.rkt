#lang racket

(require rackunit)

(require racket/hash)

(define LINES (file->lines "inputs/14.txt"))
(define EXAMPLE1 (file->lines "inputs/14-example1.txt"))
(define EXAMPLE2 (file->lines "inputs/14-example2.txt"))

; Massage a single line of input into a more-manageable format
; i.e. memory lines become '(x y)
;      and mask lines become "XXXX..."
(define (massage-line str)
  (if (equal? "mem" (substring str 0 3))
      (map string->number (regexp-match* #px"\\d+" str))
      (last (string-split str))))

; Convert a number to a padded binary string, to easy comparison
(define (number->padded-binary-string n)
  (~a (number->string n 2) #:min-width 36 #:align 'right #:pad-string "0"))

; Apply a string mask to a number
(define (mask-number mask n)
  (string->number
   (list->string
    (for/list
        ([m (string->list mask)]
         [v (string->list (number->padded-binary-string n))])
      (if (char=? #\X m) v m)))
   2))

(define (compute-instructions lst [bitmask '()])
  (cond
    [(empty? lst) empty]
    [(string? (first lst)) (compute-instructions (rest lst) (first lst))]
    [else (let ([k (first (first lst))]
                [v (second (first lst))])
            (cons
             (cons k (mask-number bitmask v))
             (compute-instructions (rest lst) bitmask)))]))

; =============================================================================
(eprintf "Part 1~n")


(define (solve-part-1 problem-input)
  (apply + (hash-values (make-hash (compute-instructions (map massage-line problem-input))))))

(test-equal? "Part 1 example 1 should be correct" (solve-part-1 EXAMPLE1) 165)
(test-equal? "Part 1 solution should be correct" (solve-part-1 LINES) 14925946402938)


; =============================================================================
(eprintf "Part 2~n")

(define (mask->numbers mask number [carry '()])
  (cond
    [(equal? mask "") (list->string (reverse carry))]
    [(char=? (string-ref mask 0) #\0) (mask->numbers (substring mask 1) (substring number 1) (cons (string-ref number 0) carry))]
    [(char=? (string-ref mask 0) #\1) (mask->numbers (substring mask 1) (substring number 1) (cons #\1 carry))]
    ; Case: #\X -> split down two paths
    [else
     (list
      (mask->numbers (substring mask 1) (substring number 1) (cons #\0 carry))
      (mask->numbers (substring mask 1) (substring number 1) (cons #\1 carry)))]))

(define (masked-entries mask addr value)
  (let ([addresses (flatten (mask->numbers mask (number->padded-binary-string addr)))])
    (make-immutable-hash (map (lambda (x) (cons (string->number x 2) value)) addresses))))


; FIXME: This is wretched, let's refactor a little for legibility (i.e. pull out another f'n, or else use more let statements)
(define (compute-all-memory-values lst [bitmask '()] [addresses (make-immutable-hash)])
  (cond
    [(empty? lst) addresses]
    [(string? (first lst)) (compute-all-memory-values (rest lst) (first lst) addresses)]
    [else
     (compute-all-memory-values
      (rest lst)
      bitmask (hash-union addresses (masked-entries bitmask (first (first lst)) (second (first lst))) #:combine (lambda (a b) b)))]))

(define (solve-part-2 problem-input)
  (apply + (hash-values (compute-all-memory-values (map massage-line problem-input)))))

(test-equal? "Part 2 example 2 should be correct" (solve-part-2 EXAMPLE2) 208)
(test-equal? "Part 2 solution should be correct" (solve-part-2 LINES) 3706820676200)

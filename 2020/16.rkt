#lang racket

(require rackunit)

(define LINES (file->lines "inputs/16.txt"))
(define EXAMPLE1 (file->lines "inputs/16-example1.txt"))
(define EXAMPLE2 (file->lines "inputs/16-example2.txt"))

; FIXME: This whole day is just... rough. Not my greatest code. Will need to revisit.

; The problem input has three parts
; This parses the input into three lists, one for each part
(define (parse-groups problem-input [carry '()])
  (cond
    [(empty? problem-input) (list carry)]
    [(equal? (first problem-input) "") (cons carry (parse-groups (rest problem-input)))]
    [else (parse-groups (rest problem-input) (append carry (list (first problem-input))))]))


; Helper: Convert a list of string ranges e.g. "1-3 or 5-7" to a set of integers in those ranges
(define (string->range str)
  (let ([bounds (map string->number (string-split str "-"))])
    (list->set (range (first bounds) (add1 (second bounds))))))

; Given the problem input, extract a mapping of 'field name' to set of field values
(define (rules-for-ticket-fields problem-input)
  (for/hash ([x (first (parse-groups problem-input))])
    (let* ([split (string-split x ":")]
           [key (first split)]
           [ranges (filter (lambda (x) (string-contains? x "-")) (string-split (second split) " "))])
      (values key (apply set-union (map string->range ranges))))))

; Helper: Extract the second portion of the input, your ticket, into a single list of integers
(define (numbers-on-your-ticket problem-input)
  (let ([ticket-string (second (second (parse-groups problem-input)))])
    (map string->number (string-split ticket-string ","))))

; Helper: Finally, extract the list of nearby tickets as a list of lists of integers
(define (numbers-on-other-nearby-tickets problem-input)
  (let ([strings (rest (third (parse-groups problem-input)))])
    (for/list ([x strings])
      (map string->number (string-split x ",")))))
  

; Return a set of all numbers that appear in at least one valid range
(define (valid-field-values problem-input)
  (let* ([parsed-input (parse-groups problem-input)]
         [field-rules (rules-for-ticket-fields problem-input)])
    (apply set-union (hash-values field-rules))))

; Helper
(define (invalid-field-values problem-input)
  (let* ([parsed-input (parse-groups problem-input)]
         [all-valid (valid-field-values problem-input)]
         [observed-tickets (rest (third parsed-input))]
         [ticket-sets (map (lambda (x) (map string->number (string-split x ","))) observed-tickets)])
    (map (lambda (x) (cons (set->list (set-subtract (list->set x) all-valid)) x)) ticket-sets)))

; =============================================================================
(eprintf "Part 1~n")

; Part 1: Ignore your own ticket
; 1. Collect all ranges of integers that are invalid for _all_ tickets:
; 1.1. Collect the _largest_ valid integer
; 1.2. Make a set of all integers from 0 to that integer, mark these "valid"
; 2. Iterate through the ranges of all integers. Each time one is valid, remove that from the set
; 3. Return the set length.
(define (solve-part-1 problem-input)
  (let ([invalid-fields (flatten (map car (invalid-field-values problem-input)))])
    (apply + invalid-fields)))


(test-equal? "Part 1 example 1 should be correct" (solve-part-1 EXAMPLE1) 71)
(test-equal? "Part 1 solution should be correct" (solve-part-1 LINES) 29019)


; =============================================================================
(eprintf "Part 2~n")




; Given a list of list of integers (each equal length), return a list of sets representing the observed values
(define (observed-field-values lst)
  (map list->set (apply map list lst)))

(define (not-invalid-tickets problem-input)
  (let* ([parsed-input (parse-groups problem-input)]
         [possible-field-values (valid-field-values problem-input)])
    (filter (lambda (x) (subset? (list->set x) possible-field-values)) (numbers-on-other-nearby-tickets problem-input))))

; Collate all observed field ranges by index
(define (observed-ticket-ranges problem-input)
  (let* ([valid-fields (rules-for-ticket-fields problem-input)]
         [my-ticket (map string->number (string-split (second (second (parse-groups problem-input))) ","))]
         [valid-tickets (not-invalid-tickets problem-input)])
    (observed-field-values valid-tickets)))

; Compare our observed ticket values against each possible field
; Collating a list of all fields a given ticket field _could_ be
(define (field-possible-mappings problem-input)
  (let* ([valid-fields (rules-for-ticket-fields problem-input)]
         [observed-ticket-ranges (observed-ticket-ranges problem-input)])
    (sort
     (for/list ([k (hash-keys valid-fields)])
       (cons
        k
        (for/list ([i (in-naturals)]
                   [r observed-ticket-ranges]
                   #:when (subset? r (hash-ref valid-fields k)))
          i)))
     (lambda (a b) (< (length a) (length b))))))


; FIXME: Wow, this is absolutely not the way to go about this
; Is the list of `excluded` not itself suffient?
(define (reduce-possible-mappings mappings [excluded '()])
  (if (empty? mappings) '()
      (let* ([k (first (first mappings))]
             [vs (rest (first mappings))]
             [index (first (set-subtract vs excluded))])
        (cons (cons k index)
              (reduce-possible-mappings (rest mappings) (cons index excluded))))))

; Generate mapping of ticket-field names to integer offsets
(define (ticket-mapping problem-input)
  (let ([my-ticket (numbers-on-your-ticket problem-input)]
        [field-to-index (reduce-possible-mappings (field-possible-mappings problem-input))])
    (for/hash ([k field-to-index])
      (values (car k) (list-ref my-ticket (cdr k))))))

; Finally, extract the relevant fields from your ticket, and multiple the values together
(define (solve-part-2 problem-input)
  (let* ([labelled-ticket (ticket-mapping problem-input)]
         [departure-fields (filter (lambda (x) (string-prefix? (car x) "departure")) (hash->list labelled-ticket))])
    (apply * (map cdr departure-fields))))

(test-equal? "Part 2 example 2 ticket-mapping logic"
             (ticket-mapping EXAMPLE2)
             '#hash(("class" . 12) ("row" . 11) ("seat" . 13)))
(test-equal? "Part 2 solution should be correct" (solve-part-2 LINES) 517827547723)

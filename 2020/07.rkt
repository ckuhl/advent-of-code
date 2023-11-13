#lang racket

(require rackunit)

(define LINES (file->lines "inputs/07.txt"))
(define EXAMPLE1 (file->lines "inputs/07-example1.txt"))
(define EXAMPLE2 (file->lines "inputs/07-example2.txt"))

; Oh hello there, this certainly looks like we're constructing a DAG
; While we could reach right for parsing it into a mapping, it's short enough
; that a list would be workable, and easier to manipulate for humans involved
; Let's make the computer do the work so long as it's easy


; 1. Split string by " X bags contain Y, Z, ..."
; 2. Take left
; 3. Further split right - we include numbers as a part of the regex so that
;    "contains no bags" produces no rules (it is terminal)
; 4. Convert right integers into integers
;
; RULE: (list string (list int string) ...))
; e.g. ("shiny gold" (1 "dark olive") (2 "vibrant plum"))
(define (string->rule str)
  (let* ([divided (string-split str " bags contain")]
         [left (first divided)]
         [right (regexp-match* (regexp "([0-9]+) ?([a-z][a-z ]+) bags?")
                               (second divided)
                               #:match-select rest)]
         [intified (map (lambda (x) (cons (string->number (first x)) (rest x))) right)])
    (cons left intified)))


; Run through list of rules, inspecting any that have the bag type listed as a child
(define (bag-parents rules bag)
  (filter-map (lambda (x) (if (member bag (map second (rest x))) (first x) #f)) rules))

; Goal: Iterate "up" the tree, collecting bags that are a parent of an existing bag.
(define (recursive-parents child-bag rules)
  (let [(parent-bags (bag-parents rules child-bag))]
    (if (empty? parent-bags)
        child-bag
        (append (list child-bag) (flatten (map (lambda (x) (recursive-parents x rules)) parent-bags))))))


; =============================================================================
(eprintf "Part 1~n")
; We got list->set so we can remove duplicates
; Then subtract one because we include the 'shiny gold' bag in the list of bags
(define (solve-part-1 problem-input)
  (let ([parents (recursive-parents "shiny gold" (map string->rule problem-input))])
    (sub1 (set-count (list->set parents)))))

(test-equal? "Example 1 input should be correct" (solve-part-1 EXAMPLE1) 4)
(test-equal? "Problem input should be correct" (solve-part-1 LINES) 370)



; =============================================================================
(eprintf "Part 2~n")
(define (bag-children bag-name rules [bag-multiplier 1])
  (let* ([raw-rule (filter (lambda (x) (equal? (first x) bag-name)) rules)]
         [rule (rest (first raw-rule))])
    (if
     (empty? rule)
     bag-multiplier
     (apply +
            bag-multiplier
            (map (lambda (x) (bag-children (second x) rules (* bag-multiplier (first x)))) rule)))))


(define (solve-part-2 problem-input)
  (sub1 (bag-children "shiny gold" (map string->rule problem-input))))

(test-equal? "Example 1 input should be correct" (solve-part-2 EXAMPLE1) 32)
(test-equal? "Example 2 input should be correct" (solve-part-2 EXAMPLE2) 126)
(test-equal? "Problem input should be correct" (solve-part-2 LINES) 29547)

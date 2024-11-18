#lang racket

(require rackunit)

(define EXAMPLE
  (list
   "[({(<(())[]>[[{[]{<()<>>"
   "[(()[<>])]({[<{<<[]>>("
   "{([(<{}[<>[]}>{[]{[(<()>"
   "(((({<>}<{<{<>}{[]{[]{}"
   "[[<[([]))<([[{}[[()]]]"
   "[{[{({}]{}}([{[{{{}}([]"
   "{<[[]]>}<{[{[{[]{()[[[]"
   "[<(<(<(<{}))><([]([]()"
   "<{([([[(<>()){}]>(<<{{"
   "<{([{{}}[<[[[<>{}]]]>[]]"))

(define LINES (file->lines "input/10.txt"))


(define (first-invalid s [acc empty])
  ; (string-ref s 0 0)
  (cond
    [(zero? (string-length s)) acc]
    [(equal? (string-ref s 0) #\{) (first-invalid (substring s 1) (cons (string-ref s 0) acc))]
    [(equal? (string-ref s 0) #\[) (first-invalid (substring s 1) (cons (string-ref s 0) acc))]
    [(equal? (string-ref s 0) #\() (first-invalid (substring s 1) (cons (string-ref s 0) acc))]
    [(equal? (string-ref s 0) #\<) (first-invalid (substring s 1) (cons (string-ref s 0) acc))]
    [(equal? (string-ref s 0) #\}) (if (equal? (first acc) #\{) (first-invalid (substring s 1) (rest acc)) (string-ref s 0))]
    [(equal? (string-ref s 0) #\]) (if (equal? (first acc) #\[) (first-invalid (substring s 1) (rest acc)) (string-ref s 0))]
    [(equal? (string-ref s 0) #\)) (if (equal? (first acc) #\() (first-invalid (substring s 1) (rest acc)) (string-ref s 0))]
    [(equal? (string-ref s 0) #\>) (if (equal? (first acc) #\<) (first-invalid (substring s 1) (rest acc)) (string-ref s 0))]
    [else acc]))


; ==============================================================================
(printf "Part 1~n")
(define (char->p1-score c)
  (cond
    [(equal? c #\}) 1197]
    [(equal? c #\]) 57]
    [(equal? c #\)) 3] 
    [(equal? c #\>) 25137]
    [else 0]))

(define (solve-part-1 input)
  (apply
   +
   (map
    char->p1-score
    (map first-invalid input))))

(check-equal? (solve-part-1 EXAMPLE) 26397)
(check-equal? (solve-part-1 LINES) 390993)

; ==============================================================================
(printf "Part 2~n")

; Clever part - if we push back the character we _want_ to see when we match, we
; already have the matching segment if we hit a valid-but-incomplete string

(define (is-closer? chr)
  (or
   (eq? chr #\])
   (eq? chr #\})
   (eq? chr #\))
   (eq? chr #\>)))

(define (closer-score chr)
  (match chr
    [#\) 1]
    [#\] 2]
    [#\} 3]
    [else 4]))
    

(define (partner chr)
  (match chr
    [#\] #\[]
    [#\[ #\]]
    [#\( #\)]
    [#\) #\(]
    [#\{ #\}]
    [#\} #\{]
    [#\< #\>]
    [#\> #\<]))

; Algorithm:
; 1. If charlist is empty, return stack
; 2. Otherwise, take first from charlist:
; 2.1. IF first is opening bracket, push back closing bracket to stack, recurse.
; 2.2. Else compare closing bracket against top of stack:
; 2.2.1. If it matches, remove it from the stack, recurse.
; 2.2.2. Otherwise, return sentinel that string is invalid
(define (push-back lst [expected-closing empty])
  (cond
    [(empty? lst) expected-closing]
    [(not (is-closer? (first lst)))
     (push-back (rest lst) (cons (partner (first lst)) expected-closing))]
    [(and (not (empty? expected-closing)) (equal? (first lst) (first expected-closing)))
     (push-back (rest lst) (rest expected-closing))]
    [else '|Invalid string|]))

(define (score-closing-sequence lst [score 0])
  (if
   (empty? lst)
   score
   (score-closing-sequence
    (rest lst)
    (+ (* score 5) (closer-score (first lst))))))

(define (solve-part-2 input)
  (define closing-sequences (filter list? (map (lambda (x) (push-back (string->list x))) input)))
  (define scores (sort (map score-closing-sequence closing-sequences) >))
  (list-ref scores (floor (/ (length scores) 2))))

(check-equal? (solve-part-2 EXAMPLE) 288957)
(check-equal? (solve-part-2 LINES) 2391385187)

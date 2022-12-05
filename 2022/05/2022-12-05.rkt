#lang racket

(require rackunit)

(define TEST-INPUT (file->lines "2022-12-05-example.txt"))
(define INPUT (file->lines "2022-12-05.txt"))  

; ==============================================================================
; Helpers

(define (get-stack lst)
  (define stack-strings
    (filter (lambda (x)
              (not (or (string-contains? x "move")
                       (not (non-empty-string? x)))))
            lst))


  ; Transpose string list
  (define transposed (apply map list (map string->list stack-strings)))

  ; Filter out nonimportant characters
  (define filtered (map (lambda (x) (filter (lambda (y) (not (or (equal? y #\space) (equal? y #\]) (equal? y #\[)))) x)) transposed))

  ; Remove now-empty lists (i.e. "] [" strings
  (define almost (filter (lambda (x) (not (empty? x))) filtered))

  ; Reverse so top of stack 
  (define final (map reverse almost))

  ; Finally, remove the index of the stack - we know this by position
  (map reverse (map (lambda (x) (rest x)) final)))
  

; Given a problem input, return a list of triples that are the "moves"
(define (get-moves lst)
  (define move-strings (filter (lambda (x) (string-contains? x "move")) lst))
  (define split (map (lambda (x) (string-split x)) move-strings))
  (map (lambda (x) (map string->number x))
       (map (lambda (x) (list (second x) (fourth x) (sixth x))) split)))
  


; ==============================================================================
(printf "Part 1~n")

(define (move-stack move stack)
  (define num-to-take (first move))
  (define stack-from (sub1 (second move)))
  (define stack-to (sub1 (third move)))
  
  ; The sublist to move from A to B
  (define to-move
    (take
     (list-ref stack stack-from)
     num-to-take))

  (define stack-with-items-removed
    (list-update stack stack-from (lambda (x) (drop x num-to-take))))

  ; Finally, add moved items to new stack
  (list-update stack-with-items-removed stack-to (lambda (x) (append (reverse to-move) x))))


(define (solve-part-1 x)
  (define final-position (foldl move-stack (get-stack x) (get-moves x)))
  (list->string (map first final-position)))

(test-equal? "Final position of example is correct" (solve-part-1 TEST-INPUT) "CMZ")

(solve-part-1 INPUT)

; ==============================================================================
(printf "Part 2~n")

(define (move-stack-at-once move stack)
  (define num-to-take (first move))
  (define stack-from (sub1 (second move)))
  (define stack-to (sub1 (third move)))
  
  ; The sublist to move from A to B
  (define to-move
    (take
     (list-ref stack stack-from)
     num-to-take))

  (define stack-with-items-removed
    (list-update stack stack-from (lambda (x) (drop x num-to-take))))

  ; Finally, add moved items to new stack
  ; FIXME: Copypasta just to remove the `reverse` here...
  (list-update stack-with-items-removed stack-to (lambda (x) (append to-move x))))


(define (solve-part-2 x)
  (define final-position (foldl move-stack-at-once (get-stack x) (get-moves x)))
  (list->string (map first final-position)))


(test-equal? "Final position of example is correct" (solve-part-2 TEST-INPUT) "MCD")
(solve-part-2 INPUT)

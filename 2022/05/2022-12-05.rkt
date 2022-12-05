#lang racket

(require rackunit)

(define TEST-INPUT (file->lines "2022-12-05-example.txt"))
(define INPUT (file->lines "2022-12-05.txt"))  

; ==============================================================================
; Helpers

(define (get-stack lst)
  ; First, we filter for strings that define the items on the stacks
  ;  We can determine the stack number by the index of it in the list
  (define stack-strings (filter (lambda (x) (string-contains? x "[")) lst))

  ; Transpose string list - now each stack is a single sub-list
  (define transposed (apply map list (map string->list stack-strings)))

  ; Now we can remove all non-stack-defining characters
  ;  We can't just remove sublists containing spaces,
  ;  as a shorter stack may have some spaces at the end
  (define filtered
    (map
     (lambda (x)
       (filter
        (lambda (y)
          (not
           (or
            (equal? y #\space)
            (equal? y #\])
            (equal? y #\[))))
        x))
     transposed))

  ; Remove now-empty lists (i.e. the columns containing only "[" strings
  (filter (lambda (x) (not (empty? x))) filtered))


(define (get-moves lst)
  ; First, get only the strings that contain the word "move"
  (define move-strings (filter (lambda (x) (string-contains? x "move")) lst))

  ; Then split the input on spaces
  (define split (map string-split move-strings))

  ; And simply take the relevant parts
  ;  At this point each line should be something like
  ;  '("move" "x" "from" "y" "to" "z")
  ;  where we're only interested in x,y,z
  (define (take-relevant-elements x) (map string->number (list (second x) (fourth x) (sixth x))))

  ; Finally, do so for each move
  (map take-relevant-elements split))



; ==============================================================================
(printf "Part 1~n")

(define (move-stack move stack [one-at-a-time? #t])
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
  (list-update stack-with-items-removed stack-to (lambda (x) (append (if one-at-a-time? (reverse to-move) to-move) x))))


(define (solve-part-1 x)
  (define final-position (foldl move-stack (get-stack x) (get-moves x)))
  (list->string (map first final-position)))

(test-equal? "Final position of example is correct" (solve-part-1 TEST-INPUT) "CMZ")
(test-equal? "Final position of input is correct" (solve-part-1 INPUT) "SBPQRSCDF")
(solve-part-1 INPUT)


; ==============================================================================
(printf "Part 2~n")

; Wrap function with default argument overwritten, so we can call it from foldl
(define move-stack-at-once (lambda (x y) (move-stack x y #f)))

(define (solve-part-2 x)
  (define final-position (foldl move-stack-at-once (get-stack x) (get-moves x)))
  (list->string (map first final-position)))

(test-equal? "Final position of example is correct" (solve-part-2 TEST-INPUT) "MCD")
(test-equal? "Final position of input is correct" (solve-part-2 INPUT) "RGLVRCQSB")
(solve-part-2 INPUT)

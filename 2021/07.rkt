
#lang racket

(define LINES (file->string "input/07.txt"))

(define NUMBERS (map string->number (string-split (string-trim LINES) ",")))

(define TEST-NUMBERS (map string->number (string-split (string-trim "16,1,2,0,4,2,7,1,2,14") ",")))


; Given a list of items, insert each into the hash as a key, with the value
;  being the number of times it has been counted.
(define (list->counted-hash lst)
  (foldr
   (lambda (x acc) (hash-update acc x add1 0))
   (hash)
   lst))

(define crab-hash (list->counted-hash NUMBERS))
(define furthest-crab (apply max NUMBERS))

; ==============================================================================
(printf "Part 1~n")

; It takes 1 fuel to move one crab one unit.
; If we know the number of crabs on both sides of a point, we know how much
;  _more_ fuel it would take them to move one unit to the right:
;  all the crabs on the left (and current centre) would expend 1 more fuel unit
;  and all crabs on the right (and new centre) would expend 1 less fuel unit.
;
; Let x_n be the amount of fuel required to move all crabs to position n.
; Let l_n, c_n, l_n be the number of crabs on the left, centre, and right of the
;  current position n.
;
; We can formulate the relation above as
;  (1) x_n = x_{n-1} + l_n - c_n - r_n
; Further, we know
;  (2) l_n = l_{n-1} + c_{n-1}
;  (3) r_n = r_{n-1} - c_n
; Which we can subsitute (2) and (3) into (1), which will reduce to:
;  (4) x_n = x_{n-1} + c_{n-1} - r_{n-1}
;
; Which defines the recurrence entirely in the context of previous values.
(define (recurrence x_n-1 l_n-1 c_n-1 r_n-1)
  (+ x_n-1 l_n-1 c_n-1 (- r_n-1)))

; No optimal point will ever have all of the crabs on the left or right:
;  Otherwise, let the new middlepoint be the leftmost or rightmost point.
;  All points are closer, and so the fuel cost is lower.
(define (run-recurrence x_n-1 l_n-1 r_n-1 c_n-1_idx h)
  (define c_n-1 (hash-ref h c_n-1_idx 0))
  (define c_n (hash-ref h (add1 c_n-1_idx) 0))
  (define r_n (- r_n-1 c_n))
  (define l_n (+ c_n-1 l_n-1))
  (define x_n (recurrence x_n-1 l_n-1 c_n-1 r_n-1))

  (if (= c_n-1_idx furthest-crab) empty
      (cons
       x_n 
       (run-recurrence
        x_n
        l_n
        r_n
        (add1 c_n-1_idx)
        h))))

(define x_0 (apply + (hash-map crab-hash (lambda (k v) (* k v)))))
(define l_0 0)
(define r_0 (apply + (hash-map crab-hash (lambda (k v) (if (zero? k) 0 v)))))
(define c_0_idx 0)

(define fuel-by-index
  (run-recurrence x_0 l_0 r_0 c_0_idx crab-hash))

;Solution is 331067
(time
 (apply min fuel-by-index))


; ==============================================================================
(printf "Part 2~n")

; Fuel calculation functions: How much fuel is required to move x units?
(define (linear-fuel x) x)
(define (arithmetic-fuel x) (/ (* x (+ x 1)) 2))

; Create a line of fuel units required to move to each point in a line
(define (create-line size fn loc)
  (for/list ([i (in-inclusive-range 0 size)])
    (abs (fn (abs (- i loc))))))

; Helper: Apply create-line to a list of integers
(define (create-lines size fn lst)
  (for/list
      ([i lst])
    (create-line size fn i)))

; Helper: Rotate a list of lists 90 (i.e. make rows into columns)
(define (rotate-list-lists lst)
  (apply map list lst))

; Helper: Sum a list of numbers
(define (list-sum lst) (apply + lst))
(define (list-min lst) (apply min lst))

; Disgusting function to calculate the minimal amount of fuel required to align
;  all of the crabs. Calculate each line, then rotate, sum, and select the
;  minimal value.
(define (minimize-fuel-usage positions fuel-function)
  (list-min
   (map
    list-sum
    (rotate-list-lists
     (create-lines furthest-crab fuel-function NUMBERS)))))

; Re-run part 1 solution using part 2 code
(time
 (minimize-fuel-usage NUMBERS linear-fuel))

; Part 2 solution is 92881128
(time
 (minimize-fuel-usage NUMBERS arithmetic-fuel))

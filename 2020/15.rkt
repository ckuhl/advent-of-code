#lang racket

(require rackunit)

(define LINES (file->string "inputs/15.txt"))
(define EXAMPLE1 (file->string "inputs/15-example1.txt"))

; Mapping of <number spoken> : (second-last-time-seen . last-time-seen)
; For the first time we see a number, we set both values to the same
(define (input->initial-state problem-input)
  (for/hash ([v (in-naturals 1)]
             [k (map string->number (string-split problem-input ","))])
    (values k (cons v v))))


; When a number is spoken, update the sightings of it
; If it is the first time, make both the previous sightings the current step
(define (update-game-state game-state spoken step)
  (let* ([last-seen (hash-ref game-state spoken (cons step step))]
         [new-last (cons (cdr last-seen) step)])
    (hash-set game-state spoken new-last)))

; Return the difference between the last two occurrences
(define (next-number game-state spoken)
  (let ([last-seen (hash-ref game-state spoken)])
    (- (cdr last-seen) (car last-seen))))

; Apply the above two steps recursively until we reach the stopping point
(define (play-game-until game-state end step spoken)
  (if (equal? step end) spoken
      (let* ([next-state (update-game-state game-state spoken step)]
             [next-spoken (next-number next-state spoken)])
        (play-game-until next-state end (add1 step) next-spoken))))


; =============================================================================
(eprintf "Part 1~n")


(define (solve-part-1 problem-input [target-step 2020])
  (let* ([initial-state (input->initial-state problem-input)]
         [initial-steps (length (hash-keys initial-state))]
         ; FIXME: Can we hoist this up a level into the recursion?
         [last-seen (string->number (last (string-split problem-input ",")))])
    (play-game-until initial-state target-step (add1 initial-steps) (next-number initial-state last-seen))))

(test-equal? "Part 1 example 1 should be correct" (solve-part-1 EXAMPLE1) 436)
(test-equal? "Part 1 solution should be correct" (solve-part-1 LINES) 852)


; =============================================================================
(eprintf "Part 2~n")

; Now that we know we only need to track the last two ocurrences of a number, we can optimize the first part:
; Without part two, it was hard to tell if we were going to need more lookback.
; Now that we only need the last two ocurrences (i.e. now and previously), we can be more efficient.
; FIXME: This is still slow! But it's seconds-slow instead of hours-slow.
(define (solve-part-2 problem-input) (solve-part-1 problem-input 30000000))

(test-equal? "Part 2 example 1 should be correct" (solve-part-2 EXAMPLE1) 175594)
(test-equal? "Part 2 solution should be correct" (solve-part-2 LINES) 6007666)

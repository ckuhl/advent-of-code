#lang racket

(require rackunit)

(define LINES (file->list "inputs/10.txt"))
(define EXAMPLE1 (file->list "inputs/10-example1.txt"))
(define EXAMPLE2 (file->list "inputs/10-example2.txt"))


; =============================================================================
(eprintf "Part 1~n")

(define (take-deltas lst)
  (for/list ([f (drop lst 1)]
             [s (drop-right lst 1)])
    (- f s)))

(define (solve-part-1 problem-input)
  (let* ([padded-input (append problem-input (list 0 (+ 3 (apply max problem-input))))]
         [steps (sort padded-input <)]
         [deltas (take-deltas steps)])
    (* (length (indexes-of deltas 1))
       (length (indexes-of deltas 3)))))

(test-equal? "Example 1 input should be correct" (solve-part-1 EXAMPLE1) 35)
(test-equal? "Example 2 input should be correct" (solve-part-1 EXAMPLE2) 220)
(test-equal? "Part 1 solution should be correct" (solve-part-1 LINES) 2310)


; =============================================================================
(eprintf "Part 2~n")


; This feels like a lil bit of Dynamic Programming
; We know how many states we can reach from the end (1)
; We know how many states we can reach from the second-last (1, since we must jump 3 to the end)
; Thus we can calculate any prior arrangement as a combination of these:
; Paths(x) = Paths(x+1) + Paths(x+2) + Paths(x+3)
; Where x = 1
;     x-1 = 0
;     x-2 = 0

(define (calculate-paths lst [prior-paths (make-immutable-hash)])
  (if (empty? lst) (hash-ref prior-paths 0)
      (let* ([poi (last lst)]
             [back1 (hash-ref prior-paths (+ poi 1) 0)]
             [back2 (hash-ref prior-paths (+ poi 2) 0)]
             [back3 (hash-ref prior-paths (+ poi 3) 0)]
             [next-paths (hash-set prior-paths poi (+ back1 back2 back3))])
        (calculate-paths (take lst (- (length lst) 1)) next-paths))))

(define (solve-part-2 problem-input)
  (let* ([padded-input (append problem-input '(0))]
         [steps (sort padded-input <)])
    (calculate-paths steps (make-immutable-hash (list (cons (+ 3 (apply max problem-input)) 1))))))

(test-equal? "Part 2 example 1 should be correct" (solve-part-2 EXAMPLE1) 8)
(test-equal? "Part 2 example 2 should be correct" (solve-part-2 EXAMPLE2) 19208)
(test-equal? "Part 2 solution should be correct" (solve-part-2 LINES) 64793042714624)

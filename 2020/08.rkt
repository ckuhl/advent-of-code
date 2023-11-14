#lang racket

(require rackunit)

(define LINES (file->lines "inputs/08.txt"))
(define EXAMPLE1 (file->lines "inputs/08-example1.txt"))

(define (cmd->pair str)
  (let ([pair (string-split str)])
    (cons (string->symbol (first pair))
          (string->number (second pair)))))

(define (parse-instructions problem-input)
  (for/list ([item problem-input]
             [index (in-naturals)])
    (cons (cmd->pair item) index)))

(define (identify-loop instructions [ip 0] [acc 0] [seen (set)])
  (if
   (>= ip (length instructions))
   (error 'success "Loop exit found, accumulator value is: ~v~n" acc)
   (let* ([instr (list-ref instructions ip)]
          [cmd (caar instr)]
          [arg (cdar instr)]
          [next-seen (values (set-add seen instr))])
     (cond
       [(set-member? seen instr) acc]
       [(eq? 'jmp cmd) (identify-loop instructions (+ ip arg) acc next-seen)]
       [(eq? 'acc cmd) (identify-loop instructions (add1 ip) (+ acc arg) next-seen)]
       [else (identify-loop instructions (add1 ip) acc next-seen)]))))

; =============================================================================
(eprintf "Part 1~n")

(define (solve-part-1 problem-input)
  (let ([instructions (parse-instructions problem-input)])
    (identify-loop instructions)))

(test-equal? "Example 1 input should be correct" (solve-part-1 EXAMPLE1) 5)
(test-equal? "Part 1 solution should be correct" (solve-part-1 LINES) 1337)


; =============================================================================
(eprintf "Part 2~n")

; FIXME: Likely we don't want to utilize the same loop detection as-is for above
; Maybe this is a good place to start thinking about continuations?
(define (solve-part-2 problem-input)
  (let ([instructions (parse-instructions problem-input)])
    (for ([i instructions])
      (let ([index (cdr i)]
            [cmd (caar i)]
            [arg (cdar i)])
        (cond
          [(eq? cmd 'jmp) (identify-loop (list-set instructions index (cons (cons 'nop arg) index)))]
          [(eq? cmd 'nop) (identify-loop (list-set instructions index (cons (cons 'jmp arg) index)))]
          [else '()])))))

(solve-part-2 LINES)
; 1358
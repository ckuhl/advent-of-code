#lang racket

(require rackunit)

(define INPUT (file->lines "2022-12-10.txt"))
(define TEST-INPUT (file->lines "2022-12-10-example.txt"))

; ==============================================================================
; Helpers


; ==============================================================================
(printf "Part 1~n")

; Convert line to more manageable format
(define (line->parts str)
  (define lst (string-split str))
  (cond
    [(equal? (first lst) "noop") lst]
    [else
     (list
      (first lst)
      (string->number (second lst)))]))

(define (parse lst)
  (if
   (empty? lst)
   empty
   (cons
    (line->parts (first lst))
    (parse (rest lst)))))


(define (cpu input cycles [reg-x 1] [counter 1] [delay 0] [to-add empty])
  (cond
    ; No more input, return early
    [(empty? input) empty]

    ; No more cycles to check, return early
    [(empty? cycles) empty]

    ; We've passed a relevant cycle marker, return the value before continuing
    [(equal? counter (first cycles))
     (cons
      (* counter reg-x)
      (cpu input (rest cycles) reg-x counter delay to-add))]

    ; Do we have a delay to count down?
    ; Count it down, _then_ add values to the register
    [(> delay 1) (cpu input cycles reg-x (+ counter 1) (- delay 1) to-add)]
    [(equal? delay 1) (cpu input cycles (+ reg-x to-add) (+ counter 1))]
    
    ; Interpret instruction `noop`
    [(equal? (first (first input)) "noop")
     (cpu (rest input) cycles reg-x (+ counter 1))]

    ; Interpret instruction `addx`
    [else
     (cpu (rest input) cycles reg-x counter 2 (second (first input)))]))



(define (solve-part-1 lst)
  (define CYCLES '(20 60 100 140 180 220))
  (apply + (cpu (parse lst) CYCLES)))

(check-equal? (solve-part-1 TEST-INPUT) 13140)
(solve-part-1 INPUT)


; ==============================================================================
(printf "Part 2~n")

(define (cpu-draw input cycles [reg-x 1] [counter 1] [delay 0] [to-add empty] [drawn? #f])
  (cond
    [(not drawn?)
     (cons
      (pixel-value (- counter (* 40 (- 6 (length cycles)))) reg-x)
      (cpu-draw input cycles reg-x counter delay to-add #t))]

    ; No more input, return early
    [(empty? input) empty]

    ; No more cycles to check, return early
    [(empty? cycles) empty]

    ; We've passed a relevant cycle marker, return the value before continuing
    [(equal? counter (first cycles))
     (cpu-draw input (rest cycles) reg-x counter delay to-add #t)]

    ; Do we have a delay to count down?
    ; Count it down, _then_ add values to the register
    [(> delay 1) (cpu-draw input cycles reg-x (+ counter 1) (- delay 1) to-add)]
    [(equal? delay 1) (cpu-draw input cycles (+ reg-x to-add) (+ counter 1))]
    
    ; Interpret instruction `noop`
    [(equal? (first (first input)) "noop")
     (cpu-draw (rest input) cycles reg-x (+ counter 1))]

    ; Interpret instruction `addx`
    [else
     (cpu-draw (rest input) cycles reg-x counter 2 (second (first input)) #t)]))

(define (pixel-value counter register)
  ; You'd think the range would be +1 to -1, but due to the counter being
  ;  one-based instead of zero-based, we have to account for that here
  (if (>= counter register (- counter 2)) #\# #\.))

(define (format-answer str)
  (if (<= (string-length str) 40)
      (list str)
      (cons
       (substring str 0 40)
       (format-answer (substring str 40)))))

(define (solve-part-2 lst)
  (define CYCLES '(40 80 120 160 200 240))
  (format-answer (list->string (cpu-draw (parse lst) CYCLES))))

(check-equal?
 (solve-part-2 TEST-INPUT)
 '("##..##..##..##..##..##..##..##..##..##.."
   "###...###...###...###...###...###...###."
   "####....####....####....####....####...."
   "#####.....#####.....#####.....#####....."
   "######......######......######......####"
   "#######.......#######.......#######....."))
(display (string-join (solve-part-2 INPUT) "\n"))
;###..####.#..#.####..##....##..##..###..
;#..#....#.#..#.#....#..#....#.#..#.#..#.
;#..#...#..####.###..#.......#.#....###..
;###...#...#..#.#....#.##....#.#....#..#.
;#.#..#....#..#.#....#..#.#..#.#..#.#..#.
;#..#.####.#..#.#.....###..##...##..###..

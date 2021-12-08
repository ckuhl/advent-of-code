#lang racket

(define LINES (file->lines "2021-12-08.txt"))

(define EXAMPLE-LINES
  (list
   "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe"
   "edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc"
   "fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg"
   "fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb"
   "aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea"
   "fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb"
   "dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe"
   "bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef"
   "egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb"
   "gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce"))

; Convert the inputted strings into a list of two lists:
;  The left being the strings left of the bar, and the right, the right.
(define (line->formatted x)
  (define split (string-split x " "))
  (define bar (index-of split "|"))
  
  (list (take split bar) (drop split (add1 bar))))

; The formatted input
(define DIVIDED (map line->formatted LINES))


; ==============================================================================
(printf "Part 1~n")

; Helpers: Simple predicates for the easy cases
;  Optional parameters bolted on for easy-of-copy-pasting
(define (is-1-seg? s [4-seg '()] [1-seg '()]) (= 2 (string-length s)))
(define (is-4-seg? s [4-seg '()] [1-seg '()]) (= 4 (string-length s)))
(define (is-7-seg? s [4-seg '()] [1-seg '()]) (= 3 (string-length s)))
(define (is-8-seg? s [4-seg '()] [1-seg '()]) (= 7 (string-length s)))

; For part one, we only care about these four characters, so they are
;  what counts as pertinent.
(define (is-pertinent? s)
  (or
   (is-1-seg? s)
   (is-4-seg? s)
   (is-7-seg? s)
   (is-8-seg? s)))

(apply
 + ; count all of the 
 (map
  (lambda (x) (count identity x)) ; count of matching characters
  (map (lambda (x) (map is-pertinent? (second x))) DIVIDED))) ; for each line

; ==============================================================================
(printf "Part 2~n")

; Helper: Return whether a given string s contains all of the characters within
;  another string, s0. Order does not matter.
(define (string-contains-all? s s0)
  (for/and ([i (in-range (string-length s0))])
    (string-contains? s (substring s0 i (add1 i)))))

; Helper: Return a string containing only characters that s1 and s2 do not have
;  in common with each other. Order is not guaranteed.
(define (string-difference s1 s2)
  (list->string
   (set->list
    (set-symmetric-difference
     (list->set (string->list s1))
     (list->set (string->list s2))))))

; Predicate for three-segment character:
;  Only 3-seg has 5 segments and the segments as 1-seg
(define (is-3-seg? s 4-seg 1-seg)
  (and
   (= 5 (string-length s))
   (string-contains-all? s 1-seg)))

; Predicate: Only 5-seg has 5 segments and the same characters as the
;  set-difference of 1-seg and 4-seg (the "arm" of the 4, if you will)
(define (is-5-seg? s 4-seg 1-seg)
  (and
   (= 5 (string-length s))
   (string-contains-all? s (string-difference 4-seg 1-seg))))

; Predicate: 2-seg has 5 segments and isn't 3-seg or 5-seg.
(define (is-2-seg? s 4-seg 1-seg)
  (and
   (= 5 (string-length s))
   (not (is-3-seg? s 4-seg 1-seg))
   (not (is-5-seg? s 4-seg 1-seg))))

; Predicate: Only 9-seg has 6 segments and the same segments as 4-seg
(define (is-9-seg? s 4-seg 1-seg)
  (and
   (= 6 (string-length s))
   (string-contains-all? s 4-seg)))

; Predicate: Only 0-seg has 6 segments, is not 9-seg, and has the same
;  segments as 1-seg
(define (is-0-seg? s 4-seg 1-seg)
  (and
   (= 6 (string-length s))
   (not (is-9-seg? s 4-seg 1-seg))
   (string-contains-all? s 1-seg)))

; Predicate: Only 6-seg has 6 segments and isn't 9-seg or 0-seg.
(define (is-6-seg? s 4-seg 1-seg)
  (and
   (= 6 (string-length s))
   (not (is-9-seg? s 4-seg 1-seg))
   (not (is-0-seg? s 4-seg 1-seg))))

; Convert a given number string into the corresponding string number.
(define (seg->number s 4-seg 1-seg)
  (cond
    [(is-0-seg? s 4-seg 1-seg) "0"]
    [(is-1-seg? s 4-seg 1-seg) "1"]
    [(is-2-seg? s 4-seg 1-seg) "2"]
    [(is-3-seg? s 4-seg 1-seg) "3"]
    [(is-4-seg? s 4-seg 1-seg) "4"]
    [(is-5-seg? s 4-seg 1-seg) "5"]
    [(is-6-seg? s 4-seg 1-seg) "6"]
    [(is-7-seg? s 4-seg 1-seg) "7"]
    [(is-8-seg? s 4-seg 1-seg) "8"]
    [else "9"]))

; Given a formatted line, use the left half to convert the right half into the
;  corresponding number it represents.
(define (formatted-line->number lst)
  (define left (first lst))
  (define right (second lst))

  (define 4-seg (first (filter is-4-seg? left)))
  (define 1-seg (first (filter is-1-seg? left)))

  (string->number
   (apply
    string-append
    (map
     (lambda (x) (seg->number x 4-seg 1-seg))
     right))))

; Convert each line to a string, and add them up.
(apply + (map formatted-line->number DIVIDED))


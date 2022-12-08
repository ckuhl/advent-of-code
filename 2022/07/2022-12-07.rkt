#lang racket

(require racket/hash)
(require rackunit)

(define INPUT (file->lines "2022-12-07.txt"))
(define TEST-INPUT (file->lines "2022-12-07-example.txt"))

; ==============================================================================
; Helpers

; Given a mapping of directories, and a stack, add to all parents the value
(define (generate-paths stack)
  (if (empty? stack) empty
      (cons (string-join stack "/") (generate-paths (rest stack)))))

(define (update-all-parents directories stack v)
  (foldl (lambda (x acc) (hash-update acc x (lambda (y) (+ y v)) 0)) directories (generate-paths stack)))

(define (update-stack state line)
  (define directories (first state))
  (define stack (second state))

  (cond
    [(equal? line "$ cd /") (list directories (list "/"))]
    [(equal? line "$ cd ..") (list directories (list-tail stack 1))]
    [(string-prefix? line "$ cd") (list directories (cons (substring line 5) stack))]
    [(equal? line "$ ls") state]
    [(string-prefix? line "dir") state]
    [else (list (update-all-parents directories stack (string->number (first (string-split line)))) stack)]))

(define (count-subdir-sizes lst)
  (foldl (lambda (x acc) (update-stack acc x)) (list (make-immutable-hash) (list)) lst))

; ==============================================================================
(printf "Part 1~n")

(define (solve-part-1 lst)
  (define subdirs (first (count-subdir-sizes lst)))
  (apply + (filter (lambda (x) (< x 100000)) (hash-values subdirs))))

(check-equal? (solve-part-1 TEST-INPUT) 95437)
(solve-part-1 INPUT)


; ==============================================================================
(printf "Part 2~n")

; Calculate the smallest "largest" number to free space
(define (select-smallest-to-free-required-space lst used-space)
  (define total-space 70000000)
  (define space-needed 30000000)
  (define free-space (- total-space used-space))
  (define free-space-needed (- space-needed free-space))

  (first (sort (filter (lambda (x) (>= x free-space-needed)) lst) <)))

(define (solve-part-2 lst)
  (define subdirs (first (count-subdir-sizes lst)))
  (define root (hash-ref subdirs "/"))
  (select-smallest-to-free-required-space (hash-values subdirs) root))

(check-equal? (solve-part-2 TEST-INPUT) 24933642)
(solve-part-2 INPUT)

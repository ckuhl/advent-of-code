#lang racket

(define TEST-INPUT
  '("vJrwpWtwJgWrhcsFMMfFFhFp"
    "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL"
    "PmmdzqPrVvPwwTWBwg"
    "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn"
    "ttgJtRGJQctTZtZT"
    "CrZsJsPPZsGzwwsLwLmpwMDw"))

(define INPUT (file->lines "2022-12-03.txt"))


(printf "Part 1~n")

(define (list-in-equal-halves lst)
  (define midpoint (/ (length lst) 2))
  (cons
   (list->set (take lst midpoint))
   (list->set (list-tail lst midpoint))))

(define (prepare-list x) (map list-in-equal-halves (map string->list x)))

(define common-elements (map (lambda (x) (set-intersect (car x) (cdr x))) (prepare-list INPUT)))



(define (char->value x)
  (cond
    [(and (char>=? x #\a) (char<=? x #\z)) (add1 (- (char->integer x) (char->integer #\a)))]
    [else (+ (- (char->integer x) (char->integer #\A)) 1 26)]))

(apply + (map (lambda (x) (apply + (map char->value (set->list x)))) common-elements))


(printf "Part 2~n")

(define (take-three-elements lst [acc empty])
  (cond
    [(equal? (length acc) 3) (cons acc (take-three-elements lst))]
    [(empty? lst) empty]
    [else (take-three-elements (rest lst) (cons (first lst) acc))]))

(define
  sets-of-three
  (map
   (lambda (x) (map (lambda (y) (list->set (string->list y))) x))
   (take-three-elements INPUT)))

(define
  badges
  (map (lambda (x) (set-first (set-intersect (first x) (second x) (third x)))) sets-of-three))

(apply + (map char->value badges))
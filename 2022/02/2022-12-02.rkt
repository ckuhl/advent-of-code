#lang racket

(define INPUT (file->lines "2022-12-02.txt"))

(define split-input (map string-split INPUT))

(printf "Part 1~n")

(define points
  (make-hash
   (list
    (cons (list "A" "X") 4)
    (cons (list "A" "Y") 8)
    (cons (list "A" "Z") 3)
    (cons (list "B" "X") 1)
    (cons (list "B" "Y") 5)
    (cons (list "B" "Z") 9)
    (cons (list "C" "X") 7)
    (cons (list "C" "Y") 2)
    (cons (list "C" "Z") 6))))

(apply + (map (lambda (x) (hash-ref points x)) split-input))


(printf "Part 2~n")

(define new-points
  (make-hash
   (list
    (cons (list "A" "X") 3)
    (cons (list "A" "Y") 4)
    (cons (list "A" "Z") 8)
    (cons (list "B" "X") 1)
    (cons (list "B" "Y") 5)
    (cons (list "B" "Z") 9)
    (cons (list "C" "X") 2)
    (cons (list "C" "Y") 6)
    (cons (list "C" "Z") 7))))

(apply + (map (lambda (x) (hash-ref new-points x)) split-input))

#lang racket

(require rackunit)

(define INPUT (file->string "2022-12-06.txt"))

; ==============================================================================
; Helpers
(define (find-index-of-marker s [index 0] [marker-length 4])
  (define segment (substring s index (+ marker-length index)))

  (if
   (equal? marker-length
           (set-count (list->set (string->list segment))))
   (+ index marker-length)
   (find-index-of-marker s (add1 index) marker-length)))


; ==============================================================================
(printf "Part 1~n")

(define (solve-part-1 x [index 0])
  (find-index-of-marker x index 4))

(check-equal? (solve-part-1 "mjqjpqmgbljsphdztnvjfqwrcgsmlb") 7)
(check-equal? (solve-part-1 "bvwbjplbgvbhsrlpgdmjqwftvncz") 5)
(check-equal? (solve-part-1 "nppdvjthqldpwncqszvftbrmjlhg") 6)
(check-equal? (solve-part-1 "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") 10)
(check-equal? (solve-part-1 "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") 11)

(solve-part-1 INPUT)


; ==============================================================================
(printf "Part 2~n")

(define (solve-part-2 x [index 0])
  (find-index-of-marker x index 14))

(check-equal? (solve-part-2 "mjqjpqmgbljsphdztnvjfqwrcgsmlb") 19)
(check-equal? (solve-part-2 "bvwbjplbgvbhsrlpgdmjqwftvncz") 23)
(check-equal? (solve-part-2 "nppdvjthqldpwncqszvftbrmjlhg") 23)
(check-equal? (solve-part-2 "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") 29)
(check-equal? (solve-part-2 "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") 26)

(solve-part-2 INPUT)

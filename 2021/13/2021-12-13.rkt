#lang racket

(define LINES (file->lines "2021-12-13.txt"))

(define EXAMPLE (file->lines "example.txt"))


; ==============================================================================
; Helpers

(define (str->point s) (map string->number (string-split s ",")))

; ==============================================================================
(printf "Part 1~n")

; ==============================================================================
(printf "Part 2~n")

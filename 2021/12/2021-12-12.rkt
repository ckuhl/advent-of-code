#lang racket

(define LINES (file->lines "2021-12-12.txt"))

(define EXAMPLE1
  (list
   "start-A"
   "start-b"
   "A-c"
   "A-b"
   "b-d"
   "A-end"
   "b-end"))

(define EXAMPLE2
  (list
   "dc-end"
   "HN-start"
   "start-kj"
   "dc-start"
   "dc-HN"
   "LN-dc"
   "HN-end"
   "kj-sa"
   "kj-HN"
   "kj-dc"))

; Determine if a symbol represents a big room
(define (big? v)
  (define s (symbol->string v))
  (equal? s (string-upcase s)))

(define (extract-graph lst)
  (map
   (lambda (x) (map string->symbol (string-split x "-")))
   lst))

; Given a symbol and a list of lists of connections, return all values that
;  appear as one-half of a connection
(define (get-adjacent v connections)
  (filter
   (lambda (x) (not (empty? x)))
   (map
    (lambda (x)
      (cond
        [(equal? v (first x)) (second x)]
        [(equal? v (second x)) (first x)]
        [else '()]))
    connections)))

; Give a value, remove all connections to that value
(define (remove-value v connections)
  (filter
   (lambda (x) (not (member v x)))
   connections))


; The number of paths is the number of times 'end appears in the tree
(define (path-count t)
  (cond
    [(equal? t 'end) 1]
    [(symbol? t) 0]
    [else (apply + (map path-count t))]))

; ==============================================================================
(printf "Part 1~n")

; Find all paths from v to 'end
(define (find-paths-no-revisit v connections)
  (cond
    [(equal? v 'end) (list v)]
    [(not (big? v))
     (cons
      v
      (map
       (lambda (x) (find-paths-no-revisit x (remove-value v connections)))
       (get-adjacent v connections)))]
    [else
     (cons
      v
      (map
       (lambda (x) (find-paths-no-revisit x connections))
       (get-adjacent v connections)))]))

(path-count (find-paths-no-revisit 'start (extract-graph LINES)))


; ==============================================================================
(printf "Part 2~n")

; Find all paths from v to 'end, possibly revisiting a single small room twice
;  We keep track of rooms we've seen, until we see one twice
(define (find-paths-one-revisit v connections [seen '()])
  (printf "~v: ~v~n" v seen)
  (cond
    [(equal? v 'end) (list v)]

    ; Small room: Use revisit
    [(and (not (big? v)) (member v seen))
     (printf "switching~n")
     (cons
      v
       (map
        (lambda (x) (find-paths-no-revisit x connections))
        (get-adjacent v connections)))]

    ; Big room: Keep all connections
    [else
     (cons
      v
      (map
       (lambda (x) (find-paths-one-revisit x connections (cons v seen)))
       (get-adjacent v connections)))]))

(path-count (find-paths-one-revisit 'start (extract-graph LINES)))

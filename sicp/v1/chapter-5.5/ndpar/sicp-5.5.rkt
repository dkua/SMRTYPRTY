#lang racket

;; -------------------------------------------------------
;; Compiler Tests and Exercises
;; -------------------------------------------------------

;; Object program in factorial.scm

(display (compile
 '(define (factorial n)
    (if (= n 1)
        1
        (* (factorial (- n 1)) n)))
 'val
 'next))

;; Exercise 5.33, p.594
;; Object program in factorial-alt.scm

(display (compile
 '(define (factorial n)
    (if (= n 1)
        1
        (* n (factorial (- n 1)))))
 'val
 'next))

;; Exercise 5.34, p.594
;; Object program in factorial-iter.scm

(display (compile
 '(define (factorial n)
    (define (iter prod count)
      (if (< n count)
          prod
          (iter (* count prod)
                (+ count 1))))
    (iter 1 1))
 'val
 'next))

;; Exercise 5.35, p.595

(display (compile
 '(define (f x)
    (+ x (g (+ x 2))))
 'val
 'next))

;; Exercise 5.36, p.595
;; Order of evaluation

(display (compile
 '(define (f x y) (+ x y))
 'val
 'next))

;; Exercise 5.37, p.595
;; Compiler stack optimizations

; diff out/ex-5.37-optimized.scm out/ex-5.37-no-optimization.scm
; 35 redundant saves and 35 redundant restores

; 1  6  16
; 2  9  52
; 3 12  88
; 4 15 124
; 5 18 160
; 6 21 196

; Factorials
; ┌────────────────────────┬─────────┬──────────┐
; │                        │max depth│ # pushes │
; │                        │ (space) │  (time)  │
; ├────────────────────────┼─────────┼──────────┤
; │preserving     (ex 5.45)│  3n - 1 │  6n -  1 │
; │w/o preserving (ex 5.37)│  3n + 3 │ 36n - 20 │
; └────────────────────────┴─────────┴──────────┘

;; Exercise 5.38, p.595
;; Open-coded procedures

(display (compile
 '(define (f x y)
    (* (+ x y) (- x y)))
 'val
 'next))

(compile
 '(define (f x y)
    (* (+ x y) (- x y))))

(display (compile
 '(define (g x y)
    (+ (+ (* x x)
          (* y y))
       (+ (* x y)
          (* y x))))
 'val
 'next))

(compile
 '(define (g x y)
    (+ (+ (* x x)
          (* y y))
       (+ (* x y)
          (* y x)))))

(display (compile
 '(define (h a b c d)
    (+ a b c d))
 'val
 'next))

(compile
 '(define (h a b c d)
    (+ a b c d)))

; 1  3  3
; 2  3  5
; 3  4  7
; 4  6  9
; 5  8 11
; 6 10 13

; Factorials
; ┌────────────────────┬─────────┬────────┐
; │                    │max depth│# pushes│
; │                    │ (space) │ (time) │
; ├────────────────────┼─────────┼────────┤
; │generic    (ex 5.45)│  3n - 1 │ 6n - 1 │
; │open-coded (ex 5.38)│  2n - 2 │ 2n + 1 │
; └────────────────────┴─────────┴────────┘

;; -------------------------------------------------------
;; Lexical Addressing
;; -------------------------------------------------------

;; Exercise 5.42, p.602

(compile
 '(let ((x 3) (y 4))
    ((lambda (a b c d e)
       (let ((y (* a b x))
             (z (+ c d x)))
         (* x y z)))
     1 2 3 4 5)))

(display (compile
 '(let ((x 3) (y 4))
    ((lambda (a b c d e)
       (let ((y (* a b x))
             (z (+ c d x)))
         (* x y z)))
     1 2 3 4 5))
 'val
 'next))

;; Exercise 5.43, p.603

(display (scan-out-defines
 '((define x 5) (define y 6) (+ x y))))

(compile
 '(let ((x 3) (y 4))
    ((lambda (a b c d e)
       (define y (* a b x))
       (define z (+ c d x))
       (* x y z))
     1 2 3 4 5)))

;; Exercise 5.44, p.603

(compile
 '(define (f + * a b x y)
    (+ (* a x) (* b y))))

(f * + 1 3 2 4) ;=> 14 (before), 21 (after)

;; -------------------------------------------------------
;; Compiler + Evaluator
;; -------------------------------------------------------

;; Exercise 5.45.a, p.608
;; Compiler efficiency

(compile
 '(define (factorial n)
    (if (= n 1)
        1
        (* (factorial (- n 1)) n))))

; 1  3  5
; 2  5 11
; 3  8 17
; 4 11 23
; 5 14 29
; 6 17 35

; Recursive factorials
; ┌─────────────────────┬─────────┬──────────┐
; │                     │max depth│ # pushes │
; │                     │ (space) │  (time)  │
; ├─────────────────────┼─────────┼──────────┤
; │interpretor (ex 5.27)│  5n + 3 │ 32n - 16 │
; │compiler    (ex 5.45)│  3n - 1 │  6n -  1 │
; │reg.machine (ex 5.14)│  2n - 2 │  2n -  2 │
; ├─────────────────────┼─────────┼──────────┤
; │compiler/interpretor │     3/5 │     3/16 │
; │machine/interpretor  │     2/5 │     1/16 │
; └─────────────────────┴─────────┴──────────┘

;; Exercise 5.46, p.609
;; Compiler efficiency

(compile
 '(define (fib n)
    (if (< n 2)
        n
        (+ (fib (- n 1)) (fib (- n 2))))))

; 2  5  15  1
; 3  8  25  2
; 4 11  45  3
; 5 14  75  5
; 6 17 125  8
; 7 20 205 13

; Recursive Fibonacci
; ┌─────────────────────┬─────────┬──────────────────┐
; │                     │max depth│     # pushes     │
; │                     │ (space) │      (time)      │
; ├─────────────────────┼─────────┼──────────────────┤
; │interpretor (ex 5.29)│  5n + 3 │ 56 Fib(n+1) - 40 │
; │compiler    (ex 5.46)│  3n - 1 │ 10 Fib(n+1) -  5 │
; │reg.machine  (ex 5.6)│  2n - 2 │                  │
; ├─────────────────────┼─────────┼──────────────────┤
; │compiler/interpretor │     3/5 │             5/28 │
; │machine/interpretor  │     2/5 │                  │
; └─────────────────────┴─────────┴──────────────────┘

;; Exercise 5.47, p.609
;; Compiled proc calls interpreted proc

(compile
 '(define (f x y)
    (+ (g x) (g y))))

(define (g x) (* x x))

(f 3 4)

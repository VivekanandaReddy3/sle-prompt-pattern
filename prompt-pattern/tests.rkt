#lang racket

(require rackunit
         "main.rkt")

(define-pattern greet
  #:slots (name tone)
  (system "Your tone is {tone}.")
  (user "Hello {name}."))

(test-case "render fills slots into messages"
  (define out (render greet #:name "Vivek" #:tone "warm"))
  (check-equal? (length out) 2)
  (check-equal? (hash-ref (first out) 'role) "system")
  (check-equal? (hash-ref (first out) 'content) "Your tone is warm.")
  (check-equal? (hash-ref (second out) 'role) "user")
  (check-equal? (hash-ref (second out) 'content) "Hello Vivek."))

(test-case "render errors when a slot value is missing at call time"
  (check-exn exn:fail?
             (lambda () (render greet #:name "Vivek"))))

(test-case "pattern records its declared slots and messages"
  (check-equal? (pattern-slots greet) '(name tone))
  (check-equal? (length (pattern-messages greet)) 2))

#lang prompt-pattern

;; This file is intentionally broken: {missing} is not in #:slots.
;; Loading or running it MUST fail at compile time with a clear
;; syntax error pointing at the offending template line.

(define-pattern bad
  #:slots (name)
  (user "Hello {name}, your account balance is {missing}."))

#lang racket

;; A minimal usage demo, matching the style of MetaLib chrestomathy members.
;; Run with: racket prompt-pattern/usage.rkt

(require "main.rkt")

(define-pattern greeting
  #:slots (name tone)
  (system "You are an assistant. Your tone is {tone}.")
  (user "Say hello to {name}."))

(for ([m (in-list (render greeting #:name "Vivek" #:tone "warm"))])
  (printf "[~a] ~a~n"
          (hash-ref m 'role)
          (hash-ref m 'content)))

#lang prompt-pattern

(define-pattern greeting
  #:slots (name tone)
  (system "You are an assistant. Your tone is {tone}.")
  (user "Say hello to {name}."))

(define result (render greeting #:name "Vivek" #:tone "warm"))

(for ([m (in-list result)])
  (printf "[~a] ~a~n"
          (hash-ref m 'role)
          (hash-ref m 'content)))

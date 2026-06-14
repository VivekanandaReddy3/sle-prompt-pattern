#lang prompt-pattern

(define-pattern support-bot
  #:slots (question company)
  (system "You are a support agent for {company}. Be concise.")
  (user "How do I get a refund?")
  (assistant "Go to Settings -> Billing -> Refund.")
  (user "Can I cancel my subscription?")
  (assistant "Account -> Cancel.")
  (user "{question}"))

(define result
  (render support-bot
          #:company "Acme"
          #:question "Where do I find my invoice?"))

(for ([m (in-list result)])
  (printf "[~a] ~a~n"
          (hash-ref m 'role)
          (hash-ref m 'content)))

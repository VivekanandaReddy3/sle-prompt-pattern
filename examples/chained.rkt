#lang prompt-pattern

;; Two things this example shows.
;;
;; 1. PROMPT CHAINING. Impromptu (Clariso & Cabot, MODELS 2023) offers an
;;    explicit `chain` construct for feeding one prompt's result into the
;;    next. In a *hosted* DSL we get that for free: a pattern is an ordinary
;;    Racket value and `render` returns ordinary data, so a chain is just
;;    plain Racket — no new language construct is needed.
;;
;; 2. INTERCHANGE FORMAT. `render` returns a `jsexpr`, so the prompt is
;;    one `jsexpr->string` away from being an API-ready JSON request body.

(require json)

;; Stage 1 — summarise a document.
(define-pattern summarize
  #:slots (document)
  (system "You summarise text in a single sentence.")
  (user "Summarise the following:\n{document}"))

;; Stage 2 — translate some text into a target language.
(define-pattern translate
  #:slots (text language)
  (system "You are a translator. Reply with only the translation.")
  (user "Translate into {language}:\n{text}"))

;; Render stage 1 into chat-completion messages.
(define step1 (render summarize #:document "Racket lets programmers build new languages."))

;; In a live pipeline the model's reply to step1 would arrive here. We pin a
;; fixed reply so the example stays deterministic and runs offline.
(define model-reply "Racket is a language for building languages.")

;; The chain: feed stage 1's (model) reply as a slot value into stage 2.
(define step2 (render translate #:text model-reply #:language "German"))

(printf "— stage 1 messages —~n")
(for ([m (in-list step1)])
  (printf "[~a] ~a~n" (hash-ref m 'role) (hash-ref m 'content)))

(printf "~n— stage 2 messages (chained on stage 1's reply) —~n")
(for ([m (in-list step2)])
  (printf "[~a] ~a~n" (hash-ref m 'role) (hash-ref m 'content)))

(printf "~n— stage 2 as API-ready JSON —~n~a~n" (jsexpr->string step2))

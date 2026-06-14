#lang racket

(require (for-syntax syntax/parse))

(provide define-pattern
         render
         pattern?
         pattern-slots
         pattern-messages
         (all-from-out racket))

;; ----------------------------------------------------------------------------
;; Abstract syntax — the AST a pattern compiles to.
;; ----------------------------------------------------------------------------

(struct pattern (name slots messages) #:transparent)
(struct message (role template) #:transparent)

;; ----------------------------------------------------------------------------
;; Compile-time helpers.
;; A slot reference looks like {name} inside a template string.
;; ----------------------------------------------------------------------------

(define-for-syntax slot-ref-rx
  #px"\\{([A-Za-z_][A-Za-z0-9_]*)\\}")

(define-for-syntax (slot-refs-in str)
  (for/list ([groups (in-list (regexp-match* slot-ref-rx str #:match-select cdr))])
    (string->symbol (car groups))))

;; ----------------------------------------------------------------------------
;; The core macro.
;;
;; (define-pattern name
;;   #:slots (s1 s2 ...)
;;   (role "template with {slot} refs")
;;   ...)
;;
;; Expansion-time well-formedness check: every {slot} referenced in any
;; template must appear in the declared #:slots list. Otherwise we raise
;; a syntax error before the program is even allowed to run.
;; ----------------------------------------------------------------------------

(define-syntax (define-pattern stx)
  (syntax-parse stx
    [(_ name:id
        (~seq #:slots (slot:id ...))
        (~and msg (role:id template:str)) ...)
     (define declared (map syntax-e (syntax->list #'(slot ...))))
     ;; Walk the *original* message forms (msg ...) in lock-step with their
     ;; template strings. Using the original syntax (not a freshly built
     ;; copy) means a reported error carries the source location of the
     ;; offending line in the user's program, not of this macro.
     (for ([m (in-list (syntax->list #'(msg ...)))]
           [t (in-list (syntax->list #'(template ...)))])
       (for ([r (in-list (slot-refs-in (syntax-e t)))])
         (unless (memq r declared)
           (raise-syntax-error
            'define-pattern
            (format "slot {~a} is referenced in a template but not declared in #:slots ~a"
                    r declared)
            m))))
     #'(define name
         (pattern 'name
                  '(slot ...)
                  (list (message 'role template) ...)))]))

;; ----------------------------------------------------------------------------
;; Runtime: fill templates with the supplied keyword arguments.
;; Result is a list of {role, content} hasheqs — a `jsexpr` in Racket's
;; `json` vocabulary, i.e. the chat-completion shape, ready to be written
;; with `jsexpr->string` and POSTed to an LLM API.
;; ----------------------------------------------------------------------------

(define render
  (make-keyword-procedure
   (lambda (kws vals pat)
     (unless (pattern? pat)
       (error 'render "expected a pattern, got: ~v" pat))
     (define env
       (for/hash ([k (in-list kws)] [v (in-list vals)])
         (values (string->symbol (keyword->string k)) v)))
     (for ([s (in-list (pattern-slots pat))])
       (unless (hash-has-key? env s)
         (error 'render "missing required slot: ~a" s)))
     (for/list ([m (in-list (pattern-messages pat))])
       (hasheq 'role (symbol->string (message-role m))
               'content (fill-template (message-template m) env))))))

(define (fill-template template env)
  (regexp-replace* #px"\\{([A-Za-z_][A-Za-z0-9_]*)\\}"
                   template
                   (lambda (_ name)
                     (define v (hash-ref env (string->symbol name) #f))
                     (if v (format "~a" v)
                         (error 'render "missing slot: ~a" name)))))

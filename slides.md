---
marp: true
theme: default
paginate: true
size: 16:9
style: |
  section { font-size: 24px; padding: 60px 80px; }
  section.title { display: flex; flex-direction: column; justify-content: center; }
  h1 { color: #0b3d6e; }
  h2 { color: #0b3d6e; border-bottom: 2px solid #0b3d6e; padding-bottom: 4px; }
  code { background: #f3f4f6; padding: 1px 5px; border-radius: 3px; }
  pre { background: #0f172a; color: #f8fafc; padding: 16px; border-radius: 6px; font-size: 18px; line-height: 1.4; }
  table { font-size: 20px; }
  th { background: #e8edf3; }
  .small { font-size: 18px; }
  .ref { font-size: 16px; color: #555; }
---

<!-- _class: title -->

# `#lang prompt-pattern`
## A chrestomathy member for prompt engineering, in Racket

Vivekananda Reddy Godala
SLE 2026 — Metaprogramming Assignment
University of Koblenz · Prof. Ralf Lämmel
2026-06-15

---

## Research context

**Prompt engineering** is becoming a real DSL domain.
Two notable recent approaches:

| Work | Style | Implementation |
|---|---|---|
| **Impromptu** — Clariso & Cabot, MODELS 2023 | external textual DSL | **Langium** (grammar workbench) |
| **DSPy** — Khattab et al., 2023 | embedded programming model | Python (signatures, modules, teleprompters) |

Both target the same domain — prompts as first-class artifacts — but
they sit at opposite ends of the metaprogramming spectrum.

<span class="ref">References: doi:10.1109/MODELS58315.2023.00020 · arXiv:2310.03714</span>

---

## The methodological frame: MetaLib

Schauss, Lämmel, Härtel, Heinz, Klein, Härtel, Berger.
*A Chrestomathy of DSL Implementations.* SLE 2017.

> *Implement the same DSL (FSML) across many metaprogramming
> approaches; compare via a feature model.*

MetaLib has implementations in **Java · Python · Haskell QQ · Scala ·
Rascal · MPS · Spoofax · EMF/Xtext · Racket · …**

**Gap in the prompt-engineering space:** existing tools (Impromptu,
DSPy) cover the two ends of the spectrum, but no **hosted-language**
implementation exists — despite Racket being a MetaLib member for FSML.

<span class="ref">Reference: doi:10.1145/3136014.3136038</span>

---

## Research question and methodology

**RQ.** What feature coverage does a Racket `#lang` realize for
prompt engineering, and where in the lifecycle does it catch errors
compared to Impromptu's Langium pipeline and DSPy's runtime modules?

**Method.** Implement a small `#lang prompt-pattern` in Racket and
document its feature coverage in the MetaLib vocabulary (abstract
syntax, concrete syntax, static semantics, translation semantics).

**Scope** — kept deliberately small: one macro, one runtime function,
~60 lines of language code. Three example programs. Three unit tests.

---

## The language

```racket
#lang prompt-pattern

(define-pattern support-bot
  #:slots (question company)
  (system "You are a support agent for {company}. Be concise.")
  (user "How do I get a refund?")
  (assistant "Go to Settings -> Billing -> Refund.")
  (user "{question}"))

(render support-bot
        #:company  "Acme"
        #:question "Where is my invoice?")
```

Result: a list of `{role, content}` hashes — chat-completion-shape
JSON, ready for an LLM API.

---

## The two metaprogramming moves

**1. `#lang prompt-pattern` — a 2-line module reader.**
```racket
#lang s-exp syntax/module-reader
prompt-pattern
```
Reuses Racket's s-expression reader; swaps the language bindings.

**2. `define-pattern` — compile-time slot well-formedness.**

At expansion time:
- read the `#:slots (...)` declaration
- scan each template string for `{slot}` references
- `raise-syntax-error` if any reference is undeclared

Programs that reference an undeclared `{slot}` **never reach run time.**

---

## Live demo — greeting

```racket
#lang prompt-pattern
(define-pattern greeting
  #:slots (name tone)
  (system "You are an assistant. Your tone is {tone}.")
  (user "Say hello to {name}."))

(render greeting #:name "Vivek" #:tone "warm")
```

Output:
```
[system] You are an assistant. Your tone is warm.
[user]   Say hello to Vivek.
```

---

## Live demo — the headline insight

```racket
#lang prompt-pattern
(define-pattern bad
  #:slots (name)
  (user "Hello {name}, your balance is {missing}."))
```

The program **fails to compile**:

```
define-pattern: slot {missing} is referenced in a template
  but not declared in #:slots (name)
  at: (user "Hello {name}, your balance is {missing}.")
```

The error is raised by `raise-syntax-error` during macro expansion.
The program never produces a runtime — the bad reference is gone
before `render` ever exists.

---

## Feature coverage — MetaLib vocabulary

| MetaLib feature | Realization in `#lang prompt-pattern` |
|---|---|
| Abstract syntax — AST | `pattern` / `message` structs |
| Concrete syntax — textual | s-expressions under a custom `#lang` |
| Parsing — Text-to-AST | Racket reader + `define-pattern` macro |
| Static semantics — Analysis | compile-time `{slot}` reference check |
| Static semantics — Piggyback | identifier scoping delegated to Racket |
| Translation — Compilation | macro expands to a runtime `pattern` value |
| Translation — Staging | slot extraction at expansion time |
| Dynamic semantics — Interpretation | `render` fills templates at run time |

---

## Where slot well-formedness is caught

| Tool | Style | Slot check at |
|---|---|---|
| **Impromptu** (Langium) | external DSL | parse / validator time |
| **DSPy** (Python) | embedded library | **run time** |
| **`#lang prompt-pattern`** (Racket) | hosted DSL via macros | **macro-expansion time** |

The MetaLib chrestomathy frame **explains why** this matters —
the three tools occupy distinct positions in the feature model and
catch the same class of error at different stages of the lifecycle.

Generalizing the methodology to N approaches yields a **PromptLib**
in the spirit of MetaLib.

---

<!-- _class: title -->

## Reproduce it

GitHub: **github.com/VivekanandaReddy3/sle-prompt-pattern**

```
make install   # raco pkg install
make test      # 3 rackunit tests
make demo      # examples/greeting.rkt
make few-shot  # examples/few-shot.rkt
make bad       # examples/bad-pattern.rkt — compile-time error
```

Thank you. Questions?

<span class="ref">References:
Schauss, Lämmel et al., *A Chrestomathy of DSL Implementations*, SLE 2017.
Clariso & Cabot, *Model-Driven Prompt Engineering*, MODELS 2023.
Khattab et al., *DSPy*, arXiv:2310.03714, 2023.</span>

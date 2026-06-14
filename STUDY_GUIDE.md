# SLE 2026 Study Guide — Metaprogramming Assignment

> Personal study notes for the SLE course (Prof. Ralf Lämmel,
> University of Koblenz). Covers the lecture concepts that matter for
> tomorrow's metaprogramming presentation, what the assignment asks for,
> what we built, and an honest grade assessment.

---

## Part 1 — Foundations of Software Language Engineering

### 1.1 What is a "software language"?

A **software language** is any formal notation used to build, describe,
configure, query or model software. Not just programming languages.

Concrete examples — every one of these is a software language:

| Kind                    | Examples                                  |
| ----------------------- | ----------------------------------------- |
| Programming languages   | Python, Java, Racket, Haskell             |
| Markup                  | HTML, Markdown, LaTeX                     |
| Configuration           | YAML, JSON, TOML                          |
| Query                   | SQL, GraphQL, XPath                       |
| Modeling                | UML, ER diagrams, state-machine notations |
| Domain-Specific (DSLs)  | Regex, CSS, Makefile, Gradle              |

### 1.2 What is Software Language Engineering (SLE)?

The discipline of **designing, implementing, and maintaining software
languages** — including their syntax, semantics, tooling, evolution,
and ecosystem.

The lifecycle of a language: *design → implementation → use →
documentation → migration → retirement.* SLE covers all of it.

### 1.3 Why bother?

Because instead of writing the same boilerplate code over and over, you
can invent a *small language* that describes the problem directly.
A SQL query is shorter and clearer than the equivalent code that walks
hash tables. A regex is shorter than the equivalent if-else state machine.

---

## Part 2 — DSLs (the core of the course)

### 2.1 What's a DSL?

A **Domain-Specific Language** is a language designed for one narrow
problem domain instead of being general-purpose.

The running example in this course is **FSML** — a tiny DSL for
describing Finite State Machines (think turnstiles, traffic lights,
vending machines). The same FSML example is used across every lecture
so you can see different approaches side-by-side.

A trivial FSML program:

```
initial state locked {
  ticket / collect -> unlocked;
  pass / alarm -> exception;
}
state unlocked {
  ticket / eject;
  pass -> locked;
}
```

### 2.2 Internal vs external DSLs

Two fundamentally different styles:

| Style       | Means                                          | Examples              |
| ----------- | ---------------------------------------------- | --------------------- |
| **External** | Has its own syntax and its own parser. Looks unlike any host language. | SQL, CSS, regex |
| **Internal** | Lives inside a "host" language. You're writing host-language code that *looks like* a DSL. | jQuery's chaining, Ruby on Rails routes |

A special, more powerful sub-flavor of internal DSL:

- **Hosted DSL** — uses the host language's *language-extension features*
  (macros, syntax extensions, custom `#lang`) so it really does have its
  own syntax, but built *inside* the host. Racket and Haskell are famous
  for this. **This is what we are doing.**

### 2.3 DSL services (what tooling you need to build around a DSL)

When you ship a DSL, you typically also build:

- a **parser** (text → tree)
- a **well-formedness checker** (static semantics)
- an **interpreter** or **code generator** (dynamic or translation
  semantics)
- a **visualizer** (rendering the program graphically)
- often **editor support** (syntax highlighting, autocomplete) — see LSP
  in Part 6

---

## Part 3 — Syntax: concrete and abstract

### 3.1 Concrete syntax

The **concrete syntax** is the actual text you type. Defined by a
**grammar** — typically in BNF or EBNF notation.

Example EBNF fragment for FSML:
```
fsm        ::= state+
state      ::= ('initial')? 'state' name '{' transition* '}'
transition ::= event ('/' action)? ('->' name)? ';'
```

EBNF is just BNF with convenience operators (`?` for optional, `*` for
zero-or-more, `+` for one-or-more, `|` for alternatives).

### 3.2 Abstract syntax

The **abstract syntax** is the tree structure that survives after parsing
strips away punctuation, whitespace, and keywords. It's what the
*semantic* machinery operates on.

For FSML, an abstract syntax could be:
```
type fsm        = state*
type state      = initial × name × transition*
type transition = event × action? × name?
```

This is the **abstract syntax tree (AST)**.

If your language allows references between nodes (e.g. a transition
target *referring to* a state declared elsewhere), the structure becomes
a **graph** — an **abstract syntax graph (ASG)**. Lecture 03 calls the
distinction *tree-based* vs *graph-based* abstract syntax.

### 3.3 Conformance

A concrete-syntax program **conforms** to an abstract-syntax definition
when its parsed tree matches the AST schema. Conformance is the
relationship between the two layers.

### 3.4 Parsing

**Parsing** is the act of turning concrete syntax into abstract syntax.
A parser is a program (often generated from a grammar) that reads text,
checks it against the grammar rules, and produces the AST.

---

## Part 4 — Semantics

A language's *semantics* answers "what does this program mean?"
Three flavors:

| Flavor                  | Question                       | Example                                    |
| ----------------------- | ------------------------------ | ------------------------------------------ |
| **Static semantics**    | Is the program well-formed?    | type-checking, "is every variable declared?" |
| **Dynamic semantics**   | What does it do when you run it? | interpreter that simulates state transitions |
| **Translation semantics** | What does it compile to?     | generate C code from the FSML              |

For FSML specifically:
- *Static* example — every transition's target must refer to a declared
  state.
- *Dynamic* example — an interpreter that takes the FSM and a sequence
  of events and walks through the state changes.
- *Translation* example — generate C code with a giant `switch` statement.

---

## Part 5 — Metaprogramming (the heart of the assignment)

### 5.1 What metaprogramming is

**Metaprogramming** is writing programs that read, generate, check or
transform other programs. Implementing a DSL is metaprogramming because
your code (the DSL implementation) treats other code (the DSL programs
your users write) as *data*.

The "meta-meta level" — your meta-program is itself written in some
host language, and that host language has its own grammar and
semantics, etc. Languages all the way down.

### 5.2 The four classic techniques

| Technique                | What it does                                                     | Best fit             |
| ------------------------ | ---------------------------------------------------------------- | -------------------- |
| **Term rewriting / transformation** | Pattern-match parts of the program tree; rewrite to new shapes. | Rascal, Stratego |
| **Attribute grammars**   | Annotate the syntax tree with computed properties (types, scopes). | JastAdd, Kiama   |
| **Templates / translation** | Generate target code by filling blanks in a template.            | Xtend, Velocity |
| **Multi-stage programming** | Run some computation at *compile time*, the rest at *run time*. Two stages. | MetaOCaml, Racket macros, Template Haskell |

### 5.3 Object-program representation

The thing your meta-program manipulates (a parsed program, AST, model)
is called the **object program**. Common representations:

- **In-memory data structures** (records, structs, classes)
- **Interchange formats** like **XML**, **JSON**, **YAML** — useful
  when crossing tool/language boundaries

### 5.4 Metaprogramming systems and language workbenches

A **language workbench** is a tool/IDE built to help you create
languages and their tooling.

| Tool         | Style                                |
| ------------ | ------------------------------------ |
| **Xtext**, **Langium** | grammar-based external DSLs    |
| **MPS**                | projectional editing (no parser!) |
| **Spoofax**, **Rascal** | research/academic SLE workbenches |
| **Racket** (`#lang`)   | language *family* — extend the host    |
| **Haskell** quasi-quotation | embed external syntax via brackets |

---

## Part 6 — The chrestomathy methodology (Lecture 04, this is THE paper)

### 6.1 What's a chrestomathy?

A **chrestomathy** is a collection of programs that solve the *same
task* in *many different styles* — useful for *learning* by comparison.
The most famous example is [Rosetta Code](https://rosettacode.org/).

### 6.2 MetaLib

**MetaLib** = the chrestomathy by Schauss, Lämmel, Härtel, Heinz, Klein,
Härtel, Berger (*A Chrestomathy of DSL Implementations*, SLE 2017,
doi:10.1145/3136014.3136038).

- They picked one DSL (FSML).
- They implemented it in **14 different metaprogramming approaches**
  (Java, Python, Haskell QQ, Scala, Rascal, MPS, Spoofax, EMF/Xtext,
  **Racket**, …).
- They compared all 14 with a **feature model** capturing what each
  implementation does and doesn't cover.

The feature-model dimensions (from MetaLib Section 4):

- Abstract syntax (AST / ASG / model editing / serialization)
- Concrete syntax (textual / graphical, parsing / projectional editing)
- Static semantics (analysis / piggyback)
- Translation semantics (compilation / staging)
- Dynamic semantics (interpretation)

You will see those words in your slides. They are the prof's own
vocabulary — using them shows you read his paper.

### 6.3 Why this matters for OUR assignment

The assignment asks you to **pick one approach and do a small
experiment**, in the prompt-engineering domain. The natural framing is:
*"I am extending MetaLib's methodology to a new domain by implementing
one chrestomathy member in Racket."* That is exactly what we are doing.

---

## Part 7 — LSP (Lecture 05, for the 3rd assignment — skim only)

The **Language Server Protocol** is the standard that lets you write
the language *once* (parser, type-checker, autocomplete) and have it
work in every editor (VS Code, IntelliJ, Emacs, …) without re-writing.
Not relevant to *this* assignment, but you'll be choosing between LSP
and ontologies for the 3rd assignment in July.

---

## Part 8 — The assignment

### 8.1 What it actually asks

From the OLAT post by Prof. Lämmel:

> *The assignment is concerned with metaprogramming broadly and with
> DSL implementation more specifically. The domain for this assignment
> is "prompt engineering". Course participants need to pick an approach
> for DSL implementation and develop a VERY (!) small experiment for
> language implementation within the domain.*

Boiled down:

1. **Pick one approach** from the prof's list (you picked **Racket**).
2. **Pick a piece of the prompt-engineering domain** to model with a
   small DSL.
3. **Build a VERY small experiment** — small is explicitly OK.
4. **Present 10 min + 5 min Q&A** on 2026-06-15 / 16:15.
5. **Submit** a GitHub link + the slide PDF by reply on the OLAT thread.

### 8.2 The presentation metamodel (from the reading assignment, applies here too)

The prof grades against a metamodel with 1+ slide per item:

| Slide block                          | Our coverage                                     |
| ------------------------------------ | ------------------------------------------------ |
| Title                                | Slide 1                                          |
| Research context + challenge         | Slide 2 (Impromptu, DSPy) + Slide 3 (MetaLib)    |
| Research question + methodology      | Slide 4                                          |
| Key insights                         | Slides 5–10 (language + demos + comparison)      |
| Optional: reproduction               | Slide 11 (repo link + Makefile commands)         |

### 8.3 The prof's hard rules (from his feedback on the reading assignment)

- *"You must abstract and help us all to understand the essence."*
- *"You must be able to answer clarifying questions. Don't give us an
  AI summary."*
- *"For best grades, try reproducing some aspect of the paper in an
  inspiring manner."*

This is **why we built actual working code**, not just slides about an
approach. The live demo IS the reproduction.

---

## Part 9 — What we built and why

### 9.1 The choice: Racket

Reasons that hold up if challenged:

- **MetaLib has a `racket` chrestomathy member** — we follow his own
  paper's example.
- The assignment list cites a recent **Racket SLE 2024 paper**
  (doi:10.1145/3687997.3695645).
- Racket's `#lang` + macro system is a unique point in the design space:
  *hosted* DSL — neither external grammar workbench (Aman's Langium)
  nor embedded library (DSPy).

### 9.2 The experiment: `#lang prompt-pattern`

A tiny custom language for declaring LLM prompt patterns. A user writes:

```racket
#lang prompt-pattern

(define-pattern greeting
  #:slots (name tone)
  (system "You are an assistant. Your tone is {tone}.")
  (user   "Say hello to {name}."))

(render greeting #:name "Vivek" #:tone "warm")
```

`render` returns a list of `{role, content}` hashes — chat-completion
shape, ready for an LLM API call.

### 9.3 The two metaprogramming moves (what makes this a real experiment)

**Move 1 — `#lang prompt-pattern` is a custom Racket `#lang`.**

A two-line file `prompt-pattern/lang/reader.rkt`:
```racket
#lang s-exp syntax/module-reader
prompt-pattern
```
registers a *module reader*. When Racket sees `#lang prompt-pattern`
at the top of any file, it reads the file as s-expressions and uses the
`prompt-pattern` collection as the language. Users get Racket plus our
`define-pattern` macro and `render` function.

**Move 2 — `define-pattern` does its work at *expansion time*.**

`define-pattern` is a `syntax-parse` macro. At expansion time:
1. It reads the `#:slots (...)` declaration.
2. It scans every template string for `{slot}` references using a regex.
3. If a reference isn't in `#:slots`, it calls `raise-syntax-error` —
   the program fails to compile.
4. Otherwise it expands to a plain `define` of a runtime `pattern`
   struct.

### 9.4 The headline insight (one-sentence version)

> *Slot well-formedness is caught at **macro-expansion time** —
> earlier in the lifecycle than Impromptu (parse/validator time) or
> DSPy (runtime).*

This is the single most important sentence in the whole presentation.
The MetaLib feature model and the chrestomathy frame are what
*explain why this is interesting*, not just clever.

### 9.5 Where this sits in the prompt-engineering DSL space

| Tool                          | Style                  | Slot check at          |
| ----------------------------- | ---------------------- | ---------------------- |
| Impromptu (Clariso & Cabot, MODELS 2023) | external DSL (Langium) | parse / validator time |
| DSPy (Khattab et al., 2023)   | embedded library (Python) | **run time**        |
| `#lang prompt-pattern` (ours) | hosted DSL (Racket)    | **macro-expansion time** |

### 9.6 What's in the repo

```
sle-prompt-pattern/
├── README.md                       MetaLib-style writeup with feature table
├── Makefile                        install / test / demo
├── examples/
│   ├── greeting.rkt
│   ├── few-shot.rkt
│   └── bad-pattern.rkt             intentionally fails at compile time
├── prompt-pattern/
│   ├── info.rkt                    package metadata
│   ├── main.rkt                    AST + macro + render (~60 lines)
│   ├── lang/reader.rkt             the 2-line module reader
│   ├── tests.rkt                   rackunit tests
│   └── usage.rkt                   plain-Racket usage demo
├── slides.md / slides.pptx / slides.pdf
└── STUDY_GUIDE.md                  this file
```

---

## Part 10 — Anticipated Q&A and answers in plain English

**Q. What does `#lang prompt-pattern` actually do?**
*A: It's a 2-line module reader. When Racket sees that line at the top
of a file, it reads the rest of the file as s-expressions and uses the
`prompt-pattern` collection as the language. The collection provides
the `define-pattern` macro, the `render` function, and re-exports
`racket` so the user has the full host language available.*

**Q. What does `define-pattern` actually expand to?**
*A: At expansion time it reads the `#:slots`, scans each template for
`{slot}` references, and either raises a syntax error (if a reference
is undeclared) or expands to a `define` of a runtime `pattern` struct
that holds the slot list and the list of `(role, template)` messages.*

**Q. Why not just do this with string templating in Python?**
*A: Two reasons. First, the slot-reference check would happen at
runtime, not at compile time — exactly the DSPy point. Second,
Python lacks first-class syntactic macros, so you can't really define
new language constructs. The hosted-DSL approach is the value
proposition.*

**Q. What does the chrestomathy framing buy you?**
*A: It explains why this experiment is interesting beyond "I built a
small DSL." Three tools (Impromptu, DSPy, ours) cover three points in
the metaprogramming design space, and they catch the same class of
error at different points in the lifecycle. The MetaLib feature model
is the vocabulary for comparing them. Generalizing the methodology
across all approaches yields a "PromptLib" in the spirit of MetaLib.*

**Q. Why Racket and not Haskell QQ or Rascal — those got more lecture coverage?**
*A: Three reasons. The assignment explicitly lists a recent Racket SLE
2024 paper. MetaLib has a Racket chrestomathy member, so I had a
reference implementation to mirror. And Racket's learning curve is the
most tractable in 3.5 weeks for someone with no prior Lisp background.*

**Q. What did you cover from the MetaLib feature model?**
*A: Abstract syntax (AST via structs), textual concrete syntax
(s-expressions under a custom `#lang`), parsing (Racket reader plus
the macro), static-semantics analysis (slot reference check), staging
(work done at expansion vs run time), translation (macro expanding to a
runtime value), and dynamic-semantics interpretation (`render` filling
slots).*

**Q. What did you NOT cover?**
*A: Graphical syntax — irrelevant in a textual prompt domain.
Projectional editing — also irrelevant. Full piggyback static semantics
beyond identifier scoping — out of scope for the experiment.*

**Q. What would extending it look like?**
*A: Prompt chaining (Impromptu has it). Hyperparameter declarations.
Multi-modal inputs. A code generator from the pattern to actually call
an OpenAI / Anthropic API. A small benchmarking harness to compare
outputs across LLMs.*

---

## Part 11 — Honest grade assessment

### 11.1 What we have that's genuinely good (gets you to ~1.3-1.7)

- **The framing is unusually strong.** Most students will say *"I built
  a small DSL."* You will say *"I extended Lämmel's own chrestomathy
  methodology to a new domain, and I sit at a specific point in the
  design space defined by Impromptu, DSPy, and my work."* That framing
  alone separates you from the median.
- **You cite two papers the prof gave you** (Impromptu, DSPy) plus his
  own (MetaLib) plus the assignment-listed Racket SLE 2024 paper. Four
  citations is heavy for a 10-minute talk.
- **The implementation works** — three passing tests, three runnable
  demos, including the failing one. Many students at this level will
  show slides only; you'll show working code.
- **The headline insight is concrete and defensible.** "Slot
  well-formedness is caught at macro-expansion time, earlier than
  Impromptu or DSPy" is a real comparison statement.

### 11.2 What might keep you below 1.0

- **The implementation is genuinely small (~60 lines).** The prof said
  "VERY small experiment" is OK, but a 1.0 presentation usually feels
  like the student went *one step further* than the minimum.
- **No actual LLM call.** The demos render to chat-completion JSON but
  never hit an API. Adding that would close the loop end-to-end.
- **No feature-model picture.** The README has a *table*, but a feature
  diagram (in the MetaLib visual style — see the original paper's
  Fig. 2) on a slide is more striking than a table.
- **Macro Stepper isn't part of the rehearsed demo.** If you walk
  through `define-pattern` expansion in DrRacket's Macro Stepper, the
  prof sees you really know what the macro is doing — that's a 1.0
  move.

### 11.3 What you could add tonight to push toward 1.0

In rough order of effort vs. payoff:

1. **Rehearse a Macro Stepper demo** (15 min) — open `greeting.rkt`
   in DrRacket, choose Racket → Macro Stepper, step through
   `define-pattern`. Practice 2–3 times. Add one line to slide 6:
   *"Live: Macro Stepper walks through `define-pattern` expansion."*
2. **Add a feature-model diagram to slide 9** (30 min in Keynote) —
   recreate MetaLib's Figure 2 (Abstract syntax / Concrete syntax /
   Static / Dynamic / Translation semantics as a feature tree) and
   highlight the leaves your implementation covers. This is *exactly*
   how MetaLib documents its members. Easy 0.3-grade gain.
3. **Add an `examples/api-call.rkt`** (45 min) — uses `http-easy` to
   actually POST to the OpenAI/Anthropic API with the rendered prompt
   and prints the response. End-to-end demo, even if you don't run it
   live tomorrow.
4. **Add a prompt-chaining example** (45 min) — a pattern that
   references another pattern's output, mirroring Impromptu's `chain`
   concept. Shows you read Impromptu deeply.

Realistic path: **items 1 + 2 are doable tonight without risk**. Items
3 and 4 only if Keynote design and rehearsal go faster than expected.

### 11.4 Bottom line

What you have *as-is* should grade in the **1.3–1.7** range based on
the prof's prior feedback patterns (he praised your reading assignment
presentation). Adding items 1 and 2 from §11.3 likely pushes it to
**1.0–1.3**. Adding items 3 or 4 only if there's time.

The single biggest grade lever isn't more code — it's **how
confidently you defend the work in Q&A**. Re-read Part 10 until you
can answer every question without looking at notes. That's what
separates 1.0 from 1.3.

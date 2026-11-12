# Where egglog resists

egglog comes from compilers. There, an equality is a theorem: once two
terms are known equal they stay equal, and nobody asserted it. In a
catalogue, an identity is testimony: a source says it, at some level, it
can be withdrawn, and another source may have judged the two things
different.

This file lists what happened when the second kind of identity was written
in a tool built for the first. Each entry is a requirement, a program in
`frictions/` that tests it, and what the program printed. Nothing here is
from documentation or memory: every "observed" was run.

All observations are for **egglog 3.0.0**, built from crates.io on
12 November 2026. They describe one version of one tool. Several look like
choices that suit its intended use; none is offered as a defect.

## What works as is

- **Levels.** One sort per level (`Sheet`, `State`, `Plate`). A sheet and a
  plate cannot be unioned by accident.
- **Identity goes up, not down.** With `state-of` and `plate-of` as
  constructors, congruence gives "same sheet, so same state, so same
  plate" and never the reverse. No rule had to be written for it.
- **Trying a hypothesis.** `(push)`, assume an identifier is a key at some
  level, run, read the contradictions, `(pop)`. The whole audit is that.
- **Explaining an identity.** With `--proofs`, `(prove (= a b))` returns
  the rule that fired and the facts it used. For the two sheets that
  Wikidata's inventory numbers bring together, the proof names the reading
  of Wikidata's statements, the hypothesis, and the four facts they rest
  on (`cases/three-crosses/expected/explain.txt`).

## Differences

**01. A difference between objects does not survive their identification.**
`(different (sheet "a") (sheet "b"))`, then a union of the two, leaves
`(different (sheet "a") (sheet "a"))`. The row is rewritten along with
everything else. A difference stated between the two *names* survives and
can be checked against the union. So a judged difference has to be carried
by signs, not by the objects they stand for. The audit does this: its
differences are between inventory names.

**07. "Not equal" means "not identified so far".** A rule that concludes
`different` from `(!= x y)` fires before the union, and its conclusion is
still in the database after it. `!=` cannot stand for a judged difference.

**10. A difference has no proof.** `(prove (!= a b))` succeeds, and returns
a certificate that both terms exist and that the test passed. An identity
has a derivation; a difference is only the absence of one.

## Refusals

**02. A refused union aborts the run.** A `:no-merge` function is egglog's
own way to say that two things must not be merged. When a union violates
it, the program stops with exit code 1 and one line on stderr. Output
printed before that point is not shown. There is no verdict to read and no
indication of which identifications led there.

**03. A caught refusal leaves the union in place.** Wrapping the union in
`(fail ...)` lets the program continue. The two sheets are then identified
anyway, and one of the two inventory names has disappeared. Refusing is not
the same as not doing.

**11. Refusals and proofs exclude each other.** Under `--proofs`, a
`:no-merge` function is rejected before the program runs ("All functions
need to specify a :merge function").

The audit therefore uses neither `:no-merge` nor `(fail ...)`. A
contradiction is a row derived by a rule, read inside a `(push)`.

## Levels

**04. A question across levels cannot be written.** `(= (sheet ...)
(bartsch ...))` is a type error. That keeps levels apart, which is wanted.
It also means "is this sheet that plate?" has no answer of the form
"undetermined": it is not a sentence. Every bridge between levels is a
function someone declares.

## Sources

**06. One congruence, so one source at a time.** Two sources that disagree
cannot both be held as two sets of identifications. Each can be tried
inside `(push)` ... `(pop)`, but nothing computed inside survives the pop,
the verdict included. Comparing sources means reading egglog's output from
outside. Coloured e-graphs address this gap for `egg` [1]; a 2025 paper
describes bringing contextual equality to egglog as ongoing work [2].

**09. A proof knows the rule, not the author.** Asserted facts appear in
proofs as `Fiat`. The author of a judgment shows up only if the source was
written into the fact as an argument. That is easy to do, and it has to be
done everywhere, by convention.

## Withdrawal

**05. A judgment can be deleted; its consequences cannot.** Deleting the
row that caused a union leaves the union. Deleting one of the two terms and
creating it again does separate them, but an attribute that one sheet
acquired from the other while they were one stays with it. There is no
retraction, only starting again.

The wall-drawings case has a withdrawal that happened in the world: a wall
in Houston was Wall Drawing #679, and after it was painted over its holder
wrote that the drawing lives on as papers.
[`cases/wall-drawings/withdrawn.egg`](cases/wall-drawings/withdrawn.egg)
writes this twice. With `union`, the wall and the papers become one thing
and the engine proves it. Without `union`, as a relation with two dates,
the answers are right and can still be proved. But then equality takes no
part in the case at all: nothing is merged and nothing propagates, and
the engine does what a Datalog would do. An identity that holds for a time
has no form here between those two.

## Absence

**08. "Unchecked" needs negation, and rules have none.** A rule cannot
test that a row is absent. The audit gets "this pair was identified and no
record says anything about it" from two booleans with
`:merge (or old new)`, set to `false` when the pair is found and to `true`
by the rules that judge it, and read in a ruleset that runs afterwards. It
works because the rulesets are run in a fixed order. The order is the
negation.

## Smaller things

- Strings have no ordering in rules (`<` is numeric), so records carry an
  index to list each pair once.
- `(include "facts.egg")` is resolved from the working directory, not from
  the including file. `check.sh` changes directory for that reason.
- With `--proofs`, the merge functions used for "unchecked" draw a
  warning that the program is not in proof normal form. The audit prints
  the same output with and without the flag.

## References

1. E. Singher and S. Itzhaky, "Colored E-Graph: Equality Reasoning with
   Conditions", 2023. https://arxiv.org/abs/2305.19203
2. "Towards Relational Contextual Equality Saturation", 2025.
   https://arxiv.org/abs/2507.11897
3. Y. Zhang et al., "Better Together: Unifying Datalog and Equality
   Saturation", PLDI 2023. https://arxiv.org/abs/2304.04332

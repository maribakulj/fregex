# fregex

An experiment on one question: **at which level is an identifier a key?**

A Bartsch number, a museum inventory number and a Wikidata item can all be
attached to "the same print". They do not identify the same thing. One
names a copper plate, another a state of that plate, another a single sheet
in a drawer. Reconciliation pipelines that treat "same identifier" as "same
object" are right at one level and wrong one level down.

This branch writes that question in [egglog](https://github.com/egraphs-good/egglog)
and runs it on one real case. It has two results: the level of each
identifier in the case, and a list of the places where egglog, built for a
different kind of equality, resists.

## The case

Rembrandt's *Three Crosses* (Bartsch 78, New Hollstein 274): ten
impressions in four collections, transcribed by hand from the public
records. [`cases/three-crosses/SOURCES.md`](cases/three-crosses/SOURCES.md)
gives the page behind every row.

Three levels: **plate**, **state**, **sheet**. An identifier is a key at a
level if reading "same value" as "same object at that level" contradicts no
judged difference. Two kinds of difference are used: an inventory
individuates sheets, and two records that count states in the same
catalogue and give different numbers place their sheets in different
states.

| Identifier, as cited in the records | Plate | State | Sheet | Level |
|---|---|---|---|---|
| Bartsch number (`78`) | key | 11 contradictions | 15 contradictions | plate |
| New Hollstein number (`274`) | key | 14 contradictions | not run | plate |
| Bartsch number with state (`78-3(5)`) | | key | 2 contradictions | state |
| New Hollstein number with state (`274-3(5)`) | | key | 2 contradictions | state |
| Rijksmuseum persistent identifier | | | key | sheet |
| Met object ID | | | key | sheet |
| Wikidata Q1218084, through its inventory numbers | key | undetermined | 1 contradiction | plate |

The last row is the one that is not obvious. The Wikidata item for the
print lists inventory numbers from several museums. Read as a key for
sheets, it makes one sheet out of an impression in Amsterdam and one in New
York. Read as a key for states, nothing contradicts it and nothing
confirms it: the Rijksmuseum counts its impression as state 3 in New
Hollstein, the Met calls its own "the second state" without naming a
catalogue, and the two numbers cannot be compared. Those two rows rest on
search-result text, not on the live item; see `SOURCES.md`.

The numbers are in
[`cases/three-crosses/expected/audit.txt`](cases/three-crosses/expected/audit.txt).

## Where egglog resists

[`FRICTIONS.md`](FRICTIONS.md) has eleven observations, each with a program
in `frictions/` and its recorded output. In short:

| Requirement | What egglog 3.0.0 does |
|---|---|
| A judged difference is a fact | A difference between objects is rewritten away by their union; only one between names survives |
| A contradicted identification is refused, readably | The run aborts and its output is discarded; if the error is caught, the union stays |
| Sources that disagree are kept side by side | One congruence; one source at a time inside `push`/`pop`; verdicts do not survive the `pop` |
| A judgment can be withdrawn | The row can be deleted; what followed from it remains |
| "Undetermined" is a verdict | Rules have no negation; obtained from a merge function and the order of rulesets |
| An identity can be traced to its author | Proofs name the rule and the facts; the author only if written into the fact |

What needed no work: sorts as levels, identity that propagates upward and
not downward, hypotheses tried with `push`/`pop`, and proofs of identities.

## Running it

```sh
cargo install egglog --locked --version 3.0.0
./check.sh
```

`check.sh` runs every program and compares its output with the file in the
neighbouring `expected/` directory. `./check.sh --update` records the
current output instead.

To run one program by hand, do it from its own directory, because
`(include ...)` is resolved from the working directory:

```sh
cd cases/three-crosses
egglog audit.egg
egglog --proofs explain.egg
```

## Limits

- One case, ten records. The table says what holds for these records, not
  for Bartsch numbers or Wikidata in general.
- The facts were transcribed by hand. There is no extraction step, so
  nothing here tests what a regular expression or a model would do to
  these identifiers.
- The state numbers for the Rijksmuseum depend on reading `-3(5)` as
  "state 3 of 5", which the pages do not spell out.
- The Wikidata rows were not checked against the live item.
- The frictions are observations of egglog 3.0.0 on programs written by
  someone new to it. A more idiomatic encoding may avoid some of them.

## The name

Frege asked how `a = b` can tell us something that `a = a` does not. His
answer was that two expressions can reach the same object by different
routes. Here the routes are identifiers, and the experiment asks which
object each one reaches.

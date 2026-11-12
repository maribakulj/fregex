# fregex

An experiment on one question: **at which level can an identifier be read
as a key?**

A Bartsch number, a museum inventory number and a Wikidata item can all be
attached to "the same print". They do not identify the same thing. One
names a copper plate, another a state of that plate, another a single sheet
in a drawer. Treating "same identifier" as "same object" can be right at
one level and wrong one level down.

This branch writes that question in [egglog](https://github.com/egraphs-good/egglog)
and runs it on one real case. It has two results: what the records of the
case allow one to say about each identifier, and a list of the places where
egglog, built for a different kind of equality, resists.

## The case

Rembrandt's *Three Crosses* (Bartsch 78, New Hollstein 274): ten
impressions in four collections, and two impressions of a second plate,
*Christ Presented to the People* (Bartsch 76), so that plates can differ.
Everything is transcribed by hand from the public records.
[`cases/three-crosses/SOURCES.md`](cases/three-crosses/SOURCES.md) gives
the page behind every row.

Three levels: **plate**, **state**, **sheet**. A hypothesis says that two
records carrying the same value of an identifier present the same object
at a level. The audit applies it, lists the pairs of records it
identifies, and sorts each pair by what the records themselves say:

- **refuted**: a judged difference contradicts the identification;
- **corroborated**: an independent judgment agrees and none contradicts;
- **unchecked**: no record says anything either way.

A hypothesis that identifies no pair is **untested**. Judgments that come
from the identifier under audit are left out: a Bartsch number is not
evidence for itself.

The judgments are of three kinds. An inventory individuates sheets. A
catalogue individuates plates. Two records that count the states of one
plate in one catalogue agree or disagree about the state.

| Identifier | Read as key of | Pairs | Refuted | Corroborated | Unchecked | |
|---|---|---|---|---|---|---|
| Bartsch number (`78`) | plate | 16 | 0 | 16 | 0 | holds |
| | state | 16 | 12 | 4 | 0 | refuted |
| | sheet | 16 | 16 | 0 | 0 | refuted |
| Hollstein number | plate | 16 | 0 | 16 | 0 | holds |
| New Hollstein number (`274`) | plate | 22 | 0 | 21 | 1 | holds |
| | state | 22 | 9 | 2 | 11 | refuted |
| Hind number | plate | 0 | | | | untested |
| Bartsch number with state (`78-3(5)`) | plate | 2 | 0 | 2 | 0 | holds |
| | state | 2 | 0 | 2 | 0 | holds |
| | sheet | 2 | 2 | 0 | 0 | refuted |
| New Hollstein number with state | state | 2 | 0 | 2 | 0 | holds |
| | sheet | 2 | 2 | 0 | 0 | refuted |
| Rijksmuseum persistent identifier | sheet | 0 | | | | untested |
| Met object ID | sheet | 0 | | | | untested |
| Collector's mark (Lugt 240) | plate | 6 | 3 | 3 | 0 | refuted |
| | state | 6 | 6 | 0 | 0 | refuted |
| | sheet | 6 | 6 | 0 | 0 | refuted |
| Wikidata Q1218084, inventory numbers read as identities | plate | 1 | 0 | 0 | 1 | unchecked |
| | state | 1 | 0 | 0 | 1 | unchecked |
| | sheet | 1 | 1 | 0 | 0 | refuted |
| Wikidata Q1218084, Met object ID read as identity | sheet | 0 | | | | untested |

"Holds" means: corroborated on these pairs and refuted on none. It does not
mean the identifier is a key in general.

Three rows are worth reading.

**The persistent identifiers are untested.** Every value is different, so
"same value, same sheet" identifies nothing. Nothing contradicts it and
nothing could.

**The collector's mark would have passed.** Lugt 240 is stamped on three
impressions of the Three Crosses. With that plate alone, reading it as a
key of the plate is corroborated three times and refuted never. The fourth
sheet that carries it is an impression of another plate, and that refutes
it.

**Wikidata's item is unchecked even at the level of the plate.** The item
lists inventory numbers from several museums. Read as a key of sheets, it
makes one sheet out of an impression in Amsterdam and one in New York, and
the inventories refute that. Read as a key of the plate, it identifies the
same two records, and no record confirms it: the Met record carries no
catalogue number, so nothing here says, independently of Wikidata, that the
two are impressions of one plate. Those rows rest on search-result text,
not on the live item; see `SOURCES.md`.

The numbers are in
[`cases/three-crosses/expected/audit.txt`](cases/three-crosses/expected/audit.txt).
The proof egglog gives for the Wikidata identification, with the reading
and the hypothesis as two named steps, is in
[`expected/explain.txt`](cases/three-crosses/expected/explain.txt).

## Where egglog resists

[`FRICTIONS.md`](FRICTIONS.md) has eleven observations, each with a program
in `frictions/` and its recorded output. In short:

| Requirement | What egglog 3.0.0 does |
|---|---|
| A judged difference is a fact | A difference between objects is rewritten away by their union; only one between names survives |
| A contradicted identification is refused, readably | The run aborts and its output is discarded; if the error is caught, the union stays |
| Sources that disagree are kept side by side | One congruence; one source at a time inside `push`/`pop`; verdicts do not survive the `pop` |
| A judgment can be withdrawn | The row can be deleted; what followed from it remains |
| "Unchecked" is a verdict | Rules have no negation; obtained from a merge function and the order of rulesets |
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
current output instead. The audit also carries its own `check` assertions,
which fail the run whatever the recorded output says: identity must not go
down a level, merging two sheets must be reported, and an unchecked pair
must be neither refuted nor corroborated.

To run one program by hand, do it from its own directory, because
`(include ...)` is resolved from the working directory:

```sh
cd cases/three-crosses
egglog audit.egg
egglog --proofs explain.egg
```

## Limits

- One case, twelve records, two plates. The table says what holds for
  these records.
- A plate is not a catalogue entry. No record here individuates plates
  except through a catalogue, so the audit can show two catalogues
  disagreeing and cannot show one being wrong.
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

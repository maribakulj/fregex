# fregex

An experiment on one question: **at which level can an identifier be read
as a key?**

A Bartsch number, a museum inventory number and a Wikidata item can all be
attached to "the same print". They do not identify the same thing. One
names a copper plate, another a state of that plate, another a single sheet
in a drawer. Treating "same identifier" as "same object" can be right at
one level and wrong one level down.

This branch writes that question in [egglog](https://github.com/egraphs-good/egglog)
and runs it on two real cases. It has two results: what the records of
each case allow one to say about its identifiers, and a list of the places
where egglog, built for a different kind of equality, resists. A second
engine, in Prolog, then runs the same audit on the same facts, and the two
are compared.

## The first case: a print

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

## The second case: wall drawings

The first case has a lowest level that lasts: the sheet, which an
inventory number names. The second has none. A wall drawing by Sol LeWitt
is drawn on a wall from instructions and can be painted over. The Whitney's
records for *Wall Drawing #289* give its dimensions as variable and say
that its only permanent form is a set of guidelines and a certificate.
[`cases/wall-drawings/SOURCES.md`](cases/wall-drawings/SOURCES.md) gives
the page behind every row.

**An inventory number that names no object.** The Whitney has four numbers
for #289, one per wall. The fourth, 78.1.4, was drawn at the Whitney in
2015 and again in 2018–19. The same wall is drawn at MASS MoCA, where its
credit line carries the range `78.1.1-4`. Read as a key of what is on the
wall, the number identifies three pairs of executions:

| Identifier | Read as key of | Pairs | Refuted | Unchecked |
|---|---|---|---|---|
| Whitney accession number (`78.1.4`) | the drawn wall | 3 | 2 | 1 |

Two pairs are refuted: the wall was drawn in North Adams and in New York
at the same time. The third is the two Whitney executions, and it is
unchecked: no page says on which surface either was drawn. Nothing on the
pages could corroborate a pair, so that column is absent.

In the Three Crosses the inventory number was the one identifier that
individuated the lowest level, and it refuted the others. Here it names the
plan, and the lowest level has no identifier at all.

The same two pairs contradict a sentence from an essay on these works,
that they exist in one place at a time. This holds for the sentence taken
literally, and it assumes that the wall at MASS MoCA has stayed drawn since
2008, which its pages imply and do not state.

**An identity that was withdrawn.** *Wall Drawing #679* was drawn in a
house in Houston in 1991. The Menil Collection inherited the house, painted
the drawing over before selling, and wrote that the drawing lives on only
as a certificate and a diagram. If the two statements are read as
identities, egglog proves that a wall in Houston is the papers in the
Menil's files, and names the two statements it used. If they are read as
"realizes, between two dates", the answers by year are the right ones: in
1995 a wall; in 2015 a wall painted over and papers at the Menil; in 2018
a wall being uncovered that no record calls the work. But nothing is
merged any more, and egglog's equality has left the case.

The outputs are in
[`expected/executions.txt`](cases/wall-drawings/expected/executions.txt)
and [`expected/withdrawn.txt`](cases/wall-drawings/expected/withdrawn.txt).

## Where egglog resists

[`FRICTIONS.md`](FRICTIONS.md) has eleven observations, each with a program
in `frictions/` and its recorded output. In short:

| Requirement | What egglog 3.0.0 does |
|---|---|
| A judged difference is a fact | A difference between objects is rewritten away by their union; only one between names survives |
| A contradicted identification is refused, readably | The run aborts and its output is discarded; if the error is caught, the union stays |
| Sources that disagree are kept side by side | One congruence; one source at a time inside `push`/`pop`; verdicts do not survive the `pop` |
| A judgment can be withdrawn | The row can be deleted; what followed from it remains |
| An identity can hold for a time | A union is permanent; a relation with dates works and uses no equality |
| "Unchecked" is a verdict | Rules have no negation; obtained from a merge function and the order of rulesets |
| An identity can be traced to its author | Proofs name the rule and the facts; the author only if written into the fact |

What needed no work: sorts as levels, identity that propagates upward and
not downward, hypotheses tried with `push`/`pop`, and proofs of identities.

## The same audit in Prolog

The list above reads as a specification. [`prolog/levels.pl`](prolog/levels.pl)
is an engine written to it, for SWI-Prolog, in about two hundred lines. A
case tells it six things: what is compared, which identifiers each thing
bears, what the sources judge the same or different and at which level,
how the levels are ordered, and which evidence is the identifier under
another name. A hypothesis is an argument, so nothing is assumed and
nothing is undone.

It reads the same `facts.egg` as egglog, through a small grammar
([`prolog/egg.pl`](prolog/egg.pl)), so there is one transcription and not
two.

**The two engines agree.** On the Three Crosses, the 21 hypotheses give the
same four numbers in both; on the wall drawings, the same three.
`check.sh` compares them on every run.

**What the requirements become.**
[`frictions/requirements.pl`](frictions/requirements.pl) puts each one to
the engine on a made-up case:

| Requirement | In Prolog |
|---|---|
| A judged difference is a fact | A row with a source; it is still there when the two things are identified, and that is what refutes |
| A contradicted identification is refused, readably | A verdict, with its reasons, and the run goes on; nothing is left behind |
| Sources that disagree are kept side by side | Both rows are kept; the pair is refuted and marked contested |
| A judgment can be withdrawn | Retracting the row changes every verdict that rested on it |
| An identity can hold for a time | A judgment carries a period; a chain of identities is followed only through judgments in force at the date asked |
| "Unchecked" is a verdict | One negation |
| An identity can be traced to its author | The source is an argument of every judgment and comes out with the verdict |

**What the dates change.** `withdrawn.egg` had to choose between an
identity that made a wall the same thing as papers, and a relation with
dates that used no identity. In
[`withdrawn.pl`](cases/wall-drawings/withdrawn.pl) "is" stays an identity
in both readings. Without dates the wall is the papers, as in egglog. With
them, the wall is the work in 1995, the papers are the work in 2015, and
the wall is the papers in none of the years asked.

**Two notations are read by a grammar.** The rows that `facts.egg` gives
for `78-3(5)` (a number, a state) were written by hand; `audit.pl` reads
the fourteen strings and checks the rows against the reading. The four
rows that `executions.egg` writes for the range `78.1.1-4` are produced by
a grammar in `executions.pl`. The second reading is a relation from one
string to several.

**What Prolog costs.** Three things egglog gave for nothing:

- Levels are not sorts. A judgment that a sheet and a wall are the same
  plate is accepted without complaint.
- "Same sheet, so same plate" and "two plates, so two sheets" are two
  rules of the engine, not a property of the language.
- An explanation is a chain that the engine builds for the two questions
  it knows how to explain. egglog's proofs cover any equality.

## Running it

```sh
cargo install egglog --locked --version 3.0.0
apt install swi-prolog-nox        # or: brew install swi-prolog
./check.sh
```

`check.sh` runs every program in both engines and compares its output
with the file in the neighbouring `expected/` directory, then compares the
two engines' numbers. `./check.sh --update` records the current output
instead. The case programs also carry their own assertions, which fail
the run whatever the recorded output says. In the first case: identity
must not go down a level, merging two sheets must be reported, and an
unchecked pair must be neither refuted nor corroborated. In the second:
the two overlaps, the pair left unchecked, and the years for which nothing
can be said.

To run one program by hand, do it from its own directory, because egglog
resolves `(include ...)` from the working directory:

```sh
cd cases/three-crosses
egglog audit.egg
egglog --proofs explain.egg
swipl audit.pl

cd ../wall-drawings
egglog executions.egg
egglog --proofs withdrawn.egg
swipl executions.pl
swipl withdrawn.pl

cd ../../frictions
swipl requirements.pl
```

## Limits

- Two small cases: twelve records and two plates; five executions of one
  wall and one drawing that was painted over. The tables say what holds
  for these records.
- The facts about Wall Drawing #679 come from two press articles, not from
  the Menil's records. The two statements read as identities in
  `withdrawn.egg` are readings of those articles.
- The overlap between MASS MoCA and the Whitney assumes that the wall at
  MASS MoCA was drawn without interruption.
- A plate is not a catalogue entry. No record here individuates plates
  except through a catalogue, so the audit can show two catalogues
  disagreeing and cannot show one being wrong.
- The facts were transcribed by hand. Two notations are now read by a
  grammar and checked against that transcription; nothing is extracted
  from the pages themselves, so nothing here tests what a regular
  expression or a model would do to these identifiers in the wild.
- The Prolog engine has run on a dozen records and five executions. It
  finds what a hypothesis identifies by plain search; nothing has been
  done for size.
- That egglog fails where Prolog works is shown on these small cases and
  on a made-up one. Neither engine has seen a corpus.
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

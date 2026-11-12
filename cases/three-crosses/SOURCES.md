# Sources for the Three Crosses case

Rembrandt, *Christ Crucified between the Two Thieves: The Three Crosses*,
drypoint, 1653 and later. Ten impressions in four collections.

Every row in `facts.egg` comes from one of the pages below, read on
12 November 2026. The pages were read through a fetch tool that returns a
summary of the page, not its source, so each value was asked for by name
and is given here as returned.

## Rijksmuseum, Amsterdam

| Object number | Catalogue references on the record | Persistent identifier |
|---|---|---|
| RP-P-OB-616 | Bartsch 78-1(5); Hollstein Dutch 78-1(5); New Hollstein 274-1(5) | https://id.rijksmuseum.nl/200124983 |
| RP-P-OB-617 | Bartsch 78-3(5); Hollstein Dutch 78-3(5); New Hollstein 274-3(5) | https://id.rijksmuseum.nl/200124981 |
| RP-P-OB-618 | Bartsch 78-4(5); Hollstein Dutch 78-4(5); New Hollstein 274-4(5) | https://id.rijksmuseum.nl/200124982 |
| RP-P-1962-39 | Bartsch 78-3(5); Hollstein Dutch 78-3(5); New Hollstein 274-3(5) | https://id.rijksmuseum.nl/200124978 |
| RP-P-1962-40 | Bartsch 78-4(5); Hollstein Dutch 78-4(5); New Hollstein 274-4(5) | https://id.rijksmuseum.nl/200124979 |

Record pages:

- RP-P-OB-616: https://www.rijksmuseum.nl/en/collection/object/The-Three-Crosses--f53eb6fbb41ca29f770062ee2f46ee12
- RP-P-OB-617: https://www.rijksmuseum.nl/en/collection/object/The-Three-Crosses--750d6b597e45ff8dd9205765e99b5051
- RP-P-OB-618: https://www.rijksmuseum.nl/en/collection/object/The-Three-Crosses--bc4fc02f13b46c3c7da618f5cb33b653
- RP-P-1962-39: https://www.rijksmuseum.nl/nl/collectie/object/RP-P-1962-39--7b9320dad7806437d71325eb4044f1dd
- RP-P-1962-40: https://www.rijksmuseum.nl/en/collection/object/The-Three-Crosses--3501fb5b891d3cfe6218ffd73d92a322

**A reading, not a transcription.** The pages do not label the `-3(5)`
suffix. `facts.egg` reads it as "state 3 of 5", which is how the
Rijksmuseum writes states and agrees with the other collections for the
fourth state. The `state-number` rows for the Rijksmuseum rest on that
reading.

## The Metropolitan Museum of Art, New York

| Object number | Object ID | State on the record | Catalogue number on the record |
|---|---|---|---|
| 41.1.31 | 354631 | not on its own page; the page for 41.1.33 says "see also the second state, 41.1.31" | none |
| 41.1.32 | 347371 | none | none |
| 41.1.33 | 359757 | "fourth state" | none |

- https://www.metmuseum.org/art/collection/search/354631
- https://www.metmuseum.org/art/collection/search/347371
- https://www.metmuseum.org/art/collection/search/359757

The Met names a state without naming the catalogue it counts in, so
`facts.egg` files its numbers under the scheme `met-unspecified` and never
compares them with New Hollstein numbers.

## National Gallery of Victoria, Melbourne

Accession number 1971-4. "4th of 5 states". Catalogue line: "Bartsch 78;
Hind 270 iv/v; White & Boon 78 iv/v; NHD 274 iv/v".

- https://ngv.vic.gov.au/explore/collection/work/40607

## The Cleveland Museum of Art

Accession number 1959.241. State "iv/v". Catalogue line: "Hollstein 78
(XVIII.43); White-Boon 78-iv; NH(Rembrandt).II.222.274.iv".

- https://www.clevelandart.org/art/135706

The record cites Hollstein 78, not Bartsch 78, so `facts.egg` has no
`bartsch` row for Cleveland.

## Wikidata Q1218084

**Not read directly.** The Wikidata page and the Wikimedia Commons category
could not be fetched. What `facts.egg` uses comes from the text that a web
search returned for those two pages on 12 November 2026:

- the Wikidata item "The Three Crosses (Q1218084)" carries "The Met object
  ID 354631" and the inventory number "RP-P-1962-39";
- the Commons category infobox, which is filled from Wikidata, lists
  "Inventory number: RP-P-1962-39 (Rijksmuseum) 41.1.31 (Metropolitan
  Museum of Art) 2003-188-1 (Philadelphia Museum of Art)".

- https://www.wikidata.org/wiki/Q1218084
- https://commons.wikimedia.org/wiki/Category:The_Three_Crosses

Only the two inventory numbers that match records above are used. The two
`wikidata-p217` rows should be checked against the live item before anyone
relies on them.

## Not used

The Philadelphia Museum of Art page for this print
(https://philamuseum.org/collection/object/275754) describes a fourth
state, but the fetched page showed no accession number, so it could not be
tied to the inventory number 2003-188-1 that Wikidata lists. It is left out.

# Sources for the wall-drawings case

Sol LeWitt, *Wall Drawing #289* (1976) and *Wall Drawing #679* (1991).

Every row in `facts.egg` comes from one of the pages below, read on
12 November 2026. The pages were read through a fetch tool that returns a
summary of the page, not its source, so each value was asked for by name
and is given here as returned.

## Whitney Museum of American Art, New York

*Wall Drawing #289*, catalogued as a series of four works, one per wall.

| Accession number | Title on the record | Page |
|---|---|---|
| 78.1.1 | 1st wall: 24 lines from the center | https://whitney.org/collection/works/25527 |
| 78.1.2 | 2nd wall: 12 lines from the midpoint of each of the sides | https://whitney.org/collection/works/25528 |
| 78.1.3 | 3rd wall: 12 lines from each corner | https://whitney.org/collection/works/25529 |
| 78.1.4 | 4th wall: 24 lines from the center, 12 lines from the midpoint of each of the sides, 12 lines from each corner | https://whitney.org/collection/works/25530 |

On each record: date 1976; classification Drawings; medium wax crayon,
graphite pencil and paint on wall; dimensions variable; part of the series
*Wall Drawing #289*, 4 works. The record text says that the only permanent
form of the work is "a set of typewritten guidelines and a certificate of
authenticity signed by the artist".

Executions of 78.1.4 at the Whitney, from the page of 78.1.4:

| Row in `facts.egg` | Exhibition | Dates | Where on the page |
|---|---|---|---|
| `whitney/america-is-hard-to-see` | *America Is Hard to See* | 1 May to 27 September 2015 | list of exhibitions |
| `whitney/programmed` | *Programmed: Rules, Codes, and Choreographies in Art, 1965–2018* | 28 September 2018 to 14 April 2019 | captions of the installation photographs |

The page does not say on which wall of the building either was drawn.

## MASS MoCA, North Adams

Page of the drawing: https://massmoca.org/event/walldrawing289/

- Fourth wall only.
- Date of the work: July 1976.
- Credit line: Whitney Museum of American Art, New York, purchase with
  funds from the Gilman Foundation, Inc., followed by `78.1.1-4`.
- First installation: Detroit Institute of Arts, with no date. Then The
  Museum of Modern Art, New York, January 1978, fourth wall only.
- First drawn by Jo Watanabe.
- Building 7, ground floor.

Page of the retrospective: https://massmoca.org/event/sol-lewitt/

- Opened 16 November 2008; on view through 2043.

Three things in `facts.egg` go beyond these two pages.

1. **Continuity.** The row `massmoca/retrospective` runs from 16 November
   2008 to 2043. The pages give the opening and the end of the
   retrospective. They do not say that this wall stayed drawn without
   interruption, and they mention a restoration in 2021–2022. The two
   overlaps found by `executions.egg` fall in 2015 and in 2018–2019 and
   depend on the wall having been up at MASS MoCA then.
2. **The range.** `78.1.1-4` is read as the four numbers 78.1.1 to 78.1.4.
   That reading is written in `executions.egg`, not in `facts.egg`.
3. **Detroit.** The page lists Detroit as the first installation and marks
   the next one "fourth wall only". That Detroit had all four walls is
   likely and not stated, so the row says `not stated` and has no dates.

## Wall Drawing #679

The Art Newspaper, 1 February 2018:
https://www.theartnewspaper.com/2018/02/01/hidden-lewitt-wall-drawing-may-once-again-see-light-of-day

- Made in 1991 for the Houston house of William Stern.
- Stern died in 2013; the house and his collection went to the Menil
  Collection.
- The Menil painted the drawing over when it decided to sell the house.
  The article gives no date for this.
- The house was bought in 2014.
- The buyers began to uncover the drawing in December 2017.
- David Aylsworth, collections registrar at the Menil, in a letter to the
  buyers: "The drawing lives on only as a certificate of authenticity and
  diagram".
- The buyers acknowledge that the Menil owns the drawing.

Glasstire: https://glasstire.com/?p=205315

- The Menil owns the certificate and the diagram and keeps the right to
  have the drawing made again.
- Statement of the Menil: "The artistic creation is in the design".

How the rows were derived:

- `(realizes "stern-house/wall" "679" 1991 2013)`: drawn in 1991, and
  still on the wall when the house came to the Menil in 2013, since it was
  the Menil that painted it over.
- `(painted-over-by "stern-house/wall" 2014)`: painted over before the
  sale, and the house was bought in 2014. The article does not say this in
  one sentence; it follows from the order of the events it tells.
- `(holds "menil" "certificate and diagram" "679" 2013)`: the holding is
  from Glasstire and from the registrar's letter, the year from the
  bequest.
- The two `says-is` rows in `withdrawn.egg` are readings, not
  transcriptions. No page says in so many words that the wall was the
  work. The first row stands for what a catalogue entry "Wall Drawing
  #679, 1991, Stern residence" is ordinarily taken to say. The second
  stands for the registrar's sentence.

## The sentence about one place

Creative Time, page on LeWitt for *The Plain of Heaven*, 2005:
https://creativetime.org/programs/archive/2005/Heaven/artists-lewitt.html

The essay says that the wall drawings "exist only in one place at any
time". This is the essay's own sentence. It is not given as LeWitt's, and
no page read here presents it as a rule of the artist or of the estate.
`executions.egg` tests the sentence taken literally and nothing else. The
same page quotes a note by LeWitt according to which a wall drawing is
permanent until it is destroyed.

## Read and not used

Harvard Art Museums, accession 2001.15.1, *Certificate for Wall Drawing
#128 (Ten Thousand Random Not Straight Lines)*, 1972, classification
Drawings: https://ai.harvardartmuseums.org/object/171166

Here an inventory number names the certificate itself, a sheet of paper.
It concerns another wall drawing, so no rule uses it.

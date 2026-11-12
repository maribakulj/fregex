% The requirements of FRICTIONS.md, put to the engine in prolog/levels.pl.
%
% Each line of output is a requirement, by the number of the observation
% that states it, and whether a test of it passes. The tests run on a
% small made-up case, as the egglog programs in this directory do.
%
% Run:  swipl requirements.pl

:- use_module('../prolog/levels').

:- initialization(main, main).

% --- A made-up case ---------------------------------------------------------
% Four sheets with one catalogue number; two of them with one mark.

subject(a, 1).
subject(b, 2).
subject(c, 3).
subject(d, 4).

bears(a, number, '78', stated).
bears(b, number, '78', stated).
bears(c, number, '78', stated).
bears(d, number, '78', stated).
bears(a, mark, '240', stated).
bears(b, mark, '240', stated).

finer(sheet, plate).

:- dynamic stated/6.

says(Source, Verdict, Level, A, B, During) :-
    stated(Source, Verdict, Level, A, B, During).

% Sources are written by(Who, When).
stated(by(inventory, 1900), different, sheet, a, b, always).
stated(by(first_reader, 1987),  same,      plate, a, b, always).
stated(by(second_reader, 2006),  different, plate, a, b, always).
stated(by(dealer, 1950),    same,      sheet, c, d, always).
stated(by(curator, 1960),   same,      plate, a, d, always).

stated(by(owner, 1991),     same, is, wall, work,   between(1991, 2013)).
stated(by(registrar, 2014), same, is, work, papers, from(2014)).

% A sheet and a wall, said to be the same plate. Nothing objects.
stated(by(nobody, 2000),    same, plate, a, wall, always).

% --- The requirements -------------------------------------------------------
% requirement(Number, Status, Text, Test)

requirement('01', met,
    "a judged difference survives the identification it contradicts",
    ( verdict(number, sheet, a, b, refuted),
      evidence(number, sheet, a, b, different(sheet), by(inventory, 1900))
    )).

requirement('07', met,
    "not identified is not judged different",
    ( \+ identified(mark, a, c),
      \+ evidence(mark, sheet, a, c, different(_), _)
    )).

requirement('10', met,
    "a difference has a derivation: who said it, and at which level",
    evidence(number, sheet, a, b, different(plate), by(second_reader, 2006))).

requirement('02', met,
    "a refused identification is a verdict, and the run goes on",
    ( findall(A-B-Verdict, verdict(number, plate, A, B, Verdict), Rows),
      memberchk(a-b-refuted, Rows),
      memberchk(b-c-unchecked, Rows)
    )).

requirement('03', met,
    "refusing leaves nothing behind",
    ( snapshot(Before),
      forall(verdict(_, _, _, _, _), true),
      snapshot(After),
      Before == After
    )).

requirement('11', met,
    "a refusal and its reasons come in the same answer",
    ( verdict(number, plate, a, b, refuted),
      evidence(number, plate, a, b, different(plate), _)
    )).

requirement('04', lost,
    "levels are not sorts: a sentence across levels is accepted",
    is_same(plate, any, a, wall, _)).

requirement('06', met,
    "two sources that disagree are both kept",
    ( contested(number, plate, a, b),
      evidence(number, plate, a, b, same(plate), by(first_reader, 1987)),
      evidence(number, plate, a, b, different(plate), by(second_reader, 2006))
    )).

requirement('06', met,
    "two hypotheses are held at once, and their verdicts stay",
    ( findall(Scheme-Verdict,
              ( member(Scheme, [number, mark]),
                verdict(Scheme, sheet, a, b, Verdict)
              ),
              Both),
      Both == [number-refuted, mark-refuted]
    )).

requirement('09', met,
    "the author of a judgment is in the answer",
    ( evidence(number, plate, a, b, same(plate), by(Who, When)),
      Who == first_reader,
      When == 1987
    )).

requirement('05', met,
    "withdrawing a judgment withdraws what followed from it",
    ( Judgment = stated(by(second_reader, 2006), different, plate, a, b, always),
      setup_call_cleanup(
          retract(Judgment),
          once(( verdict(number, plate, a, b, corroborated),
                 \+ contested(number, plate, a, b)
               )),
          assertz(Judgment)),
      verdict(number, plate, a, b, refuted)
    )).

requirement('08', met,
    "unchecked is one negation: no independent source says anything",
    ( verdict(number, plate, b, c, unchecked),
      \+ evidence(number, plate, b, c, _, _)
    )).

requirement('up', met,
    "identity goes up and not down, as two rules and not for free",
    ( verdict(number, plate, c, d, corroborated),
      evidence(number, plate, c, d, same(sheet), by(dealer, 1950)),
      verdict(number, sheet, a, d, unchecked)
    )).

requirement('time', met,
    "an identity can hold for a time",
    ( is_same(is, 1995, wall, work, _),
      is_same(is, 2015, work, papers, _),
      \+ is_same(is, 1995, wall, papers, _),
      \+ is_same(is, 2015, wall, papers, _),
      is_same(is, any, wall, papers, _)
    )).

snapshot(Clauses) :-
    findall(Fact,
            (   Fact = stated(_, _, _, _, _, _), clause(Fact, true)
            ;   Fact = bears(_, _, _, _), clause(Fact, true)
            ),
            Clauses).

main :-
    forall(requirement(Number, Status, Text, Test),
           report(Number, Status, Text, Test)).

% A requirement marked `lost` is one egglog met and this engine does not.
% Its test shows the loss, so that the line cannot go stale either.
report(Number, Status, Text, Test) :-
    (   \+ \+ call(Test)
    ->  format("~w~t~6|~w~t~12|~s~n", [Number, Status, Text])
    ;   format("~w~t~6|FAILS ~s~n", [Number, Text]),
        halt(1)
    ).

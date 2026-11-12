% One inventory number, two walls at once.
%
% executions.egg, on the same facts file, with the engine in
% prolog/levels.pl. The numbers are those egglog prints; check.sh
% compares them.
%
% Run:  swipl executions.pl

:- use_module('../../prolog/egg').
:- use_module('../../prolog/levels').
:- use_module(library(dcg/basics)).

:- initialization(main, main).

:- prolog_load_context(directory, Here),
   atomic_list_concat([Here, '/facts.egg'], Facts),
   load_egg_facts(Facts).

% --- What is compared -------------------------------------------------------

subject(Execution, Rank) :-
    execution(Execution, Rank, _, _, _, _, _).

% --- The notation "78.1.1-4" ------------------------------------------------
% MASS MoCA's credit line gives a range. A range names several numbers:
% the reading is a relation from one string to many, where executions.egg
% has four rows written by hand.

accession_range(Stem, From, To) -->
    stem(Stem), integer(From), "-", integer(To).

stem([Code|Codes]) --> [Code], stem(Codes).
stem([0'.])        --> ".".

range_member(Range, Member) :-
    atom_codes(Range, Codes),
    phrase(accession_range(Stem, From, To), Codes),
    From =< To,
    between(From, To, Last),
    format(atom(Member), "~s~d", [Stem, Last]).

% --- Identifiers ------------------------------------------------------------
% An execution bears an inventory number when the page attaches it,
% itself or inside a range, and the number is catalogued for its wall.

bears(Execution, 'inventory number', Number, stated) :-
    carries(Execution, accession, Number),
    catalogued_for(Execution, Number).
bears(Execution, 'inventory number', Number,
      reading('range-read-as-its-members',
              [carries(Execution, 'credit-line', Range)])) :-
    carries(Execution, 'credit-line', Range),
    range_member(Range, Number),
    catalogued_for(Execution, Number).

catalogued_for(Execution, Number) :-
    execution(Execution, _, _, Work, Walls, _, _),
    inventory_record(Number, _, Work, Walls).

% --- Judgments --------------------------------------------------------------
% Two places at one time, two walls. An execution whose end is not on the
% page cannot be tested. Nothing on the pages could say that two
% executions are one drawn wall, so there is no `same`.

says('two places at once', different, 'drawn wall', A, B, always) :-
    simultaneous(A, B).

simultaneous(A, B) :-
    execution(A, RankA, PlaceA, Work, Walls, FromA, UntilA),
    execution(B, RankB, PlaceB, Work, Walls, FromB, UntilB),
    RankA < RankB,
    PlaceA \== PlaceB,
    UntilA > 0,
    UntilB > 0,
    FromA =< UntilB,
    FromB =< UntilA.

% --- The audit --------------------------------------------------------------

main :-
    format("\"executions of the same wall in two places at once\"~n"),
    forall(simultaneous(A, B), format("  ~w  ~w~n", [A, B])),
    audit('inventory number', 'drawn wall',
          row(Pairs, Refuted, Corroborated, Unchecked)),
    expect(Corroborated =:= 0),
    format("\"inventory number as key of the drawn wall: identified, refuted, unchecked\"~n"),
    format("~d~n~d~n~d~n", [Pairs, Refuted, Unchecked]),
    forall(verdict('inventory number', 'drawn wall', A, B, Verdict),
           ( format("  ~w  ~w  ~w~n", [Verdict, A, B]),
             forall(evidence('inventory number', 'drawn wall', A, B, Says, Source),
                    format("      ~w: ~w~n", [Source, Says]))
           )),
    format("\"the notation 78.1.1-4, read\"~n"),
    forall(range_member('78.1.1-4', Member), format("  ~w~n", [Member])),
    assertions.

% --- These hold whatever the recorded output says ---------------------------

assertions :-
    expect(simultaneous('massmoca/retrospective',
                        'whitney/america-is-hard-to-see')),
    expect(simultaneous('massmoca/retrospective', 'whitney/programmed')),
    expect(verdict('inventory number', 'drawn wall',
                   'massmoca/retrospective', 'whitney/programmed', refuted)),
    % The range reads as four numbers, the ones executions.egg lists.
    expect(( findall(Member, range_member('78.1.1-4', Member), Members),
             Members == ['78.1.1', '78.1.2', '78.1.3', '78.1.4']
           )),
    % MASS MoCA's range covers four numbers and its wall bears only one.
    expect(bears('massmoca/retrospective', 'inventory number', '78.1.4', _)),
    expect_not(bears('massmoca/retrospective', 'inventory number', '78.1.1', _)),
    % The two Whitney executions: same place, different years. Not
    % refuted, and nothing says they are one drawn wall either.
    expect(verdict('inventory number', 'drawn wall',
                   'whitney/america-is-hard-to-see', 'whitney/programmed',
                   unchecked)),
    % An execution with no end date is never judged simultaneous.
    expect_not(simultaneous('moma/1978', _)),
    expect_not(simultaneous(_, 'moma/1978')).

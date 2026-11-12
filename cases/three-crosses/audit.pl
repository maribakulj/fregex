% At which level can each identifier be read as a key?
%
% The audit of audit.egg, on the same facts file, with the engine in
% prolog/levels.pl. The four numbers of each block are those egglog
% prints; check.sh compares them.
%
% What is different here:
%   a hypothesis is an argument, so there is no push and no pop;
%   "unchecked" is one negation, not two booleans and an order of rulesets;
%   a difference is a row with a source, and it can be asked for.
%
% Run:  swipl audit.pl

:- use_module('../../prolog/egg').
:- use_module('../../prolog/levels').
:- use_module(library(dcg/basics)).

:- initialization(main, main).

:- prolog_load_context(directory, Here),
   atomic_list_concat([Here, '/facts.egg'], Facts),
   load_egg_facts(Facts).

% --- What is compared -------------------------------------------------------

subject(Record, Rank) :-
    record(Record, Rank).

% --- Identifiers ------------------------------------------------------------

bears(Record, Scheme, Value, stated) :-
    cites(Record, Scheme, Value).

% Readings. Wikidata states that an item has an inventory number in a
% collection. Taking that to mean "the item is the thing with that
% inventory number" is a reading. It has a name, and the name comes out
% wherever the reading was used.

bears(Record, 'wikidata-p217', Item,
      reading('inventory-number-read-as-identity',
              [ wikidata_statement(Item, 'P217', Number, Collection),
                inventory_name(Record, Collection, Number)
              ])) :-
    wikidata_statement(Item, 'P217', Number, Collection),
    inventory_name(Record, Collection, Number).

bears(Record, 'wikidata-p3634', Item,
      reading('met-object-id-read-as-identity',
              [ wikidata_statement(Item, 'P3634', Id, Qualifier),
                cites(Record, 'met-object', Id)
              ])) :-
    wikidata_statement(Item, 'P3634', Id, Qualifier),
    cites(Record, 'met-object', Id).

% --- Levels -----------------------------------------------------------------

finer(sheet, state).
finer(state, plate).

% --- Families ---------------------------------------------------------------
% "78-3(5)" is the Bartsch number with something added. What Bartsch says
% about plates and states is the same evidence under another name.

family('bartsch-state', bartsch).
family('nh-state', 'new-hollstein').

source_family(catalogue(Catalogue), Catalogue).
source_family(states(Catalogue), Catalogue).

% --- Judgments --------------------------------------------------------------

% An inventory individuates sheets: two inventory names, two sheets.
says(inventory, different, sheet, A, B, always) :-
    record(A, _),
    record(B, _),
    A \== B.

% A catalogue individuates plates.
says(catalogue(Catalogue), same, plate, A, B, always) :-
    plate_catalogue(Catalogue),
    cites(A, Catalogue, Number),
    cites(B, Catalogue, Number),
    A \== B.
says(catalogue(Catalogue), different, plate, A, B, always) :-
    plate_catalogue(Catalogue),
    cites(A, Catalogue, NumberA),
    cites(B, Catalogue, NumberB),
    NumberA \== NumberB.

% A holder points from one of its records to another.
says(holder, same, plate, A, B, always) :-
    cross_reference(A, B).

% Two records agree or disagree about a state only when they count the
% states of one plate in one catalogue.
says(states(Catalogue), same, state, A, B, always) :-
    state_number(A, Catalogue, Number, State),
    state_number(B, Catalogue, Number, State),
    A \== B.
says(states(Catalogue), different, state, A, B, always) :-
    state_number(A, Catalogue, Number, StateA),
    state_number(B, Catalogue, Number, StateB),
    StateA \== StateB.

% --- The notation "78-3(5)" -------------------------------------------------
% The Rijksmuseum writes a catalogue number, a state and a number of
% states in one string. facts.egg carries the parts as separate rows,
% transcribed by hand. This is the reading that gives them.

state_citation(Number, State, Of) -->
    digits(NumberCodes), "-", integer(State), "(", integer(Of), ")",
    { NumberCodes = [_|_], atom_codes(Number, NumberCodes) }.

reads_as(String, Number, State, Of) :-
    atom_codes(String, Codes),
    phrase(state_citation(Number, State, Of), Codes).

written_with_state('bartsch-state', bartsch).
written_with_state('nh-state', 'new-hollstein').

% --- The audit --------------------------------------------------------------
% block(Scheme, Level, Verdicts to list with their evidence)

block(bartsch,          plate, []).
block(bartsch,          state, []).
block(bartsch,          sheet, []).
block(hollstein,        plate, []).
block('new-hollstein',  plate, [unchecked]).
block('new-hollstein',  state, []).
block(hind,             plate, []).
block('bartsch-state',  plate, []).
block('bartsch-state',  state, []).
block('bartsch-state',  sheet, [refuted]).
block('nh-state',       state, []).
block('nh-state',       sheet, []).
block('rijks-pid',      sheet, []).
block('met-object',     sheet, []).
block('lugt-mark',      plate, [refuted, corroborated]).
block('lugt-mark',      state, []).
block('lugt-mark',      sheet, []).
block('wikidata-p217',  plate, [unchecked]).
block('wikidata-p217',  state, []).
block('wikidata-p217',  sheet, [refuted]).
block('wikidata-p3634', sheet, []).

main :-
    forall(block(Scheme, Level, Listed), print_block(Scheme, Level, Listed)),
    print_notation,
    print_identification('wikidata-p217',
                         'rijksmuseum/RP-P-1962-39', 'met/41.1.31'),
    assertions.

print_block(Scheme, Level, Listed) :-
    audit(Scheme, Level, row(Pairs, Refuted, Corroborated, Unchecked)),
    format("\"~w as ~w key\"~n~d~n~d~n~d~n~d~n",
           [Scheme, Level, Pairs, Refuted, Corroborated, Unchecked]),
    (   untested(Scheme)
    ->  format("  untested~n")
    ;   true
    ),
    forall(( member(Verdict, Listed),
             verdict(Scheme, Level, A, B, Verdict)
           ),
           print_pair(Scheme, Level, A, B, Verdict)).

print_pair(Scheme, Level, A, B, Verdict) :-
    format("  ~w  ~w  ~w~n", [Verdict, A, B]),
    forall(evidence(Scheme, Level, A, B, Says, Source),
           format("      ~w: ~w~n", [Source, Says])).

% The rows transcribed by hand, against the reading of the strings.
print_notation :-
    format("\"the notation 78-3(5), read\"~n"),
    findall(Record-Catalogue,
            ( written_with_state(Scheme, Catalogue),
              cites(Record, Scheme, String),
              reads_as(String, Number, State, _),
              cites(Record, Catalogue, Number),
              state_number(Record, Catalogue, Number, State)
            ),
            Agreeing),
    findall(Record-Scheme,
            ( written_with_state(Scheme, _), cites(Record, Scheme, _) ),
            Strings),
    length(Agreeing, AgreeingCount),
    length(Strings, StringCount),
    format("  ~d strings, ~d agree with the rows written by hand~n",
           [StringCount, AgreeingCount]),
    forall(distinct(Catalogue-Number-Of,
                    ( written_with_state(Scheme, Catalogue),
                      cites(_, Scheme, String),
                      reads_as(String, Number, _, Of)
                    )),
           format("  ~w ~w: ~d states counted~n", [Catalogue, Number, Of])).

% Why two records are identified: the values they share and how each
% comes to bear them.
print_identification(Scheme, A, B) :-
    format("\"why ~w identifies ~w and ~w\"~n", [Scheme, A, B]),
    once(identified_by(Scheme, A, B, Links)),
    forall(member(link(X, Y, Value, ViaX, ViaY), Links),
           ( format("  both bear ~w~n", [Value]),
             print_via(X, ViaX),
             print_via(Y, ViaY)
           )).

print_via(X, stated) :-
    format("    ~w: stated on the record~n", [X]).
print_via(X, reading(Name, Premises)) :-
    format("    ~w: by the reading ~w, from~n", [X, Name]),
    forall(member(Premise, Premises),
           format("      ~q~n", [Premise])).

% --- These hold whatever the recorded output says ---------------------------

assertions :-
    % An identification at the level of the state does not go down to
    % sheets, and one at the level of the sheet is reported.
    expect(verdict('bartsch-state', state,
                   'rijksmuseum/RP-P-OB-617', 'rijksmuseum/RP-P-1962-39',
                   corroborated)),
    expect(verdict('bartsch-state', sheet,
                   'rijksmuseum/RP-P-OB-617', 'rijksmuseum/RP-P-1962-39',
                   refuted)),
    % Identifiers that are all different identify nothing.
    expect(untested('rijks-pid')),
    expect(untested('met-object')),
    % The second plate refutes the collector's mark, and the refutation
    % has a source.
    expect(verdict('lugt-mark', plate,
                   'rijksmuseum/RP-P-OB-616', 'rijksmuseum/RP-P-OB-611',
                   refuted)),
    expect(evidence('lugt-mark', plate,
                    'rijksmuseum/RP-P-OB-616', 'rijksmuseum/RP-P-OB-611',
                    different(plate), catalogue(bartsch))),
    % A Bartsch number is not evidence for itself.
    expect_not(evidence(bartsch, plate, _, _, _, catalogue(bartsch))),
    expect_not(evidence('bartsch-state', state, _, _, _, states(bartsch))),
    % No record says these two are in the same state, and none says they
    % are not. That is not a difference and not an identity.
    expect(verdict('wikidata-p217', state,
                   'rijksmuseum/RP-P-1962-39', 'met/41.1.31', unchecked)),
    expect_not(evidence('wikidata-p217', state,
                        'rijksmuseum/RP-P-1962-39', 'met/41.1.31', _, _)),
    % The reading is named in the explanation of the identification.
    expect(( identified_by('wikidata-p217',
                           'rijksmuseum/RP-P-1962-39', 'met/41.1.31',
                           [link(_, _, 'Q1218084', ViaA, ViaB)]),
             ViaA = reading('inventory-number-read-as-identity', _),
             ViaB = reading('inventory-number-read-as-identity', _)
           )),
    % Every string with a state reads, and reads as the rows say.
    expect_not(( written_with_state(Scheme, _),
                 cites(_, Scheme, String),
                 \+ reads_as(String, _, _, _)
               )),
    expect_not(( written_with_state(Scheme, Catalogue),
                 cites(Record, Scheme, String),
                 reads_as(String, Number, State, _),
                 \+ ( cites(Record, Catalogue, Number),
                      state_number(Record, Catalogue, Number, State)
                    )
               )).

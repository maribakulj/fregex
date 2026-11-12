:- module(levels,
          [ identified/3,       % +Scheme, ?A, ?B
            identified_by/4,    % +Scheme, +A, +B, -Links
            verdict/5,          % +Scheme, +Level, ?A, ?B, -Verdict
            contested/4,        % +Scheme, +Level, ?A, ?B
            audit/3,            % +Scheme, +Level, -Row
            untested/1,         % +Scheme
            evidence/6,         % +Scheme, +Level, +A, +B, -Says, -Source
            is_same/5,          % +Level, +When, ?A, ?B, -Sources
            expect/1,           % :Goal
            expect_not/1        % :Goal
          ]).

/** <module> At which level does an identifier hold as a key?

A case describes itself with six predicates, written in module `user`.

    subject(X, Rank)
        A thing that sources describe: a record, an execution, a coin.
        Rank orders them, so that each pair is listed once.

    bears(X, Scheme, Value, Via)
        X carries this value of this identifier. Via is `stated` when
        the source says so, or reading(Name, Premises) when it follows
        from an interpretation that has a name.

    says(Source, Verdict, Level, A, B, During)
        A judgment. Verdict is `same` or `different`. During is
        `always`, between(From, Until), from(From) or until(Until).
        A difference is somebody's judgment, like an identity.

    finer(Finer, Coarser)
        The order of the levels. Sameness goes up: same sheet, so same
        plate. Difference goes down: two plates, so two sheets.

    family(Scheme, Family)
    source_family(Source, Family)
        A judgment is left out of an audit when its source belongs to
        the family of the identifier under audit. A Bartsch number is
        not evidence for itself. A scheme with no family/2 row is its
        own family; a source with no source_family/2 row is independent
        of every scheme.

A hypothesis is a pair: a scheme and a level. It says that two subjects
carrying the same value of the scheme are the same thing at that level.
It is an argument of every predicate below, so nothing is assumed and
nothing has to be undone.
*/

:- use_module(library(lists)).
:- use_module(library(aggregate)).
:- use_module(library(solution_sequences)).

:- meta_predicate expect(0), expect_not(0).

:- multifile     user:subject/2, user:bears/4, user:says/6,
                 user:finer/2, user:family/2, user:source_family/2.
:- dynamic       user:subject/2, user:bears/4, user:says/6,
                 user:finer/2, user:family/2, user:source_family/2.
:- discontiguous user:subject/2, user:bears/4, user:says/6,
                 user:finer/2, user:family/2, user:source_family/2.

% --- What a hypothesis identifies ----------------------------------------
% Two subjects are identified when a chain of shared values joins them.

%!  identified(+Scheme, ?A, ?B) is nondet.
%   A comes before B in rank. Each pair once.

identified(Scheme, A, B) :-
    user:subject(A, RankA),
    component(Scheme, A, Component),
    member(B, Component),
    user:subject(B, RankB),
    RankA < RankB.

component(Scheme, A, Component) :-
    grow(Scheme, [A], [A], Component).

grow(_, [], Seen, Seen).
grow(Scheme, [X|Queue], Seen, Component) :-
    findall(Y, ( shares(Scheme, X, Y, _), \+ memberchk(Y, Seen) ), Found),
    sort(Found, New),
    append(Seen, New, Seen1),
    append(Queue, New, Queue1),
    grow(Scheme, Queue1, Seen1, Component).

shares(Scheme, X, Y, link(X, Y, Value, ViaX, ViaY)) :-
    user:bears(X, Scheme, Value, ViaX),
    user:bears(Y, Scheme, Value, ViaY),
    X \== Y.

%!  identified_by(+Scheme, +A, +B, -Links) is nondet.
%   The chain of shared values, with how each end comes to bear its value.

identified_by(Scheme, A, B, Links) :-
    chain(Scheme, A, B, [A], Links).

chain(Scheme, A, B, Seen, Links) :-
    shares(Scheme, A, C, Link),
    \+ memberchk(C, Seen),
    (   C == B
    ->  Links = [Link]
    ;   chain(Scheme, C, B, [C|Seen], Rest),
        Links = [Link|Rest]
    ).

% --- What the sources say about a pair ----------------------------------

judged(Source, Verdict, Level, A, B, During) :-
    user:says(Source, Verdict, Level, A, B, During).
judged(Source, Verdict, Level, A, B, During) :-
    user:says(Source, Verdict, Level, B, A, During).

independent(Scheme, Source) :-
    family_of(Scheme, Family),
    \+ user:source_family(Source, Family).

family_of(Scheme, Family) :-
    (   user:family(Scheme, Declared)
    ->  Family = Declared
    ;   Family = Scheme
    ).

coarser_or_same(Level, Level).
coarser_or_same(Level, Coarser) :-
    user:finer(Level, Middle),
    coarser_or_same(Middle, Coarser).

finer_or_same(Level, Level).
finer_or_same(Level, Finer) :-
    user:finer(Middle, Level),
    finer_or_same(Middle, Finer).

contradiction(Scheme, Level, A, B, different(At), Source) :-
    coarser_or_same(Level, At),
    judged(Source, different, At, A, B, _),
    independent(Scheme, Source).

support(Scheme, Level, A, B, same(At), Source) :-
    finer_or_same(Level, At),
    judged(Source, same, At, A, B, _),
    independent(Scheme, Source).

%!  evidence(+Scheme, +Level, +A, +B, -Says, -Source) is nondet.
%   Every independent judgment that bears on the pair at this level.
%   Says is same(At) or different(At): the level the source spoke at.

evidence(Scheme, Level, A, B, Says, Source) :-
    distinct(Says-Source,
             (   contradiction(Scheme, Level, A, B, Says, Source)
             ;   support(Scheme, Level, A, B, Says, Source)
             )).

% --- Verdicts --------------------------------------------------------------
%   refuted       an independent source judges the two different
%   corroborated  an independent source judges them the same, none different
%   unchecked     no independent source says anything

%!  verdict(+Scheme, +Level, ?A, ?B, -Verdict) is nondet.

verdict(Scheme, Level, A, B, Verdict) :-
    identified(Scheme, A, B),
    (   contradiction(Scheme, Level, A, B, _, _)
    ->  Verdict = refuted
    ;   support(Scheme, Level, A, B, _, _)
    ->  Verdict = corroborated
    ;   Verdict = unchecked
    ).

%!  contested(+Scheme, +Level, ?A, ?B) is nondet.
%   Refuted by one source and supported by another. Both are kept.

contested(Scheme, Level, A, B) :-
    identified(Scheme, A, B),
    once(contradiction(Scheme, Level, A, B, _, _)),
    once(support(Scheme, Level, A, B, _, _)).

%!  audit(+Scheme, +Level, -Row) is det.
%   Row = row(Pairs, Refuted, Corroborated, Unchecked).

audit(Scheme, Level, row(Pairs, Refuted, Corroborated, Unchecked)) :-
    findall(Verdict, verdict(Scheme, Level, _, _, Verdict), Verdicts),
    length(Verdicts, Pairs),
    count(refuted, Verdicts, Refuted),
    count(corroborated, Verdicts, Corroborated),
    count(unchecked, Verdicts, Unchecked).

count(Verdict, Verdicts, Count) :-
    aggregate_all(count, member(Verdict, Verdicts), Count).

%!  untested(+Scheme) is semidet.
%   The hypothesis identifies no pair: nothing to be right or wrong about.

untested(Scheme) :-
    \+ identified(Scheme, _, _).

% --- Identity that holds for a time ----------------------------------------

%!  is_same(+Level, +When, ?A, ?B, -Sources) is nondet.
%   A chain of `same` judgments, each of them in force at When, joins A
%   and B. When is a number, or `any` to ignore the dates. Sources lists
%   each judgment used with the period it gives itself.

is_same(Level, When, A, B, Sources) :-
    walk(Level, When, A, B, [A], Sources).

walk(Level, When, A, B, Seen, Sources) :-
    step(Level, When, A, C, Source),
    \+ memberchk(C, Seen),
    (   B = C,
        Sources = [Source]
    ;   walk(Level, When, C, B, [C|Seen], Rest),
        Sources = [Source|Rest]
    ).

step(Level, When, A, B, Source-During) :-
    judged(Source, same, Level, A, B, During),
    in_force(During, When).

in_force(_, any) :- !.
in_force(always, _).
in_force(between(From, Until), When) :- From =< When, When < Until.
in_force(from(From), When)           :- From =< When.
in_force(until(Until), When)         :- When < Until.

% --- Assertions ------------------------------------------------------------
% They fail the run whatever the recorded output says.

expect(Goal) :-
    (   \+ \+ call(Goal)
    ->  true
    ;   format(user_error, "expected, and not the case: ~q~n", [Goal]),
        halt(1)
    ).

expect_not(Goal) :-
    (   \+ call(Goal)
    ->  true
    ;   format(user_error, "not expected, and the case: ~q~n", [Goal]),
        halt(1)
    ).

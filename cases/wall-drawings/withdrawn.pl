% An identity that was withdrawn.
%
% withdrawn.egg had to choose. With `union`, a wall in Houston became the
% papers in the Menil's files. Without it, the answers were right and
% equality took no part.
%
% Here "is" stays an identity in both parts. In the second, each statement
% carries the period it holds for, and a chain of identities is followed
% only through statements in force in the year asked.
%
% Run:  swipl withdrawn.pl

:- use_module('../../prolog/egg').
:- use_module('../../prolog/levels').

:- initialization(main, main).

:- prolog_load_context(directory, Here),
   atomic_list_concat([Here, '/facts.egg'], Facts),
   load_egg_facts(Facts).

% --- Two statements, both with "is" -----------------------------------------
% These are readings, as in withdrawn.egg: see SOURCES.md.

% In 1991 a wall is the wall drawing. It is, for as long as the drawing is
% on it.
says('execution of 1991', same, is,
     surface(Wall), wall_drawing(Work), between(From, Until)) :-
    realizes(Wall, Work, From, Until).

% After the wall is painted over, the Menil's registrar writes that the
% drawing lives on only as a certificate and a diagram. That holds from
% the painting over, which happened in a known year at the latest.
says('menil registrar''s letter', same, is,
     wall_drawing(Work), papers(Holder, What), from(PaintedOverBy)) :-
    holds(Holder, What, Work, _),
    realizes(Wall, Work, _, _),
    painted_over_by(Wall, PaintedOverBy).

asked(1995).
asked(2013).
asked(2015).
asked(2018).

main :-
    Wall = surface('stern-house/wall'),
    Papers = papers(menil, 'certificate and diagram'),
    Work = wall_drawing('679'),

    format("\"is, read as identity, the dates ignored\"~n"),
    forall(once(is_same(is, any, Wall, Papers, Sources)),
           ( format("  ~w is ~w~n", [Wall, Papers]),
             forall(member(Source-During, Sources),
                    format("      ~w, ~w~n", [Source, During]))
           )),

    format("\"is, read as identity, each statement with its dates\"~n"),
    forall(asked(Year),
           (   setof(Thing, Sources^is_same(is, Year, Work, Thing, Sources), Things)
           ->  forall(member(Thing, Things),
                      format("  ~d  ~w is ~w~n", [Year, Work, Thing]))
           ;   format("  ~d  no statement in force~n", [Year])
           )),

    format("\"the wall is the papers, by year asked\"~n"),
    forall(asked(Year),
           (   is_same(is, Year, Wall, Papers, _)
           ->  format("  ~d  yes~n", [Year])
           ;   format("  ~d  no~n", [Year])
           )),

    format("\"which wall is being uncovered, by year asked\"~n"),
    forall(( asked(Year), uncovered_since(Surface, Since), Since =< Year ),
           format("  ~d  ~w~n", [Year, Surface])),

    assertions(Wall, Papers, Work).

% --- These hold whatever the recorded output says ---------------------------

assertions(Wall, Papers, Work) :-
    % Without dates, the two statements make the wall the papers, and the
    % chain names both.
    expect(( is_same(is, any, Wall, Papers, Sources),
             Sources = ['execution of 1991'-_, 'menil registrar''s letter'-_]
           )),
    % With dates, they never do.
    expect_not(( asked(Year), is_same(is, Year, Wall, Papers, _) )),
    % Each statement still holds in its own time.
    expect(is_same(is, 1995, Work, Wall, _)),
    expect(is_same(is, 2015, Work, Papers, _)),
    % 2013 falls between the two bounds: nothing can be said.
    expect_not(is_same(is, 2013, Work, _, _)),
    % In 2018 a wall is being uncovered and no record says it is the work.
    expect(( uncovered_since('stern-house/wall', Since), Since =< 2018 )),
    expect_not(is_same(is, 2018, Wall, Work, _)).

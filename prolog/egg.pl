:- module(egg, [load_egg_facts/1]).

/** <module> Read the facts of an egglog file

Both engines run on the same facts file, so that there is one
transcription to check against the sources and not two.

A fact is a top-level form whose head is a relation declared in the file
and whose arguments are strings or integers:

    (relation cites (String String String))
    (cites "ngv/1971-4" "bartsch" "78")

It is asserted in module `user` as cites('ngv/1971-4', bartsch, '78'):
strings become atoms, hyphens in relation names become underscores.
Everything else in the file (sorts, constructors, rules) is read and
ignored.
*/

:- use_module(library(readutil)).
:- use_module(library(lists)).
:- use_module(library(apply)).

%!  load_egg_facts(+File) is det.

load_egg_facts(File) :-
    read_file_to_codes(File, Codes, [encoding(utf8)]),
    (   phrase(forms(Forms), Codes)
    ->  true
    ;   throw(error(syntax_error(cannot_read_egg_file), context(_, File)))
    ),
    forall(member([sym(relation), sym(Name), Types], Forms),
           declare(Name, Types)),
    findall(Name, member([sym(relation), sym(Name)|_], Forms), Relations),
    forall(( member([sym(Name)|Arguments], Forms),
             memberchk(Name, Relations),
             maplist(value, Arguments, Values)
           ),
           add(Name, Values)).

value(str(Atom), Atom).
value(int(Integer), Integer).

declare(Name, Types) :-
    functor_of(Name, Functor),
    length(Types, Arity),
    dynamic(user:Functor/Arity).

add(Name, Values) :-
    functor_of(Name, Functor),
    Fact =.. [Functor|Values],
    (   clause(user:Fact, true)
    ->  true
    ;   assertz(user:Fact)
    ).

functor_of(Name, Functor) :-
    atomic_list_concat(Parts, '-', Name),
    atomic_list_concat(Parts, '_', Functor).

% --- The grammar: s-expressions with ";" comments -----------------------

forms([Form|Forms]) --> blank, form(Form), !, forms(Forms).
forms([])           --> blank.

form(Items)     --> "(", !, items(Items), blank, ")".
form(str(Atom)) --> "\"", !, characters(Codes), "\"", { atom_codes(Atom, Codes) }.
form(Token)     --> token(Codes), { Codes = [_|_], classify(Codes, Token) }.

items([Item|Items]) --> blank, form(Item), !, items(Items).
items([])           --> [].

characters([Code|Codes]) --> "\\", [Code], !, characters(Codes).
characters([Code|Codes]) --> [Code], { Code \== 0'" }, !, characters(Codes).
characters([])           --> [].

token([Code|Codes]) --> [Code], { \+ delimiter(Code) }, !, token(Codes).
token([])           --> [].

delimiter(Code) :- code_type(Code, space), !.
delimiter(Code) :- memberchk(Code, `();"`).

classify(Codes, int(Integer)) :-
    catch(number_codes(Integer, Codes), _, fail),
    integer(Integer),
    !.
classify(Codes, sym(Atom)) :-
    atom_codes(Atom, Codes).

blank --> [Code], { code_type(Code, space) }, !, blank.
blank --> ";", !, rest_of_line, blank.
blank --> [].

rest_of_line --> [Code], { Code \== 0'\n }, !, rest_of_line.
rest_of_line --> [].

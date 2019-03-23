:- [diagnosis].
:- [warmup2].


isMinimalSubset(_, []) :-
    !. % no more backtracking after minimality is confirmed
isMinimalSubset(Elems, [List|Lists]) :-
    not(subset(List, Elems)),
    isMinimalSubset(Elems, Lists).


prune([], _, []).
prune([List|Lists], Selected, Next) :-
    not(isMinimalSubset(List, Lists)),
    !, % red cut
    prune(Lists, Selected, Next).
prune([List|Lists], Selected, Next) :-
    not(isMinimalSubset(List, Selected)),
    !, % red cut
    prune(Lists, Selected, Next).
prune([List|Lists], Selected, [List|Next]) :-
    prune(Lists, [List|Selected], Next).


main(SD, COMP, OBS, HSS) :-
    findall(HS,
            main2(SD, COMP, OBS, HS, []),
            HSS1),
    prune(HSS1, [], HSS).


main2(SD, COMP, OBS, [], PATH) :-
    not(tp(SD, COMP, OBS, PATH, _)).
main2(SD, COMP, OBS, [E|HS], PATH) :-
    tp(SD, COMP, OBS, PATH, CS),
    member(E, CS),
    main2(SD, COMP, OBS, HS, [E|PATH]).


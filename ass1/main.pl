:- [diagnosis].
:- [warmup2].


% element is a minimal subset of all sets in list
isMinimalSubset(_, []).
isMinimalSubset(Elems, [List|Lists]) :-
    not(subset(List, Elems)),
    isMinimalSubset(Elems, Lists).


gatherDiagnosis(SD, COMP, OBS, [], PATH) :-
    not(tp(SD, COMP, OBS, PATH, _)).
gatherDiagnosis(SD, COMP, OBS, [E|HS], PATH) :-
    tp(SD, COMP, OBS, PATH, CS),
    member(E, CS),
    gatherDiagnosis(SD,
                    COMP,
                    OBS,
                    HS,
                    [E|PATH]).


pruneDiagnosis([], _, []).
pruneDiagnosis([List|Lists], Selected, Next) :-
    not(isMinimalSubset(List, Lists)),
    !, % red cut
    pruneDiagnosis(Lists, Selected, Next).
pruneDiagnosis([List|Lists], Selected, Next) :-
    not(isMinimalSubset(List, Selected)),
    !, % red cut
    pruneDiagnosis(Lists, Selected, Next).
pruneDiagnosis([List|Lists], Selected, [List|Next]) :-
    pruneDiagnosis(Lists, [List|Selected], Next).


main(SD, COMP, OBS, HSS) :-
    findall(HS,
            gatherDiagnosis(SD, COMP, OBS, HS, []),
            HSS1),
    pruneDiagnosis(HSS1, [], HSS).
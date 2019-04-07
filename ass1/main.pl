:- [diagnosis].
:- [warmup2].


% element is a minimal subset of all sets in list
isMinimalSubset(_, []).
isMinimalSubset(Elems, [List|Lists]) :-
    not(subset(List, Elems)),
    isMinimalSubset(Elems, Lists).


gatherDiagnoses(SD, COMP, OBS, [], PATH) :-
    not(tp(SD, COMP, OBS, PATH, _)).
gatherDiagnoses(SD, COMP, OBS, [E|HS], PATH) :-
    tp(SD, COMP, OBS, PATH, CS),
    member(E, CS),
    gatherDiagnoses(SD,
                    COMP,
                    OBS,
                    HS,
                    [E|PATH]).


pruneDiagnoses([], _, []).
pruneDiagnoses([Set|Sets], Selected, Minimal) :-
    not(isMinimalSubset(Set, Sets)),
    !, % red cut
    pruneDiagnoses(Sets, Selected, Minimal).
pruneDiagnoses([Set|Sets], Selected, Minimal) :-
    not(isMinimalSubset(Set, Selected)),
    !, % red cut
    pruneDiagnoses(Sets, Selected, Minimal).
pruneDiagnoses([Set|Sets], Selected, [Set|Minimal]) :-
    pruneDiagnoses(Sets, [Set|Selected], Minimal).


main(SD, COMP, OBS, HSS) :-
    findall(HS,
            gatherDiagnoses(SD, COMP, OBS, HS, []),
            UHSS),
    pruneDiagnoses(UHSS, [], HSS).
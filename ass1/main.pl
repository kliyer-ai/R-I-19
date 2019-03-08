:- [diagnosis].
:- [warmup2].

listEquals(List1, List2) :-
    subset(List1, List2),
    subset(List2, List1).

minimalSubset(_, []).
minimalSubset(Elems1, [Elems2|Rest]) :-
    listEquals(Elems1, Elems2),
    minimalSubset(Elems1, Rest).
minimalSubset(Elems, [List|Lists]) :-
    not(subset(List, Elems)),
    minimalSubset(Elems, Lists).

    
pruneOne(List, Elem) :-
    member(Elem, List),
    minimalSubset(Elem, List).
pruneAll(In, Out) :-
    findall(Elem, pruneOne(In, Elem), Out).


main(SD, COMP, OBS, HSS) :-
    findall(HS,
            main2(SD, COMP, OBS, HS, []),
            HSS).
    % pruneAll(Out, HSS).
main2(SD, COMP, OBS, HS, PATH) :-
    not(tp(SD, COMP, OBS, PATH, _)),
    HS=[].
main2(SD, COMP, OBS, [E|HS], PATH) :-
    tp(SD, COMP, OBS, PATH, CS),
    member(E, CS),
    main2(SD, COMP, OBS, HS, [E|PATH]).

% L=[[1], [1, 2], [1, 2, 3], [3]],
% minimalHSs(L, H) :-
%     member(H, L),
%     minimalSubset(H, L).

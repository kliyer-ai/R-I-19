:- [diagnosis].
:- [warmup2].

setEquals(List1, List2) :-
    subset(List1, List2),
    subset(List2, List1).

setEquals2(List1, List2) :-
    length(List1, Len1),
    length(List2, Len2),
    Len1==Len2,
    subset(List2, List1).

% minimalSubset(_, []).
% minimalSubset(Elems1, [Elems2|Rest]) :-
%     setEquals(Elems1, Elems2),
%     minimalSubset(Elems1, Rest).
% minimalSubset(Elems, [List|Lists]) :-
%     not(subset(List, Elems)),
%     minimalSubset(Elems, Lists).
pruneOne(List, Elem) :-
    member(Elem, List),
    minimalSubset(Elem, List).
pruneAll(In, Out) :-
    findall(Elem, pruneOne(In, Elem), Out).


minimalSubset(_, []).
minimalSubset(Elems, [List|Lists]) :-
    not(subset(List, Elems)),
    minimalSubset(Elems, Lists).

pruneSubsets([], [], _).
pruneSubsets([H|List], PList, Found) :-
    (   minimalSubset(H, Found)
    ->  append(Found, [H], NF),
        pruneSubsets(List, P2, NF),
        PList=[H|P2]
    ;   pruneSubsets(List, PList, Found)
    ).

main(SD, COMP, OBS, HSS) :-
    findall(HS,
            main2(SD, COMP, OBS, HS, []),
            HSS).
    % pruneSubsets(HSS1, HSS, []).



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

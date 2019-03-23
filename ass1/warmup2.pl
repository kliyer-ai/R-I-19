member(X, [X|_]).
member(X, [_|T]) :-
    member(X, T).


subset([], _).
subset([H|T], List) :-
    member(H, List),
    subset(T, List).


path(End, End, _, _, [End]).
path(From, To, Graph, Visited, [From|Path]) :-
    (   member(edge(From, Mid), Graph)
    ;   member(edge(Mid, From), Graph)
    ),
    not(member(Mid, Visited)),
    path(Mid, To, Graph, [From|Visited], Path).


longest_paths(From, To, Graph, Paths) :-
    findall(Path,
            path(From, To, Graph, [], Path),
            AllPaths),
    findall(LongestPath, find_longest(LongestPath, AllPaths), Paths).


find_longest(Elem, List) :-
    member(Elem, List),
    length(Elem, Len),
    is_longest(Len, List).


is_longest(_, []).
is_longest(Len1, [L|Ls]) :-
    length(L, Len2),
    Len1>=Len2,
    is_longest(Len1, Ls).


% [edge(1, 5), edge(1, 7), edge(2, 1), edge(2, 7), edge(3, 1), edge(3, 6), edge(4, 3), edge(4, 5), edge(5, 8), edge(6, 4), edge(6, 5), edge(7, 5), edge(8, 6), edge(8, 7)]
% isBinaryTree(leaf).
% isBinaryTree(node(X, Y)) :-
%     isBinaryTree(X),
%     isBinaryTree(Y).


% nnodes(leaf, 1).
% nnodes(node(X, Y), N) :-
    % nnodes(X, M1),
    % nnodes(Y, M2),
    % M is M1+M2,
    % N is M+1.
% 
isBinaryTree(leaf(_)).
isBinaryTree(node(_, X, Y)) :-
    isBinaryTree(X),
    isBinaryTree(Y).

nnodes(leaf(_), 1).
nnodes(node(_, X, Y), N) :-
    nnodes(X, M1),
    nnodes(Y, M2),
    M is M1+M2,
    N is M+1.

makeBinaryTree(0, leaf(0)).
makeBinaryTree(N, Tree) :-
    Tree=node(N, A, B),
    M is N-1,
    makeBinaryTree(M, A),
    makeBinaryTree(M, B).


makeTree(0, _, leaf(0)).
makeTree(N, NumberOfChildren, Tree) :-
    getChildren(N, NumberOfChildren, L, NumberOfChildren),
    Tree=node(N, L).

getChildren(_, _, [], 0).
getChildren(N, NumberOfChildren, [H|T], C) :-
    N1 is N-1,
    makeTree(N1, NumberOfChildren, H),
    C1 is C-1,
    getChildren(N, NumberOfChildren, T, C1).
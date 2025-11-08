/*Question 2
Suppose you are given a relation R with four attributes ABCD. For the given sets of FDs,
A → B, BC → D, A → C
a) identify the canidate key(s) for R
attribute closure
R = (A,B,C,D)
A -> B, closure = {A, B}
A -> C, closure = {A, B, C}
BC -> D, closure = {A, B, C, D}
{A}+ = {A, B, C, D}
A is the canidate key
b) 1NF each cell has single value
2NF all non-key attributes must depend on the entire canidate key
3NF either the left is superkey, or the right is part of canidate key
BC is not superkey, thus it violates 3NF
c) R1(B,C,D)
R2(A, B, C)

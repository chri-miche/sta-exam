# Maximal Independent Set (MIS)

An **independent set** is a set of vertexes `X \subseteq V` such that if `v \in X` then none of its neighbours is in `X`.

A **maximal** independent set `X` is an IS for which there not exists another MIS `Y` such that `X \subset Y` 

To solve in a centralized manner is simple with a greedy algorithm: start from one node and put it in the MIS; remove all of its neighbours from the candidates. Then, choose another node and repeat the process.

**Important**: "centralized" means "apply the gather all algorithm in LOCAL". You cannot do that in CONGEST.

# Solving it in LOCAL

An algorithm O(n^`c`) is given. Remember that in LOCAL we have a function `id: V -> {1..n^c}` for some `c`. (Remember: `n = |V|`)

For each round `i` and node `v`: 
1. `send status(v)`
2. `statuses <- receive`
3. `if 'selected' in statuses then status(v) = 'removed'`
   `else if id(v) == i then status(v) = 'selected'`
4. `if status(v) == 'removed' then stop`

Of course this is very poor performance.

# Solving with coloring

Suppose you have a proper `k`-coloring `f: V -> {1..k}`. Then an algorithm O(k) is given.

Run the previous given algorithm but substitute `id` with `f`.

# Solving with network decompositions

Suppose you have a *network decomposition with `c` colors and strong diameter of `d`* `l: V -> {1..c}`. Then an algorithn O(`c * d`) is given:

For each color `i` to `c`:

1. Apply the "Gathering All" algorithm on the cluster of color `i` (O(`d`)), and on the locally built graph solve MIS (O(1)). Notice that this will be done in parallel for all clusters of color `i`
2. Remove from the graph all neighbours of the nodes in the union of all MIS (O(1)).

# The aim of polylogarithmic complexity

Notice that if `c` and `d` were polylogarithmic in `n`, we would have a polylogarithmic algorithm solving MIS in LOCAL!


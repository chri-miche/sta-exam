# Decomposing Networks

Consider this (centralized) solution to the coloring problem. 

Choose color `c1`. Compute a MIS on G, color all vertexes in the MIS with `c1`.
Now ignore all colored nodes, and choose a color `c2`. Repeat.

We can follow the same concept to build network decompositions.

# Centralized Network Decomposition

Choose a color `c1` and a node `v`. Color the `ball {G} v r` with `r` = O(log(n)). "Freeze" the uncolored adjacent nodes to the one colored.
Repeat with unfrozen nodes.

When finished with color `c1`, remove all colored nodes from `G`, choose color `c2`, unfreeze all frozen nodes and repeat.

Notice that this is an unbalanced coloring. 
With balanced net shapes it would not be a problem, however we can not ensure that we have O(log(n)) colors.

# Ball carving

The algorithm proceeds as follows:

1. Select a node `v`, let `ball = {v}`
2. Let `b` the number of nodes at the border of `ball`
3. If `b >= 2 * size(ball)` take all nodes on the border in `ball`; goto 2.
4. Else, stop;
5. Freeze all the nodes at the border of `ball`

Notice that:
* that loop runs for at most log(n) iterations (A1); 
* the frozen nodes are at most the size of the `ball` (??? should be half).

# Getting a strong diameter from a weak diameter

Take into account that from a weak diameter network decomposition is possible to get a strong network decomposition.
Follow this steps.

Let `f` be a network decomposition of O(log(n)) colors.
For each color:
1. apply "gather all" on this color;
2. compute a strong decomposition of this color

Each strong decomposition will have O(log(n)) sub-colors.
Hence the algorithm outputs a O(log^2(n)) strong decomposition.

# A1

The size of `ball` at iteration `i` is:
* `i = 1` => 1
* `i > 1` => (size of i-1) * 3
So it is: 3^i

Now: `i > log n` => `size(ball) = 3^i > n`
Hence: it is now clear that it is impossible to run the loop in more than log(n) iterations.

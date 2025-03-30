#import "@preview/polylux:0.3.1": *
#import "unipd.typ": *
#import "@preview/cetz:0.3.2"
#import "@preview/algorithmic:0.1.0"
#import algorithmic: algorithm

#let oxford-blue= rgb("#002147");
#let bluesnow   = rgb("#cce5ec");
#let whitesnow  = rgb("#f1f2f6");
#let ocra       = rgb("#d17a22");
// no need for claret, use unipd-red instead #let claret     = rgb("#990d35");
#let darkpurple = rgb("#28112b");

// TODO emph darkpurple in notes and ocra in ideas
#let emph(body) = text(fill: ocra.darken(30%),weight: "bold")[#body]

#let example(body) = block(
  width: 100%,
  inset: .5em,
  fill: aqua.lighten(80%),
  radius: .5em,
  text(size: .8em, body),
)

#let warning(body) = block(
  width: 100%,
  inset: .5em,
  fill: orange.lighten(60%),
  radius: .5em,
  text(grid(
    columns: (1fr, 10fr, 1fr),
    align(left, "🚨"),
    align(center, body),
    align(right, "")
  )),
)

#let note(body) = block(
  width: 100%,
  inset: .5em,
  fill: teal.lighten(80%),
  radius: .5em,
  text(grid(
    columns: (1fr, 10fr, 1fr),
    align(left, "🎶"),
    align(center, body),
    align(right, "")
  )),
)

#let idea(body) = block(
  width: 100%,
  inset: .5em,
  fill: yellow.lighten(60%),
  radius: .5em,
  text(grid(
    columns: (1fr, 10fr, 1fr),
    align(left, "💡"),
    align(center, body),
    align(right, "")
  )),
)

// todo background magari giallo..?
// key concept
#let key(body) = block(
  width: 100%,
  inset: .5em,
  fill: bluesnow.lighten(60%),
  radius: .5em,
  text(grid(
    columns: (1fr, 10fr, 1fr),
    align(left, ""),
    align(center, body),
    align(right, "")
  )),
)

#let question(body) = block(
  width: 100%,
  inset: .5em,
  fill: bluesnow.lighten(60%),
  radius: .5em,
  text(grid(
    columns: (1fr, 10fr, 1fr),
    align(left, "❓"),
    align(center, body),
    align(right, "")
  )),
)

#let formal-def(body) = underline[_#text(fill: unipd-red,weight: "bold")[#body]_]

#let faded(body) = text(fill: rgb("#c9c9c9"), weight: "bold")[#body]

// todo background
#let def(body) = [#formal-def[def:] #body]

// #let today = datetime.today().display("[day]/[month]/[year]")

#show: unipd-theme.with(author: "Christian Micheletti", date: "")
#show math.equation: set text(font: "Fira Math")
#show raw: set text(font: "Iosevka Extended")

#set text(font: (
  // "EB Garamond",
  "Marianne",
  "Noto Color Emoji",
), weight: "light", size: 30pt)

#show raw: set text(size: 1.1em)
#show smallcaps: set text(font: "EB Garamond SC 12")

#title-slide(
  title: "Efficient Low Diameter Clustering",
  subtitle: "with strong diameter in the CONGEST model",
)

// pannellone "What are we talking about?"

#slide(
  title: "Intuition",
  new-section: "Overview"
)[
  Some graph problems are interesting for #emph("networks of computers")

  #key[$"Distribution" => "Parallelism"$]

  #idea[We'd like to leverage parallelism to relieve computation costs]
]

#slide(
  title: "A First Simple Model",
  new-section: "Models"
)[

  #set align(center)
  #cetz.canvas({
    import cetz.draw: *

    set-style(stroke: (paint: teal.darken(30%), thickness: 2pt))

    line((-1.5, 0), (0, 0))
    line((-1.5, 0), (-3, 0), stroke: (dash: "dashed"))
    circle((-3, 0), fill: teal.lighten(80%), radius: 0.75, stroke: (dash: "dashed"))

    line((1, 1), (0, 0))
    line((1, 1), (2, 2), stroke: (dash: "dashed"))
    circle((2, 2), fill: teal.lighten(80%), radius: 0.75, stroke: (dash: "dashed"))

    line((-1, 1), (0, 0))
    line((-1, 1), (-2, 2), stroke: (dash: "dashed"))
    circle((-2, 2), fill: teal.lighten(80%), radius: 0.75, stroke: (dash: "dashed"))

    circle((0, 0), fill: teal.lighten(80%), radius: 0.75)    
  })

  #set align(left)

  - In the *PN-Network* a node only knows some _Numbered *Ports*_
   - Each connected with a *different* node
   - #def[Those are called #formal-def[neighbours]]
   - There are no *self loops*

  #warning[From the perspective of a single node, we don't see the whole topology]

  // this is going to raise some problems, lets see which!
]

#slide(
  title: "Centralized Graph Problems"
)[

  Example: *Maximal Independent Set* (MIS)

  #set align(center)
  #cetz.canvas({
    import cetz.draw: *

    set-style(stroke: (paint: red.darken(30%), thickness: 3pt, dash: "dashed"))
    circle((-2, 2), fill: red.lighten(80%), radius: 1)   //
    circle((4, 0), fill: red.lighten(80%), radius: 1)   //
    circle((0, -2), fill: red.lighten(80%), radius: 1) //

    set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))

    line((-2, 2), (2, 2))
    
    line((-2, 2), (-3, -0.5))
    line((-2, 2), (0, 0.25))

    line((2, 2), (0, 0.25))
    line((4, 0), (2, 2))

    line((-3, -0.5), (0, -2))
    line((0, 0.25), (0, -2))
    line((4, 0), (2.75, -2))

    line((0, -2), (2.75, -2))

    circle((-2, 2), fill: teal.lighten(80%), radius: 0.75)   //
    circle((2, 2), fill: teal.lighten(80%), radius: 0.75)
    circle((-3, -0.5), fill: teal.lighten(80%), radius: 0.75)
    circle((0, 0.25), fill: teal.lighten(80%), radius: 0.75) 
    circle((4, 0), fill: teal.lighten(80%), radius: 0.75)   //
    circle((0, -2), fill: teal.lighten(80%), radius: 0.75) //
    circle((2.75, -2), fill: teal.lighten(80%), radius: 0.75)
  })

  #set align(left)

  Solving it centralized is an easy greedy algorithm
]

#slide(title: "The PN-Network")[

  #warning[Each node appears identical to any other]

  - The only difference _could be_ in the number of ports
    - Not enough!

  - *We must break this symmetry*
]

#slide(
  title: [The LOCAL Model]
)[
  #idea[We add *unique identifiers* to the nodes]

  #set align(center)
  $italic(id) : V -> NN$

  $"where" forall v in V : italic(id)(v) <= n^c "for some" c >= 1$

  #set align(left)

  // we don't want to [limitare] the pool of indentifiers too much, but we want at least an upper bound

  #note[We choose $n^c$ so that we need $O(log n)$ bits to represent an identifier, i.e. identifiers are reasonably #formal-def[small]]

  // so this seems enough for the model
  // but we need to define how communication works
]

#slide(
  title: "Distributed Algorithms"
)[
  - This seems enough for the model
  - We must now define:
    - What *"distributed"* algorithms consist of
    - And the criteria for *complexity* analysis
]

#slide(
  title: "Distributed Algorithms"
)[
  #warning($"Distribution" => "Collaboration"$)

  - Collaborating requires *exchanging messages*
   - ...on a medium that is *slow* and *unreliable*

  //  Our aim is to study algorithms that execute in a distributed environment
  #key[$=>$ Communication has the most impact on complexity]

  $=>$ We are intersted in *quantifying* the number of messages that travel across the network
]

#slide(
  title: "Communication",
)[

  W.l.o.g.#footnote[Without loss of generality.] we adopt a model of #emph[synchronous communication]

  // why? so that we can quantify easier the ceiling / "worst case" of the number of message sent in the network

  Each round, a node $v in V$ performs this actions:
  1. $v$ #emph[sends] a message $italic("msg") in NN$ to its neighbours;
  2. $v$ #emph[receives] messages from its neighbours;
  3. ...
]

#slide(
  title: "Communication",
)[
  3. $v$ #emph[executes locally] some algorithm (same for each node).
  
  #def[Any message exchange establishes a communication #formal-def[round]]

  #note[Point (3.) doesn't affect the algorithm's complexity]
  // we are interested in capture the complexity that is upon the network
]

#slide(
  title: [A First Example (#smallcaps("Wave"))],
  new-section: "LOCAL Algorithms"
)[

  In #smallcaps("Wave"), the node with $id(v) = 1$ _"waves hello"_
  // doing stuff based on id is enough to break symmetry
  
  When a node receives the message, forwards it to its neighbours

  // Each communication round can take a significant amount of time to happen

  // #key[Complexity is measured in #emph[rounds]]

  The running time of this algorithm on a graph $G$ is $O(italic("diam")(G))$
]

#slide(
  title: [A Second Example (#smallcaps("Naive MIS"))]
)[
  #idea[Let's leverage $id$ to select the first MIS node]
  
  - At round \#$i$, node $v : id(v) = i$ executes
    - If no neighbour is in the MIS, add the node
      - And inform the neighbours
    - Otherwise, the node is outside the MIS

  #algorithm({
    import algorithmic: *
    ast_to_content_list(1, {
      
      If(cond: [`round` $ = italic(id)(v)$],
        {
          Assign[$m$][`'want-to-select'`]
        }
      )
      State[#smallcaps("send") $m$]
      State[#smallcaps("receive") $italic("messages")$]
      If(cond: [`'want-to-select'` $in italic("messages")$], {
        Fn[stop][`result: 'not-in-MIS'`]
      })
      If(cond: [`round` $ = italic(id)(v)$],
        {
        Fn[stop][`result: 'in-MIS'`]
        }
      )
    })
  })

  - It is correct since no node has the same $id$
  - This algorithm runs in $O(n^c)$ (the maximum $id$)
    - *Very bad*

]

#slide(
  title: "Gathering All"
)[
  We can be way smarter than that

  #idea[Running a centralized algorithm on a single node would take O(1) rounds]
  // minimizes number of messages in the net

  - We'd like to run a MIS algorithm on each node
    - *Centralized* $=>$ each node must have a *local copy* of the *entire* graph

  - The algorithm #smallcaps[Gather-All] makes all nodes build a local copy of the whole graph
    - At round $i$, each node $v$ knows $italic("ball")(i, v)$


  
  #let left-content = [
    #set align(center)

    #set text(fill: ocra.darken(30%), size: 24pt)
    $italic("ball")(0, v)$
    #scale(75%)[
    #cetz.canvas({
      import cetz.draw: *

      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))

      line((-2, 2), (2, 2))
      
      line((-2, 2), (-3, -0.5))
      line((-2, 2), (0, 0.25))

      line((2, 2), (0, 0.25))
      line((4, 0), (2, 2))

      line((-3, -0.5), (0, -2))
      line((0, 0.25), (0, -2))
      line((4, 0), (2.75, -2))

      line((0, -2), (2.75, -2))



      set-style(stroke: (paint: ocra.darken(30%), thickness: 3pt, dash: none))
      circle((-2, 2), fill: ocra.lighten(80%), radius: 0.75)   //

      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))
      circle((2, 2), fill: teal.lighten(80%), radius: 0.75)
      circle((-3, -0.5), fill: teal.lighten(80%), radius: 0.75)
      circle((0, 0.25), fill: teal.lighten(80%), radius: 0.75) 
      circle((4, 0), fill: teal.lighten(80%), radius: 0.75)   //
      circle((0, -2), fill: teal.lighten(80%), radius: 0.75) //
      circle((2.75, -2), fill: teal.lighten(80%), radius: 0.75)
    })]
  ]
  #let right-content = [
    #set align(center)

    #set text(fill: ocra.darken(30%), size: 24pt)
    $italic("ball")(1, v)$

    #scale(75%)[
    #cetz.canvas({
      import cetz.draw: *

      set-style(stroke: (paint: ocra.darken(30%), thickness: 3pt, dash: none))
      // circle((-2, 2), fill: green.lighten(80%), radius: 1)   //


      line((-2, 2), (2, 2))
      
      line((-2, 2), (-3, -0.5))
      line((-2, 2), (0, 0.25))

      line((2, 2), (0, 0.25))
      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))

      line((4, 0), (2, 2))

      line((-3, -0.5), (0, -2))
      line((0, 0.25), (0, -2))
      line((4, 0), (2.75, -2))

      line((0, -2), (2.75, -2))

      set-style(stroke: (paint: ocra.darken(30%), thickness: 3pt, dash: none))
      circle((-2, 2), fill: ocra.lighten(80%), radius: 0.75)   //
      circle((2, 2), fill: ocra.lighten(80%), radius: 0.75)
      circle((-3, -0.5), fill: ocra.lighten(80%), radius: 0.75)
      circle((0, 0.25), fill: ocra.lighten(80%), radius: 0.75) 
      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))
      circle((4, 0), fill: teal.lighten(80%), radius: 0.75)   //
      circle((0, -2), fill: teal.lighten(80%), radius: 0.75) //
      circle((2.75, -2), fill: teal.lighten(80%), radius: 0.75)
    })]
  ]

  #side-by-side(left-content, right-content)

  - All nodes will know the whole graph after $O(italic("diam")(G))$ rounds
]

#slide(
  title: [Critique to LOCAL]
)[
  #warning[Graph can be really large]
  - In a real world setting, it is not always possible to send arbitrary large messages
  - We'd like to lift this assumption
    - Messages need to be reasonably #formal-def[small]
]

#slide(
  title: [The CONGEST model],
  new-section: "CONGEST Algorithms"
)[
  // In real world scenario, we can't send messages on networks that are too big without incurring in performance penalties

  - We provide an upper bound on messages size
    - Messages larger than will require more rounds to be fully sent

  #key[In the CONGEST model, messages can only be in the size of $O(log n)$]

  #emph[Examples:]
  - Sending a single (or a constant amount of) identifier takes $O(1)$ rounds
  - Sending a _set_ of identifiers can take up to $O(n)$
  - Sending the whole graph requires $O(n^2)$ rounds:
    - The adjacency matrix alone reaches that

  #key[$=>$ We can't use #smallcaps[Gather-All] in the CONGEST model]
]

#slide(
  title: "MIS in CONGEST"
)[
  - Censor-Hillel et al. provided an algorithm that solves MIS in $O(italic("diam")(G) log^2 n)$ in CONGEST @chps17

  #warning[The diameter can be very large \ Worst case: $italic("diam")(G) = n$]
]

#slide(
  title: [Network Decomposition]
)[

  - A #formal-def[Network Decomposition] groups nodes in *colored clusters*
    - Clusters with the same color are not adjacent
    - We say it to #formal-def["have diameter"] $d$ if all of its clusters have diameter at most $d$
    - It has $c$ colors

  // TODO IMMAGINE

]

#slide(
  title: [How to use it?]
)[
  #idea[Solving MIS in a color will give a correct partial solution]

  - We can iterate this action with @chps17 for all colors
    - (dropping neighbours of different colors)

  - This algorithm has complexity $O(c dot d log^2 n)$
    - If $c = O(log n) = d$ then we would have a MIS algorithm in polylogarithmic time
]

#slide(
  title: "How to compute one?",
)[
  // TODO low?
  - Each color induces a *low diameter clustering*

  #def[A #formal-def[low diameter clustering] $cal("C") subset.eq 2^V$ for a graph $G$ with diameter $d$ is such:]
  1. $forall C_1 != C_2 in cal("C") : italic("dist")_G (C_1, C_2) >= 2$
    - #emph["There are no adjacent clusters"]
  2. $forall C in cal("C") : italic("diam")(G[C]) <= d$
    - #emph["Any cluster has diameter at most"] $d$

  #idea[A clustering #emph[can not be a partitioning]: some nodes have to be left out]

  Main iteration:
    1. Find a low diameter clustering
    2. Assign a free color to its nodes
    3. Repeat to discarded nodes until there are no more left

  #note[To get a $O(log n)$-colors decomposition, each color has to cluster *at least half* of the uncolored nodes]

  // TODO proof?
]

#slide(
  title: "Definitions",
  new-section: "Clusterings"
)[
  - Our previous definition of diamter is also called #formal-def[strong] diameter
  
  #def[We say a clustering has #formal-def[weak] diameter when]:
  1. (unchanged) #faded["There are no adjacent clusters"];
  2.  "Any cluster has diameter #emph[in $G$] at most" $d$

]

#slide(
  title: [Introduction],
  new-section: "The Algorithm"
)[
  - The main accomplishment of @rhg22 is to provide a straightforward algorithm that:
    - Terminates in $O(log^6 n)$ rounds in the CONGEST model
    - Outputs a clustering with $O(log^3 n)$ colors
    - The clustering has strong diameter

  - Previously @rg20 provided an algorithm for low diameter clustering with #emph[weak] diameter
    - $O(log^7 n)$ rounds with $O(log^3 n)$ colors
    - It's possible to turn it into strong diameter
  
  - @ehrg22 provided strong diameter in $O(log^4 n)$ rounds with $O(log^3 n)$ colors
    - Still has to pass by a weak diameter intermediate solution
]

#slide(
  title: [Algorithm Outline]
)[
  #emph[Phases]
  - There are $b = log (max i) = O(log n)$ #emph[phases]
  - "One phase for each bit in index"
    - Phase $i in [0, b - 1]$ computes "_#emph[terminals] set_" $Q_i$

  #emph[Notation]
  - $Q_i$ is the terminals set built _before_ phase $i$
  - $Q_b$ is the terminals set built _after_ phase $b-1$

]

// TODO terminal definition?

#slide(
  title: [Algorithm Outline (informal)],
  new-section: "The Algorithm"
)[
  // TODO ripassa cos'è un connected component
  #emph[Objective 1:] Creating *connected components* with low diameters
  - Eventually, each connected component will contain exactly one terminal
    - Keep terminals #formal-def[close] to active nodes
      - This ensures polylogarithmic diameter
      - Removing nodes is allowed

  - $Q_(i+1)$ is "_closer_" than $Q_i$ to any node
    - $Q_b$ is #formal-def[close] to any node

// TODO valutare un colore per efficient, close, small...

// TODO nomenclatura nodi: living vs dead / active vs inactive ... scegliere e usare unificata
]

#slide(title: [Algorithm Outline (informal)])[
  #emph[Objective 2:]
  - The algorithm must cluster at least $n/2$ nodes
    - Each phase *removes* at most $n/(2b)$ nodes
]

#slide(
  title: [Algorithm Outline]
)[
  #emph[Further notation:]
  - $V_i$ is the set of *living nodes* at the beginning of phase $i$ ($V_0 = V$)
  - $V'$ is the set of *living nodes* after the last phase;
    - $V' = V_b$
]

#slide(
  title: [Phase Invariants $forall i in [0..b]$]
)[
  1. $Q_i$ is $R_i$-ruling, i.e. $italic("dist")_G (Q_i, v) <= R_i$ for all $v in V$
    - We set $R_i = i * O(log^2 n)$
    - $Q_0$ is $0$-ruling, trivially true with $Q_0 = V$
    // "all nodes are terminals at the beginning"
    - $Q_b$ is $O(log^3 n)$-ruling
  
  #key[Each node has polylogarithmic distance from $Q_b$ $=>$ each connected component has #emph[at least one] terminal]
  // if not, some nodes would have infinite distance
]

#slide(
  title: [Phase Invariants $forall i in [0..b]$]
)[
  2. let $q_1, q_2 in Q_i$ s.t. they are in the same connected component in $G[V_i]$. Then $id(q_1)[0..i] = id(q_2)[0..i]$
    - for $i = 0$ it's trivially true
    - for $i = b$ there is $<= 1$ terminal in each c.c.
  
  #key[Along with invariant (1.), it means that each c.c. has polylogarithmic diameter! ]
]

#slide(
  title: [Phase Invariants $forall i in [0..b]$]
)[
  3. $|V_i| >= (1 - frac(i, 2b)) |V|$
    - $V_0 >= V$
    - $V' >= frac(1, 2) |V|$
  
  "The algorithm doesn't discard too much vertexes from the graph"
]

#slide(
  title: [Phase Outline]
)[
  #emph[Objective:] Keeping only terminals from which is possible to build a *forest* whose *trees* have polylogarithmic diameter
  - Leaves of the trees may be connected in $G$
  // TODO immagine

  #emph[Outline:]
  - $2b^2$ #emph[steps], each computing a forest
  - resulting into a sequence of forests $F_0 .. F_(2b^2)$
]

// per lavorare: apri con vscode il file (anche da fuori nix-shell)
// poi apri il pdf con zathura
// poi da una shell, entrare nella cartella
//                 , lanciare nix-shell
//                 , lanciare typst watch slides.typ 

#slide(
  title: [Step Outline]
)[
  #emph[Inductive definition:]
  - $F_0$ is a BFS forest with roots in $Q_i$
  - let $T$ be any tree in $F_j$ and $r$ its root
    - if $id(r)[i] = 0$ the whole tree is `red`, if not `blue`
      - `red` vertexes stay `red`
      - some `blue` nodes stay `blue`
      - some others #emph[propose] to join `red` trees
]

#slide(
  title: [Step Outline]
)[
  #emph[Proposal:]

  $v in V_j^italic("propose") <=> & v "is `blue`" \
  and & v "is the only one in " italic("path")(v, italic("root")(v)) \ 
  & "that neighbours a `red` node"$

  Define $T_v$ the (`blue`) subtree rooted at $v$

  #note[$v$ is the only node in $T_v$ that is also in $V_j^italic("propose")$]
]

#slide(
  title: [Step Outline]
)[
  #emph[Proposal:]

  - Each node in $V_j^italic("propose")$ proposes to an arbitrary `red` neighbour
  - Each `red` tree decides to grow or not
    - If it grows, it accepts all proposing trees
    - If not, all proposing subtrees are frozen
  - #emph[Criteria:] it decides to grow if it would gain at least $frac(|V(T)|, 2b)$ nodes
]

#slide(
  title: [Observations]
)[
  #note[If the `red` tree doesn't decide to grow, it will neighbour `red` nodes only]

  - This means it will be able to delete nodes only once in the whole phase // (i.e. among all $2b^2$ steps)
    #list(
      marker: [$=>$],
      [At most $frac(|V|, 2b)$ nodes are lost in each phase],
      [After the $b$ phases at most $frac(|V|, 2)$ nodes are removed]
    )
]

#slide(
  title: [High Level Pseudocode]
)[

  #grid(
    columns: (2fr, 1fr, 1fr, 1fr),
    [
      #set text(size: 24pt)
      
      #algorithm({
        import algorithmic: *
        ast_to_content_list(1, {
          Assign[$V_0$][$V$]
          Assign[$Q_0$][$V$]
          For(cond: $i in 0..b-1$, {
            State[#smallcaps("init") $F_0$]
            For(cond: $j in 0..2b^2 - 1$, {
              State[#smallcaps("build") $V_j^italic("propose")$]
              Assign[$F_(j+1)$][#smallcaps("step")]
            })
            Assign[$V_(i+1)$][$V(F_(2b^2))$]
            Assign[$Q_(i+1)$][$italic("roots")(F_(2b^2))$]
          })
        })
      })
    ],
    [ 
      #set text(size: 18pt)
      $ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ #scale(x: -100%)[$cases("", "", "")$] O(italic("diam")(T_v))$
    ],
    [
      #set text(size: 18pt)
      $ \ \ \ \ \ \ \ \ \ \ \ \ \  #scale(x: -100%)[$cases( "", "", "", "")$] 2b^2 = O(log^2 n)$
    ],
    [
      #set text(size: 18pt)
      $ \ \ \ \ \ \ \   #scale(x: -100%)[$cases("", "", "", "", "", "", "", "", "", "", "", "")$] b = O(log n)$
    ]
      
  )
]

#slide(
  title: [Step Complexity]
)[

  - Recall invariant (1.)
    - $forall v in V : italic("dist")_G (Q_i, v) = O(log^3 n)$, for all $i in 0..b$
    - Hence, $italic("diam")(T_v) = O(log^3 n)$, for all $v in V$

  - Complexity is $italic("#steps") times italic("#phases") times O(italic("diam")(T_v))$
    - $= O(log n) times O(log^2 n) times O(log^3 n)$
  The algorithm runs in $O(log^6 n)$ communication steps
  
]

/*
#slide(
  title: "The Communication Pitfall"
)[
  #set align(center)

  #cetz.canvas({
    import cetz.draw: *

    set-style(stroke: (paint: teal.darken(30%), thickness: 2pt))

    line((-3, -1), (0, 0))
    line((-3, 3), (0, 0))
    line((2, 3), (1, 5))
    line((2, 3), (5, 7))
    line((-3, 3), (-6, 7))
    line((-3, 3), (-6, 5))
    line((0, 0), (0, 3))
    line((-3, 3), (0, 3))
    line((1, 5), (0, 3))
    line((-4, 1), (-3, -1))


    circle((-3, -1), fill: teal.lighten(80%), radius: 0.75)
    circle((-6, 5), fill: teal.lighten(80%), radius: 0.75)
    circle((1, 5), fill: teal.lighten(80%), radius: 0.75)
    circle((0, 0), fill: teal.lighten(80%), radius: 0.75)
    circle((0, 3), fill: teal.lighten(80%), radius: 0.75)
    circle((5, 7), fill: teal.lighten(80%), radius: 0.75)
    content((5, 7), text(size: .8em, $u$))
    circle((-6, 7), fill: teal.lighten(80%), radius: 0.75)
    circle((2, 3), fill: teal.lighten(80%), radius: 0.75)
    circle((-3, 3), fill: teal.lighten(80%), radius: 0.75)
    circle((-4, 1), fill: teal.lighten(80%), radius: 0.75)
    content((-4, 1), text(size: .8em, $v$))
    
    set-style(mark: (end: "straight"), stroke: (paint: olive.darken(30%), thickness: 3pt))
    // bezier((-4.5, -2.5), (-3.5, -0.5), (-4.5, -0.5), stroke:(dash: "dashed"))
    line((-4, 1), (-3, -1), (0, 0), (0, 3), (1, 5), (2, 3), (5, 7), stroke: (dash: "dashed"))
    bezier((-4, 1), (-3, -1), (0, 0))
  })

  #set align(left)
  Hence we are interested in *#text(fill: unipd-red)[_(communication) rounds_]* complexity
]
*/

#slide(
  title: "Bibliography",
  new-section: ""
)[
  #bibliography("works.bib")
]

#slide(
  title: "About this presentation",
  new-section: "Introduction",
)[
    This presentation is supposed to briefly showcase
    what you can do with this package.

    For a full documentation, read the #link(
      "https://andreaskroepelin.github.io/polylux/book/",
    )[online book].
  ]

#slide(
  title: "A title",
)[
    Let's explore what we have here.

    On the top of this slide, you can see the slide
    title.

    We used the `title` argument of the `#slide`
    function for that: ```typ
        #slide(title: "First slide")[
            ...
        ]
        ```
    (This works because we utilise the `clean` theme;
    more on that later.)
  ]

#slide[
    Titles are not mandatory, this slide doesn't have
    one.

    But did you notice that the current section name
    is displayed above that top line?

    We defined it using #raw(
      "#new-section-slide(\"Introduction\")",
      lang: "typst",
      block: false,
    ).

    This helps our audience with not getting lost
    after a microsleep.

    You can also spot a short title above that.
  ]

#slide(
  title: "The bottom of the slide",
)[
    Now, look down!

    There we have some general info for the audience
    about what talk they are actually attending right
    now.

    You can also see the slide number there.
  ]

#slide(
  title: "Random text",
  new-section: "Dynamic content",
)[
    #lorem(64)
  ]

#slide(
  title: [A dynamic slide with `pause`s],
)[
    Sometimes we don't want to display everything at
    once. #pause

    That's what the `#pause` function is there for! #pause

    It makes everything after it appear at the next
    subslide.

    #text(
      .6em,
    )[(Also note that the slide number does not change
        while we are here.)]
  ]

#slide(
  title: "Fine-grained control",
)[
    When `#pause` does not suffice, you can use more
    advanced commands to show or hide content.

    These are some of your options: - `#uncover`
    - `#only`
    - `#alternatives`
    - `#one-by-one`
    - `#line-by-line`

    Let's explore them in more detail!
  ]

#slide(
  title: [`#uncover`: Reserving space],
)[
    With `#uncover`, content still occupies space,
    even when it is not displayed.

    For example, #uncover(2)[these words] are only
    visible on the second"subslide".

    In `()` behind `#uncover`, you specify _when_ to
    show the content, and in `[]` you then say _what_
    to show: #example[
        ```typ
                #uncover(3)[Only visible on the third "subslide"]
                ```
        #uncover(3)[Only visible on the third"subslide"]
      ]
  ]

#slide(
  title: "Complex display rules",
)[
    So far, we only used single subslide indices to
    define when to show something.

    We can also use arrays of numbers ...
    #example[
        ```typ
                #uncover((1, 3, 4))[Visible on subslides 1, 3, and 4]
                ```
        #uncover((1, 3, 4))[Visible on subslides 1, 3, and 4]
      ]

    ...or a dictionary with `beginning` and/or `until`
    keys: #example[
        ```typ
                #uncover((beginning: 2, until: 4))[Visible on subslides 2, 3, and 4]
                ```
        #uncover(
          (beginning: 2, until: 4),
        )[Visible on subslides 2, 3, and 4]
      ]
  ]

#slide(
  title: "Convenient rules as strings",
)[
    As as short hand option, you can also specify
    rules as strings in a special syntax.

    Comma separated, you can use rules of the form #table(
      columns: (auto, auto),
      column-gutter: 1em,
      stroke: none,
      align: (x, y) => (right, left).at(x),
      [`1-3`],
      [from subslide 1 to 3 (inclusive)],
      [`-4`],
      [all the time until subslide 4 (inclusive)],
      [`2-`],
      [from subslide 2 onwards],
      [`3`],
      [only on subslide 3],
    )
  ]

#slide(
  title: [`#only`: Reserving no space],
)[
    Everything that works with `#uncover` also works
    with `#only`.

    However, content is completely gone when it is not
    displayed.

    For example, #only(2)[#text(red)[see how]] the
    rest of this sentence moves.

    Again, you can use complex string rules, if you
    want. #example[
        ```typ
                #only("2-4, 6")[Visible on subslides 2, 3, 4, and 6]
                ```
        #only("2-4, 6")[Visible on subslides 2, 3, 4, and 6]
      ]
  ]

#slide(
  title: [`#alternatives`: Substituting content],
)[
    You might be tempted to try #example[
        ```typ
                #only(1)[Ann] #only(2)[Bob] #only(3)[Christopher] likes #only(1)[chocolate] #only(2)[strawberry] #only(3)[vanilla] ice cream.
                ```
        #only(1)[Ann] #only(2)[Bob] #only(3)[Christopher]

        likes #only(1)[chocolate] #only(2)[strawberry] #only(3)[vanilla]

        ice cream.
      ]

    But it is hard to see what piece of text actually
    changes because everything moves around. Better: #example[
        ```typ
                #alternatives[Ann][Bob][Christopher] likes #alternatives[chocolate][strawberry][vanilla] ice cream.
                ```
        #alternatives[Ann][Bob][Christopher] likes #alternatives[chocolate][strawberry][vanilla]
        ice cream.
      ]
  ]

#slide(
  title: [`#one-by-one`: An alternative for `#pause`],
)[
    `#alternatives` is to `#only` what `#one-by-one`
    is to `#uncover`.

    `#one-by-one` behaves similar to using `#pause`
    but you can additionally state when uncovering
    should start. #example[
        ```typ
                #one-by-one(start: 2)[one ][by ][one]
                ```
        #one-by-one(start: 2)[one][by][one]
      ]

    `start` can also be omitted, then it starts with
    the first subside: #example[
        ```typ
                #one-by-one[one ][by ][one]
                ```
        #one-by-one[one][by][one]
      ]
  ]

#slide(
  title: [`#line-by-line`: syntactic sugar for `#one-by-one`],
)[
    Sometimes it is convenient to write the different
    contents to uncover one at a time in subsequent
    lines.

    This comes in especially handy for bullet lists,
    enumerations, and term lists. #example[
        #grid(
          columns: (1fr, 1fr),
          gutter: 1em,
          ```typ
                      #line-by-line(start: 2)[
                          - first
                          - second
                          - third
                      ]
                      ```,
          line-by-line(
            start: 2,
          )[
              - first
              - second
              - third
            ],
        )
      ]

    `start` is again optional and defaults to `1`.
  ]

#slide(
  title: [`#list-one-by-one` and Co: when `#line-by-line`
    doesn't suffice],
)[
    While `#line-by-line` is very convenient
    syntax-wise, it fails to produce more
    sophisticated bullet lists, enumerations or term
    lists. For example, non-tight lists are out of
    reach.

    For that reason, there are `#list-one-by-one`, `#enum-one-by-one`
    , and `#terms-one-by-one`, respectively. #example[
        #grid(
          columns: (1fr, 1fr),
          gutter: 1em,
          ```typ
                      #enum-one-by-one(start: 2, tight: false, numbering: "i)")[first][second][third]
                      ```,
          enum-one-by-one(
            start: 2,
            tight: false,
            numbering: "i)",
          )[first][second][third],
        )
      ]

    Note that, for technical reasons, the bullet
    points, numbers, or terms are never covered.

    `start` is again optional and defaults to `1`.
  ]

#slide(
  title: "How a slide looks...",
  new-section: "Themes",
)[
    ... is defined by the _theme_ of the presentation.

    This demo uses the `unipd` theme.

    Because of it, the title slide and the decoration
    on each slide (with section name, short title,
    slide number etc.) look the way they do.

    Themes can also provide variants, for example ...
  ]

#focus-slide[
    ... this one!

    It's very minimalist and helps the audience focus
    on an important point.
  ]

#slide(
  title: "Your own theme?",
)[
    If you want to create your own design for slides,
    you can define custom themes!

    #link(
      "https://andreaskroepelin.github.io/polylux/book/themes.html#create-your-own-theme",
    )[The book]
    explains how to do so.
  ]

#slide(
  title: [The `utils` module],
  new-section: "Utilities",
)[
    Polylux ships a `utils` module with solutions for
    common tasks in slide building.
  ]

#slide(
  title: [Fit to height],
)[
    You can scale content such that it has a certain
    height using `#fit-to-height(height, content)`:

    #fit-to-height(2.5cm)[Height is `2.5cm`]
  ]

#slide(
  title: "Fill remaining space",
)[
    This function also allows you to fill the
    remaining space by using fractions as heights,
    i.e. `fit-to-height(1fr)[...]`:

    #fit-to-height(1fr)[Wow!]
  ]

#slide(
  title: "Side by side content",
)[
    Often you want to put different content next to
    each other. We have the function `#side-by-side`
    for that:

    #side-by-side(lorem(10), lorem(15), lorem(12))
  ]

#slide(
  title: "Outline",
)[
    Why not include an outline? #polylux-outline(padding: 0.5em, enum-args: (tight: false))
  ]

#slide(
  title: "Use Typst!",
  new-section: "Typst features",
)[
    Typst gives us so many cool things #footnote[For example footnotes!]
    . Use them!
  ]

#slide(
  title: "That's it!",
  new-section: "Conclusion",
)[
    Hopefully you now have some kind of idea what you
    can do with this template.

    Consider giving it #link(
      "https://github.com/andreasKroepelin/polylux",
    )[a GitHub star]
    or open an issue if you run into bugs or have
    feature requests.
  ]

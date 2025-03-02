#import "@preview/polylux:0.3.1": *
#import "unipd.typ": *
#import "@preview/cetz:0.3.2"
#import "@preview/algorithmic:0.1.0"
#import algorithmic: algorithm

#let emph(body) = text(fill: unipd-red)[*#body*]

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
  fill: orange.lighten(80%),
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

// todo background
// key concept
#let key(body) = [🗝️ #body]

// todo background
#let def(body) = [#underline[#emph[_def_]] #body]

#let today = datetime.today().display("[day]/[month]/[year]")

#show: unipd-theme.with(author: "Christian Micheletti", date: today)
#show math.equation: set text(font: "Fira Math")
#show raw: set text(font: "Iosevka Extended")

#set text(font: (
  "Marianne",
  "Noto Color Emoji",
), size: 30pt)

#show raw: set text(size: 1.1em)
#show smallcaps: set text(font: "EB Garamond SC 12")

#title-slide(
  title: "Efficient Low Diameter Clustering",
  subtitle: "with strong diameter in the CONGEST model",
)

// pannellone "What are we talking about?"

#slide(
  title: "Distributed Algorithms",
  new-section: "Overview"
)[
  Many modern problems apply to #emph("networks of computers")

  #idea($"Distribution" => "Parallelism"$)

  #emph("Idea:") we can leverage parallelism to speed up computations

  #warning($"Distribution" => "Remoteness"$)

  #emph[Bottleneck:] remote communication

  Our aim is to study algorithms that execute in a distributed environment
]

#slide(
  title: "Complexity",
)[

  W.l.o.g.#footnote[Without loss of generality.] we adopt a model of execution divided in #emph[communication rounds]

  Each round, a node $v in V$ performs this actions:
  1. $v$ #emph[sends] messages to its neighbours;
  2. $v$ #emph[receives] messages from its neighbours;
  3. $v$ #emph[executes locally] some algorithm (same for each node)
  
  W.l.o.g. rounds are #emph[synchronized]
]

#slide(
  title: [A First Example (#smallcaps("Wave"))]
)[
  // TODO visualizzare 'wave'

  In #smallcaps("Wave") a single node starts "waving hello" to its neighbours that, in turn, "wave" to their neighbours

  Each communication round can take a significant amount of time to happen

  #key[Complexity is measured in #emph[rounds]]

  The running time of this algorithm on a graph $G$ is $O(italic("diam")(G))$

  We say #emph[efficient] meaning $O("polylog" n)$, where $n = |V|$ 
]

#slide(
  title: "Centralized Graph Problems"
)[

  Example: #emph[Maximal Independent Set] (MIS)

  Solving it in a centralized model is easily done with a greedy algorithm

  #def["*Centralized*" $equiv$ "*knowing the graph topology*"]

  #warning[From the perspective of a single node, we don't see the whole topology]
]

#slide(
  title: "PN-Network",
  new-section: "Models"
)[

  What can a node see?

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

  In the #emph[PN-Network] a node only knows that it has some *ports*, each connected with a *different* node

  #warning[Each node appears identical to any other]

  We must break this symmetry
]

#slide(
  title: [LOCAL Model]
)[
  #idea[We add unique identifiers to the model]

  #set align(center)
  $italic(id) : V -> NN$

  $"where" forall v in V : italic(id)(v) <= n^c "for some" c >= 1$

  #set align(left)

  #note[We choose $n^c$ so that we need $O(log n)$ bits to represent an identifier, i.e. identifiers are reasonably #emph[small]]
]

#slide(
  title: "Naive MIS",
  new-section: "LOCAL Algorithms"
)[
  #algorithm({
    import algorithmic: *
    ast_to_content_list(1, {
      Assign[$m$][$m || bot$]
      If(cond: [$m =$ `selected`], {
        Fn[stop][`result: 1`]
      })
      State[#smallcaps("send") $m$]
      State[#smallcaps("receive") $italic("messages")$]
      If(cond: [`selected` $in italic("messages")$], {
        Fn[stop][`result: 0`]
      })
      If(cond: [`round` $ = italic(id)(v)$],
        {
          Assign[$m$][`selected`]
        }
      )
    })
  })

  This algorithm runs in $O(n^c)$

]

#slide(
  title: "Gathering All"
)[
  We can be way smarter than that

  #idea[Running a centralized algorithm on a single node would take O(1) rounds]

  The algorithm #smallcaps[Gather-All] makes all nodes build a local copy of the whole graph

  It takes $O(italic("diam")(G))$

  Then, we can run a deterministic centralized MIS algorithm on each node and output `1` if the node is in the computed MIS
]

#slide(
  title: [The CONGEST model],
  new-section: "CONGEST Algorithms"
)[
  // In real world scenario, we can't send messages on networks that are too big without incurring in performance penalties

  We aim to bind the message sizes to a reasonably small limit

  #key[In the CONGEST model, messages can only be in the size of $O(log n)$]

  To send messages bigger than that, more rounds are needed

  #emph[Examples:]
  - Sending a single (or a constant amount of) identifier takes $O(1)$ rounds;
  - Sending a _set_ of identifiers can take up to $O(n)$ rounds;

  For this reason, we can't use #smallcaps[Gather-All] in the CONGEST model.
]

#slide(
  title: [Network Decomposition]
)[
  There is an algorithm that solves MIS in $O(italic("diam")(G) log^2 n)$ in CONGEST @chps17

  #warning[The diameter can be very large: \  we can only say that $italic("diam")(G) <= n$]

  A #emph[Network Decomposition] divides a network in colored clusters, where clusters with the same color are not adjacent
  - It has diameter $d$ if all of its clusters have diameter at almost $d$;
  - It has $c$ colors.

  #idea[We can run #smallcaps("MIS") @chps17 for each color, in parallel in its clusters \
  and remove the neighbours of the newly added nodes]

  This algorithm would have complexity $O(c dot d log^2 n)$

  If $c = O(log n) = d$ then we would have a MIS algorithm in polylogarithmic time
]

#slide(
  title: "How to compute one?",
)[
  // TODO low?
  By definition, each color induces a #emph[low diameter clustering]

  #idea[We can find a low diameter clustering, color them with a color, and repeat on uncolored nodes]

  #note[To get a $O(log n)$ colored decomposition, each clustering has to cluster at least half of the nodes]
]

#slide(
  title: "Definitions",
  new-section: "Clusterings"
)[
  #def[A #emph[clustering] $cal(C) subset.eq 2^V$ is any set of #emph[disjoint subsets] of $V$]

  #def[We say it has (strong) #emph[diameter] $d in NN$ when:
  1. No two clusters are adjacent, i.e. $forall C_1, C_2 in cal(C) : italic("dist")_G (C_1, C_2) >= 2$;
  #note[This means that a clustering _can not_ be a partitioning: some node has to be left out]
  2. Each cluster has at most diameter $d$, i.e. $forall C in cal(C) italic("diam")_C (C) <= d$.
  ]

  #def[We say it has #emph[low] diameter instead when:
  1. (unchanged);
  2. Each cluster has at most diameter in $G$ $d$, i.e. $forall C in cal(C) italic("diam")_G (C) <= d]$.
  ]
]

#slide(
  title: [Previous works]
)[
  The state of the art before @rhg22 is @rg20 and @ehrg22
  - TODO

  The main accomplishment of @rhg22 is to provide an easier algorithm that still runs in polylogarithmic time
]

#slide(
  title: [Outline],
  new-section: "The Algorithm"
)[
  #emph[Objective:] Creating connected components with low diameters

  #emph[Outline:]
  - There are $b = O(log n)$ #emph[phases], phase $i$ computes a set of #emph[terminals] $Q_i$;
  - $Q_i$ is $R$-ruling, i.e. $italic("dist")_G (Q_i, v) <= R$ for all $v in V$.

]

#slide(title: [Outline])[
  #emph[Objective:]
  - Each phase removes some nodes: at most $frac(|V|, 2b)$;

  #emph[Outline:]
  - $V_i$ is the set of living nodes at the beginning of phase $i$;
    - $V_0 = V$
  - $V'$ is the set of living nodes after the last phase;
    - $V' = V_b$
]

#slide(
  title: [Outline]
)[
  #emph[Objective] (formalised):
  - Each connected component of $G[V']$ contains exactly one terminal
  - Moreover, it has polylogarithmic diameter
]

#slide(
  title: [Invariants $forall i in [0..b]$]
)[
  1. $Q_i$ is $R_i$-ruling, i.e. $italic("dist")_G (Q_i, v) <= R_i$ for all $v in V$, with $R_i = i * O(log n)$
    - $Q_0$ is $0$-ruling, trivially true since $Q_0 = V$;
    - $Q_b$ is $O(log^3 n)$-ruling
  
  #idea[Each node has polylogarithmic distance from $Q_b$ $=>$ each connected component has at least one terminal]
]

#slide(
  title: [Invariants $forall i in [0..b]$]
)[
  2. let $q_1, q_2 in Q_i$ s.t. they are in the same connected component in $G[V_i]$. Then $id(q_1)[0..i] = id(q_2)[0..i]$
    - for $i = 0$ it's trivially true
    - for $i = b$ there is $<= 1$ terminal in each c.c.
  
  #idea[Along with invariant (1.), it means that each c.c. has polylogarithmic diameter! ]
]

#slide(
  title: [Invariants $forall i in [0..b]$]
)[
  3. $|V_i| >= (1 - frac(i, 2b)) |V|$
    - $V_0 >= V$
    - $V' >= frac(1, 2) |V|$
  
  #idea[The algorithm doesn't discard too much vertexes from the graph]
]

#slide(
  title: [Phase Outline]
)[
  #emph[Objective:] Keeping only terminals from which is possible to build forests whose trees have polylogarithmic diameter

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
  #emph[Inductive definition]
  - $F_0$ is a BFS forest with roots in $Q_i$
  - let $T$ be any tree in $F_j$, and $r$ its root
    - if $id(r)[i] = 0$ the whole tree is `red`, if not `blue`
      - `red` vertexes stay `red`
      - some `blue` nodes stay `blue`
      - some others #emph[propose] to join `red` trees
]

#slide(
  title: [Step Outline]
)[
  #emph[Proposal]

  $v in V_j^italic("propose") <=> & v "is `blue`" \
  and & v "is the only one in " italic("path")(v, italic("root")(v)) \ 
  & "that neighbours a `red` node"$

  Define $T_v$ the (`blue`) subtree rooted at $v$

  #note[$v$ is the only node in $T_v$ that is also in $V_j^italic("propose")$]
]

#slide(
  title: [Step Outline]
)[
  #emph[Proposal]

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

  - This means it will be able to delete nodes only once in the whole phase (i.e. after $2b^2$ steps)
  - Hence at most $frac(|V|, 2b)$ nodes are lost in each phase
  - After the $b$ phases at most $frac(|V|, 2)$ nodes are deleted
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
      $ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ #scale(x: -100%)[$cases("", "", "")$] O(log italic("diam")(T_v))$
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

  Recall invariant (1.): $forall v in V : italic("dist")_G (Q_i, v) = O(log^3 n)$, for all $i in 0..b$

  Hence, $italic("diam")(T_v) = O(log^3 n)$, for all $v in V$

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

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

#let emph(body) = text(style: "italic", fill: unipd-red.darken(30%),weight: "bold")[#body]

#let polylog-hint(body) = text(style: "italic", fill: oxford-blue, weight: "bold")["#body"]

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
    align(center, text(fill: unipd-red.darken(30%), weight: "medium")[#body]),
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
    align(center, text(fill: oxford-blue, weight: "medium")[#body]),
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
    align(center, text(fill: ocra.darken(95%), weight: 400)[#body]),
    align(right, "")
  )),
)

// key concept
#let key(body) = block(
  width: 100%,
  inset: .5em,
  fill: bluesnow.lighten(60%),
  radius: .5em,
  text(grid(
    columns: (1fr, 10fr, 1fr),
    align(left, ""),
    align(center, text(fill: oxford-blue, weight: "medium")[#body]),
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

#let faded(body) = text(fill: rgb("#999999"), weight: "bold")[#body]

// todo background

// #let today = datetime.today().display("[day]/[month]/[year]")

#show: unipd-theme.with(author: "Christian Micheletti", date: "")
#show math.equation: set text(font: "Fira Math")
#show raw: set text(font: "Iosevka Extended")

#set text(font: (
  "FreeSans",
  "Noto Color Emoji",
), weight: "regular", size: 26pt)

#show raw: set text(size: 1.1em)
#show smallcaps: set text(font: "FreeSans")

#title-slide(
  title: "Efficient Low Diameter Clustering",
  subtitle: "with strong diameter in the CONGEST model",
)

// pannellone "What are we talking about?"

#slide(
  title: [About this Presentation]
)[
  // #polylux-outline(padding: 0.5em, enum-args: (tight: false))
  #v(1fr)
  1. Distributed Algorithms
  #v(1fr)
  2. Network Decomposition
  #v(1fr)
  3. Low Diameter Clustering
  #v(1fr)
]

#slide(
  title: "Intuition",
  new-section: "Distributed Algorithms"
)[
  - We want to solve graph problems on *networks*
    - Computers are like nodes in a graph
  
  #key[Distribution $=>$ Multiple processors]

  #pause

  - Nodes can run code
    - Should be *the same for all nodes*

  #idea[Each node gives a partial solution]
  
  - Arcs are *communication links* between computers
]

#slide(
  title: "A First Simple Model"
)[

  #let right-content = [

    #set align(center + horizon)
    #cetz.canvas({
      import cetz.draw: *

      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt))
      set-style(content: (frame: "rect", stroke: none, fill: white))


      line((-2, 2), (2, 2), stroke: (dash: "dashed"))
      line((-1.5, 0), (0, 0))
      line((-1.5, 0), (-3, 0), stroke: (dash: "dashed"))
      circle((-3, 0), fill: teal.lighten(80%), radius: 0.75, stroke: (dash: "dashed"))

      line((1, 1), (0, 0))
      line((1, 1), (2, 2), stroke: (dash: "dashed"))
      circle((2, 2), fill: teal.lighten(80%), radius: 0.75, stroke: (dash: "dashed"))

      line((-1, 1), (0, 0))
      line((-1, 1), (-2, 2), stroke: (dash: "dashed"))
      circle((-2, 2), fill: teal.lighten(80%), radius: 0.75, stroke: (dash: "dashed"))

      circle((0, 0), fill: teal.lighten(80%), radius: 0.75, name: "node")
      /*  
      content("node.north-east", [#set text(size: 17pt, fill: teal.darken(50%), weight: "bold"); 1], anchor: "south-west")   
      content("node.north-west", [#set text(size: 17pt, fill: teal.darken(50%), weight: "bold"); 2], anchor: "south-east") 
      content("node.west", [#set text(size: 17pt, fill: teal.darken(50%), weight: "bold"); 3], anchor: "east")  
      circle((0, 0), fill: teal.lighten(80%), radius: 0.75)
      */
    })
  ]

  #let left-content = [

    - In the *PN-Network* a node only knows its #emph[neighbours]
      - And how to "contact" them
    - There are no *self loops*
    - Connection is two-way
    - There is $<= 1$ arc between two nodes
  ]

  #grid(
    columns: (2fr, 1fr),
    left-content,
    right-content
  ) #pause

  #warning[A node can't see the whole topology]
  #pause
  
  #warning[All nodes appear identical]
]

/*
#slide(title: "The PN-Network")[

  - The only difference _could be_ in the total number of ports
    - Not enough!

  - *We must break this symmetry*
]
*/

#slide(
  title: [The LOCAL Model]
)[
  #idea[We add *unique identifiers* to the nodes]

  #set align(center)
  $italic(id) : V -> NN$

  $"where" forall v in V : italic(id)(v) <= n^c "for some" c >= 1$

  #set align(left)

  // we don't want to [limitare] the pool of indentifiers too much, but we want at least an upper bound

  #key[We choose $n^c$ so we need $O(log n)$ bits to represent an identifier, \
  (identifiers are reasonably #polylog-hint[small])]

  // so this seems enough for the model
  // but we need to define how communication works
]


#slide(
  title: "Communication (Intuition)"
)[
  - Collaboration requires *exchanging messages*
   \ ...on a medium that is *slow* and *unreliable*

  //  Our aim is to study algorithms that execute in a distributed environment
  #warning[$=>$ Communication is the main pitfall]

  - Too many messages congest the network
  - We *quantify* the number of messages that an algorithm requires
    - An #polylog-hint[efficient] algorithm will need few messages
]

#slide(
  title: "Communication Model",
)[

  W.l.o.g.#footnote[Without loss of generality.] we adopt a model of #emph[synchronous communication]

  // why? so that we can quantify easier the ceiling / "worst case" of the number of message sent in the network

  Each round, a node $v in V$ performs these actions:
  1. $v$ #emph[sends] a message $italic("msg") in NN$ to its neighbours
  2. $v$ #emph[receives] messages from its neighbours
  3. ... #pause

  - (1.) and (2.) establish a #emph[communication round]
    - *Measure unit of complexity*
    - Few communication rounds $=>$ few messages
]

#slide(
  title: "Communication Model",
)[
  3. $v$ #emph[executes locally] some algorithm (same for each node).
    - A node may #emph[stop] in this phase
      - Its local result is *final*
  
  #note[(3.) doesn't affect the algorithm's complexity] #pause
  // we are interested in capture the complexity that is upon the network

  - When all nodes *stopped* the algorithm terminates

  #key[An algorithm is #polylog-hint[efficient] when it stops in a number of rounds #text(fill: oxford-blue, weight: 700)[polylogarithmic] in $|V|$]
]

/*
#slide(
  title: "Distributed Algorithms"
)[
  - This seems enough for the model
  - We must now define:
    - What *"distributed"* algorithms consist of
    - And the criteria for *complexity* analysis
]
*/

#slide(
  title: [#smallcaps("Wave"): A First Example]
)[

  - The node with $id(v) = 0$ _"waves hello"_ to neighbours
    - ...sending them a message #pause
  // doing stuff based on id is enough to break symmetry
  
  - When a node receives the message, *forwards* it to its neighbours
    - And then *stops* #pause

 -  The running time of this algorithm on a graph $G$ is $O(italic("diam")(G))$
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

  - Solving it #emph[centralized] is easy
  - How can we solve it #emph[distributed]?
]

#slide(
  title: [A Second Example (#smallcaps("Naive-MIS"))]
)[
  #idea[Let's leverage $id(v)$ to select the next MIS node]
  
  - At round \#$i$, node $v : id(v) = i$ executes
    - If no neighbour is in the MIS, add the node
      - And inform the neighbours
    - Otherwise, the node is outside the MIS #pause

  
  /*
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
  */

  - It is correct since no node has the same $id$
  - This algorithm runs in $O(n^c)$ (the maximum $id$)
    - *Very bad*

]

#slide(
  title: "Gathering All"
)[

  #idea[Running a centralized algorithm on a single node would take O(1) rounds]
  // minimizes number of messages in the net

  - We'd like to run a MIS algorithm on each node
    - Each must have a *local copy* of the *entire* graph
    - The algorithm must be deterministic
      - When a node stops it checks if it is included in MIS
]

#slide(
  title: "Gathering All"
)[

  - The algorithm #smallcaps[Gather-All] makes all nodes build a local copy of the whole graph
    - At round $i$, each node $v$ knows $italic("ball")(i, v)$
  
  #let left-content = [
    #set align(center)

    #set text(fill: ocra.darken(30%), size: 24pt)
    $italic("ball")(0, v)$

    #v(-32pt)

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

    #v(-32pt)

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
  
  #v(-32pt)

  - All nodes will know the whole graph after $O(italic("diam")(G))$ rounds
]

#slide(
  title: [Critique to LOCAL]
)[
  - #smallcaps[Gather-All] assumes that messages size is *unbounded*

  #warning[Requires to send the whole graph in one message]
  - It is not always possible to send arbitrary large messages
    - Heavy ones may be "sharded"
  - We provide an upper bound for message size
    - Messages need to be reasonably #polylog-hint[small]
    - Large messages will require more rounds to be sent
]

#slide(
  title: [The CONGEST model]
)[
  // In real world scenario, we can't send messages on networks that are too big without incurring in performance penalties

  

  #key[In the CONGEST model, messages size has to be $O(log n)$]

  - Sending $k$ identifiers takes $O(1)$ rounds
  - Sending a _set_ of identifiers can take up to $O(n)$
  - Sending the whole graph requires $O(n^2)$ rounds:
    - The adjacency matrix suffices...

  #warning[$=>$ We can't use #text(weight: "light")[#smallcaps[Gather-All]] in the CONGEST model]
]

#focus-slide[
  // We've established our computation model

  // Now we'll see how to solve problems in CONGEST

  Solving problems in CONGEST
]

#slide(
  title: "MIS in CONGEST",
  new-section: [Network Decomposition]
)[
  - Censor-Hillel et al. @chps17 provided an algorithm that solves MIS in $O(italic("diam")(G) log^2 n)$ in CONGEST

  #warning[The diameter can be very large]

  - Worst case: $italic("diam")(G) = n$
  - How can we improve it?
]



  #let network-decomposition = [
    #set align(center)

    #cetz.canvas({
      import cetz.draw: *

      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))

      line((-2, 1), (2, 1.5))
      
      line((-2, 1), (-3, -1))

      line((4, 0.5), (2, 1.5))

      line((-3, -1), (-0.25, 0))
      line((-0.25, 0), (1.25, -1.75))
      line((4, 0.5), (3.75, -1.5))

      line((1.25, -1.75), (3.75, -1.5))
      line((4, 0.5), (6, 0.25))
      line((9, 1), (6, 0.25))
      line((8, -1.75), (6, 0.25))
      line((8, -1.75), (9, 1))



      set-style(stroke: (paint: ocra.darken(30%), thickness: 2pt, dash: none))
      circle((-2, 1), fill: ocra.lighten(80%), radius: 0.75)   //
      circle((-3, -1), fill: ocra.lighten(80%), radius: 0.75)

      set-style(stroke: (paint: green.darken(30%), thickness: 2pt, dash: none))
      circle((2, 1.5), fill: green.lighten(80%), radius: 0.75)
      circle((-0.25, 0), fill: green.lighten(80%), radius: 0.75) 

      set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 2pt, dash: none))
      circle((4, 0.5), fill: oxford-blue.lighten(80%), radius: 0.75)   //
      circle((1.25, -1.75), fill: oxford-blue.lighten(80%), radius: 0.75) //
      circle((3.75, -1.5), fill: oxford-blue.lighten(80%), radius: 0.75)

      set-style(stroke: (paint: green.darken(30%), thickness: 2pt, dash: none))
      circle((6, 0.25), fill: green.lighten(80%), radius: 0.75)
      circle((8, -1.75), fill: green.lighten(80%), radius: 0.75)
      circle((9, 1), fill: green.lighten(80%), radius: 0.75)

    })
  ]

#slide(
  title: [Network Decomposition]
)[

  - A #emph[Network Decomposition] groups nodes in *colored clusters*
    - Clusters with the same color are not adjacent
    - We say it to #emph[have diameter] $d$ if each cluster has diameter at most $d$
    - It has $c$ colors
    
  #v(-16pt)

  #network-decomposition

]

#slide(
  title: [How to use it?]
)[
  #idea[Solving MIS in a color gives a partial solution]

  - We can apply @chps17 for all colors
    - (dropping MIS neighbours after each iter)
    - This has complexity $O(c dot d log^2 n)$
      - If $c = O(log n) = d$ it would be #polylog-hint[efficient] 
  
  #v(-16pt)

  #network-decomposition
]

#let low-diameter-clustering = [
    #set align(center)

    #cetz.canvas({
      import cetz.draw: *

      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))

      line((-2, 1), (2, 1.5))
      
      line((-2, 1), (-3, -1))

      line((4, 0.5), (2, 1.5))

      line((-3, -1), (-0.25, 0))
      line((-0.25, 0), (1.25, -1.75))
      line((4, 0.5), (3.75, -1.5))

      line((1.25, -1.75), (3.75, -1.5))
      line((4, 0.5), (6, 0.25))
      line((9, 1), (6, 0.25))
      line((8, -1.75), (6, 0.25))
      line((8, -1.75), (9, 1))



      set-style(stroke: (paint: whitesnow.darken(30%), thickness: 2pt, dash: none))
      circle((-2, 1), fill: whitesnow.lighten(80%), radius: 0.75)   //
      circle((-3, -1), fill: whitesnow.lighten(80%), radius: 0.75)

      set-style(stroke: (paint: green.darken(30%), thickness: 2pt, dash: none))
      circle((2, 1.5), fill: green.lighten(80%), radius: 0.75)
      circle((-0.25, 0), fill: green.lighten(80%), radius: 0.75) 

      set-style(stroke: (paint: whitesnow.darken(30%), thickness: 2pt, dash: none))
      circle((4, 0.5), fill: whitesnow.lighten(80%), radius: 0.75)   //
      circle((1.25, -1.75), fill: whitesnow.lighten(80%), radius: 0.75) //
      circle((3.75, -1.5), fill: whitesnow.lighten(80%), radius: 0.75)

      set-style(stroke: (paint: green.darken(30%), thickness: 2pt, dash: none))
      circle((6, 0.25), fill: green.lighten(80%), radius: 0.75)
      circle((8, -1.75), fill: green.lighten(80%), radius: 0.75)
      circle((9, 1), fill: green.lighten(80%), radius: 0.75)

    })
  ]

#slide(
  title: "How to compute one?",
)[

  A #emph[low diameter clustering] $cal("C") subset.eq 2^V$ for a graph $G$ with diameter $d$ is such:
  1. $forall C_1 != C_2 in cal("C") : italic("dist")_G (C_1, C_2) >= 2$
    - *_"There are no adjacent clusters"_*
  2. $forall C in cal("C") : italic("diam")(G[C]) <= d$
    - *_"Any cluster has diameter at most $d$"_*
    
  #v(-16pt)
  
  #low-diameter-clustering

 // #key[A non-trivial clustering #text(weight: 700)[can not be a partitioning]: some nodes have to be left out]
]

#slide(
  title: "How to compute one?",
)[

  Main iteration:
    1. Find a low diameter clustering
    2. Assign a free color to its nodes
    3. Repeat to discarded nodes until there are no more left

  #let build-nd-1 = scale(70%)[
    #set align(center)

    #cetz.canvas({
      import cetz.draw: *

      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))

      line((-2, 1), (2, 1.5))
      
      line((-2, 1), (-3, -1))

      line((4, 0.5), (2, 1.5))

      line((-3, -1), (-0.25, 0))
      line((-0.25, 0), (1.25, -1.75))
      line((4, 0.5), (3.75, -1.5))

      line((1.25, -1.75), (3.75, -1.5))
      line((4, 0.5), (6, 0.25))
      line((9, 1), (6, 0.25))
      line((8, -1.75), (6, 0.25))
      line((8, -1.75), (9, 1))

      set-style(stroke: (paint: unipd-red.darken(30%), thickness: 2pt, dash: "dashed"))
      circle((2, 1.5), fill: unipd-red.lighten(80%), radius: 0.75)
      circle((-0.25, 0), fill: unipd-red.lighten(80%), radius: 0.75) 
      circle((6, 0.25), fill: unipd-red.lighten(80%), radius: 0.75)
      circle((8, -1.75), fill: unipd-red.lighten(80%), radius: 0.75)
      circle((9, 1), fill: unipd-red.lighten(80%), radius: 0.75)

      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))
      // set-style(stroke: (paint: ocra.darken(30%), thickness: 2pt, dash: none))
      circle((-2, 1), fill: teal.lighten(80%), radius: 0.75)   //
      circle((-3, -1), fill: teal.lighten(80%), radius: 0.75)


      // set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 2pt, dash: none))
      circle((4, 0.5), fill: teal.lighten(80%), radius: 0.75)   //
      circle((1.25, -1.75), fill: teal.lighten(80%), radius: 0.75) //
      circle((3.75, -1.5), fill: teal.lighten(80%), radius: 0.75)


    })
  ]
  #let build-nd-2 = scale(70%)[
    #set align(center)

    #cetz.canvas({
      import cetz.draw: *

      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))

      line((-2, 1), (2, 1.5))
      
      line((-2, 1), (-3, -1))

      line((4, 0.5), (2, 1.5))

      line((-3, -1), (-0.25, 0))
      line((-0.25, 0), (1.25, -1.75))
      line((4, 0.5), (3.75, -1.5))

      line((1.25, -1.75), (3.75, -1.5))
      line((4, 0.5), (6, 0.25))
      line((9, 1), (6, 0.25))
      line((8, -1.75), (6, 0.25))
      line((8, -1.75), (9, 1))



      set-style(stroke: (paint: green.darken(30%), thickness: 2pt, dash: none))
      circle((2, 1.5), fill: green.lighten(80%), radius: 0.75)
      circle((-0.25, 0), fill: green.lighten(80%), radius: 0.75) 
      circle((6, 0.25), fill: green.lighten(80%), radius: 0.75)
      circle((8, -1.75), fill: green.lighten(80%), radius: 0.75)
      circle((9, 1), fill: green.lighten(80%), radius: 0.75)

      // set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))
      set-style(stroke: (paint: unipd-red.darken(30%), thickness: 2pt, dash: "dashed"))
      circle((-2, 1), fill: unipd-red.lighten(80%), radius: 0.75)   //
      circle((-3, -1), fill: unipd-red.lighten(80%), radius: 0.75)

      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))
      // set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 2pt, dash: none))
      circle((4, 0.5), fill: teal.lighten(80%), radius: 0.75)   //
      circle((1.25, -1.75), fill: teal.lighten(80%), radius: 0.75) //
      circle((3.75, -1.5), fill: teal.lighten(80%), radius: 0.75)

    })
  ]
  #let build-nd-3 = scale(70%)[
    #set align(center)

    #cetz.canvas({
      import cetz.draw: *

      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))

      line((-2, 1), (2, 1.5))
      
      line((-2, 1), (-3, -1))

      line((4, 0.5), (2, 1.5))

      line((-3, -1), (-0.25, 0))
      line((-0.25, 0), (1.25, -1.75))
      line((4, 0.5), (3.75, -1.5))

      line((1.25, -1.75), (3.75, -1.5))
      line((4, 0.5), (6, 0.25))
      line((9, 1), (6, 0.25))
      line((8, -1.75), (6, 0.25))
      line((8, -1.75), (9, 1))




      set-style(stroke: (paint: green.darken(30%), thickness: 2pt, dash: none))
      circle((2, 1.5), fill: green.lighten(80%), radius: 0.75)
      circle((-0.25, 0), fill: green.lighten(80%), radius: 0.75) 
      circle((6, 0.25), fill: green.lighten(80%), radius: 0.75)
      circle((8, -1.75), fill: green.lighten(80%), radius: 0.75)
      circle((9, 1), fill: green.lighten(80%), radius: 0.75)

      // set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))
      set-style(stroke: (paint: ocra.darken(30%), thickness: 2pt, dash: none))
      circle((-2, 1), fill: ocra.lighten(80%), radius: 0.75)   //
      circle((-3, -1), fill: ocra.lighten(80%), radius: 0.75)

      set-style(stroke: (paint: unipd-red.darken(30%), thickness: 2pt, dash: "dashed"))
      // set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 2pt, dash: none))
      circle((4, 0.5), fill: unipd-red.lighten(80%), radius: 0.75)   //
      circle((1.25, -1.75), fill: unipd-red.lighten(80%), radius: 0.75) //
      circle((3.75, -1.5), fill: unipd-red.lighten(80%), radius: 0.75)

    })
  ]
  #let build-nd-4 = scale(70%)[
    #set align(center)

    #cetz.canvas({
      import cetz.draw: *

      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))

      line((-2, 1), (2, 1.5))
      
      line((-2, 1), (-3, -1))

      line((4, 0.5), (2, 1.5))

      line((-3, -1), (-0.25, 0))
      line((-0.25, 0), (1.25, -1.75))
      line((4, 0.5), (3.75, -1.5))

      line((1.25, -1.75), (3.75, -1.5))
      line((4, 0.5), (6, 0.25))
      line((9, 1), (6, 0.25))
      line((8, -1.75), (6, 0.25))
      line((8, -1.75), (9, 1))




      set-style(stroke: (paint: green.darken(30%), thickness: 2pt, dash: none))
      circle((2, 1.5), fill: green.lighten(80%), radius: 0.75)
      circle((-0.25, 0), fill: green.lighten(80%), radius: 0.75) 
      circle((6, 0.25), fill: green.lighten(80%), radius: 0.75)
      circle((8, -1.75), fill: green.lighten(80%), radius: 0.75)
      circle((9, 1), fill: green.lighten(80%), radius: 0.75)

      // set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))
      set-style(stroke: (paint: ocra.darken(30%), thickness: 2pt, dash: none))
      circle((-2, 1), fill: ocra.lighten(80%), radius: 0.75)   //
      circle((-3, -1), fill: ocra.lighten(80%), radius: 0.75)

      set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 2pt, dash: none))
      // set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 2pt, dash: none))
      circle((4, 0.5), fill: oxford-blue.lighten(80%), radius: 0.75)   //
      circle((1.25, -1.75), fill: oxford-blue.lighten(80%), radius: 0.75) //
      circle((3.75, -1.5), fill: oxford-blue.lighten(80%), radius: 0.75)

    })
  ]

  #let left-arrow-incl = place(
    center,
    dx: 200pt
  )[
    #rotate(-20deg)[$<--$]
  ]

  #grid(
    columns: (9fr, 1fr, 9fr),
    [#v(-40pt); #build-nd-1 #v(-21pt) #pause],
    [#set align(center); $-->$],
    [#v(-40pt); #build-nd-2 #v(-21pt) #pause],
    [ #left-arrow-incl #v(-20pt); #build-nd-3 #pause],
    [#set align(center + horizon); $-->$],
    [ #v(-20pt); #build-nd-4 ],
  )
]

/*
#slide(
  title: "How to compute one?",
)[
  #key[To get a $O(log n)$-colors decomposition, each color has to cluster *at least half* of the uncolored nodes]

  - Otherwise we can end up with too many colors

  // TODO proof?
]
*/

#let weak-d = [
    #set align(center)

    #cetz.canvas({
      import cetz.draw: *


      set-style(stroke: (paint: gray, thickness: 4pt, dash: "dashed"))

      line((-3, 1), (-1, 0))
      line((-1, 0), (-2.5, -2))

      set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))

      line((-3, 1), (2, 1.5))
      

      line((4, 0.5), (2, 1.5))

      line((-2.5, -2), (1.25, -1.75))
      line((4, 0.5), (3.75, -1.5))

      line((1.25, -1.75), (3.75, -1.5))

      set-style(stroke: (paint: green.darken(30%), thickness: 2pt, dash: none))
      circle((2, 1.5), fill: green.lighten(80%), radius: 0.75)
      circle((-2.5, -2), fill: green.lighten(80%), radius: 0.75) 
      circle((4, 0.5), fill: green.lighten(80%), radius: 0.75)   //
      circle((1.25, -1.75), fill: green.lighten(80%), radius: 0.75) //
      circle((3.75, -1.5), fill: green.lighten(80%), radius: 0.75)
      circle((-3, 1), fill: green.lighten(80%), radius: 0.75)   //

      // set-style(stroke: (paint: teal.darken(30%), thickness: 2pt, dash: none))
      set-style(stroke: (paint: gray.darken(30%), thickness: 2pt, dash: none))
      circle((-1, 0), fill: gray.lighten(80%), radius: 0.75)

    })
  ]

#slide(
  title: "Definitions"
)[
  - Our previous definition of diamter is also called #emph[strong] diameter
  
  We say a clustering has #emph[weak] diameter when:
  1. (unchanged) #faded["There are no adjacent clusters"];
  2.  Any cluster has *_"diameter in $G$"_* at most $d$

  #set align(center)
  #weak-d
]

#focus-slide[
  How to compute a low diameter clustering
]

#slide(
  title: [Today's Algorithm],
  new-section: "Computing a Clustering"
)[
  - Main accomplishments of @rhg22:
    - Terminates in $O(log^6 n)$ rounds in the CONGEST model
    - Outputs a clustering with $d = O(log^3 n)$
    - Directly strong diameter #pause

  - Previously @rg20 provided a l.d.c. with *weak* diameter
    - $O(log^7 n)$ rounds with $d = O(log^3 n)$
    - It's possible to turn it into strong diameter #pause
  
  - @ehrg22 did it in $O(log^4 n)$ rounds with $d = O(log^3 n)$
    - Has to pass by a weak d. intermediate solution
]

#slide(
  title: [Algorithm Outline (Intuition)]
)[
  *Objectives*:
  1. Creating connected components with #polylog-hint[low] diameters
    - Keep track of the "center" of the c.c.
      - A.k.a. #emph[Terminal]
    - We will merge c.c.s
      - Only one terminal is going to be the new center
    - Remove nodes separating c.c.s "too far away" #pause
  2. Cluster *at least half* of the nodes
    - Required for #polylog-hint[few] colors *network decompositions*
]



#let forest-1 = scale(75%)[
  #set align(center)

  #cetz.canvas({
    import cetz.draw: *

    set-style(stroke: (paint: gray.darken(30%), thickness: 2pt, dash: none))

    line((-2, 1), (2, 1.5))
    
    line((-2, 1), (-3, -1))

    line((4, 0.5), (2, 1.5))

    line((-3, -1), (-0.25, 0))
    line((-0.25, 0), (1.25, -1.75))
    line((4, 0.5), (3.75, -1.5))

    line((1.25, -1.75), (3.75, -1.5))
    line((4, 0.5), (6, 0.25))
    line((9, 1), (6, 0.25))
    line((8, -1.75), (6, 0.25))
    line((8, -1.75), (9, 1))

    set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 4pt, dash: none))
    circle((-0.25, 0), fill: oxford-blue.lighten(80%), radius: 0.75) 


    set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 2pt, dash: none))

    circle((2, 1.5), fill: oxford-blue.lighten(80%), radius: 0.75)
    
    // set-style(stroke: (paint: ocra.darken(30%), thickness: 2pt, dash: none))
    circle((-2, 1), fill: oxford-blue.lighten(80%), radius: 0.75)   //
    circle((-3, -1), fill: oxford-blue.lighten(80%), radius: 0.75)


    // set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 2pt, dash: none))
    circle((4, 0.5), fill: oxford-blue.lighten(80%), radius: 0.75)   //
    circle((1.25, -1.75), fill: oxford-blue.lighten(80%), radius: 0.75) //
    circle((3.75, -1.5), fill: oxford-blue.lighten(80%), radius: 0.75)

    set-style(stroke: (paint: unipd-red.darken(30%), thickness: 2pt, dash: none))
    circle((6, 0.25), fill: unipd-red.lighten(80%), radius: 0.75)
    circle((8, -1.75), fill: unipd-red.lighten(80%), radius: 0.75)
    set-style(stroke: (paint: unipd-red.darken(30%), thickness: 4pt, dash: none))
    circle((9, 1), fill: unipd-red.lighten(80%), radius: 0.75)

  })
]

#let forest-2 = scale(75%)[
  #set align(center)

  #cetz.canvas({
    import cetz.draw: *

    set-style(stroke: (paint: gray.darken(30%), thickness: 2pt, dash: none))

    line((-2, 1), (2, 1.5))
    
    line((-2, 1), (-3, -1))

    line((4, 0.5), (2, 1.5))

    line((-3, -1), (-0.25, 0))
    line((-0.25, 0), (1.25, -1.75))
    line((4, 0.5), (3.75, -1.5))

    line((1.25, -1.75), (3.75, -1.5))
    line((4, 0.5), (6, 0.25))
    line((9, 1), (6, 0.25))
    line((8, -1.75), (6, 0.25))
    line((8, -1.75), (9, 1))

    set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 4pt, dash: none))
    circle((-0.25, 0), fill: oxford-blue.lighten(80%), radius: 0.75) 


    set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 2pt, dash: none))

    circle((2, 1.5), fill: oxford-blue.lighten(80%), radius: 0.75)
    
    // set-style(stroke: (paint: ocra.darken(30%), thickness: 2pt, dash: none))
    circle((-2, 1), fill: oxford-blue.lighten(80%), radius: 0.75)   //
    circle((-3, -1), fill: oxford-blue.lighten(80%), radius: 0.75)


    // set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 2pt, dash: none))
    circle((1.25, -1.75), fill: oxford-blue.lighten(80%), radius: 0.75) //
    circle((3.75, -1.5), fill: oxford-blue.lighten(80%), radius: 0.75)

    set-style(stroke: (paint: unipd-red.darken(30%), thickness: 2pt, dash: none))
    circle((4, 0.5), fill: unipd-red.lighten(80%), radius: 0.75)   //
    circle((6, 0.25), fill: unipd-red.lighten(80%), radius: 0.75)
    circle((8, -1.75), fill: unipd-red.lighten(80%), radius: 0.75)
    set-style(stroke: (paint: unipd-red.darken(30%), thickness: 4pt, dash: none))
    circle((9, 1), fill: unipd-red.lighten(80%), radius: 0.75)

  })
]


#let forest-3 = scale(75%)[
  #set align(center)

  #cetz.canvas({
    import cetz.draw: *

    set-style(stroke: (paint: gray.darken(30%), thickness: 2pt, dash: none))

    line((-2, 1), (2, 1.5))
    
    line((-2, 1), (-3, -1))

    line((4, 0.5), (2, 1.5))

    line((-3, -1), (-0.25, 0))
    line((-0.25, 0), (1.25, -1.75))
    line((4, 0.5), (3.75, -1.5))

    line((1.25, -1.75), (3.75, -1.5))
    line((4, 0.5), (6, 0.25))
    line((9, 1), (6, 0.25))
    line((8, -1.75), (6, 0.25))
    line((8, -1.75), (9, 1))

    set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 4pt, dash: none))
    circle((-0.25, 0), fill: oxford-blue.lighten(80%), radius: 0.75) 


    set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 2pt, dash: none))

    
    // set-style(stroke: (paint: ocra.darken(30%), thickness: 2pt, dash: none))
    circle((-2, 1), fill: oxford-blue.lighten(80%), radius: 0.75)   //
    circle((-3, -1), fill: oxford-blue.lighten(80%), radius: 0.75)
    circle((1.25, -1.75), fill: oxford-blue.lighten(80%), radius: 0.75) //
    

    // set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 2pt, dash: none))
    
    set-style(stroke: (paint: unipd-red.darken(30%), thickness: 2pt, dash: none))
    circle((2, 1.5), fill: unipd-red.lighten(80%), radius: 0.75)
    circle((4, 0.5), fill: unipd-red.lighten(80%), radius: 0.75)   //
    circle((3.75, -1.5), fill: unipd-red.lighten(80%), radius: 0.75)
    circle((6, 0.25), fill: unipd-red.lighten(80%), radius: 0.75)
    circle((8, -1.75), fill: unipd-red.lighten(80%), radius: 0.75)
    set-style(stroke: (paint: unipd-red.darken(30%), thickness: 4pt, dash: none))
    circle((9, 1), fill: unipd-red.lighten(80%), radius: 0.75)

  })
]


#let forest-4 = scale(75%)[
  #set align(center)

  #cetz.canvas({
    import cetz.draw: *

    set-style(stroke: (paint: gray.darken(30%), thickness: 2pt, dash: none))

    line((-2, 1), (2, 1.5))
    
    line((-2, 1), (-3, -1))

    line((4, 0.5), (2, 1.5))

    line((-3, -1), (-0.25, 0))
    line((-0.25, 0), (1.25, -1.75))
    line((4, 0.5), (3.75, -1.5))

    line((1.25, -1.75), (3.75, -1.5))
    line((4, 0.5), (6, 0.25))
    line((9, 1), (6, 0.25))
    line((8, -1.75), (6, 0.25))
    line((8, -1.75), (9, 1))

    set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 4pt, dash: none))
    circle((-0.25, 0), fill: oxford-blue.lighten(80%), radius: 0.75) 


    set-style(stroke: (paint: oxford-blue.darken(30%), thickness: 2pt, dash: none))

    
    // set-style(stroke: (paint: ocra.darken(30%), thickness: 2pt, dash: none))
    circle((-3, -1), fill: oxford-blue.lighten(80%), radius: 0.75)
    

    set-style(stroke: (paint: gray.darken(30%), thickness: 2pt, dash: none))
    circle((-2, 1), fill: gray.lighten(80%), radius: 0.75)   //
    circle((1.25, -1.75), fill: gray.lighten(80%), radius: 0.75) //


    set-style(stroke: (paint: unipd-red.darken(30%), thickness: 2pt, dash: none))
    circle((2, 1.5), fill: unipd-red.lighten(80%), radius: 0.75)
    circle((4, 0.5), fill: unipd-red.lighten(80%), radius: 0.75)   //
    circle((3.75, -1.5), fill: unipd-red.lighten(80%), radius: 0.75)
    circle((6, 0.25), fill: unipd-red.lighten(80%), radius: 0.75)
    circle((8, -1.75), fill: unipd-red.lighten(80%), radius: 0.75)
    set-style(stroke: (paint: unipd-red.darken(30%), thickness: 4pt, dash: none))
    circle((9, 1), fill: unipd-red.lighten(80%), radius: 0.75)

  })
]

#slide(
  title: [Visual Hint]
)[
  #set align(center)
  #grid(
    columns: (1fr, 1fr),
    [#forest-1 #pause],
    [#forest-2 #pause],
    [#forest-3 #pause],
    [#forest-4]
  )
  
]

#slide(
  title: [Algorithm Outline]
)[
  #emph[Phases]
  - There are $b = log (max_(v in V) id(v)) = O(log n)$ *phases*
  - "One phase for each bit in index"
    - Phase $i in [0, b - 1]$ computes #emph[terminals set] $Q_i$
  
  *Notation*:
  - $Q_i$ is the terminals set built _before_ phase $i$
  - $Q_b$ is the terminals set built _after_ phase $b-1$
  - $V_i$ is the set of *living nodes* at the beginning of phase $i$
  - $V' = V_b$ is the set of *living nodes* after the last phase
]

/*
#slide(
  title: [Algorithm Outline (informal)]
)[
  // TODO ripassa cos'è un connected component
  *Objective 1:* Creating c.c. with #polylog-hint[low] diameters
  - In the end each c.c. will contain exactly 1 terminal
    - Keep terminals #polylog-hint[close] to active nodes
      - This ensures polylogarithmic diameter
      - Removing nodes is allowed

  - $Q_(i+1)$ is "_closer_" than $Q_i$ to any node
    - $Q_b$ is #formal-def[close] to any node

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
]
*/

#slide(
  title: [Phase Invariants $forall i in [0..b]$]
)[
  1. $Q_i$ is $R_i$-ruling, i.e. $italic("dist")_G (Q_i, v) <= R_i$ for all $v in V_i$
    - *We set* $R_i = i * O(log^2 n)$
      - $Q_0$ is $0$-ruling, trivially true with $Q_0 = V$
        - _*"All nodes are terminals at the beginning"*_
      - $Q_b$ is $O(log^3 n)$-ruling
  
  #key[_"Each node has polylog distance from $Q_b$"_ \ $=>$ Each c.c. has #text(weight: 700)[at least one] terminal]
  // if not, some nodes would have infinite distance
]

#slide(
  title: [Phase Invariants $forall i in [0..b]$]
)[
  2. Let $q_1, q_2 in Q_i$ s.t. they are in the same c.c. in $G[V_i]$. \ Then $id(q_1)[0..i] = id(q_2)[0..i]$
    - For $i = 0$ it's trivially true
    - For $i = b$ there is $<= 1$ terminal in each c.c.
  
  #key[Along with invariant (1.), it means that each c.c. has polylog diameter! ]
]

#slide(
  title: [Phase Invariants $forall i in [0..b]$]
)[
  3. $|V_i| >= (1 - frac(i, 2b)) |V|$
    - $|V_0| >= |V|$
    - $|V'| >= frac(1, 2) |V|$
  
  - *_"The algorithm clusters at least half of the nodes"_*
]

#slide(
  title: [Phase Outline]
)[
  *Objective:* In a c.c. remove from $Q_i$ all terminals with different $id(v)$ prefix except one
    - Keep c.c. #polylog-hint[small]
    - Divide it if not possible by removing nodes
  

  *Outline:*
  - $2b^2$ #emph[steps], each computing a forest
  - Resulting into a sequence of forests $F_0 .. F_(2b^2)$
]

// per lavorare: apri con vscode il file (anche da fuori nix-shell)
// poi apri il pdf con zathura
// poi da una shell, entrare nella cartella
//                 , lanciare nix-shell
//                 , lanciare typst watch slides.typ 

#let red-node = highlight(fill: rgb("#c10007"))[#text(fill: white, weight: 700)[` red `]]
#let blue-node = highlight(fill: oxford-blue)[#text(fill: white, weight: 700)[` blue `]]

#slide(
  title: [Step Outline]
)[
  *Inductive definition:*
  - $F_0$ is a BFS forest with roots set $Q_i$
  - Let $T$ be any tree in $F_j$ and $r$ its root
    - If $id(r)[i] = 0$ the whole tree is #red-node, otherwise #blue-node
      - #red-node vertexes stay #red-node
      - Some #blue-node nodes stay #blue-node
      - Some others #emph[propose] #red-node trees to join
        - If accepted, the become #red-node
        - Otherwise, they are *deleted*
]

#slide(
  title: [Step Outline]
)[
  #emph[Proposal]:

  $v in V_j^italic("propose") <=> & v "is " #text[#blue-node] \
  and & v "is the only one in " italic("path")(v, italic("root")(v)) \ 
  & "that neighbours a " #text[#red-node] " node"$

  - Define $T_v$ the (#blue-node) subtree rooted at $v$

  #key[$v$ is the only node in $T_v$ that is also in $V_j^italic("propose")$]
]

#slide(
  title: [Step Outline]
)[
  #emph[Proposal]:

  - Each node in $V_j^italic("propose")$ proposes to a #red-node neighbour
  - Each #red-node tree decides to grow or not
    - If it grows, it accepts all proposing subtrees
      - #blue-node nodes become #red-node
    - If not, all proposing subtrees are *deleted*
  - *Criteria*: it decides to grow if gains at least $frac(|V(T)|, 2b)$ nodes
]

#slide(
  title: [Observations]
)[
  #note[If a #red-node tree doesn't decide to grow, it will neighbour #red-node nodes only]

  - This means it will be able to delete nodes only once in the whole phase // (i.e. among all $2b^2$ steps)
    #list(
      marker: [$=>$],
      [At most $frac(|V|, 2b)$ nodes are lost in each phase],
      [After the $b$ phases at most $frac(|V|, 2)$ nodes are removed]
    ) #pause
  
  #v(1fr)
  - #red-node trees grow at most of $(i + 1) dot O(log^2 n)$
  #v(1fr)
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
  title: [Complexity]
)[

  - Recall invariant (1.)
    - $forall v in V : italic("dist")_G (Q_i, v) = O(log^3 n)$, for all $i in 0..b$
    - Hence, $italic("diam")(T_v) = O(log^3 n)$, for all $v in V$

  - Complexity is $italic("#steps") dot italic("#phases") dot O(italic("diam")(T_v))$ \
    $= O(log n) dot O(log^2 n) dot O(log^3 n)$
  $=>$ The algorithm runs in $O(log^6 n)$ communication steps
  
]

#slide(
  title: [Recap]
)[
  - We've seen how to build a *low diameter clustering* 
    - In $O(log^6 n)$ communication steps
    - It clusters at least $n/2$ nodes #pause
  - We can apply that until all nodes have a color
    - $O(log n)$ steps and therefore $O(log n)$ colors
    - *Network decomposition* in $O(log^7 n)$ #pause
  - We solve MIS @chps17 for each color $(O(log n) dot ...)$
    - In parallel in the clusters $(... dot O(log^3 n dot log^2 n))$ #pause
  #list(
    marker: [$=>$],
    [We end up solving MIS in $O(log^7 n)$ rounds]
  )
]

#slide(
  title: "Bibliography"
)[
  #bibliography("works.bib")
]

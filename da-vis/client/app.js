
// DA demo

function setup_cytoscape(n, edges) {

  const net = [];

  for (let i = 0; i < n; i++) {
    net.push(new Node(i, {}));
  }

  for (const [left, right] of edges) {
    net[left].neighbours.push(net[right]);
    net[right].neighbours.push(net[left]);
  }

  // net[0].neighbours = [net[1]];
  // net[1].neighbours = [net[0], net[2]];
  // net[2].neighbours = [net[1]];

  const elements = [];
  for (const node of net) {
    elements.push({
      data: {
        id: node.id
      }
    });
  }
  for (const [key, value] of edges) {
    elements.push({
      data: {
        source: key,
        target: value
      }
    });
  }

  let cy = cytoscape({
    container: document.getElementById("cy"),

    // elements: [ // list of graph elements to start with
    //   { // node a
    //     data: { id: 1 }
    //   },
    //   { // node b
    //     data: { id: 2 }
    //   },
    //   { // edge ab
    //     data: { id: 'ab', source: 1, target: 2 }
    //   }
    // ],
    elements: elements,

    style: [ // the stylesheet for the graph
      {
        selector: 'node',
        style: {
          'background-color': '#D5E68D',
          'label': 'data(id)',
          "text-valign" : "center",
          "text-halign" : "center",
          'border-width': '1px',
          'border-color': 'black',
          'border-style': 'dashed'
        }
      },

      {
        selector: 'edge',
        style: {
          'width': 2,
          'line-color': '#ccc',
          'target-arrow-color': '#ccc',
          'curve-style': 'bezier'
        }
      },

      {
        selector: '.waving-true',
        style: {
          'color': 'white',
          'background-color': '#002147',
        }
      },

      {
        selector: '.stopped.waving-true',
        style: {
          'color': 'white',
          'background-color': 'darkgreen',
        }
      },

      {
        selector: '.stopped.mis-selected-true',
        style: {
          'color': 'white',
          'background-color': '#47A025',
        }
      },

      {
        selector: '.stopped.mis-selected-false',
        style: {
          'color': 'white',
          'background-color': 'darkred',
        }
      },

      {
        selector: '.is-root-true',
        style: {
          'border-width': '3px',
        }
      },

      {
        selector: '.color-red',
        style: {
          'background-color': 'coral'
        }
      },

      {
        selector: '.color-blue',
        style: {
          'background-color': 'teal'
        }
      },

      {
        selector: '.color-grey',
        style: {
          'background-color': 'gainsboro'
        }
      },

      {
        selector: '.can-propose-true',
        style: {
          'border-color': 'red',
          'border-width': '2px'
        }
      },

      {
        selector: '.stopped',
        style: {
          'border-style': 'solid'
        }
      }
    ],

    layout: {
      name: 'cose',
      randomize: false,
      animate: false,
    }
  });
  cy.userZoomingEnabled( false );
  cy.userPanningEnabled( false );

  return {cy, net};
}

function net_1() {


  const n = 20;


  // generated with https://networkx.org/documentation/stable/reference/generated/networkx.classes.function.edges.html
  // https://math.libretexts.org/Bookshelves/Scientific_Computing_Simulations_and_Modeling/Introduction_to_the_Modeling_and_Analysis_of_Complex_Systems_(Sayama)/15%3A_Basics_of_Networks/15.06%3A_Generating_Random_Graphs
  const edges = 
  [[8, 13], [1, 13], [2, 10], [2, 19], [3, 6], [3, 12], [3, 14], [3, 15], [4, 11], [5, 6], [5, 10], [5, 13], [7, 11], [0, 18], [9, 10], [11, 12], [11, 16], [11, 18], [12, 13], [13, 19], [17, 9]]
  ;

  return setup_cytoscape(n, edges);
}

function ring_net() {

  const n = 10;

  const edges = 
  [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 0]]
  ;

  return setup_cytoscape(n, edges);

}

function forest_net() {
  const n = 16;

  const edges = 
  [[0, 1], [1, 2], [1, 3], [1, 4], [5, 6], [6, 7], [6, 8], [8, 11], [8, 9], [8, 10], [11, 12], [12, 13], [13, 14], [13, 1], [9, 14], [12, 15]]
  ;

  return setup_cytoscape(n, edges);

}

function selectNet(net_fn, btn) {
  if (btn) {
    if (window.net && btn.classList.contains("selected")) {
      return;
    }
    const oldSel = document.getElementsByClassName("selected")[0];
    oldSel.classList.remove("selected");
    btn.classList.add("selected");
  }

  const {cy, net} = net_fn();

  window.net = net;
  window.cy = cy;
  window.selectedNet = net_fn;
}

selectNet(net_1);

const pauseBehavior = new BehaviorSubject(false);

async function main(algorithms) {

  let totalRounds = 0;
  for (const algorithm of algorithms) {
    
    for (const node of window.net) {
      node.restart();
    }
    const rounds = await run(algorithm, window.net, {
      // roundTimeout: 1000,
      applyStyle: node => {
        const els = window.cy.elements(`#${node.id}`);
        els.classes([]);
        for (const [key, value] of Object.entries(node.properties)) {
          els.addClass(`${key}-${value}`);
        }
        if (node.stopped) {
          els.addClass('stopped');
        } else {
          els.removeClass('stopped');
        }
      },
      pauseBehavior: pauseBehavior
    });

    await sleep(1000);
    
    await firstValueFrom(pauseBehavior);

    totalRounds += rounds;
  }
  
  
  const displayRounds = document.getElementById("display-rounds");
  displayRounds.innerHTML = `Total: ${totalRounds} communication rounds`
}

function reset() {
  // location.reload();
  selectNet(window.selectedNet);

  const displayRounds = document.getElementById("display-rounds");
  displayRounds.innerHTML = "";
}


function togglePause() {
  const btn = document.getElementById("pause-btn");
  if (pauseBehavior.value) {
    pauseBehavior.next(false);
    btn.innerHTML = "⏸️";
  } else {
    pauseBehavior.next(true);
    btn.innerHTML = "▶️";
  }
}

function oneStep() {
  pauseBehavior.next(false);
  pauseBehavior.next(true);
}

function setDisplayPhase(title) {
  const p = document.getElementById("display-phase");
  p.innerHTML = title;
}

// run(wave_1, net);


async function wave_1(node) {

  if (!('waving' in node.properties)) {
    node.properties['waving'] = false;
  }

  const wave_neighbours = async () => {
    console.warn(`${node} waves`)
    node.properties.waving = true;
    await broadcast(node, 'wave');
    node.stop();
  }

  if (node.id === 0) {
    await wave_neighbours();
  } else {
    console.warn(`${node} does nothing`)
    const messages = await broadcast(node, null);
    if (messages.map(mail => mail.body).includes('wave')) {
      await wave_neighbours();
    }
  }
}

async function naive_mis(node) {
  const currentRound = node.properties['round'] ?? 0;
  let message = null;
  if (currentRound === node.id) {
    message = 'want-to-select';
  }
  const messages = await broadcast(node, message);
  if (messages.map(mail => mail.body).includes('want-to-select')) {
    node.properties['mis-selected'] = false;
    node.stop();
  } else if (message === 'want-to-select') {
    node.properties['mis-selected'] = true;
    node.stop();
  } else {
    // continue
    node.properties['round'] = currentRound + 1;
  }
}

async function define_roots(node) {
  setDisplayPhase("Defining roots");
  if ([1, 6, 11].includes(node.id)) {
    node.properties['is-root'] = true;
  }
  if (node.id === 11) {
    node.properties['color'] = 'blue';
  }
  if ([1, 6].includes(node.id)) {
    node.properties['color'] = 'red';
  }
  await broadcast(node, null);
  node.stop();
}

async function build_trees(node) {
  // inform children that they are colored
  if (!node.properties['color']) {

    const colors = await broadcast(node, null);
    const blue = colors.find(mail => mail.body === 'blue');
    const red = colors.find(mail => mail.body === 'red');
    if (blue) {
      // prio to blue just for this example
      node.properties['color'] = 'blue';
      node.properties['parent'] = blue.header.sender;
    } else if (red) {
      node.properties['color'] = 'red';
      node.properties['parent'] = red.header.sender;
    }

  } else {

    let dispatch = {};
    for (const neighbour of node.neighbours) {
      dispatch[neighbour.id] = node.properties['color'];
    }
    if (node.properties['parent']) {
      dispatch[node.properties['parent']] = node.id;
    }

    await communicate(node, dispatch);

    const messages = await broadcast(node, null);
    const children = messages
      .filter(mail => typeof mail.body === 'number')
      .map(mail => mail.body);

    node.properties['children'] = children;
    node.stop();
  }
  setDisplayPhase("Building trees");
}

async function discover_neighbours_colors(node) {
  node.properties['want-propose'] = false;
  const messages = await broadcast(node, node.properties['color']);
  if (node.properties['color'] === 'blue') {
    const redMessage = messages.find(mail => mail.body === 'red');
    if (redMessage) {
      // I have a red neighbour, I want to join!
      node.properties['want-propose'] = true;
      node.properties['red-neighbour'] = redMessage.header.sender;
    }
  }
  node.properties['can-propose'] = node.properties['want-propose'];
  setDisplayPhase("Discover neighbours colors");
  node.stop();
}

async function build_v_propose(node) {
  if (!node.properties['parent']) {
    // I am root, I have to do something different
    if (node.properties['want-propose']) {
      await broadcast(node, 'dont-propose');
    } else {
      // allow children
      await broadcast(node, 'can-propose');
    }
    node.stop();
  } else {
    let messages = [];
    if (node.properties['want-propose']) {
      // Children, don't propose!
      messages = await broadcast(node, 'dont-propose');
    } else {
      messages = await broadcast(node, null);
      // possibly forward messages from parent
    }
    const messageFromParent = messages.find(mail => mail.header.sender === node.properties['parent']);
    // i assume messageFromParent !== null
    if (messageFromParent.body === 'dont-propose') {
      node.properties['want-propose'] = true;
      node.properties['can-propose'] = false;
    } else if (messageFromParent.body === 'can-propose') {
      await broadcast(node, 'can-propose'); // it may happen that can-propose is sent after a dont-propose, but it is required for child nodes to stop
      node.stop();
    }
  }

  setDisplayPhase("Building V^propose");
}

async function compute_size_of_trees(node) {
  setDisplayPhase("Computing the sizes of the subtrees")
  const childNum = node.properties.children?.length || 0;
  if (childNum === 0) {
    // there is only me in this subtree
    node.properties['subtree-size'] = 1;
    if (node.properties['parent']) {
      const message = {};
      message[node.properties['parent']] = 1;
      await communicate(node, message);
    } else {
      // there is only me in this tree
    }
    node.stop();
  } else {
    let fromChildren = [];
    while (fromChildren.length < childNum) {
      const messages = await broadcast(node, null);
      const fc = messages
        .filter(mail => typeof mail.body === 'number')
        .map(mail => mail.body);
      fromChildren = fromChildren.concat(fc);
    }
    const total = fromChildren.reduce((partialSum, a) => partialSum + a, 0);
    node.properties['subtree-size'] = total + 1;
    
    const message = {};
    message[node.properties['parent']] = total + 1;
    await communicate(node, message);
    node.stop();
  }
}

async function broadcast_tree_size(node) {
  setDisplayPhase("Computing tree sizes")
  if (!node.properties['parent']) {
    node.properties['tree-size'] = node.properties['subtree-size'];
    await broadcast(node, node.properties['subtree-size']);
  } else {
    let fromParent = null;
    while (!fromParent) {
      const messages = await broadcast(node, null);
      fromParent = messages.find(mail => mail.header.sender === node.properties['parent']);
    }
    node.properties['tree-size'] = fromParent.body;
    await broadcast(node, fromParent.body);
  }
  node.stop();
}

async function propose(node) {
  setDisplayPhase("Proposing");
  console.log(node.properties['subtree-size']);

  if (node.properties['color'] === 'blue' && node.properties['can-propose']) {
    const receiver = node.properties['red-neighbour'];

    let message = {};
    message[receiver] = node.properties['subtree-size'];

    await communicate(node, message);

    const messages = await broadcast(node, null);
    const mail = messages.find(mail => mail.body === 'accept');
    if (mail) {
      node.properties['parent'] = mail.header.sender;
      node.properties['color'] = 'red';
    } else {
      node.properties['parent'] = null;
      node.properties['is-root'] = true;
      node.properties['color'] = 'grey';
    }
  } else if (node.properties['color'] === 'red') {
    const proposals = await broadcast(node, null);
    for (const proposal of proposals) {
      if (proposal.body) {
        if (proposal.body >= node.properties['tree-size'] / 2) {
          // ok accept

          const msg = {};
          msg[proposal.header.sender] = 'accept';
          await communicate(node, msg);

        } else {
          // remove

          await broadcast(node, null);

        }

      }
    }
  } else {
    await broadcast(node, null);
  }

  node.stop();
}

async function propagate_colors(node) {
  if (node.properties['is-root']) {
    await broadcast(node, node.properties['color']);
  } else {
    let fromParent = null;
    while (!fromParent) {
      const messages = await broadcast(node, null);
      fromParent = messages.find(mail => mail.header.sender === node.properties['parent']
        && mail.body
      );
    }
    node.properties['color'] = fromParent.body;
    await broadcast(node, fromParent.body);
  }
  node.stop();
}

const example_ldc = [
  define_roots, 
  build_trees, 
  discover_neighbours_colors, 
  build_v_propose,
  compute_size_of_trees,
  broadcast_tree_size,
  propose,
  propagate_colors
];

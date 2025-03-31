
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
          'border-color': 'lightgrey'
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
          'border-width': '2px',
          'border-color': 'yellow'
        }
      },

      {
        selector: '.stopped',
        style: {
          'border-color': 'black'
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
  const n = 15;

  const edges = 
  [[0, 1], [1, 2], [1, 3], [1, 4], [5, 6], [6, 7], [6, 8], [8, 11], [8, 9], [8, 10], [11, 12], [12, 13], [13, 14], [13, 1]]
  ;

  return setup_cytoscape(n, edges);

}

function selectNet(net_fn, btn) {
  if (btn) {
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

async function main(algorithm) {
  
  const rounds = await run(algorithm, window.net, {
    // roundTimeout: 1000,
    applyStyle: node => {
      const els = window.cy.elements(`#${node.id}`);
      for (const [key, value] of Object.entries(node.properties)) {
        els.addClass(`${key}-${value}`);
      }
      if (node.stopped) {
        els.addClass('stopped');
      }
      console.warn(els);
    },
    pauseBehavior: pauseBehavior
  });
  const displayRounds = document.getElementById("display-rounds");
  displayRounds.innerHTML = `Total: ${rounds} communication rounds`
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
    if (messages.includes('wave')) {
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
  if (messages.includes('want-to-select')) {
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

function setup_step_ldc() {
  for (const node of window.net) {
    if ([1, 6, 11].includes(node.id)) {
      node.properties['is-root'] = true;
    }
  }
}


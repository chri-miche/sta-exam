
// DA demo

const n = 20;
const net = [];

for (let i = 0; i < n; i++) {
  net.push(new Node(i, {waving: false}));
}


// generated with https://networkx.org/documentation/stable/reference/generated/networkx.classes.function.edges.html
// https://math.libretexts.org/Bookshelves/Scientific_Computing_Simulations_and_Modeling/Introduction_to_the_Modeling_and_Analysis_of_Complex_Systems_(Sayama)/15%3A_Basics_of_Networks/15.06%3A_Generating_Random_Graphs
const edges = [[0, 3], [0, 4], [0, 5], [0, 6], [0, 8], [0, 12], [0, 13], [0, 14], [0, 15], [0, 16], [0, 18], [0, 19], [1, 4], [1, 5], [1, 6], [1, 7], [1, 8], [1, 10], [1, 12], [1, 14], [1, 15], [1, 16], [2, 8], [2, 9], [2, 13], [2, 14], [2, 18], [2, 19], [3, 4], [3, 5], [3, 8], [3, 9], [3, 12], [3, 14], [3, 16], [4, 8], [4, 9], [4, 10], [4, 12], [4, 13], [4, 15], [4, 17], [4, 19], [5, 6], [5, 9], [5, 13], [5, 14], [5, 17], [5, 19], [6, 7], [6, 8], [6, 10], [6, 13], [6, 17], [6, 18], [7, 10], [7, 11], [7, 12], [8, 10], [8, 18], [8, 19], [9, 12], [9, 13], [9, 14], [9, 15], [9, 16], [10, 11], [10, 15], [10, 16], [10, 19], [11, 12], [11, 15], [11, 19], [12, 13], [12, 14], [12, 15], [12, 16], [12, 17], [12, 18], [13, 15], [13, 16], [13, 17], [13, 18], [13, 19], [14, 17], [14, 19], [15, 17], [15, 18], [16, 17], [16, 19]];

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

const cy = cytoscape({
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
        "text-halign" : "center"
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
      selector: '.waving',
      style: {
        'color': 'white',
        'background-color': '#171738',
      }
    },

    {
      selector: '.stopped',
      style: {
        'background-color': '#47A025'
      }
    }
  ],

  layout: {
    name: 'cose',
    randomize: true,
    animate: false
  }
});

async function wave_1(node) {

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

function main(algorithm, net) {
  run(algorithm, net, {
    // roundTimeout: 1000,
    applyStyle: node => {
      const els = cy.elements(`#${node.id}`);
      if (node.properties.waving) {
        els.addClass('waving');
      } 
      if (node.stopped) {
        els.addClass('stopped');
      }
      console.warn(els);
    },
  })
}

// run(wave_1, net);
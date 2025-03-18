
// DA demo

const n = 3;
const net = [];

for (let i = 0; i < n; i++) {
  net.push(new Node(i, {waving: false}));
}

const edges = {
  1: [0, 2]
};

for (const [key, values] of Object.entries(edges)) {
  for (const value of values) {
    net[key].neighbours.push(net[value]);
    net[value].neighbours.push(net[key]);
  }
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
for (const [key, values] of Object.entries(edges)) {
  for (const value of values) {
    elements.push({
      data: {
        source: key,
        target: value
      }
    });
  }
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
    name: 'grid',
    rows: 1
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
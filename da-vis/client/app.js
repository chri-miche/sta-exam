
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
          'background-color': 'gainsboro',
          'border-color': 'gray',
          'border-width': '1px'
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

function dense_net() {
  const n = 20;
  const edges = [[0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 9], [0, 10], [0, 12], [0, 15], [0, 17], [0, 18], [0, 19], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [1, 7], [1, 8], [1, 9], [1, 10], [1, 12], [1, 13], [1, 14], [1, 17], [1, 18], [1, 19], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], [2, 8], [2, 9], [2, 10], [2, 12], [2, 13], [2, 14], [2, 15], [2, 16], [2, 18], [2, 19], [3, 4], [3, 7], [3, 8], [3, 9], [3, 10], [3, 11], [3, 12], [3, 14], [3, 17], [3, 18], [3, 19], [4, 6], [4, 9], [4, 11], [4, 14], [4, 16], [4, 17], [4, 19], [5, 8], [5, 9], [5, 10], [5, 11], [5, 12], [5, 13], [5, 15], [5, 16], [5, 17], [5, 18], [6, 7], [6, 10], [6, 11], [6, 14], [6, 15], [6, 16], [6, 17], [6, 19], [7, 8], [7, 9], [7, 10], [7, 11], [7, 12], [7, 13], [7, 16], [7, 17], [7, 18], [8, 9], [8, 10], [8, 11], [8, 13], [8, 14], [8, 16], [8, 17], [8, 18], [8, 19], [9, 10], [9, 12], [9, 14], [9, 16], [9, 18], [9, 19], [10, 11], [10, 13], [10, 14], [10, 15], [10, 17], [11, 12], [11, 13], [11, 16], [11, 17], [11, 19], [12, 13], [12, 14], [12, 18], [12, 19], [13, 14], [13, 16], [13, 17], [14, 16], [14, 18], [14, 19], [15, 16], [15, 17], [15, 18], [15, 19], [16, 17], [16, 18], [17, 18], [17, 19]]
  ;
  return setup_cytoscape(n, edges);
}

function sparse_net() {
  const n = 400;
  const edges = [[208, 126], [126, 97], [97, 10], [0, 28], [0, 191], [0, 194], [0, 198], [0, 230], [0, 376], [0, 397], [1, 276], [2, 4], [2, 16], [2, 36], [2, 125], [2, 285], [2, 314], [3, 86], [3, 215], [4, 77], [4, 92], [4, 238], [4, 313], [4, 361], [4, 368], [5, 69], [5, 78], [5, 264], [5, 277], [5, 278], [5, 362], [5, 390], [6, 38], [6, 52], [6, 143], [6, 182], [6, 303], [6, 342], [7, 23], [7, 68], [7, 201], [7, 250], [7, 285], [8, 18], [8, 20], [9, 38], [9, 85], [9, 203], [9, 246], [9, 247], [9, 369], [10, 75], [11, 22], [11, 43], [11, 64], [11, 160], [11, 203], [11, 220], [11, 375], [12, 130], [12, 220], [12, 291], [13, 148], [13, 187], [13, 330], [13, 357], [13, 388], [14, 132], [14, 163], [14, 164], [14, 263], [15, 191], [16, 144], [16, 209], [16, 230], [16, 270], [16, 368], [17, 94], [17, 199], [17, 343], [18, 384], [19, 252], [19, 346], [20, 56], [20, 189], [20, 192], [20, 297], [20, 343], [20, 368], [21, 196], [21, 209], [22, 290], [22, 306], [22, 392], [23, 47], [23, 106], [23, 358], [24, 89], [24, 130], [24, 348], [25, 275], [25, 330], [26, 199], [26, 261], [26, 269], [27, 266], [27, 342], [28, 141], [28, 158], [28, 323], [29, 86], [29, 217], [29, 274], [29, 347], [29, 394], [30, 113], [30, 221], [31, 59], [31, 276], [31, 335], [32, 83], [32, 122], [32, 346], [32, 396], [33, 94], [33, 104], [34, 162], [34, 202], [34, 348], [35, 70], [35, 256], [35, 347], [36, 75], [36, 94], [36, 102], [37, 263], [37, 303], [38, 140], [38, 151], [38, 297], [38, 315], [39, 70], [39, 294], [39, 308], [39, 322], [40, 146], [40, 231], [40, 354], [41, 42], [41, 177], [41, 247], [41, 251], [41, 283], [41, 380], [42, 235], [42, 239], [42, 258], [42, 373], [43, 51], [43, 58], [44, 320], [45, 91], [45, 301], [45, 338], [45, 340], [45, 386], [46, 124], [46, 247], [46, 311], [46, 352], [47, 359], [47, 365], [47, 374], [48, 176], [49, 165], [49, 393], [50, 215], [51, 107], [51, 314], [52, 81], [52, 210], [52, 270], [52, 396], [53, 83], [53, 184], [53, 219], [53, 356], [54, 174], [54, 284], [54, 352], [54, 377], [55, 168], [55, 301], [56, 171], [57, 211], [57, 269], [57, 317], [58, 150], [58, 175], [58, 202], [58, 241], [58, 396], [59, 101], [59, 200], [59, 274], [59, 308], [59, 349], [60, 173], [61, 64], [62, 184], [63, 100], [63, 216], [63, 268], [63, 366], [64, 72], [64, 200], [65, 93], [65, 162], [65, 360], [66, 156], [66, 261], [66, 302], [67, 352], [68, 183], [68, 195], [68, 376], [68, 395], [68, 396], [69, 98], [69, 282], [69, 349], [70, 205], [70, 240], [70, 250], [70, 256], [71, 110], [71, 318], [71, 326], [72, 140], [72, 163], [72, 165], [72, 188], [72, 250], [72, 274], [72, 330], [72, 364], [73, 78], [73, 344], [74, 244], [75, 161], [75, 198], [75, 259], [75, 260], [76, 232], [76, 287], [76, 303], [76, 313], [76, 322], [78, 107], [78, 115], [79, 107], [79, 199], [80, 121], [80, 173], [80, 252], [80, 269], [80, 335], [80, 356], [81, 188], [81, 377], [82, 93], [82, 112], [82, 244], [82, 271], [82, 301], [82, 327], [83, 230], [84, 115], [84, 139], [84, 179], [85, 111], [85, 223], [86, 215], [86, 277], [86, 363], [86, 386], [87, 112], [87, 237], [87, 256], [87, 371], [88, 101], [88, 237], [88, 246], [88, 322], [88, 361], [88, 381], [89, 144], [89, 253], [89, 267], [89, 276], [90, 173], [90, 174], [90, 180], [90, 271], [90, 290], [91, 108], [91, 291], [91, 306], [91, 311], [92, 162], [92, 168], [92, 169], [92, 184], [93, 117], [93, 136], [93, 187], [94, 120], [94, 165], [94, 176], [94, 187], [94, 289], [94, 377], [95, 209], [95, 377], [95, 387], [96, 140], [96, 297], [96, 334], [96, 355], [98, 176], [98, 298], [98, 319], [98, 332], [99, 162], [99, 237], [99, 270], [99, 279], [99, 301], [99, 318], [99, 328], [100, 206], [100, 237], [100, 241], [100, 275], [101, 286], [103, 200], [103, 313], [104, 234], [104, 308], [105, 180], [105, 241], [105, 276], [105, 339], [106, 155], [106, 354], [107, 127], [107, 142], [107, 321], [107, 336], [108, 201], [108, 227], [108, 251], [109, 152], [110, 136], [110, 161], [111, 325], [111, 350], [112, 138], [112, 153], [112, 218], [112, 347], [113, 120], [113, 200], [113, 290], [113, 333], [114, 143], [114, 351], [114, 365], [115, 158], [115, 346], [116, 186], [116, 207], [116, 310], [117, 172], [117, 179], [117, 237], [117, 355], [118, 196], [118, 310], [118, 311], [119, 134], [119, 268], [119, 371], [120, 176], [120, 202], [120, 251], [120, 281], [120, 299], [121, 131], [121, 339], [122, 197], [122, 248], [122, 297], [122, 304], [123, 246], [123, 333], [123, 356], [124, 153], [124, 337], [125, 181], [125, 381], [127, 210], [127, 313], [128, 168], [129, 286], [129, 314], [129, 379], [130, 154], [130, 232], [131, 171], [131, 280], [131, 336], [132, 255], [132, 393], [133, 156], [133, 167], [133, 398], [134, 201], [134, 317], [135, 169], [135, 220], [135, 387], [136, 203], [136, 310], [136, 323], [136, 378], [137, 172], [137, 256], [137, 355], [138, 234], [138, 302], [139, 219], [139, 298], [141, 214], [141, 333], [141, 349], [142, 221], [143, 164], [143, 210], [144, 154], [144, 158], [144, 388], [145, 211], [145, 251], [145, 391], [146, 153], [146, 165], [146, 299], [147, 185], [147, 224], [147, 304], [148, 178], [148, 305], [148, 351], [149, 165], [149, 209], [150, 277], [150, 283], [150, 287], [151, 220], [152, 155], [152, 262], [152, 363], [153, 169], [154, 184], [154, 258], [154, 337], [155, 310], [156, 265], [156, 324], [156, 367], [157, 375], [158, 163], [158, 261], [159, 230], [159, 240], [159, 333], [159, 384], [160, 297], [160, 307], [161, 201], [161, 237], [161, 273], [162, 189], [162, 245], [163, 171], [163, 299], [163, 338], [164, 389], [165, 310], [165, 382], [166, 172], [166, 248], [166, 290], [166, 292], [167, 228], [167, 387], [167, 390], [167, 393], [170, 195], [171, 367], [173, 387], [174, 344], [174, 365], [174, 379], [175, 270], [176, 214], [176, 321], [176, 355], [177, 233], [177, 255], [177, 329], [177, 333], [177, 335], [178, 385], [179, 272], [183, 268], [183, 348], [184, 221], [184, 257], [184, 320], [184, 379], [185, 207], [185, 244], [185, 293], [185, 311], [187, 234], [188, 242], [188, 298], [188, 318], [188, 354], [188, 370], [188, 385], [188, 394], [188, 396], [190, 194], [190, 207], [190, 220], [190, 257], [193, 296], [193, 327], [194, 217], [194, 226], [195, 203], [195, 323], [196, 212], [196, 266], [196, 267], [196, 281], [196, 387], [198, 275], [198, 321], [200, 250], [200, 261], [200, 335], [200, 372], [200, 396], [202, 241], [202, 253], [202, 362], [202, 365], [203, 243], [203, 358], [203, 384], [204, 311], [204, 337], [205, 213], [205, 223], [205, 376], [206, 238], [206, 334], [207, 229], [207, 235], [207, 310], [209, 337], [209, 362], [210, 300], [210, 302], [211, 337], [211, 348], [213, 242], [213, 257], [213, 340], [213, 370], [214, 288], [215, 239], [215, 338], [217, 235], [217, 262], [217, 282], [218, 345], [218, 372], [219, 299], [220, 274], [220, 312], [220, 316], [220, 344], [221, 310], [221, 314], [221, 321], [221, 399], [222, 357], [222, 361], [223, 239], [223, 335], [223, 365], [223, 370], [223, 380], [224, 385], [224, 391], [225, 305], [225, 342], [225, 374], [225, 385], [226, 335], [227, 265], [227, 280], [228, 365], [229, 292], [229, 367], [229, 368], [229, 389], [230, 232], [232, 253], [233, 235], [233, 292], [233, 310], [234, 307], [234, 391], [235, 272], [235, 321], [236, 249], [237, 319], [238, 329], [239, 379], [240, 259], [241, 332], [243, 249], [243, 253], [243, 275], [243, 332], [244, 310], [244, 357], [244, 386], [246, 393], [247, 331], [247, 354], [248, 375], [250, 335], [250, 392], [250, 399], [251, 261], [251, 365], [252, 253], [252, 380], [253, 390], [254, 332], [255, 278], [256, 264], [256, 345], [258, 313], [260, 291], [260, 309], [261, 300], [262, 264], [264, 274], [265, 377], [266, 289], [266, 316], [266, 397], [267, 282], [268, 369], [269, 379], [269, 387], [271, 284], [271, 298], [272, 361], [273, 323], [273, 397], [275, 353], [275, 383], [276, 361], [277, 295], [277, 313], [277, 317], [277, 318], [279, 288], [280, 356], [281, 315], [282, 314], [282, 339], [283, 330], [283, 353], [284, 306], [284, 394], [288, 359], [290, 338], [290, 341], [291, 344], [291, 347], [292, 301], [293, 326], [294, 374], [294, 388], [296, 371], [297, 315], [297, 332], [297, 352], [298, 359], [298, 361], [299, 352], [300, 369], [300, 397], [302, 337], [306, 311], [306, 337], [306, 339], [309, 361], [309, 383], [310, 335], [312, 324], [312, 346], [312, 353], [315, 346], [316, 352], [319, 358], [319, 399], [320, 362], [320, 367], [320, 381], [321, 381], [325, 376], [325, 389], [331, 371], [332, 342], [332, 398], [334, 397], [342, 386], [344, 398], [348, 365], [349, 381], [353, 388], [357, 360], [357, 379], [357, 384], [362, 391], [374, 388], [377, 385], [385, 388], [385, 396], [391, 392]];
  return setup_cytoscape(n, edges);
}

function path_ish_net() {
  const n = 50;
  const edges = [[15, 6], [38, 46], [49, 6], [45, 6], [45, 48], [0, 20], [0, 23], [0, 37], [1, 6], [1, 46], [2, 41], [3, 5], [3, 27], [3, 36], [4, 21], [7, 16], [7, 17], [7, 26], [7, 44], [8, 33], [9, 21], [9, 22], [10, 40], [11, 21], [12, 25], [13, 34], [13, 35], [13, 32], [14, 18], [14, 33], [15, 29], [16, 30], [16, 41], [17, 19], [20, 21], [20, 42], [22, 37], [22, 44], [23, 33], [23, 39], [23, 41], [24, 30], [24, 35], [24, 42], [25, 35], [25, 39], [26, 41], [27, 34], [28, 31], [28, 47], [29, 38], [29, 44], [31, 40], [32, 43], [37, 40], [39, 42], [40, 47], [42, 47]]
  ;
  return setup_cytoscape(n, edges);
}

function big_ring() {
  const n = 50;
  const edges = [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [10, 11], [11, 12], [12, 13], [13, 14], [14, 15], [15, 16], [16, 17], [17, 18], [18, 19], [19, 20], [20, 21], [21, 22], [22, 23], [23, 24], [24, 25], [25, 26], [26, 27], [27, 28], [28, 29], [29, 30], [30, 31], [31, 32], [32, 33], [33, 34], [34, 35], [35, 36], [36, 37], [37, 38], [38, 39], [39, 40], [40, 41], [41, 42], [42, 43], [43, 44], [44, 45], [45, 46], [46, 47], [47, 48], [48, 49], [49, 0]]
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

  const inputTimeout = document.getElementById('seconds-inpt');
  const roundTimeout = inputTimeout.value;

  let totalRounds = 0;
  for (const algorithm of algorithms) {
    
    for (const node of window.net) {
      node.restart();
    }
    const rounds = await run(algorithm, window.net, {
      roundTimeout,
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

    await sleep(roundTimeout);
    
    await firstValueFrom(pauseBehavior);

    totalRounds += rounds;
  }
  
  
  // const displayRounds = document.getElementById("display-rounds");
  // displayRounds.innerHTML = `Total: ${totalRounds} communication rounds`
}

function reset() {
  // location.reload();
  selectNet(window.selectedNet);

  // const displayRounds = document.getElementById("display-rounds");
  // displayRounds.innerHTML = "";
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

async function color_roots_ex(node) {
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

async function color_trees_ex(node) {
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

async function discover_red_neighbours_ex(node) {
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

async function build_v_propose_ex(node) {
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

async function compute_size_of_trees_ex(node) {
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

async function broadcast_tree_size_ex(node) {
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

async function propose_ex(node) {
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
      // SBAGLIATO NEL CASO GENERALE (bisogna fare la somma di tutti i nodi blu che vogliono proporsi)
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

async function propagate_colors_ex(node) {
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
  color_roots_ex, 
  color_trees_ex, 
  discover_red_neighbours_ex, 
  build_v_propose_ex,
  compute_size_of_trees_ex,
  broadcast_tree_size_ex,
  propose_ex,
  propagate_colors_ex
];

// let's begin
// full algorithm
// low diameter clustering

async function low_diameter_clustering() {
  const maxId = Math.max(...window.net.map(node => node.id));
  const b = bitsForInteger(maxId);

  // In order to make the choice of expanding nodes must know b
  for (const node of window.net) {
    node.properties['b'] = b;
  }

  // SETUP V_i: set of living vertices
  // V_i is represented by the nodes that have the property 'alive' === true
  for (const node of window.net) {
    node.properties['alive'] = true;
  }
  // V_0 = V

  // SETUP Q_i: set of terminal nodes
  // Q_i is represented by the nodes that have the property 'terminal' === true
  for (const node of window.net) {
    node.properties['terminal'] = true;
  }
  // Q_0 = V

  // SETUP PHASE INDEX i
  for (const node of window.net) {
    node.properties['phase_i'] = 0;
  }

  const ldcStep = [
    connect_parents,                      // O(1)
    compute_size_of_trees,                // O(diam(T))
    discover_red_neighbours,              // O(1)
    build_v_propose,                      // O(diam(T))
    propose,                              // O(diam(T))
    decide_to_grow,                       // O(diam(T))
    fix_forest                            // O(diam(T))
  ];


  for (let i = 0; i < b; i++) {
    // one phase
    await main([elect_new_roots]);
    await main([build_bfs_tree]);
    for (let i = 0; i < (2 * b^2); i++) {
      const someRed = window.net.some(node => node.properties.color === 'red');
      const someBlue = window.net.some(node => node.properties.color === 'blue');
      if (someRed && someBlue) {
        await main(ldcStep.map(alg_fn => {
          return async (node) => {
            if (node.properties['alive']) {
              await alg_fn(node);
            } else {
              await broadcast(node, null);
              node.stop();
            }
          }
        }));
      }
    }
    await main([increase_phase_index]);
  }
  
}

async function elect_new_roots(node) {
  setDisplayPhase(`LDC: Start of phase ${node.properties['phase_i']}/${node.properties['b']}`);
  // if a node is a terminal, it is the root of a tree in this phase
  if (node.properties['alive']) {
    if (node.properties['terminal']) {

      node.properties['is-root'] = true;
      // color depends on 
      if (checkKthBit(node.id, node.properties['phase_i'])) {
        node.properties['color'] = 'red';
      } else {
        node.properties['color'] = 'blue';
      }

    } else {

      node.properties['is-root'] = false;
      node.properties['color'] = null;

    }

  } else {
    node.properties['color'] = 'grey';
    node.properties['is-root'] = true;
  }
  await broadcast(node, null);
  node.stop();
}

async function increase_phase_index(node) {
  setDisplayPhase(`LDC: End of phase ${node.properties['phase_i']}`);
  node.properties['phase_i'] += 1;
  await broadcast(node, null);
  node.stop();
}

async function build_bfs_tree(node) {
  setDisplayPhase(`LDC: Building BFS tree`);
  if (!node.properties['alive']) {
    await broadcast(node, null);
  } else {
    if (node.properties['terminal']) {
      await broadcast(node, node.properties['color']);
      node.properties['parent'] = null;
    } else {
      // the first that arrives is the parent
      // if more arrive, it doesn't matter which to pick
      let selected = null;
      while (!selected) {
        const messages = await broadcast(node, null);
        selected = messages.find(mail => mail.body);
      }
      node.properties['color'] = selected.body;
      node.properties['parent'] = selected.header.sender;
      // send join messages to all children
      await broadcast(node, selected.body);
    }
  }
  node.stop();
}

async function connect_parents(node) {
  setDisplayPhase(`LDC: Connecting parents and children`);
  node.properties['children'] = [];
  let message = {};
  message[node.properties['parent']] = true;
  const children = await communicate(node, message);
  for (const child of children) {
    if (child.body) {
      node.properties['children'].push(child.header.sender);
    }
  }
  node.stop();
}

async function compute_size_of_trees(node) {
  setDisplayPhase(`LDC: Computing sizes of (sub)-trees`);
  let messages = [];
  while (messages.length < node.properties['children'].length) {
    const received = await broadcast(node, null);
    messages.push(...received
      .filter(mail => mail.body)
      .filter(mail => node.properties['children'].includes(mail.header.sender))
      .map(mail => mail.body));
  }
  const total = messages.reduce((partialSum, a) => partialSum + a, 1);
  node.properties['rooted-tree-size'] = total;
  let message = {};
  message[node.properties['parent']] = total;
  await communicate(node, message);
  node.stop();
}

async function discover_red_neighbours(node) {
  setDisplayPhase(`LDC: Discovering red neighbours`);
  node.properties['want-propose'] = false;
  const messages = await broadcast(node, node.properties['color']);
  if (node.properties['color'] === 'blue') {
    const redMessage = messages.find(mail => mail.body === 'red');
    if (redMessage) {
      // I have a red neighbour, I want to join!
      node.properties['want-propose'] = true;
      node.properties['red-neighbour'] = redMessage.header.sender;
    } else {
      delete node.properties['red-neighbour'];
    }
  }
  node.properties['can-propose'] = node.properties['want-propose'];
  node.stop();
}

async function build_v_propose(node) {
  setDisplayPhase(`LDC: Building V_propose`);

  if (node.properties['color'] === 'blue') {

    if (node.properties['is-root']) {
      if (node.properties['want-propose']) {
        await broadcast(node, 'dont-propose');
      }
      await broadcast(node, 'shutdown');
      node.stop();
    } else {
  
      let fromParent = null;
      while (fromParent !== 'shutdown') {
        const messages = await broadcast(node, fromParent)
        const fp = messages
          .find(mail => mail.header.sender === node.properties['parent']);
        fromParent = fp.body;
        if (fromParent === 'dont-propose') {
          node.properties['can-propose'] = false;
          delete node.properties['red-neighbour'];
        }
      }
      await broadcast(node, 'shutdown');
      node.stop();
  
    }

  } else {
    await broadcast(node, null);
    node.stop();
  }
}

async function propose(node) {
  setDisplayPhase(`LDC: Proposing`);
  if (node.properties['color'] === 'blue') {
    if (node.properties['can-propose']) {
      // I propose to my red friend!
      let message = {};
      message[node.properties['red-neighbour']] = node.properties['rooted-tree-size'];
      await communicate(node, message);
      node.stop();
    } else {
      await broadcast(node, null);
      node.stop();
    }
  } else {
    // first messages are joining blue nodes
    const proposals = await broadcast(node, null);
    node.properties['proposals'] = proposals
      .filter(mail => typeof mail.body === 'number')
      .map(mail => mail.header.sender);
    const totalProposed = proposals
      .filter(mail => typeof mail.body === 'number')
      .map(mail => mail.body)
      .reduce((partialSum, a) => partialSum + a, 0);
    
    // then i await reports from children
    
    let messages = [];
    while (messages.length < node.properties['children'].length) {
      const received = await broadcast(node, null);
      messages.push(...received
        .filter(mail => typeof mail.body === 'number')
        .filter(mail => node.properties['children'].includes(mail.header.sender))
        .map(mail => mail.body));
    }
    const totalGain = messages.reduce((partialSum, a) => partialSum + a, totalProposed);
    node.properties['total-gain'] = totalGain;

    let message = {};
    message[node.properties['parent']] = totalGain;
    await communicate(node, message);
    node.stop();
  }
}

async function decide_to_grow(node) {
  setDisplayPhase(`LDC: Deciding whether to grow or not`);

  if (node.properties['color'] === 'red') {
    let annex;
    if (node.properties['is-root']) {
      if (node.properties['total-gain'] >= node.properties['rooted-tree-size'] / (2 * node.properties['b'])) {
        // annex all nodes
        annex = true;
      } else {
        // kill all proposing nodes
        annex = false;
      }
    } else {
      let found = null;
      while (!found) {
        const messages = await broadcast(node, null);
        found = messages.find(mail => mail.header.sender === node.properties['parent']
          && typeof mail.body === 'boolean');
      }
      annex = found.body;
    }
    await broadcast(node, annex);

    // now, inform blue nodes

    let message = {};
    for (const proposal of node.properties['proposals']) {
      message[proposal] = annex;
      if (annex) {
        node.properties['children'].push(proposal);
      }
    }
    await communicate(node, message);
    // decision communicated, nothing to do after this
    node.stop();
  } else {
    
    if ('red-neighbour' in node.properties) {

      let found = null;
      while (!found) {
        const messages = await broadcast(node, null);
        found = messages.find(mail => typeof mail.body === 'boolean');
      }
      if (found.body) {
        // good, I'm in!
        node.properties['parent'] = node.properties['red-neighbour'];
        node.properties['is-root'] = false;
        node.properties['terminal'] = false;
      } else {
        // oh no
        node.properties['parent'] = null;
        node.properties['is-root'] = true;
        node.properties['color'] = 'grey';
      }
      node.stop();

    } else {
      // I don't have to await for a proposal decision
      await broadcast(node, null);
      node.stop();
    }
  }
}

async function fix_forest(node) {
  setDisplayPhase(`LDC: Applying decisions`);

  if (!node.properties['is-root']) {
    let found = null;
    while (!found) {
      const messages = await broadcast(node, null);
      found = messages.find(mail => mail.header.sender === node.properties['parent']
        && mail.body);
    }
    node.properties['color'] = found.body;
  }
  node.properties['want-propose'] = false;
  node.properties['can-propose'] = false;
  await broadcast(node, node.properties['color']);
  if (node.properties['color'] === 'grey') {
    node.properties['alive'] = false;
    node.properties['terminal'] = false;
  }
  node.stop();
}



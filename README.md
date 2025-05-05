# Distributed Algorithms

Artifact for the Selected Topics in Algorithms @ UniPD (Spring 24)

## Structure

### Folder `./typst`

This folder contains the source for the slides. The slides are made with [Typst](https://typst.app/) version 0.12.0. They are heavily based on [this theme](https://github.com/augustozanellato/polylux-unipd/), which itself depends on [this package](https://github.com/polylux-typ/polylux).

If you are using `nix`, simply type
```bash
nix-shell
```
to enter the proper environment.

Otherwise, you have to get in some way the right version of typst to make it work.

The slides main file is `slides.typ`. To modify the slides, type the command
```bash
typst watch slides.typ
```
to automatically recompile the `slides.pdf` file.

### Folder `da-vis/client`

This folder contains the code for the Distributed Algorithm Visualizer. It is a simple html page that loads some local scripts. It depends on:
* the library [Cytoscape JS](https://js.cytoscape.org/);
* the library [RXJS](https://rxjs.dev/).
Please note that the respective minified files are served locally.

The file `da-runtime.js` contains the runtime implementation for the LOCAL model (there is no software enforcement for message sizes).
Please note that this file is loaded _before_ the html page is loaded.

The file `app.js` contains:
* the cytoscape canvas configuration (and therefore its styling);
* the algorithms implementation.
Please note that this file is loaded _after_ the html page has been loaded, as the main logic needs to reference the DOM.



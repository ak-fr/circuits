Each folder is a complete example for an openlane2 run.

- Install nix-shell.
- [Install openlane2](https://openlane2.readthedocs.io/en/latest/getting_started/common/nix_installation/index.html#nix-based-installation)
- Inside each folder (after starting nix-shell e.g. `nix-shell --pure [path-to-openlane2-folder]/shell.nix `)
  - run: `openlane config.json`
  - to see the results graphically run: `openlane --last-run --flow openinklayout config.json `
  - It will create a folder `runs/`, inside that folder you can look the folder `06-yosys-synthesis` for netlist statistics.
  
  
  ____________
# Note to self

Add a file for pdk specs. Extract total area occupied by wires in a layer. Folder 06,  folder 43, and final folder.

0. Desing Instance Area
refers to the total area occupied by all standard cells and macro instances in your design. It represents the sum of the actual cell areas placed in the core, excluding empty spaces.

1. Design Core Area

    Definition:
    The core area is the region where all standard cells (logic gates, flip-flops, etc.) are placed and connected.

    Determined By:
        The synthesis and placement of standard cells.
        The estimated number of logic gates and their sizes.

    Excludes:
        IO pads
        Power rings
        Additional spacing for routing

2. Design Die Area

    Definition:
    The die area is the total area of the chip, including the core area, IO pads, and extra margins for manufacturing.

    Determined By:
        The core area size.
        The required space for IO pads, power rails, and manufacturing constraints.

    Includes:
        IO pads (input/output pads for external connections).
        Extra margins for fabrication (scribe lines, ESD protection, etc.).

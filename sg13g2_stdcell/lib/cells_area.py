


cells_area = {
    "a21o_1": 12.7008, 
    "a21o_2": 14.5152, 
    "a21oi_1": 9.072, 
    "a21oi_2": 14.5152, 
    "a221oi_1": 14.5152, 
    "a22oi_1": 10.8486, 
    "and2_1": 9.072, 
    "and2_2": 10.8864, 
    "and3_1": 12.7008, 
    "and3_2": 12.7008, 
    "and4_1": 14.5152, 
    "and4_2": 16.3296, 
    "antennanp": 5.4432, 
    "buf_1": 7.2576, 
    "buf_16": 45.36, 
    "buf_2": 9.072, 
    "buf_4": 14.5152, 
    "buf_8": 23.5872, 
    "decap_4": 7.2576, 
    "decap_8": 12.7008, 
    "dfrbp_1": 47.1744, 
    "dfrbp_2": 54.432, 
    "dlhq_1": 30.8448, 
    "dlhr_1": 32.6592, 
    "dlhrq_1": 27.216, 
    "dllr_1": 34.4736, 
    "dllrq_1": 29.0304, 
    "dlygate4sd1_1": 14.5152, 
    "dlygate4sd2_1": 14.5152, 
    "dlygate4sd3_1": 16.3296, 
    "ebufn_2": 18.144, 
    "ebufn_4": 25.4016, 
    "ebufn_8": 45.36, 
    "einvn_2": 16.3296, 
    "einvn_4": 23.5872, 
    "einvn_8": 39.9168, 
    "fill_1": 1.8144, 
    "fill_2": 3.6288, 
    "fill_4": 7.2576, 
    "fill_8": 14.5152, 
    "inv_1": 5.4432, 
    "inv_16": 34.4736, 
    "inv_2": 7.2576, 
    "inv_4": 10.8864, 
    "inv_8": 18.144, 
    "lgcp_1": 27.216, 
    "mux2_1": 18.144, 
    "mux2_2": 19.9584, 
    "mux4_1": 38.1024, 
    "nand2_1": 7.2576, 
    "nand2_2": 10.8864, 
    "nand2b_1": 9.072, 
    "nand2b_2": 14.5152, 
    "nand3_1": 9.072, 
    "nand3b_1": 12.7008, 
    "nand4_1": 10.8864, 
    "nor2_1": 7.2576, 
    "nor2_2": 10.8864, 
    "nor2b_1": 9.072, 
    "nor2b_2": 12.7008, 
    "nor3_1": 9.072, 
    "nor3_2": 16.3296, 
    "nor4_1": 10.8864, 
    "nor4_2": 21.7728, 
    "o21ai_1": 9.072, 
    "or2_1": 9.072, 
    "or2_2": 10.8864, 
    "or3_1": 12.7008, 
    "or3_2": 14.5152, 
    "or4_1": 14.5152, 
    "or4_2": 16.3296, 
    "sdfbbp_1": 63.504, 
    "sighold": 9.072, 
    "slgcp_1": 30.8448, 
    "tiehi": 7.2576, 
    "tielo": 7.2576, 
    "xnor2_1": 14.5152, 
    "xor2_1": 14.5152, 
}


def extract_cells(log: str):
    cells = []
    capture = False

    for line in log.splitlines():
        line = line.strip()
        if line.startswith("Number of cells:"):
            capture = True
            continue
        if capture:
            if not line or not re.match(r'\S+\s+\d+', line):
                break
            parts = line.split()
            cell_name = parts[0]
            count = int(parts[-1])
            cells.append((cell_name, count))
    return cells

def get_area(cell_name):
    if cell_name.endswith("_x0"):
        cell_name = cell_name[:-2] + "1"

    return cells_area[cell_name]
    


def run_yosys(verbose=True):
    import subprocess 
    import time
    
    command_base = "~/coriolis-2.x/src/alliance-check-toolkit/bin/crlenv.py"
    command_yosys = "doit clean_flow b2v"
    command = command_base + " " + command_yosys
    
    # Run the command and capture output
    t0 = time.time()
    process = subprocess.run(command, shell=True, capture_output=True, text=True)
    t1 = time.time()

    
    print(f"It took yosys = {format_time(t1 - t0)}")

    # Save the portion stats of the output to a file
    stdout_list = process.stdout.split()
    index_yosys_stat_start = process.stdout.find("9. Printing statistics.")
    index_yosys_stat_end = process.stdout.find("10. Executing BLIF backend.")
    yosys_stat =  process.stdout[index_yosys_stat_start : index_yosys_stat_end] 
    if verbose:
        print(yosys_stat)

        
    with open("yosys_stat.log", "w") as f:
        f.write(yosys_stat)



if __name__ == "__main__":
    run_yosys()


    with open("yosys_stat.log") as f:
        log = f.readlines()

    cells = extract_cells(log)

    area = 0
    for cell, n in cells:
        area += n*get_area(cell)

    print(f"netlist_area={area}")

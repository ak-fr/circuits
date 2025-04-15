#!/usr/bin/env python
# coding: utf-8

scalar_a, scalar_b, connectors_margin = 650, 100, 4

def format_time(seconds):
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = seconds % 60
    
    parts = []
    if hours > 0:
        parts.append(f"{hours}h")
    if minutes > 0 or hours > 0:
        parts.append(f"{minutes}m")
    parts.append(f"{secs:.2f}s")
    
    return " ".join(parts)



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
    


# In[4]:


def extract_effective_density(text):
    import re
    
    match = re.search(r"Effective density\s+\.*\s+([\d.]+)%", text)
    if match:
        return float(match.group(1))
    return None  # or raise an exception if preferred



def extract_wire_length(text):
    import re
    
    # Extract last 'Wire Length Completion Ratio' wire length
    wire_length_match = re.findall(r"Wire Length Completion Ratio\s+\.*\s+[\d.]+%\s+\[([\d]+)um", text)
    if wire_length_match:
        wire_length = int(wire_length_match[-1])  # Take the last match
    else:
        wire_length = None  # If not found
    
    return wire_length


def extract_area_dimensions(text):
    import re
    # This regex captures decimal or integer numbers before 'um'
    match = re.search(r"Whole place area: <Box \d+um \d+um ([\d.]+)um ([\d.]+)um>", text)
    if match:
        width = float(match.group(1))
        height = float(match.group(2))
        return width, height
    return None, None


# In[5]:


def run_gds():
    """
    Run gds
    Returns the effective density
    Also, it saves the wire length, chips area, and effective density in the file
    core_stats
    """
    
    import subprocess 
    import time
    
    command_base = "~/coriolis-2.x/src/alliance-check-toolkit/bin/crlenv.py"
    command_yosys = "doit gds"
    command = command_base + " " + command_yosys
    
    # Run the command and capture output
    t0 = time.time()
    process = subprocess.run(command, shell=True, capture_output=True, text=True)
    t1 = time.time()
    
    
    
    density = extract_effective_density(process.stdout)
    wire_length = extract_wire_length(process.stdout)
    dimensions = extract_area_dimensions(process.stdout)
    
    # if  density == None:
    #     print("ERROR")
    #     print(process.stderr)
        
    print(f"GDS: took = {format_time(t1 - t0)} . Effective desnsity =  {density}, Wire length = {wire_length}")

    with open("output.stdout.log", "w") as f:
        f.write(process.stdout)

    with open("output.stderr.log", "w") as f:
        f.write(process.stderr)



    return density, wire_length, dimensions





def update_doDesign(scalar_a, scalar_b, connectors_margin):
    filename="MydoDesign.py"
    
    with open(filename, "r") as file:
        lines = file.readlines()
    
    new_lines = []
    for line in lines:
        if line.strip().startswith("scalar_a") and "scalar_b" in line:
            new_line = f"scalar_a, scalar_b = {scalar_a}, {scalar_b}  # updated values\n"
        elif line.strip().startswith("connectors_margin"):
            new_line = f"connectors_margin = {connectors_margin}  # updated value\n"
        else:
            new_line = line
        new_lines.append(new_line)
    
    with open(filename, "w") as file:
        file.writelines(new_lines)



# optimize_effective_area
# delete the old file
with open("gds_stat.log", "a") as f:
    f.write("")

run_yosys()


print(f"Trying with a={scalar_a}, b={scalar_b}")

threshold_min, threshold_max = 70, 100

update_doDesign(scalar_a, scalar_b, connectors_margin)
density = 0

# history_wire_lengths = []
# history_density = []
# history_dimensions = []
# reduce or increase the density
height_or_length = 1
history = []
while True:
    
    print(f"Going to try with a={scalar_a}, b={scalar_b}")
    run_yosys(verbose=False)
    update_doDesign(scalar_a, scalar_b, connectors_margin)
    density, wire_length, dimensions = run_gds()

    if isinstance(wire_length, int):
        with open("gds_stat.log", "a") as f:
            f.write(f"effective_density = {density}\n")
            f.write(f"wire_length = {wire_length}\n")
            f.write(f"dimensions = {dimensions}\n")
            f.write("\n")


    #print(f"Trying with a={scalar_a}, b={scalar_b}")
    # # use multiplication here to get a better density
    # if density < 25:# or density > 120:
    #     scalar_a = 2 * scalar_a / density 
    #     scalar_b = 2 * scalar_b / density
    
    # elif density > 400:
    #     scalar_a = scalar_a * ( density / 50) 
    #     scalar_b = scalar_b * ( density / 50)       
    #     #print(f"factor = {(1/ (density / 100) )}, scalar_a = {scalar_a}, scalar_b = {scalar_b} ")
        
    # # increase the chip by adding 10, and 5
    # elif density > 50 and density < 59:
    #     scalar_a = scalar_a - 13
    #     scalar_b = scalar_b - 2
    
    # elif density >= 70 and density < 400:
    #     scalar_a = scalar_a + 13
    #     scalar_b = scalar_b + 2


    # test only substract and add
    # increase the chip by adding 10, and 5
    if  density < 90:
        history.append("+")
        if height_or_length:
            scalar_a = scalar_a - 13
            height_or_length ^= 1
        else:
            scalar_b = scalar_b - 2
            height_or_length ^= 1
                
    elif density > 100:
        history.append("-")
        if height_or_length:
            scalar_a = scalar_a + 13
            height_or_length ^= 1
        else:
            scalar_b = scalar_b + 2
            height_or_length ^= 1





# In[ ]:


# def min_index_skip_None(L):
#     # first find an element of type int
#     for i in range(len(L)):
#         if isinstance(L[i], int):
#             idx = i
#             break # exit the loop

#     for i in range(len(L)):
#         try: 
#             if L[i] < L[idx]:
#                 idx = i
#         except:
#             pass # Skip none types

#     return idx


# min_index_skip_None([None, 1, 3, None, -1])


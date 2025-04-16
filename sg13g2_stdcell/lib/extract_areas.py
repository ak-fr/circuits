import re

def extract_cellname_area_from_lib(file_path):
    """
    Extracts the cell name (without 'sg13g2_' prefix) and area from each cell in a Liberty .lib file.

    Args:
        file_path (str): Path to the .lib file.

    Returns:
        dict: A dictionary in the format {cell_name_without_prefix: area}.
    """
    with open(file_path, 'r') as file:
        content = file.read()

    cell_area = {}

    # Find all cell blocks: cell (name) { ... }
    cell_blocks = re.findall(r'cell\s*\((.*?)\)\s*\{(.*?)\n\s*\}', content, re.DOTALL)

    for full_cell_name, block_content in cell_blocks:
        # Remove "sg13g2_" prefix if present
        cell_name = re.sub(r'^sg13g2_', '', full_cell_name.strip())

        # Extract area
        area_match = re.search(r'area\s*:\s*([0-9.]+)\s*;', block_content)

        if area_match:
            area = float(area_match.group(1))
            cell_area[cell_name] = area

    return cell_area

# Example usage
if __name__ == "__main__":
    file_path = "sg13g2_stdcell_fast_1p32V_m40C.lib"
    result = extract_cellname_area_from_lib(file_path)
    for cell, area in result.items():
        print(f"\"{cell}\": {area}")

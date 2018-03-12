"""
BOM Generate.py

This script is called at the end of 'BOM Generate.BAS' which is a basic
script to run in PADS Layout. This script takes the CSV file outputted by
the basic script as well as the component map file and creates the final
formatted BOM file. In formatting the data, there are two main goals:

1) Take the BASIC script output (which describes each component individually)
and group them based on description. In theory, if the description matches then
they should be the same physical component (ex. both are 0402 100k ohm resistors).

2) Add the information from the component map file which includes the manufacturer
and vendor part number for every physical component.
"""

import sys
import os
import csv

# Name of the final BOM file (output)
bom_file = 'BOM.csv'

# Name of the component map file (input)
comp_map_file = 'comp_map.csv'

# Column names for the final outputted BOM
col_names = ['Item', 'Qty', 'Ref Des', 'Description', 'Manufacturer', 'Part Number', 'Digikey Part Number']

"""
main()

Entry point (driver) for the script. Takes the data from the BASIC script and places
all of the data into a dictionary. Also grabs data from the component map file and
adds it to the dictionary. Final, creates and outputs all of the data into the final
BOM file.
"""
def main():

    # Dictionary data struct used to format all of the data from the basic output
    # and comp map files
    data = {}

    # Name of the temp file from the basic script (if there are spaces in the path,
    # the name comes in as multiple arguments)
    temp_file = (' ').join(sys.argv[1:])

    # Load the comp_map_file into a dictionary
    comp_map = load_map_file()

    # Read in data from VB Pads Script and create the main dictionary
    with open(temp_file, 'r') as fid:
        for line in fid:

            # Separate the reference and description for the line
            (ref, desc) = [l.strip() for l in line.strip().split(',')]

            # If that description has been seen before, just append the reference to the list
            if desc in data:
                data[desc]['ref'].append(ref)

            # If this part in new (never seen the description before) get the vendor part number
            # as well as the manufacturer number and create a list of reference starting with this one.
            else:
                (part, man, vendor_part) = get_mapped_data(desc, comp_map)
                data[desc] = {
                    'ref': [ref],
                    'part': part,
                    'vendor': vendor_part,
                    'man': man
                }

    # Create the BOM output file and output all of the data as formatted (uses CSV writer)
    with open(bom_file, 'w') as fid:
        writer = csv.writer(fid, dialect='excel', delimiter=',', lineterminator='\n')

        # Write the column headers
        writer.writerow(col_names)

        # Put each row into a list (rows) so they can be sorted before outputted to the file
        rows = []
        for k, v in data.items():
            row = []

            row.append(len(v['ref']))			# Qty
            row.append(", ".join(v['ref']))		# Ref Des
            row.append(k)						# Description
            row.append(v['man'])				# Manufacturer
            row.append(v['part'])				# Part Number
            row.append(v['vendor'])             # Vendor Part Number

            rows.append(row)

        # Sort the rows alphabetically based on the Reg Des
        rows.sort(key=lambda x: x[1])

        # Write each row to the final file. Also, we add the Item column here because we
        # didn't want that to get sorted with the rest of the rows.
        for index, row in enumerate(rows):
            writer.writerow([index + 1] + row)
    
    # Remove the temp file created by the basic script
    os.remove(temp_file)


"""
Grabs the part number and manufacturer from the component map dictionary for the
given description. If the description is not found, then empty strings are returned
for the part number and manufacturer (fail safe default)
"""
def get_mapped_data(desc, comp_map):
    if desc in comp_map:
        return (comp_map[desc]['part'], comp_map[desc]['man'], comp_map[desc]['vendor'])
    else:
        return ('', '', '')


"""
Loads the component map csv file into a dictionary for use later. Then that
dictionary is returned.
"""
def load_map_file():
    result = {}

    desc_index = -1
    man_index = -1
    part_index = -1
    vendor_index = -1

    with open(comp_map_file, 'r') as fid:
        for index, line in enumerate(fid):
            split_line = [i for i in line.strip().split(',') if i != '']
            if index == 0:
                desc_index = split_line.index('DESCRIPTION')
                man_index = split_line.index('MANUFACTURER')
                part_index = split_line.index('PART NUMBER')
                vendor_index = split_line.index('DIGIKEY NUMBER')
            else:
                desc = split_line[desc_index]
                man = split_line[man_index]
                part = split_line[part_index]
                vendor_part = split_line[vendor_index]
                result[desc] = {'man': man, 'part': part, 'vendor': vendor_part}
        
    return result


"""
Define the entry point of this script to be main()
"""
if __name__ == "__main__":
    main()

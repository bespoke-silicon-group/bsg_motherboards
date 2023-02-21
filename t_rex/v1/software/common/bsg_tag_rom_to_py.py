import sys

if __name__ == "__main__":

  if len(sys.argv) == 2:
    filename = sys.argv[1]

    # read nbf file
    f = open(filename, "r")
    lines = f.readlines()

    for line in lines:
      # remove leading spaces
      line = line.strip()

      # extract command from line
      array = line.split("'b")
      if len(array) < 2:
        # print original comments
        if line[:4] == "// #":
          print(line[3:])
        continue
      array = array[1].split(")")
      cmd = array[0]

      # print SEND commands as function calls
      if cmd[:4] == "0001":
        cmd = cmd.replace("___", "_")
        array = cmd.split("_")
        print("write_bsg_tag_trace(", end="")
        print(str(int(array[1], 2))+", ", end="")
        print(str(int(array[2], 2))+", ", end="")
        print(str(int(array[3], 2))+", ", end="")
        print(str(int(array[4], 2))+", ", end="")
        print(str(int(array[5], 2))+")")
      # print unsupported commands as comments
      else:
        print("#"+cmd)

  else:
    print("USAGE:")
    command = "python bsg_tag_rom_to_py.py {bsg_tag_boot_rom.v}"
    print(command)

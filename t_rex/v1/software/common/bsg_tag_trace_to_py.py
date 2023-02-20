import sys

if __name__ == "__main__":

  if len(sys.argv) == 2:
    filename = sys.argv[1]

    # read nbf file
    f = open(filename, "r")
    lines = f.readlines()

    for line in lines:

      # print comments and empty lines
      if line[0] == '#' or line[0] == '\n':
        print(line, end="")
      # print SEND commands as function calls
      elif line[:4] == "0001":
        line = line[:-1]
        line = line.replace("___", "_")
        array = line.split("_")
        print("write_bsg_tag_trace(", end="")
        print(str(int(array[1], 2))+", ", end="")
        print(str(int(array[2], 2))+", ", end="")
        print(str(int(array[3], 2))+", ", end="")
        print(str(int(array[4], 2))+", ", end="")
        print(str(int(array[5], 2))+")")
      # print unsupported commands as comments
      else:
        print("#"+line, end="")

  else:
    print("USAGE:")
    command = "python bsg_tag_trace_to_py.py {bsg_tag_boot.tr}"
    print(command)

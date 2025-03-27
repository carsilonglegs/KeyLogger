file_in = "logger.exe"
file_out = "logger_exe.h"
var_name = "logger_exe"

with open(file_in, "rb") as f:
    data = f.read()

with open(file_out, "w") as out:
    out.write(f"unsigned char {var_name}[] = {{\n")
    for i, b in enumerate(data):
        out.write(f"0x{b:02x},")
        if (i + 1) % 12 == 0:
            out.write("\n")
    out.write("\n};\n")
    out.write(f"unsigned int {var_name}_len = {len(data)};\n")

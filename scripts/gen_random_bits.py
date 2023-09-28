import random
import sys

def generate_random_binary_numbers(lines, output_file):
  """Generates random 8-bit binary numbers, line by line, and outputs them to a txt file.

  Args:
    lines: The number of lines to generate.
    output_file: The path to the output txt file.
  """

  with open(output_file, "w") as f:
    for i in range(int(lines)):
      # Generate a random 8-bit binary number.
      binary_number = bin(random.randint(0, 255))[2:].zfill(8)

      # Write the binary number to the file.
      f.write(binary_number + "\n")

if __name__ == "__main__":
    lines = sys.argv[1]
    output_file = sys.argv[2]
    generate_random_binary_numbers(lines, output_file)

    print("Success")

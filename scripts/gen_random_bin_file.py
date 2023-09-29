
import random

def generate_random_binary_file(size_in_bytes, filename):
  """Generates a random binary file with the given size and filename.

  Args:
    size_in_bytes: The size of the binary file in bytes.
    filename: The name of the binary file.
  """

  with open(filename, "wb") as f:
    for i in range(size_in_bytes):
      f.write(random.randint(0, 255).to_bytes(1, "big"))


if __name__ == "__main__":
  size_in_bytes = 10 * 1024  # Generate a 10KB binary file.
  filename = "rand_file_10KB"

  generate_random_binary_file(size_in_bytes, filename)

  print("Generated random binary file at {}".format(filename))

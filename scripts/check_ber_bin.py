import sys

def check_bit_error_rate(file1, file2):
  """Checks the bit error rate between two binary files.

  Args:
    file1: The name of the first binary file.
    file2: The name of the second binary file.

  Returns:
    The bit error rate, which is a float value between 0 and 1.
  """

  with open(file1, "rb") as f1, open(file2, "rb") as f2:
    bit_errors = 0
    total_bits = 0

    while True:
      byte1 = f1.read(1)
      byte2 = f2.read(1)

      if not byte1 or not byte2:
        break

      total_bits += 8

      for i in range(8):
        bit1 = (byte1[0] >> i) & 1
        bit2 = (byte2[0] >> i) & 1

        if bit1 != bit2:
          bit_errors += 1

  return bit_errors / total_bits


if __name__ == "__main__":
  file1 = sys.argv[1]
  file2 = sys.argv[2]

  bit_error_rate = check_bit_error_rate(file1, file2)

  print("Bit error rate:", bit_error_rate)

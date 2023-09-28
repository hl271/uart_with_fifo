import sys

def check_bit_error_rate(golden_file, received_file):
  """Calculates the bit error rate between two files.

  Args:
    golden_file: The file containing the golden data.
    received_file: The file containing the received data.

  Returns:
    The bit error rate as a float.
  """

  total_bits = 0
  error_count = 0

  with open(golden_file, "r") as golden_f, open(received_file, "r") as received_f:
    for golden_line, received_line in zip(golden_f, received_f):
      golden_bits = golden_line.strip()
      received_bits = received_line.strip()

      # Check if the golden bits and received bits match.
      for golden_bit, received_bit in zip(golden_bits, received_bits):
        total_bits += 1
        if golden_bit != received_bit:
          error_count += 1

  # Calculate the bit error rate.
  ber = error_count / total_bits

  return ber


if __name__ == "__main__":
  golden_file = sys.argv[1]
  received_file = sys.argv[2]

  ber = check_bit_error_rate(golden_file, received_file)

  print(f"Bit error rate: {ber:.2f}")

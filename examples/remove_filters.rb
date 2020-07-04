require "../lib/pgm"
source = ARGV[0]
dest = ARGV[1]
program=PGM.read_file(source)
program[:pads].each_with_index { |pad, index| pad[:pad][:filter1_type] = :off }
PGM.write_file(dest, program)      

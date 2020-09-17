require "../lib/pgm"
source = ARGV[0]
program=PGM.read_file(source)
require 'pp'
pp program

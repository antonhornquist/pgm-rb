require 'pgm'

if __FILE__ == $0
	if pgm_file = ARGV.first
		require 'pp'
		pgm = PGM.read_file(pgm_file)
		pp pgm
	else
		puts "usage: ruby #{File.basename(__FILE__)} program_file"
	end
end


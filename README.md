# pgm-rb

A little Ruby lib for decoding and encoding Akai MPC PGM files

## Example

Pretty print an Akai MPC PGM structure to console:

``` ruby
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
```

## Requirements

This code has been developed and tested in Ruby 2.2.3.

## License

Copyright (c) Anton Hörnquist

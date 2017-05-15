# pgm-rb

A little Ruby lib for decoding and encoding Akai MPC PGM files

## Usage

In order to use pgm-rb add its lib folder to the Ruby load path and ```require 'pgm'```.

## Example

Pretty print an Akai MPC PGM structure to console:

``` ruby
require 'pgm'

if pgm_file = ARGV.first
	require 'pp'
	pgm = PGM.read_file(pgm_file)
	pp pgm
else
	puts "usage: ruby #{File.basename(__FILE__)} program_file"
end
```

## Requirements

This library has been developed and tested in Ruby 2.2.3.

## License

Copyright (c) Anton Hörnquist

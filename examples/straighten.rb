require "../lib/pgm"
require 'pp'

# source = ARGV[0]
# dest = ARGV[1]

[
  {
    source: "7 To 7/7 To 7.PGM",
    dest: "7 To 7/x7 To 7.PGM"
  },
  {
    source: "8 Oh 8/8 Oh 8.PGM",
    dest: "8 Oh 8/x8 Oh 8.PGM"
  },
  {
    source: "9 Oh 9/9 Oh 9.PGM",
    dest: "9 Oh 9/x9 Oh 9.PGM"
  },
  {
    source: "Drumul8r/Drumul8r.PGM",
    dest: "Drumul8r/xDrumul8r.PGM"
  },
  {
    source: "El Em 1/El Em 1.PGM",
    dest: "El Em 1/xEl Em 1.PGM"
  },
  {
    source: "El Em 2/El Em 2.PGM",
    dest: "El Em 2/xEl Em 2.PGM"
  },
  {
    source: "IIX Lo-Fi/IIx Lo-Fi.PGM",
    dest: "IIX Lo-Fi/xIIx Lo-Fi.PGM"
  },
  {
    source: "Obie DX/Obie DX.PGM",
    dest: "Obie DX/xObie DX.PGM"
  },
  {
    source: "See Our 78/See Our 78.PGM",
    dest: "See Our 78/xSee Our 78.PGM"
  },
  {
    source: "Simmons/Simmons.PGM",
    dest: "Simmons/xSimmons.PGM"
  },
  {
    source: "XR10/XR10.PGM",
    dest: "XR10/xXR10.PGM"
  }
].each do |pair|
  source = File.join("mod", pair[:source])
  dest = File.join("mod", pair[:dest])

  program=PGM.read_file(source)

  program[:pads].each_with_index do |pad, index|
    pad_settings = pad[:pad]
    pad_settings[:voice_overlap] = :mono
    pad_settings[:filter1_type] = :off
    pad_settings[:mixer_pan] = 50
  end

  PGM.write_file(dest, program)      
end
